import datetime as dt

from pydantic import BaseModel, EmailStr, Field


# ---------- Auth ----------
class RegisterRequest(BaseModel):
    kullanici_adi: str = Field(min_length=3, max_length=50)
    email: EmailStr
    sifre: str = Field(min_length=6, max_length=128)
    sifre_tekrar: str


class LoginRequest(BaseModel):
    kullanici_adi: str
    sifre: str
    beni_hatirla: bool = False


class ForgotPasswordSendRequest(BaseModel):
    email: EmailStr


class ForgotPasswordVerifyRequest(BaseModel):
    email: EmailStr
    kod: str


class ForgotPasswordResetRequest(BaseModel):
    email: EmailStr
    kod: str
    yeni_sifre: str = Field(min_length=6, max_length=128)


class CurrentUser(BaseModel):
    id: int
    kullanici_adi: str
    email: str
    tema: bool

    class Config:
        from_attributes = True


# ---------- Token auth (native clients) ----------
class TokenLoginRequest(BaseModel):
    kullanici_adi: str
    sifre: str


class RefreshRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    user: CurrentUser


# ---------- Account ----------
class UpdateProfileRequest(BaseModel):
    kullanici_adi: str = Field(min_length=3, max_length=50)
    email: EmailStr


class UpdateThemeRequest(BaseModel):
    tema: bool


# ---------- Library items ----------
class AddItemRequest(BaseModel):
    api_id: str
    istek_mi: bool = True


class UpdateStatusRequest(BaseModel):
    istek_mi: bool


class UpdateDateRequest(BaseModel):
    bitirme_tarihi: dt.date


class UpdateNoteRequest(BaseModel):
    kisisel_not: str = ""


class LibraryItem(BaseModel):
    api_id: str
    istek_mi: bool
    eklenme_tarihi: dt.datetime
    bitirme_tarihi: dt.date | None
    kisisel_not: str | None
    detail: dict | None = None


class DashboardStats(BaseModel):
    total: int
    wishlist: int


class DashboardResponse(BaseModel):
    oyunlar: DashboardStats
    filmler: DashboardStats
    diziler: DashboardStats
    kitaplar: DashboardStats


class PushRegisterRequest(BaseModel):
    token: str = Field(min_length=10, max_length=255)
    dil: str = Field(default="tr", max_length=5)
    saat_dilimi: str = Field(default="Europe/Istanbul", max_length=64)


class PushUnregisterRequest(BaseModel):
    token: str = Field(min_length=10, max_length=255)
