import httpx

from app.config import get_settings

settings = get_settings()
BASE_URL = "https://api.themoviedb.org/3"

GENRE_NAMES: dict[int, str] = {
    28: "Aksiyon", 12: "Macera", 16: "Animasyon", 35: "Komedi", 80: "Suç",
    99: "Belgesel", 18: "Dram", 10751: "Aile", 14: "Fantastik", 36: "Tarih",
    27: "Korku", 10402: "Müzik", 9648: "Gizem", 10749: "Romantik",
    878: "Bilim Kurgu", 10770: "TV Filmi", 53: "Gerilim", 10752: "Savaş",
    37: "Vahşi Batı", 10759: "Aksiyon & Macera", 10762: "Çocuk",
    10763: "Haberler", 10764: "Reality", 10765: "Bilim Kurgu & Fantastik",
    10766: "Pembe Dizi", 10767: "Talk Show", 10768: "Savaş & Politik",
}


def _headers() -> dict:
    return {"Authorization": f"Bearer {settings.tmdb_token}"}


async def search_movies(query: str) -> list[dict]:
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            f"{BASE_URL}/search/movie",
            headers=_headers(),
            params={"query": query, "language": "tr-TR"},
        )
    resp.raise_for_status()
    return resp.json().get("results", [])[:10]


async def search_tv(query: str) -> list[dict]:
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            f"{BASE_URL}/search/tv",
            headers=_headers(),
            params={"query": query, "language": "tr-TR"},
        )
    resp.raise_for_status()
    return resp.json().get("results", [])[:10]


async def get_movie(movie_id: int) -> dict | None:
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            f"{BASE_URL}/movie/{movie_id}",
            headers=_headers(),
            params={"language": "tr-TR", "append_to_response": "credits"},
        )
    if resp.status_code != 200:
        return None
    return resp.json()


async def get_tv(tv_id: int) -> dict | None:
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            f"{BASE_URL}/tv/{tv_id}",
            headers=_headers(),
            params={"language": "tr-TR"},
        )
    if resp.status_code != 200:
        return None
    return resp.json()


def movie_poster_url(poster_path: str | None) -> str | None:
    return f"https://image.tmdb.org/t/p/w500{poster_path}" if poster_path else None
