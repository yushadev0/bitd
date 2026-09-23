import datetime as dt

from fastapi import APIRouter, Cookie, Depends, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models, schemas
from app.config import get_settings
from app.database import get_db
from app.deps import get_current_user
from app.email_utils import send_otp_email
from app.security import (
    create_access_token,
    create_refresh_token,
    decode_refresh_token,
    generate_otp_code,
    generate_remember_token,
    hash_password,
    hash_remember_token,
    password_fingerprint,
    verify_password,
)

router = APIRouter(prefix="/api/auth", tags=["auth"])
settings = get_settings()

COOKIE_KWARGS = dict(httponly=True, samesite="lax", secure=settings.cookie_secure, path="/")


def _set_session_cookies(response: Response, user: models.Kullanici, remember: bool) -> None:
    access_token = create_access_token(user.id, user.kullanici_adi)
    response.set_cookie("access_token", access_token, max_age=settings.access_token_expire_minutes * 60, **COOKIE_KWARGS)

    if remember:
        raw_token, hashed_token = generate_remember_token()
        user.remember_token = hashed_token
        response.set_cookie(
            "remember_token",
            f"{user.id}:{raw_token}",
            max_age=settings.remember_token_expire_days * 24 * 3600,
            **COOKIE_KWARGS,
        )
    else:
        user.remember_token = None
        response.delete_cookie("remember_token", path="/")


@router.post("/register", response_model=schemas.CurrentUser, status_code=201)
def register(payload: schemas.RegisterRequest, db: Session = Depends(get_db)):
    if payload.sifre != payload.sifre_tekrar:
        raise HTTPException(400, "Şifreler eşleşmiyor.")

    exists = db.scalar(
        select(models.Kullanici).where(
            (models.Kullanici.kullanici_adi == payload.kullanici_adi)
            | (models.Kullanici.email == payload.email)
        )
    )
    if exists:
        raise HTTPException(409, "Bu kullanıcı adı veya e-posta zaten kayıtlı.")

    user = models.Kullanici(
        kullanici_adi=payload.kullanici_adi,
        email=payload.email,
        sifre=hash_password(payload.sifre),
        is_active=True,
        tema=False,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.post("/login", response_model=schemas.CurrentUser)
def login(payload: schemas.LoginRequest, response: Response, db: Session = Depends(get_db)):
    user = db.scalar(select(models.Kullanici).where(models.Kullanici.kullanici_adi == payload.kullanici_adi))
    if not user or not verify_password(payload.sifre, user.sifre):
        raise HTTPException(401, "Kullanıcı adı veya şifre hatalı.")

    _set_session_cookies(response, user, payload.beni_hatirla)
    db.commit()
    return user


@router.post("/logout")
def logout(
    response: Response,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user.remember_token = None
    db.commit()
    response.delete_cookie("access_token", path="/")
    response.delete_cookie("remember_token", path="/")
    return {"ok": True}


@router.get("/me", response_model=schemas.CurrentUser)
def me(user: models.Kullanici = Depends(get_current_user)):
    return user


@router.post("/remember-login", response_model=schemas.CurrentUser)
def remember_login(
    response: Response,
    remember_token: str | None = Cookie(default=None),
    db: Session = Depends(get_db),
):
    if not remember_token or ":" not in remember_token:
        raise HTTPException(401, "Hatırlatma oturumu bulunamadı.")

    user_id_str, raw_token = remember_token.split(":", 1)
    try:
        user_id = int(user_id_str)
    except ValueError as exc:
        raise HTTPException(401, "Hatırlatma oturumu geçersiz.") from exc

    user = db.get(models.Kullanici, user_id)
    if not user or not user.remember_token or hash_remember_token(raw_token) != user.remember_token:
        response.delete_cookie("remember_token", path="/")
        raise HTTPException(401, "Hatırlatma oturumu geçersiz.")

    _set_session_cookies(response, user, remember=True)
    db.commit()
    return user


# ---------- Token auth (native clients) ----------
# Same credentials as /login, but tokens come back in the body instead of cookies.
# There is no server-side logout: the client just discards its tokens, which keeps
# the web session's remember_token untouched.


def _token_response(user: models.Kullanici) -> schemas.TokenResponse:
    return schemas.TokenResponse(
        access_token=create_access_token(user.id, user.kullanici_adi),
        refresh_token=create_refresh_token(user.id, user.sifre),
        expires_in=settings.access_token_expire_minutes * 60,
        user=schemas.CurrentUser.model_validate(user),
    )


@router.post("/token", response_model=schemas.TokenResponse)
def token_login(payload: schemas.TokenLoginRequest, db: Session = Depends(get_db)):
    user = db.scalar(select(models.Kullanici).where(models.Kullanici.kullanici_adi == payload.kullanici_adi))
    if not user or not verify_password(payload.sifre, user.sifre):
        raise HTTPException(401, "Kullanıcı adı veya şifre hatalı.")
    return _token_response(user)


@router.post("/token/refresh", response_model=schemas.TokenResponse)
def token_refresh(payload: schemas.RefreshRequest, db: Session = Depends(get_db)):
    try:
        claims = decode_refresh_token(payload.refresh_token)
        user_id = int(claims["sub"])
    except Exception as exc:
        raise HTTPException(401, "Oturum geçersiz.") from exc

    user = db.get(models.Kullanici, user_id)
    if not user or claims.get("pwd") != password_fingerprint(user.sifre):
        raise HTTPException(401, "Oturum geçersiz.")
    return _token_response(user)


@router.post("/forgot-password/send-code")
def forgot_password_send_code(payload: schemas.ForgotPasswordSendRequest, db: Session = Depends(get_db)):
    user = db.scalar(select(models.Kullanici).where(models.Kullanici.email == payload.email))
    if not user:
        raise HTTPException(404, "Sistemde böyle bir e-posta kayıtlı değil.")

    code = generate_otp_code()
    user.reset_kod = code
    user.reset_kod_zaman = dt.datetime.utcnow()
    db.commit()

    ok, error = send_otp_email(user.email, user.kullanici_adi, code)
    if not ok:
        raise HTTPException(502, f"E-posta gönderilemedi: {error}")
    return {"ok": True}


@router.post("/forgot-password/verify")
def forgot_password_verify(payload: schemas.ForgotPasswordVerifyRequest, db: Session = Depends(get_db)):
    user = db.scalar(
        select(models.Kullanici).where(
            models.Kullanici.email == payload.email, models.Kullanici.reset_kod == payload.kod
        )
    )
    if not user:
        raise HTTPException(400, "Hatalı kod girdiniz.")

    if not user.reset_kod_zaman or dt.datetime.utcnow() - user.reset_kod_zaman > dt.timedelta(minutes=15):
        raise HTTPException(400, "Bu kodun süresi (15 dk) dolmuş.")

    return {"ok": True}


@router.post("/forgot-password/reset")
def forgot_password_reset(payload: schemas.ForgotPasswordResetRequest, db: Session = Depends(get_db)):
    user = db.scalar(
        select(models.Kullanici).where(
            models.Kullanici.email == payload.email, models.Kullanici.reset_kod == payload.kod
        )
    )
    if not user:
        raise HTTPException(400, "Hatalı kod girdiniz.")

    if not user.reset_kod_zaman or dt.datetime.utcnow() - user.reset_kod_zaman > dt.timedelta(minutes=15):
        raise HTTPException(400, "Bu kodun süresi (15 dk) dolmuş.")

    user.sifre = hash_password(payload.yeni_sifre)
    user.reset_kod = None
    user.reset_kod_zaman = None
    user.remember_token = None
    db.commit()
    return {"ok": True}
