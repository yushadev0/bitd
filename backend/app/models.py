import datetime as dt

from sqlalchemy import (
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Kullanici(Base):
    __tablename__ = "kullanicilar"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    kullanici_adi: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    sifre: Mapped[str] = mapped_column(String(255), nullable=False)
    remember_token: Mapped[str | None] = mapped_column("remembertoken", String(255), nullable=True)
    email: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    is_active: Mapped[bool] = mapped_column("isactive", Boolean, nullable=False, default=True)
    reset_kod: Mapped[str | None] = mapped_column(String(6), nullable=True)
    reset_kod_zaman: Mapped[dt.datetime | None] = mapped_column(DateTime, nullable=True)
    tema: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    oyunlar: Mapped[list["KullaniciOyun"]] = relationship(back_populates="kullanici", cascade="all, delete-orphan")
    filmler: Mapped[list["KullaniciFilm"]] = relationship(back_populates="kullanici", cascade="all, delete-orphan")
    diziler: Mapped[list["KullaniciDizi"]] = relationship(back_populates="kullanici", cascade="all, delete-orphan")
    kitaplar: Mapped[list["KullaniciKitap"]] = relationship(back_populates="kullanici", cascade="all, delete-orphan")
    bildirim_cihazlari: Mapped[list["BildirimCihazi"]] = relationship(
        back_populates="kullanici", cascade="all, delete-orphan"
    )


class _KullaniciItemMixin:
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    eklenme_tarihi: Mapped[dt.datetime] = mapped_column(DateTime, server_default=func.now(), nullable=False)
    istek_mi: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    bitirme_tarihi: Mapped[dt.date | None] = mapped_column(Date, nullable=True)
    kisisel_not: Mapped[str | None] = mapped_column(Text, nullable=True)


class KullaniciOyun(_KullaniciItemMixin, Base):
    __tablename__ = "kullanici_oyunlar"
    __table_args__ = (UniqueConstraint("kullanici_id", "api_oyun_id", name="uq_kullanici_oyun"),)

    kullanici_id: Mapped[int] = mapped_column(ForeignKey("kullanicilar.id", ondelete="CASCADE"), nullable=False)
    api_oyun_id: Mapped[int] = mapped_column(Integer, nullable=False)

    kullanici: Mapped["Kullanici"] = relationship(back_populates="oyunlar")


class KullaniciFilm(_KullaniciItemMixin, Base):
    __tablename__ = "kullanici_filmler"
    __table_args__ = (UniqueConstraint("kullanici_id", "api_film_id", name="uq_kullanici_film"),)

    kullanici_id: Mapped[int] = mapped_column(ForeignKey("kullanicilar.id", ondelete="CASCADE"), nullable=False)
    api_film_id: Mapped[int] = mapped_column(Integer, nullable=False)

    kullanici: Mapped["Kullanici"] = relationship(back_populates="filmler")


class KullaniciDizi(_KullaniciItemMixin, Base):
    __tablename__ = "kullanici_diziler"
    __table_args__ = (UniqueConstraint("kullanici_id", "api_dizi_id", name="uq_kullanici_dizi"),)

    kullanici_id: Mapped[int] = mapped_column(ForeignKey("kullanicilar.id", ondelete="CASCADE"), nullable=False)
    api_dizi_id: Mapped[int] = mapped_column(Integer, nullable=False)

    kullanici: Mapped["Kullanici"] = relationship(back_populates="diziler")


class KullaniciKitap(_KullaniciItemMixin, Base):
    __tablename__ = "kullanici_kitaplar"
    __table_args__ = (UniqueConstraint("kullanici_id", "api_kitap_id", name="uq_kullanici_kitap"),)

    kullanici_id: Mapped[int] = mapped_column(ForeignKey("kullanicilar.id", ondelete="CASCADE"), nullable=False)
    # Google Books volume IDs are alphanumeric (e.g. "wrOQLV6xB-wC"), not numeric.
    api_kitap_id: Mapped[str] = mapped_column(String(64), nullable=False)

    kullanici: Mapped["Kullanici"] = relationship(back_populates="kitaplar")


class BildirimCihazi(Base):
    """A device that receives the daily wishlist suggestion push (one row per Expo push token)."""

    __tablename__ = "bildirim_cihazlari"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    kullanici_id: Mapped[int] = mapped_column(ForeignKey("kullanicilar.id", ondelete="CASCADE"), nullable=False)
    token: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    dil: Mapped[str] = mapped_column(String(2), nullable=False, default="tr")
    # IANA name (e.g. "Europe/Istanbul"): the push goes out in the evening of the device's own day.
    saat_dilimi: Mapped[str] = mapped_column(String(64), nullable=False)
    olusturma_tarihi: Mapped[dt.datetime] = mapped_column(DateTime, server_default=func.now(), nullable=False)
    son_gonderim: Mapped[dt.date | None] = mapped_column(Date, nullable=True)

    kullanici: Mapped["Kullanici"] = relationship(back_populates="bildirim_cihazlari")
