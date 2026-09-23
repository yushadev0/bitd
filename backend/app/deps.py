from fastapi import Cookie, Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from app import models
from app.database import get_db
from app.security import decode_access_token


def get_current_user(
    access_token: str | None = Cookie(default=None),
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> models.Kullanici:
    # Native clients send `Authorization: Bearer <jwt>`; the web app relies on the cookie.
    if authorization and authorization.lower().startswith("bearer "):
        access_token = authorization[7:].strip()
    if not access_token:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Oturum bulunamadı.")
    try:
        payload = decode_access_token(access_token)
    except Exception as exc:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Oturum geçersiz.") from exc

    user = db.get(models.Kullanici, int(payload["sub"]))
    if user is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Kullanıcı bulunamadı.")
    return user
