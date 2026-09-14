# B.I.T.D. — Back In The Day

**[Live demo → yusa.app/bitd](https://yusa.app/bitd)**

A personal archive app for tracking games, movies, TV shows, and books you want to
experience or have already finished — with wishlist/completed tracking, personal notes,
finish dates, and a "what should I do today?" randomizer that picks something from your
wishlist for you.

This is a full rewrite of an original Delphi/UniGUI desktop-web app as a modern,
containerized **React + FastAPI** stack, keeping the same database table shapes
(`kullanicilar`, `kullanici_oyunlar`, `kullanici_filmler`, `kullanici_diziler`,
`kullanici_kitaplar`) so existing data carries over cleanly.

## Features

- Four media libraries — games, movies, TV shows, books — each with search-and-add,
  a wishlist/completed split, personal notes, and finish dates
- Live metadata from TMDB (movies/TV), IGDB (games), and Google Books — nothing is
  cached locally beyond the IDs you've added
- A daily randomizer per category, pulling from your wishlist only
- Email OTP password reset (SMTP)
- "Remember me" sessions (JWT + a hashed long-lived cookie)
- Light/dark theme, persisted per account
- Fully responsive: a mobile bottom nav and bottom-sheet modals, not just a squeezed
  desktop layout

## Stack

- **Frontend:** React 18 + TypeScript + Vite + Tailwind CSS, Font Awesome icons,
  Flatpickr for date selection, anime.js for the detail-view transition
- **Backend:** FastAPI (Python 3.12), SQLAlchemy 2.0, JWT + remember-me cookie auth
- **Database:** PostgreSQL (default, via Docker Compose) or Microsoft SQL Server —
  the backend runs against either unchanged, selected entirely by `DATABASE_URL`
- **External APIs:** TMDB (movies/TV), IGDB via Twitch (games), Google Books
- **Infra:** Docker Compose (db + backend + frontend/nginx)

## Project layout

```
backend/    FastAPI app, SQLAlchemy models, external API clients
frontend/   React + Vite SPA
docker-compose.yml
```

## Running it locally

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

The database schema (tables, constraints) is created automatically on backend startup —
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

## Deploying under a path prefix

The live demo is served at `https://yusa.app/bitd/` alongside other apps on the same
domain, rather than at its own root. Both halves support this:

- Frontend: `npm run build:bitd-app` builds with Vite's `--base=/bitd/`, which also
  flows into React Router's `basename` and the API client's request prefix
  automatically (both read `import.meta.env.BASE_URL` at build time — no separate
  config needed).
- Backend: set `PUBLIC_PATH_PREFIX=/bitd` so URLs it hands back to the browser (the
  TMDB image proxy) carry the right prefix too.

A reverse proxy (nginx, in the demo's case) then serves the built static files under
`/bitd/` and proxies `/bitd/api/` to the backend container.

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
- The TMDB API and its poster CDN are proxied through the backend (`/api/image-proxy`,
  host-allowlisted) rather than fetched directly by the browser, so a network that
  blocks `themoviedb.org` (DNS-level blocks are more common than you'd think) doesn't
  break movie/TV posters for your users.
- Never commit `backend/.env` — it holds real API keys, SMTP credentials, and a
  database connection string. `.gitignore` already excludes it; only
  `backend/.env.example` (placeholders) is tracked.

## License

Open-source, for educational and personal use.

## Contact

Developer: Yuşa Göverdik — https://yusa.app
