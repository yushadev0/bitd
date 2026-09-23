from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db
from app.deps import get_current_user
from app.push import valid_timezone

router = APIRouter(prefix="/api/push", tags=["push"])


@router.put("/device", status_code=204)
def register_device(
    payload: schemas.PushRegisterRequest,
    user: models.Kullanici = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not payload.token.startswith(("ExponentPushToken[", "ExpoPushToken[")):
        raise HTTPException(400, "Geçersiz bildirim anahtarı.")

    device = db.scalar(select(models.BildirimCihazi).where(models.BildirimCihazi.token == payload.token))
    if device is None:
        device = models.BildirimCihazi(token=payload.token, kullanici_id=user.id)
        db.add(device)
    # A phone that switches accounts keeps its token; it now belongs to whoever signed in.
    device.kullanici_id = user.id
    device.dil = "en" if payload.dil.lower().startswith("en") else "tr"
    device.saat_dilimi = valid_timezone(payload.saat_dilimi)
    db.commit()


# No auth on purpose: sign-out calls this even when the session has already expired,
# and knowing a device's token only lets you stop its notifications.
@router.post("/device/unregister", status_code=204)
def unregister_device(payload: schemas.PushUnregisterRequest, db: Session = Depends(get_db)):
    db.execute(delete(models.BildirimCihazi).where(models.BildirimCihazi.token == payload.token))
    db.commit()
