"""Sync endpoints for the native app's offline-first library.

The phone keeps the whole library in SQLite and replays its changes here one item at a
time once it is online. Writes carry the item's full state and are idempotent (an upsert
or a delete that also succeeds when there's nothing to delete), so a change that gets
sent twice — say, the response was lost and the phone retried — does no harm.

Details (title, poster, summary…) are served separately and without a session, since the
app also shows them to people who use it without an account.
"""

import asyncio
import datetime as dt
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models, rate_limit, schemas
from app.database import get_db
from app.deps import get_current_user
from app.external import google_books, igdb, tmdb
from app.rate_limit import client_ip, enforce
from app.routers.books import _book_detail
from app.routers.games import _game_detail
from app.routers.movies import _movie_detail
from app.routers.tv import _tv_detail

router = APIRouter(prefix="/api", tags=["library"])

Category = Literal["games", "movies", "tv", "books"]

# model, api id column name, api id type
_TABLES = {
    "games": (models.KullaniciOyun, "api_oyun_id", int),
    "movies": (models.KullaniciFilm, "api_film_id", int),
    "tv": (models.KullaniciDizi, "api_dizi_id", int),
    "books": (models.KullaniciKitap, "api_kitap_id", str),
}

MAX_DETAIL_IDS = 20
# Each upstream fetch is a TMDB/IGDB/Google Books call, so don't fire a whole batch at once.
_UPSTREAM_CONCURRENCY = 5


def _parse_id(category: str, api_id: str):
    _, _, id_type = _TABLES[category]
    if id_type is int:
        try:
            return int(api_id)
        except ValueError:
            raise HTTPException(404, "Kayıt bulunamadı.")
    if not api_id or len(api_id) > 64:
        raise HTTPException(404, "Kayıt bulunamadı.")
    return api_id


def _find(db: Session, user: models.Kullanici, category: str, api_id):
    model, column, _ = _TABLES[category]
    return db.scalar(select(model).where(model.kullanici_id == user.id, getattr(model, column) == api_id))


def _naive_utc(value: dt.datetime) -> dt.datetime:
    # Rows are stored as naive datetimes (the server's own clock, which runs on UTC).
    return value.astimezone(dt.timezone.utc).replace(tzinfo=None) if value.tzinfo else value


@router.get("/library", response_model=schemas.SyncLibrary)
def get_library(user: models.Kullanici = Depends(get_current_user), db: Session = Depends(get_db)):
    """Every item's state, without details: the phone already has those cached."""
    result = {}
    for category, (model, column, _) in _TABLES.items():
        rows = db.scalars(select(model).where(model.kullanici_id == user.id)).all()
        result[category] = [
            schemas.SyncItem(
                api_id=str(getattr(row, column)),
                istek_mi=row.istek_mi,
                eklenme_tarihi=row.eklenme_tarihi,
                bitirme_tarihi=row.bitirme_tarihi,
                kisisel_not=row.kisisel_not,
            )
            for row in rows
        ]
    return result


@router.put("/library/{category}/{api_id}", status_code=204)
def put_item(
    category: Category,
    api_id: str,
    payload: schemas.SyncItemWrite,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    parsed = _parse_id(category, api_id)
    row = _find(db, user, category, parsed)
    if row is None:
        model, column, _ = _TABLES[category]
        row = model(kullanici_id=user.id, **{column: parsed})
        # Keep the moment it was added on the phone, which may be long before this sync.
        if payload.eklenme_tarihi:
            row.eklenme_tarihi = _naive_utc(payload.eklenme_tarihi)
        db.add(row)
    row.istek_mi = payload.istek_mi
    row.bitirme_tarihi = payload.bitirme_tarihi
    row.kisisel_not = payload.kisisel_not
    db.commit()
    return Response(status_code=204)


@router.delete("/library/{category}/{api_id}", status_code=204)
def delete_item(
    category: Category,
    api_id: str,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = _find(db, user, category, _parse_id(category, api_id))
    if row is not None:
        db.delete(row)
        db.commit()
    return Response(status_code=204)


async def _fetch_details(category: str, ids: list) -> dict[str, dict]:
    if category == "games":
        games = await igdb.get_games(ids)
        return {str(g["id"]): _game_detail(g) for g in games}

    fetch, build = {
        "movies": (tmdb.get_movie, _movie_detail),
        "tv": (tmdb.get_tv, _tv_detail),
        "books": (google_books.get_book, _book_detail),
    }[category]
    gate = asyncio.Semaphore(_UPSTREAM_CONCURRENCY)

    async def one(api_id):
        async with gate:
            data = await fetch(api_id)
        return str(api_id), build(data) if data else None

    return {api_id: detail for api_id, detail in await asyncio.gather(*map(one, ids)) if detail}


@router.get("/details/{category}")
async def get_details(category: Category, request: Request, ids: str = Query(..., max_length=2000)):
    """Details for up to MAX_DETAIL_IDS items, keyed by api_id. Items that couldn't be loaded are left out."""
    ip = client_ip(request)
    enforce((rate_limit.details_per_ip, ip))
    rate_limit.details_per_ip.hit(ip)

    wanted = list(dict.fromkeys(i.strip() for i in ids.split(",") if i.strip()))[:MAX_DETAIL_IDS]
    parsed = []
    for api_id in wanted:
        try:
            parsed.append(_parse_id(category, api_id))
        except HTTPException:
            continue
    if not parsed:
        return {}
    return await _fetch_details(category, parsed)
