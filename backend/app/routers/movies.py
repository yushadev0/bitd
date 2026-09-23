import datetime as dt

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db, random_order
from app.deps import get_current_user
from app.external import tmdb
from app.placeholder import placeholder_poster

router = APIRouter(prefix="/api/movies", tags=["movies"])


def _search_result(item: dict) -> dict:
    genre_names = [tmdb.GENRE_NAMES.get(gid, "") for gid in item.get("genre_ids", [])]
    genre_names = [g for g in genre_names if g]
    title = item.get("title", "Bilinmeyen Film")
    return {
        "api_id": str(item["id"]),
        "title": title,
        "poster": tmdb.movie_poster_url(item.get("poster_path")) or placeholder_poster(title, "FİLM", "ff2a6d"),
        "year": (item.get("release_date") or "")[:4] or "--",
        "score": round(item.get("vote_average", 0), 1) if item.get("vote_average") else None,
        "genres": genre_names or ["--"],
    }


def _movie_detail(movie: dict) -> dict:
    director = "--"
    for crew in movie.get("credits", {}).get("crew", []):
        if crew.get("job") == "Director":
            director = crew["name"]
            break

    title = movie.get("title", "Bilinmeyen Film")
    return {
        "title": title,
        "poster": tmdb.movie_poster_url(movie.get("poster_path")) or placeholder_poster(title, "FİLM", "ff2a6d"),
        "score": round(movie.get("vote_average", 0) * 10) if movie.get("vote_average") else None,
        "year": (movie.get("release_date") or "")[:4] or "--",
        "genres": [g["name"] for g in movie.get("genres", [])] or ["--"],
        "summary": movie.get("overview") or "Bu film için bir açıklama bulunmuyor.",
        "runtime_minutes": movie.get("runtime") or None,
        "director": director,
        "trailer_url": tmdb.trailer_search_url(title, "fragman"),
    }


async def _row_with_detail(row: models.KullaniciFilm) -> dict:
    detail = None
    movie = await tmdb.get_movie(row.api_film_id)
    if movie:
        detail = _movie_detail(movie)
    return schemas.LibraryItem(
        api_id=str(row.api_film_id),
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
    results = await tmdb.search_movies(q)
    return [_search_result(r) for r in results]


@router.get("")
async def list_movies(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = db.scalars(
        select(models.KullaniciFilm)
        .where(models.KullaniciFilm.kullanici_id == user.id)
        .order_by(models.KullaniciFilm.eklenme_tarihi.desc())
    ).all()
    return [await _row_with_detail(row) for row in rows]


@router.get("/random")
async def random_movie(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = db.scalar(
        select(models.KullaniciFilm)
        .where(models.KullaniciFilm.kullanici_id == user.id, models.KullaniciFilm.istek_mi == True)
        .order_by(random_order())
    )
    if not row:
        raise HTTPException(404, "İzleme listeniz boş.")
    return await _row_with_detail(row)


@router.post("", status_code=201)
async def add_movie(
    payload: schemas.AddItemRequest,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    api_id = int(payload.api_id)
    existing = db.scalar(
        select(models.KullaniciFilm).where(
            models.KullaniciFilm.kullanici_id == user.id, models.KullaniciFilm.api_film_id == api_id
        )
    )
    if existing:
        raise HTTPException(409, "Bu film zaten listenizde mevcut.")

    row = models.KullaniciFilm(
        kullanici_id=user.id,
        api_film_id=api_id,
        istek_mi=payload.istek_mi,
        bitirme_tarihi=None if payload.istek_mi else dt.date.today(),
    )
    db.add(row)
    db.commit()
    return {"ok": True}


def _get_row(db: Session, user: models.Kullanici, api_id: str) -> models.KullaniciFilm:
    row = db.scalar(
        select(models.KullaniciFilm).where(
            models.KullaniciFilm.kullanici_id == user.id, models.KullaniciFilm.api_film_id == int(api_id)
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
def delete_movie(
    api_id: str,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = _get_row(db, user, api_id)
    db.delete(row)
    db.commit()
    return {"ok": True}
