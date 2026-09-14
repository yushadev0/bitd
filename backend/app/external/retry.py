import asyncio
from typing import Awaitable, Callable, TypeVar

import httpx

T = TypeVar("T")

_RETRYABLE_STATUS = {429, 500, 502, 503, 504}


async def with_retry(call: Callable[[], Awaitable[T]], attempts: int = 3, base_delay: float = 0.5) -> T:
    last_exc: Exception | None = None
    for attempt in range(attempts):
        try:
            return await call()
        except httpx.HTTPStatusError as exc:
            last_exc = exc
            if exc.response.status_code not in _RETRYABLE_STATUS or attempt == attempts - 1:
                raise
        except httpx.TransportError as exc:
            last_exc = exc
            if attempt == attempts - 1:
                raise
        await asyncio.sleep(base_delay * (2**attempt))
    raise last_exc  # pragma: no cover - unreachable, satisfies type checker
