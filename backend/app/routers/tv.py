import datetime as dt

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db, random_order
from app.deps import get_current_user
from app.external import tmdb
from app.i18n import t
from app.placeholder import placeholder_poster

router = APIRouter(prefix="/api/tv", tags=["tv"])


def _search_result(item: dict) -> dict:
    genre_names = [tmdb.genre_name(gid) for gid in item.get("genre_ids", [])]
    genre_names = [g for g in genre_names if g]
    title = item.get("name", t("Bilinmeyen Dizi", "Unknown Show"))
    return {
        "api_id": str(item["id"]),
        "title": title,
        "poster": tmdb.movie_poster_url(item.get("poster_path")) or placeholder_poster(title, t("DİZİ", "TV"), "38bdf8"),
        "year": (item.get("first_air_date") or "")[:4] or "--",
        "score": round(item.get("vote_average", 0), 1) if item.get("vote_average") else None,
        "genres": genre_names or ["--"],
    }


def _tv_detail(show: dict) -> dict:
    networks = show.get("networks") or []
    title = show.get("name", t("Bilinmeyen Dizi", "Unknown Show"))
    return {
        "title": title,
        "poster": tmdb.movie_poster_url(show.get("poster_path")) or placeholder_poster(title, t("DİZİ", "TV"), "38bdf8"),
        "score": round(show.get("vote_average", 0) * 10) if show.get("vote_average") else None,
        "year": (show.get("first_air_date") or "")[:4] or "--",
        "genres": [g["name"] for g in show.get("genres", [])] or ["--"],
        "summary": show.get("overview") or t("Bu dizi için bir açıklama bulunmuyor.", "No description available for this show."),
        "seasons": show.get("number_of_seasons"),
        "network": networks[0]["name"] if networks else "--",
        "trailer_url": tmdb.trailer_search_url(title, t("dizi fragman", "tv series trailer")),
    }


async def _row_with_detail(row: models.KullaniciDizi) -> dict:
    detail = None
    show = await tmdb.get_tv(row.api_dizi_id)
    if show:
        detail = _tv_detail(show)
    return schemas.LibraryItem(
        api_id=str(row.api_dizi_id),
        istek_mi=row.istek_mi,
        eklenme_tarihi=row.eklenme_tarihi,
        bitirme_tarihi=row.bitirme_tarihi,
        kisisel_not=row.kisisel_not,
        detail=detail,
    ).model_dump()


@router.get("/search")
async def search(q: str):
    if not q.strip():
        return []
    results = await tmdb.search_tv(q)
    return [_search_result(r) for r in results]


@router.get("")
async def list_tv(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = db.scalars(
        select(models.KullaniciDizi)
        .where(models.KullaniciDizi.kullanici_id == user.id)
        .order_by(models.KullaniciDizi.eklenme_tarihi.desc())
    ).all()
    return [await _row_with_detail(row) for row in rows]


@router.get("/random")
async def random_tv(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = db.scalar(
        select(models.KullaniciDizi)
        .where(models.KullaniciDizi.kullanici_id == user.id, models.KullaniciDizi.istek_mi == True)
        .order_by(random_order())
    )
    if not row:
        raise HTTPException(404, "İzleme listeniz boş.")
    return await _row_with_detail(row)


@router.post("", status_code=201)
async def add_tv(
    payload: schemas.AddItemRequest,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    api_id = int(payload.api_id)
    existing = db.scalar(
        select(models.KullaniciDizi).where(
            models.KullaniciDizi.kullanici_id == user.id, models.KullaniciDizi.api_dizi_id == api_id
        )
    )
    if existing:
        raise HTTPException(409, "Bu dizi zaten listenizde mevcut.")

    row = models.KullaniciDizi(
        kullanici_id=user.id,
        api_dizi_id=api_id,
        istek_mi=payload.istek_mi,
        bitirme_tarihi=None if payload.istek_mi else dt.date.today(),
    )
    db.add(row)
    db.commit()
    return {"ok": True}


def _get_row(db: Session, user: models.Kullanici, api_id: str) -> models.KullaniciDizi:
    row = db.scalar(
        select(models.KullaniciDizi).where(
            models.KullaniciDizi.kullanici_id == user.id, models.KullaniciDizi.api_dizi_id == int(api_id)
        )
    )
    if not row:
        raise HTTPException(404, "Kayıt bulunamadı.")
    return row


@router.patch("/{api_id}/status")
def update_status(
    api_id: str,
    payload: schemas.UpdateStatusRequest,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = _get_row(db, user, api_id)
    row.istek_mi = payload.istek_mi
    if not payload.istek_mi:
        row.bitirme_tarihi = dt.date.today()
    db.commit()
    return {"ok": True}


@router.patch("/{api_id}/date")
def update_date(
    api_id: str,
    payload: schemas.UpdateDateRequest,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = _get_row(db, user, api_id)
    row.bitirme_tarihi = payload.bitirme_tarihi
    db.commit()
    return {"ok": True}


@router.patch("/{api_id}/note")
def update_note(
    api_id: str,
    payload: schemas.UpdateNoteRequest,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = _get_row(db, user, api_id)
    row.kisisel_not = payload.kisisel_not
    db.commit()
    return {"ok": True}


@router.delete("/{api_id}")
def delete_tv(
    api_id: str,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = _get_row(db, user, api_id)
    db.delete(row)
    db.commit()
    return {"ok": True}
