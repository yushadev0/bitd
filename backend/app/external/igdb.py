import time

import httpx

from app.config import get_settings

settings = get_settings()

_token_cache: dict = {"access_token": None, "expires_at": 0}


async def _get_access_token() -> str:
    now = time.time()
    if _token_cache["access_token"] and _token_cache["expires_at"] > now + 30:
        return _token_cache["access_token"]

    async with httpx.AsyncClient() as client:
        resp = await client.post(
            "https://id.twitch.tv/oauth2/token",
            params={
                "client_id": settings.twitch_client_id,
                "client_secret": settings.twitch_client_secret,
                "grant_type": "client_credentials",
            },
        )
    resp.raise_for_status()
    data = resp.json()
    _token_cache["access_token"] = data["access_token"]
    _token_cache["expires_at"] = now + data.get("expires_in", 3600)
    return _token_cache["access_token"]


async def _headers() -> dict:
    token = await _get_access_token()
    return {
        "Authorization": f"Bearer {token}",
        "Client-ID": settings.twitch_client_id,
    }


async def search_games(query: str) -> list[dict]:
    headers = await _headers()
    body = (
        f'search "{query}"; '
        "fields id, name, cover.image_id, first_release_date, genres.name, rating; "
        "limit 10;"
    )
    async with httpx.AsyncClient() as client:
        resp = await client.post("https://api.igdb.com/v4/games", headers=headers, content=body)
    resp.raise_for_status()
    return resp.json()


async def get_games(ids: list[int]) -> list[dict]:
    if not ids:
        return []
    headers = await _headers()
    id_list = ",".join(str(i) for i in ids)
    body = (
        f"where id = ({id_list}); "
        "fields name, cover.image_id, rating, genres.name, summary, "
        "first_release_date, platforms.name, screenshots.image_id; "
        "limit 500;"
    )
    async with httpx.AsyncClient() as client:
        resp = await client.post("https://api.igdb.com/v4/games", headers=headers, content=body)
    resp.raise_for_status()
    return resp.json()


async def get_game(game_id: int) -> dict | None:
    results = await get_games([game_id])
    return results[0] if results else None


def cover_url(image_id: str | None) -> str | None:
    return f"https://images.igdb.com/igdb/image/upload/t_cover_big/{image_id}.jpg" if image_id else None


def screenshot_url(image_id: str) -> str:
    return f"https://images.igdb.com/igdb/image/upload/t_screenshot_med/{image_id}.jpg"
