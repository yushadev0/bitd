import asyncio
import logging
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, Request
from fastapi.exception_handlers import http_exception_handler
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.config import get_settings
from app.database import Base, engine
from app.i18n import set_lang_from_header, translate_error
from app.push import scheduler
from app.routers import account, auth, books, dashboard, games, movies, proxy, push, tv

settings = get_settings()
logging.basicConfig(level=logging.INFO)


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    push_loop = asyncio.create_task(scheduler())
    yield
    push_loop.cancel()


app = FastAPI(title="B.I.T.D. API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def request_language(request: Request, call_next):
    set_lang_from_header(request.headers.get("x-app-lang"))
    return await call_next(request)


@app.exception_handler(StarletteHTTPException)
async def localized_http_exception(request: Request, exc: StarletteHTTPException):
    exc.detail = translate_error(exc.detail)
    return await http_exception_handler(request, exc)


@app.exception_handler(httpx.HTTPStatusError)
async def external_api_status_error(request: Request, exc: httpx.HTTPStatusError):
    return JSONResponse(
        status_code=502,
        content={"detail": translate_error("Dış servise şu an ulaşılamıyor, lütfen birazdan tekrar dene.")},
    )


@app.exception_handler(httpx.RequestError)
async def external_api_request_error(request: Request, exc: httpx.RequestError):
    return JSONResponse(
        status_code=502,
        content={"detail": translate_error("Dış servise bağlanılamadı, lütfen birazdan tekrar dene.")},
    )


app.include_router(auth.router)
app.include_router(account.router)
app.include_router(dashboard.router)
app.include_router(games.router)
app.include_router(movies.router)
app.include_router(tv.router)
app.include_router(books.router)
app.include_router(proxy.router)
app.include_router(push.router)


@app.get("/api/health")
def health():
    return {"status": "ok"}
