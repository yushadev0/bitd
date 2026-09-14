import httpx

from app.config import get_settings
from app.external.retry import with_retry

settings = get_settings()
BASE_URL = "https://www.googleapis.com/books/v1/volumes"


async def search_books(query: str) -> list[dict]:
    async def call():
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                BASE_URL,
                params={"q": query, "key": settings.google_books_key, "maxResults": 10},
            )
        resp.raise_for_status()
        return resp.json().get("items", [])

    return await with_retry(call)


async def get_book(volume_id: str) -> dict | None:
    async def call():
        async with httpx.AsyncClient() as client:
            resp = await client.get(
                f"{BASE_URL}/{volume_id}",
                params={"key": settings.google_books_key},
            )
        if resp.status_code == 404:
            return None
        resp.raise_for_status()
        return resp.json()

    try:
        return await with_retry(call)
    except (httpx.HTTPStatusError, httpx.TransportError):
        # A single item's detail failing to load shouldn't break the whole list/random pick.
        return None


def thumbnail_url(volume: dict) -> str | None:
    links = volume.get("volumeInfo", {}).get("imageLinks", {})
    thumb = links.get("thumbnail") or links.get("smallThumbnail")
    return thumb.replace("http://", "https://") if thumb else None
