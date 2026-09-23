from fastapi import APIRouter, Depends
from sqlalchemy import Integer, func, select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db
from app.deps import get_current_user
from app.external import google_books, igdb, tmdb
from app.i18n import t
from app.placeholder import placeholder_poster

router = APIRouter(prefix="/api/dashboard", tags=["dashboard"])


def _stats(db: Session, model, user_id: int) -> schemas.DashboardStats:
    total, wish = db.execute(
        select(func.count(model.id), func.sum(func.cast(model.istek_mi, Integer))).where(
            model.kullanici_id == user_id
        )
    ).one()
    return schemas.DashboardStats(total=total or 0, wishlist=wish or 0)


@router.get("", response_model=schemas.DashboardResponse)
def stats(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return schemas.DashboardResponse(
        oyunlar=_stats(db, models.KullaniciOyun, user.id),
        filmler=_stats(db, models.KullaniciFilm, user.id),
        diziler=_stats(db, models.KullaniciDizi, user.id),
        kitaplar=_stats(db, models.KullaniciKitap, user.id),
    )


@router.get("/recent/games")
async def recent_games(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = db.scalars(
        select(models.KullaniciOyun)
        .where(models.KullaniciOyun.kullanici_id == user.id)
        .order_by(models.KullaniciOyun.eklenme_tarihi.desc())
        .limit(5)
    ).all()
    games = await igdb.get_games([r.api_oyun_id for r in rows])
    by_id = {g["id"]: g for g in games}
    result = []
    for row in rows:
        game = by_id.get(row.api_oyun_id)
        title = game.get("name", "?") if game else "?"
        cover = game.get("cover", {}).get("image_id") if game else None
        result.append({
            "api_id": str(row.api_oyun_id),
            "title": title,
            "poster": igdb.cover_url(cover) or placeholder_poster(title, t("OYUN", "GAME"), "38bdf8"),
        })
    return result


@router.get("/recent/movies")
async def recent_movies(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = db.scalars(
        select(models.KullaniciFilm)
        .where(models.KullaniciFilm.kullanici_id == user.id)
        .order_by(models.KullaniciFilm.eklenme_tarihi.desc())
        .limit(5)
    ).all()
    result = []
    for row in rows:
        movie = await tmdb.get_movie(row.api_film_id)
        title = movie.get("title", "?") if movie else "?"
        poster = tmdb.movie_poster_url(movie.get("poster_path")) if movie else None
        result.append({
            "api_id": str(row.api_film_id),
            "title": title,
            "poster": poster or placeholder_poster(title, t("FİLM", "MOVIE"), "ff2a6d"),
        })
    return result


@router.get("/recent/tv")
async def recent_tv(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = db.scalars(
        select(models.KullaniciDizi)
        .where(models.KullaniciDizi.kullanici_id == user.id)
        .order_by(models.KullaniciDizi.eklenme_tarihi.desc())
        .limit(5)
    ).all()
    result = []
    for row in rows:
        show = await tmdb.get_tv(row.api_dizi_id)
        title = show.get("name", "?") if show else "?"
        poster = tmdb.movie_poster_url(show.get("poster_path")) if show else None
        result.append({
            "api_id": str(row.api_dizi_id),
            "title": title,
            "poster": poster or placeholder_poster(title, t("DİZİ", "TV"), "38bdf8"),
        })
    return result


@router.get("/recent/books")
async def recent_books(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = db.scalars(
        select(models.KullaniciKitap)
        .where(models.KullaniciKitap.kullanici_id == user.id)
        .order_by(models.KullaniciKitap.eklenme_tarihi.desc())
        .limit(5)
    ).all()
    result = []
    for row in rows:
        volume = await google_books.get_book(row.api_kitap_id)
        title = volume.get("volumeInfo", {}).get("title", "?") if volume else "?"
        poster = google_books.thumbnail_url(volume) if volume else None
        result.append({
            "api_id": row.api_kitap_id,
            "title": title,
            "poster": poster or placeholder_poster(title, t("KİTAP", "BOOK"), "ff2a6d"),
        })
    return result
