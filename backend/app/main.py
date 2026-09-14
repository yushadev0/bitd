from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import get_settings
from app.database import Base, engine
from app.routers import account, auth, books, dashboard, games, movies, proxy, tv

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(title="B.I.T.D. API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(httpx.HTTPStatusError)
async def external_api_status_error(request: Request, exc: httpx.HTTPStatusError):
    return JSONResponse(
        status_code=502,
        content={"detail": "Dış servise şu an ulaşılamıyor, lütfen birazdan tekrar dene."},
    )


@app.exception_handler(httpx.RequestError)
async def external_api_request_error(request: Request, exc: httpx.RequestError):
    return JSONResponse(
        status_code=502,
        content={"detail": "Dış servise bağlanılamadı, lütfen birazdan tekrar dene."},
    )


app.include_router(auth.router)
app.include_router(account.router)
app.include_router(dashboard.router)
app.include_router(games.router)
app.include_router(movies.router)
app.include_router(tv.router)
app.include_router(books.router)
app.include_router(proxy.router)


@app.get("/api/health")
def health():
    return {"status": "ok"}
