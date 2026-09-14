"""
Some networks transparently hijack DNS for api.themoviedb.org / image.tmdb.org,
answering with 127.0.0.1 even when queried directly against 8.8.8.8 (observed on
the target deployment network). DNS-over-HTTPS is not intercepted, and connecting
straight to the resolved IP with the correct TLS SNI + Host header reaches TMDB
just fine — this module makes that the normal path for TMDB requests so neither
our backend nor an end user's browser ever needs to resolve those hostnames
directly.
"""

import time

import httpx

_DOH_URL = "https://cloudflare-dns.com/dns-query"
_MIN_TTL = 30

_cache: dict[str, tuple[str, float]] = {}


async def resolve_ip(hostname: str) -> str:
    now = time.time()
    cached = _cache.get(hostname)
    if cached and cached[1] > now:
        return cached[0]

    async with httpx.AsyncClient() as client:
        resp = await client.get(
            _DOH_URL,
            params={"name": hostname, "type": "A"},
            headers={"accept": "application/dns-json"},
            timeout=10,
        )
    resp.raise_for_status()
    answers = [a for a in resp.json().get("Answer", []) if a.get("type") == 1]
    if not answers:
        raise httpx.ConnectError(f"DoH lookup for {hostname} returned no A records")

    ip = answers[0]["data"]
    ttl = max(int(answers[0].get("TTL", 60)), _MIN_TTL)
    _cache[hostname] = (ip, now + ttl)
    return ip


async def get(client: httpx.AsyncClient, hostname: str, path: str, **kwargs) -> httpx.Response:
    """GET a https://{hostname}{path} URL, routed around a DNS-level block."""
    ip = await resolve_ip(hostname)
    headers = {**(kwargs.pop("headers", None) or {}), "Host": hostname}
    extensions = {**(kwargs.pop("extensions", None) or {}), "sni_hostname": hostname}
    return await client.get(f"https://{ip}{path}", headers=headers, extensions=extensions, **kwargs)
