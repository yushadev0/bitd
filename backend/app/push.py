"""Daily "how about this one?" push: a random pick from the user's wishlists, sent via Expo.

Runs inside the API process (a single uvicorn worker) as a background loop. Every few
minutes it looks for devices whose local evening has started and that haven't had
today's suggestion yet.

Send one right now, bypassing the schedule (handy for testing):
    docker exec bitd-api python -m app.push <kullanici_adi>
"""

import asyncio
import datetime as dt
import logging
import random
import sys
from dataclasses import dataclass
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

import httpx
from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app import models
from app.database import SessionLocal
from app.external import google_books, igdb, tmdb
from app.i18n import current_lang

log = logging.getLogger("bitd.push")

EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send"
CHECK_INTERVAL_SECONDS = 5 * 60
SEND_HOUR = 19  # local time
LAST_SEND_HOUR = 22  # if the server was down all evening, skip the day rather than ping at midnight
DEFAULT_TIMEZONE = "Europe/Istanbul"

# (model, api id column) per category; the category names match the app's routes.
_WISHLISTS = {
    "games": (models.KullaniciOyun, models.KullaniciOyun.api_oyun_id),
    "movies": (models.KullaniciFilm, models.KullaniciFilm.api_film_id),
    "tv": (models.KullaniciDizi, models.KullaniciDizi.api_dizi_id),
    "books": (models.KullaniciKitap, models.KullaniciKitap.api_kitap_id),
}

_BODY = {
    "tr": {
        "games": "Bugün {title} oynamaya ne dersin?",
        "movies": "Bugün {title} izlemeye ne dersin?",
        "tv": "Bugün {title} izlemeye ne dersin?",
        "books": "Bugün {title} okumaya ne dersin?",
    },
    "en": {
        "games": "How about playing {title} today?",
        "movies": "How about watching {title} today?",
        "tv": "How about watching {title} today?",
        "books": "How about reading {title} today?",
    },
}


@dataclass
class Suggestion:
    category: str
    api_id: str
    title: str


def valid_timezone(name: str) -> str:
    try:
        ZoneInfo(name)
        return name
    except (ZoneInfoNotFoundError, ValueError):
        return DEFAULT_TIMEZONE


async def _title(category: str, api_id: str) -> str | None:
    """Fetches the display title in the current request language (see i18n.current_lang)."""
    if category == "games":
        games = await igdb.get_games([int(api_id)])
        return games[0].get("name") if games else None
    if category == "movies":
        movie = await tmdb.get_movie(int(api_id))
        return movie.get("title") if movie else None
    if category == "tv":
        show = await tmdb.get_tv(int(api_id))
        return show.get("name") if show else None
    volume = await google_books.get_book(api_id)
    return volume.get("volumeInfo", {}).get("title") if volume else None


async def pick_suggestion(db: Session, user_id: int, lang: str) -> Suggestion | None:
    """A uniformly random item across all four wishlists, with its title resolved."""
    candidates: list[tuple[str, str]] = []
    for category, (model, id_column) in _WISHLISTS.items():
        ids = db.scalars(select(id_column).where(model.kullanici_id == user_id, model.istek_mi == True)).all()
        candidates += [(category, str(i)) for i in ids]
    random.shuffle(candidates)

    token = current_lang.set(lang)
    try:
        # An upstream hiccup on one item shouldn't cost the whole day's push.
        for category, api_id in candidates[:3]:
            try:
                title = await _title(category, api_id)
            except httpx.HTTPError:
                title = None
            if title:
                return Suggestion(category, api_id, title)
        return None
    finally:
        current_lang.reset(token)


def build_message(device: models.BildirimCihazi, username: str, suggestion: Suggestion) -> dict:
    lang = "en" if device.dil == "en" else "tr"
    return {
        "to": device.token,
        "title": f"Hey {username}!" if lang == "en" else f"Hey, {username}!",
        "body": _BODY[lang][suggestion.category].format(title=suggestion.title),
        "sound": "default",
        # The app opens this route when the notification is tapped.
        "data": {"url": f"/{suggestion.category}/{suggestion.api_id}"},
    }


async def send(messages: list[dict]) -> list[str]:
    """Sends through Expo's push service; returns tokens Apple no longer accepts."""
    if not messages:
        return []
    async with httpx.AsyncClient(timeout=20) as client:
        resp = await client.post(EXPO_PUSH_URL, json=messages, headers={"Accept": "application/json"})
    resp.raise_for_status()
    dead: list[str] = []
    for message, ticket in zip(messages, resp.json().get("data", [])):
        if ticket.get("status") == "error":
            log.warning("push to %s failed: %s", message["to"], ticket.get("message"))
            if ticket.get("details", {}).get("error") == "DeviceNotRegistered":
                dead.append(message["to"])
    return dead


def _is_due(device: models.BildirimCihazi, now_utc: dt.datetime) -> bool:
    local = now_utc.astimezone(ZoneInfo(valid_timezone(device.saat_dilimi)))
    return SEND_HOUR <= local.hour < LAST_SEND_HOUR and device.son_gonderim != local.date()


async def send_to_devices(db: Session, devices: list[models.BildirimCihazi], now_utc: dt.datetime) -> int:
    messages = []
    for device in devices:
        # Marked first so a crash mid-run can't turn into a second push the same evening.
        device.son_gonderim = now_utc.astimezone(ZoneInfo(valid_timezone(device.saat_dilimi))).date()
        suggestion = await pick_suggestion(db, device.kullanici_id, device.dil)
        if suggestion:
            messages.append(build_message(device, device.kullanici.kullanici_adi, suggestion))
    db.commit()

    dead = await send(messages)
    if dead:
        db.execute(delete(models.BildirimCihazi).where(models.BildirimCihazi.token.in_(dead)))
        db.commit()
    return len(messages)


async def run_due() -> int:
    now_utc = dt.datetime.now(dt.timezone.utc)
    with SessionLocal() as db:
        devices = [d for d in db.scalars(select(models.BildirimCihazi)).all() if _is_due(d, now_utc)]
        return await send_to_devices(db, devices, now_utc) if devices else 0


async def scheduler() -> None:
    while True:
        try:
            sent = await run_due()
            if sent:
                log.info("sent %d suggestion push(es)", sent)
        except Exception:  # noqa: BLE001 - keep the loop alive; the next tick retries
            log.exception("suggestion push run failed")
        await asyncio.sleep(CHECK_INTERVAL_SECONDS)


async def _send_now(username: str) -> None:
    with SessionLocal() as db:
        user = db.scalar(select(models.Kullanici).where(models.Kullanici.kullanici_adi == username))
        if not user:
            sys.exit(f"No such user: {username}")
        if not user.bildirim_cihazlari:
            sys.exit(f"{username} has no registered devices.")
        # Deliberately leaves son_gonderim alone so tonight's scheduled push still goes out.
        messages = []
        for device in user.bildirim_cihazlari:
            suggestion = await pick_suggestion(db, user.id, device.dil)
            if not suggestion:
                sys.exit(f"{username}'s wishlists are empty.")
            messages.append(build_message(device, username, suggestion))
        dead = await send(messages)
        for m in messages:
            print(f"{'DEAD ' if m['to'] in dead else 'sent '} {m['title']} {m['body']}  → {m['data']['url']}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: python -m app.push <kullanici_adi>")
    asyncio.run(_send_now(sys.argv[1]))
