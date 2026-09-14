from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # Database
    database_url: str = "postgresql+psycopg://bitd:bitd@localhost:5432/bitd"

    # Auth
    jwt_secret: str = "change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 12
    remember_token_expire_days: int = 30

    # CORS
    cors_origins: str = "http://localhost:5173"
    cookie_secure: bool = False

    # Prefix to prepend to URLs this API generates for the browser to fetch back
    # (e.g. the TMDB image proxy) — empty at the domain root, "/bitd" when the
    # frontend is served under https://yusa.app/bitd/.
    public_path_prefix: str = ""

    # External APIs
    tmdb_token: str = ""
    twitch_client_id: str = ""
    twitch_client_secret: str = ""
    google_books_key: str = ""

    # SMTP (forgot-password OTP emails)
    smtp_host: str = "smtp.gmail.com"
    smtp_port: int = 587
    smtp_username: str = ""
    smtp_password: str = ""
    smtp_from_name: str = "B.I.T.D. Sistem"

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
