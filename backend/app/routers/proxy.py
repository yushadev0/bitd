from urllib.parse import urlparse

import httpx
from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import Response

from app.external import dns_bypass

router = APIRouter(prefix="/api/image-proxy", tags=["proxy"])

# Only ever proxy to hosts we explicitly trust — this endpoint must not become an open SSRF relay.
ALLOWED_HOSTS = {"image.tmdb.org"}


@router.get("")
async def proxy_image(src: str = Query(...)):
    parsed = urlparse(src)
    if parsed.scheme != "https" or parsed.netloc not in ALLOWED_HOSTS:
        raise HTTPException(400, "Desteklenmeyen görsel kaynağı.")

    path = parsed.path + (f"?{parsed.query}" if parsed.query else "")
    async with httpx.AsyncClient() as client:
        try:
            resp = await dns_bypass.get(client, parsed.netloc, path, timeout=15)
        except httpx.HTTPError:
            raise HTTPException(502, "Görsel alınamadı.")

    if resp.status_code != 200:
        raise HTTPException(502, "Görsel alınamadı.")

    content_type = resp.headers.get("content-type", "image/jpeg")
    return Response(content=resp.content, media_type=content_type, headers={"Cache-Control": "public, max-age=86400"})
