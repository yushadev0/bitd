from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db
from app.deps import get_current_user

router = APIRouter(prefix="/api/account", tags=["account"])


@router.get("", response_model=schemas.CurrentUser)
def get_account(user: models.Kullanici = Depends(get_current_user)):
    return user


@router.patch("", response_model=schemas.CurrentUser)
def update_account(
    payload: schemas.UpdateProfileRequest,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    clash = db.scalar(
        select(models.Kullanici).where(
            models.Kullanici.id != user.id,
            (models.Kullanici.kullanici_adi == payload.kullanici_adi)
            | (models.Kullanici.email == payload.email),
        )
    )
    if clash:
        raise HTTPException(409, "Bu kullanıcı adı veya e-posta zaten kullanımda.")

    user.kullanici_adi = payload.kullanici_adi
    user.email = payload.email
    db.commit()
    db.refresh(user)
    return user


@router.patch("/theme", response_model=schemas.CurrentUser)
def update_theme(
    payload: schemas.UpdateThemeRequest,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user.tema = payload.tema
    db.commit()
    db.refresh(user)
    return user
