"""In-memory sliding-window rate limits.

Good enough for the single uvicorn worker this API runs as; counters reset on restart.
Clients sit behind nginx, which passes the real address in X-Real-IP.
"""

import threading
import time
from collections import defaultdict, deque

from fastapi import HTTPException, Request


class RateLimiter:
    def __init__(self, limit: int, window_seconds: int):
        self.limit = limit
        self.window = window_seconds
        self._hits: dict[str, deque[float]] = defaultdict(deque)
        self._lock = threading.Lock()  # sync endpoints run on a thread pool

    def _prune(self, key: str, now: float) -> deque[float]:
        hits = self._hits[key]
        while hits and hits[0] <= now - self.window:
            hits.popleft()
        return hits

    def blocked(self, key: str) -> bool:
        with self._lock:
            return len(self._prune(key, time.monotonic())) >= self.limit

    def hit(self, key: str) -> None:
        with self._lock:
            now = time.monotonic()
            self._prune(key, now).append(now)
            if len(self._hits) > 10_000:  # drop keys whose window has passed
                for k in [k for k, v in self._hits.items() if not v or v[-1] <= now - self.window]:
                    del self._hits[k]

    def reset(self, key: str) -> None:
        with self._lock:
            self._hits.pop(key, None)


TOO_MANY = "Çok fazla deneme yaptın. Lütfen biraz sonra tekrar dene."


def client_ip(request: Request) -> str:
    return request.headers.get("x-real-ip") or (request.client.host if request.client else "unknown")


def enforce(*checks: tuple[RateLimiter, str]) -> None:
    """Raises 429 if any (limiter, key) pair is over its limit."""
    if any(limiter.blocked(key) for limiter, key in checks):
        raise HTTPException(429, TOO_MANY)


# Password reset codes: each send is an email we pay for in reputation, so throttle hard.
reset_send_per_email = RateLimiter(limit=3, window_seconds=15 * 60)
reset_send_per_ip = RateLimiter(limit=10, window_seconds=60 * 60)

# Wrong 6-digit codes. After this many, the code is thrown away and a new one is needed.
reset_code_failures_per_email = RateLimiter(limit=5, window_seconds=15 * 60)
reset_code_failures_per_ip = RateLimiter(limit=20, window_seconds=60 * 60)

# Failed sign-ins (web cookie login and native token login share these).
login_failures_per_username = RateLimiter(limit=10, window_seconds=15 * 60)
login_failures_per_ip = RateLimiter(limit=30, window_seconds=15 * 60)
