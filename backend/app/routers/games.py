import datetime as dt

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db, random_order
from app.deps import get_current_user
from app.external import igdb
from app.i18n import t
from app.placeholder import placeholder_poster

router = APIRouter(prefix="/api/games", tags=["games"])


def _year_from_unix(ts: int | None) -> str:
    if not ts:
        return "--"
    return str(dt.datetime.utcfromtimestamp(ts).year)


def _search_result(item: dict) -> dict:
    title = item.get("name", t("Bilinmeyen Oyun", "Unknown Game"))
    cover = item.get("cover", {}).get("image_id")
    genres = [g["name"] for g in item.get("genres", [])] or ["--"]
    return {
        "api_id": str(item["id"]),
        "title": title,
        "poster": igdb.cover_url(cover) or placeholder_poster(title, t("OYUN", "GAME"), "38bdf8"),
        "year": _year_from_unix(item.get("first_release_date")),
        "score": round(item["rating"]) if item.get("rating") else None,
        "genres": genres,
    }


def _game_detail(game: dict) -> dict:
    title = game.get("name", t("Bilinmeyen Oyun", "Unknown Game"))
    cover = game.get("cover", {}).get("image_id")
    screenshots = [igdb.screenshot_url(s["image_id"]) for s in game.get("screenshots", [])[:5]]
    return {
        "title": title,
        "poster": igdb.cover_url(cover) or placeholder_poster(title, t("OYUN", "GAME"), "38bdf8"),
        "score": round(game["rating"]) if game.get("rating") else None,
        "year": _year_from_unix(game.get("first_release_date")),
        "genres": [g["name"] for g in game.get("genres", [])] or ["--"],
        "summary": game.get("summary") or t("Bu oyun için bir açıklama bulunmuyor.", "No description available for this game."),
        "platforms": [p["name"] for p in game.get("platforms", [])] or ["--"],
        "screenshots": screenshots,
    }


async def _rows_with_detail(rows: list[models.KullaniciOyun]) -> list[dict]:
    if not rows:
        return []
    games = await igdb.get_games([r.api_oyun_id for r in rows])
    games_by_id = {g["id"]: g for g in games}
    result = []
    for row in rows:
        game = games_by_id.get(row.api_oyun_id)
        detail = _game_detail(game) if game else None
        result.append(
            schemas.LibraryItem(
                api_id=str(row.api_oyun_id),
                istek_mi=row.istek_mi,
                eklenme_tarihi=row.eklenme_tarihi,
                bitirme_tarihi=row.bitirme_tarihi,
                kisisel_not=row.kisisel_not,
                detail=detail,
            ).model_dump()
        )
    return result


@router.get("/search")
async def search(q: str):
    if not q.strip():
        return []
    results = await igdb.search_games(q)
    return [_search_result(r) for r in results]


@router.get("")
async def list_games(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = db.scalars(
        select(models.KullaniciOyun)
        .where(models.KullaniciOyun.kullanici_id == user.id)
        .order_by(models.KullaniciOyun.eklenme_tarihi.desc())
    ).all()
    return await _rows_with_detail(list(rows))


@router.get("/random")
async def random_game(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = db.scalar(
        select(models.KullaniciOyun)
        .where(models.KullaniciOyun.kullanici_id == user.id, models.KullaniciOyun.istek_mi == True)
        .order_by(random_order())
    )
    if not row:
        raise HTTPException(404, "İstek listeniz boş.")
    detail_list = await _rows_with_detail([row])
    return detail_list[0]


@router.post("", status_code=201)
async def add_game(
    payload: schemas.AddItemRequest,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    api_id = int(payload.api_id)
    existing = db.scalar(
        select(models.KullaniciOyun).where(
            models.KullaniciOyun.kullanici_id == user.id, models.KullaniciOyun.api_oyun_id == api_id
        )
    )
    if existing:
        raise HTTPException(409, "Bu oyun zaten listenizde mevcut.")

    row = models.KullaniciOyun(
        kullanici_id=user.id,
        api_oyun_id=api_id,
        istek_mi=payload.istek_mi,
        bitirme_tarihi=None if payload.istek_mi else dt.date.today(),
    )
    db.add(row)
    db.commit()
    return {"ok": True}


def _get_row(db: Session, user: models.Kullanici, api_id: str) -> models.KullaniciOyun:
    row = db.scalar(
        select(models.KullaniciOyun).where(
            models.KullaniciOyun.kullanici_id == user.id, models.KullaniciOyun.api_oyun_id == int(api_id)
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
def delete_game(
    api_id: str,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = _get_row(db, user, api_id)
    db.delete(row)
    db.commit()
    return {"ok": True}
