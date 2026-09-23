import datetime as dt
import hashlib
import secrets

import bcrypt
import jwt

from app.config import get_settings

settings = get_settings()


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, password_hash: str) -> bool:
    return bcrypt.checkpw(password.encode(), password_hash.encode())


def create_access_token(user_id: int, username: str) -> str:
    now = dt.datetime.now(dt.timezone.utc)
    payload = {
        "sub": str(user_id),
        "username": username,
        "iat": now,
        "exp": now + dt.timedelta(minutes=settings.access_token_expire_minutes),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_access_token(token: str) -> dict:
    payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
    # Refresh tokens are signed with the same secret; never let one stand in for an access token.
    if payload.get("typ") == "refresh":
        raise jwt.InvalidTokenError("refresh token used as access token")
    return payload


def password_fingerprint(password_hash: str) -> str:
    """Short digest of the stored password hash, embedded in refresh tokens so that
    changing the password invalidates every outstanding mobile session."""
    return hashlib.sha256(password_hash.encode()).hexdigest()[:16]


def create_refresh_token(user_id: int, password_hash: str) -> str:
    # Stateless on purpose: the single `remember_token` column belongs to the web
    # client's "remember me", and a mobile login must not evict it.
    now = dt.datetime.now(dt.timezone.utc)
    payload = {
        "sub": str(user_id),
        "typ": "refresh",
        "pwd": password_fingerprint(password_hash),
        "iat": now,
        "exp": now + dt.timedelta(days=settings.remember_token_expire_days),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_refresh_token(token: str) -> dict:
    payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
    if payload.get("typ") != "refresh":
        raise jwt.InvalidTokenError("not a refresh token")
    return payload


def generate_remember_token() -> tuple[str, str]:
    """Returns (raw_token_for_cookie, hashed_token_for_db)."""
    raw = secrets.token_hex(32)
    hashed = hashlib.sha256(raw.encode()).hexdigest()
    return raw, hashed


def hash_remember_token(raw: str) -> str:
    return hashlib.sha256(raw.encode()).hexdigest()


def generate_otp_code() -> str:
    return f"{secrets.randbelow(900000) + 100000}"
