# B.I.T.D. (Back In The Day) — v2

A personal archive app for tracking games, movies, TV shows, and books you want to
experience or have already finished — with wishlist/completed tracking, notes, and a
"what should I do today?" randomizer.

This is a full rewrite of the original Delphi/UniGUI desktop-web app as a modern,
containerized **React + FastAPI** stack, using a fresh PostgreSQL database with the
same table shapes (`kullanicilar`, `kullanici_oyunlar`, `kullanici_filmler`,
`kullanici_diziler`, `kullanici_kitaplar`).

## Stack

- **Frontend:** React 18 + TypeScript + Vite + Tailwind CSS
- **Backend:** FastAPI (Python 3.12), SQLAlchemy 2.0, JWT + remember-me cookie auth
- **Database:** PostgreSQL 16
- **External APIs:** TMDB (movies/TV), IGDB via Twitch (games), Google Books
- **Infra:** Docker Compose (db + backend + frontend/nginx)

## Project layout

```
backend/    FastAPI app, SQLAlchemy models, external API clients
frontend/   React + Vite SPA
docker-compose.yml
```

## Running it

1. Copy the example env file and fill in your own secrets:

   ```
   cp backend/.env.example backend/.env
   ```

   You'll need:
   - A TMDB API Read Access Token — https://www.themoviedb.org/settings/api
   - A Twitch app (Client ID + Secret) for IGDB — https://dev.twitch.tv/console/apps
   - A Google Books API key — https://console.cloud.google.com/apis/credentials
   - An SMTP account (e.g. a Gmail address + [App Password](https://myaccount.google.com/apppasswords))
     for sending password-reset codes
   - A random `JWT_SECRET` (any long random string)

2. Start everything:

   ```
   docker compose up -d --build
   ```

3. Open the app at **http://localhost:8080**. The backend API lives at
   `http://localhost:8000` (proxied under `/api` by the frontend's nginx in the
   containerized setup, and via Vite's dev proxy when running `npm run dev` locally).

The Postgres schema (tables, constraints) is created automatically on backend startup —
no manual migration step is needed for a fresh database.

## Local development (without Docker)

```
# backend
cd backend
python -m venv .venv && .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload

# frontend (separate terminal)
cd frontend
npm install
npm run dev
```

The Vite dev server proxies `/api` to `http://localhost:8000` (see `vite.config.ts`), so
the frontend and backend can run independently during development.

## Database schema

| Table | Purpose |
|---|---|
| `kullanicilar` | Users: credentials, email, theme preference, password-reset OTP state |
| `kullanici_oyunlar` | A user's games (IGDB id, wishlist flag, finish date, note) |
| `kullanici_filmler` | A user's movies (TMDB id, same shape) |
| `kullanici_diziler` | A user's TV shows (TMDB id, same shape) |
| `kullanici_kitaplar` | A user's books (Google Books volume id — string, same shape) |

External metadata (posters, genres, summaries, scores, etc.) is never stored locally —
it's fetched live from the respective API on each read, exactly like the original app.

## Security notes

- Passwords are hashed with bcrypt (the original app used unsalted SHA-256; this is a
  deliberate improvement since this is a from-scratch rewrite with an empty database).
- "Remember me" stores only a hashed token in the database; the raw token lives solely
  in an `httpOnly` cookie.
- Never commit `backend/.env` — it holds real API keys and SMTP credentials.
  `.gitignore` already excludes it; only `backend/.env.example` (placeholders) is
  tracked.

## License

Open-source, for educational and personal use — same spirit as the original project.

## Contact

Developer: Yuşa Göverdik — https://hasup.net
