from fastapi import Cookie, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import models
from app.database import get_db
from app.security import decode_access_token


def get_current_user(
    access_token: str | None = Cookie(default=None),
    db: Session = Depends(get_db),
) -> models.Kullanici:
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
