import datetime as dt
import re

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db
from app.deps import get_current_user
from app.external import google_books
from app.placeholder import placeholder_poster

router = APIRouter(prefix="/api/books", tags=["books"])

_TAG_RE = re.compile(r"<[^>]+>")


def _strip_html(text: str) -> str:
    return _TAG_RE.sub("", text)


def _search_result(item: dict) -> dict:
    info = item.get("volumeInfo", {})
    title = info.get("title", "Bilinmeyen Kitap")
    categories = info.get("categories") or ["--"]
    return {
        "api_id": item["id"],
        "title": title,
        "poster": google_books.thumbnail_url(item) or placeholder_poster(title, "KİTAP", "ff2a6d"),
        "year": (info.get("publishedDate") or "")[:4] or "--",
        "score": None,
        "genres": categories,
    }


def _book_detail(volume: dict) -> dict:
    info = volume.get("volumeInfo", {})
    title = info.get("title", "Bilinmeyen Kitap")
    authors = info.get("authors") or ["--"]
    return {
        "title": title,
        "poster": google_books.thumbnail_url(volume) or placeholder_poster(title, "KİTAP", "ff2a6d"),
        "score": None,
        "year": (info.get("publishedDate") or "")[:4] or "--",
        "genres": info.get("categories") or ["--"],
        "summary": _strip_html(info.get("description") or "Bu kitap için bir açıklama bulunmuyor."),
        "authors": authors,
        "page_count": info.get("pageCount"),
        "preview_link": info.get("previewLink"),
    }


async def _row_with_detail(row: models.KullaniciKitap) -> dict:
    detail = None
    volume = await google_books.get_book(row.api_kitap_id)
    if volume:
        detail = _book_detail(volume)
    return schemas.LibraryItem(
        api_id=row.api_kitap_id,
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
    results = await google_books.search_books(q)
    return [_search_result(r) for r in results]


@router.get("")
async def list_books(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = db.scalars(
        select(models.KullaniciKitap)
        .where(models.KullaniciKitap.kullanici_id == user.id)
        .order_by(models.KullaniciKitap.eklenme_tarihi.desc())
    ).all()
    return [await _row_with_detail(row) for row in rows]


@router.get("/random")
async def random_book(
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = db.scalar(
        select(models.KullaniciKitap)
        .where(models.KullaniciKitap.kullanici_id == user.id, models.KullaniciKitap.istek_mi.is_(True))
        .order_by(func.random())
    )
    if not row:
        raise HTTPException(404, "Okuma listeniz boş.")
    return await _row_with_detail(row)


@router.post("", status_code=201)
async def add_book(
    payload: schemas.AddItemRequest,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    api_id = payload.api_id
    existing = db.scalar(
        select(models.KullaniciKitap).where(
            models.KullaniciKitap.kullanici_id == user.id, models.KullaniciKitap.api_kitap_id == api_id
        )
    )
    if existing:
        raise HTTPException(409, "Bu kitap zaten listenizde mevcut.")

    row = models.KullaniciKitap(
        kullanici_id=user.id,
        api_kitap_id=api_id,
        istek_mi=payload.istek_mi,
        bitirme_tarihi=None if payload.istek_mi else dt.date.today(),
    )
    db.add(row)
    db.commit()
    return {"ok": True}


def _get_row(db: Session, user: models.Kullanici, api_id: str) -> models.KullaniciKitap:
    row = db.scalar(
        select(models.KullaniciKitap).where(
            models.KullaniciKitap.kullanici_id == user.id, models.KullaniciKitap.api_kitap_id == api_id
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
def delete_book(
    api_id: str,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = _get_row(db, user, api_id)
    db.delete(row)
    db.commit()
    return {"ok": True}
