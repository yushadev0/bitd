# B.I.T.D. (Back In The Day)

**B.I.T.D. (Back In The Day)** is a robust, full-stack digital archiving application designed to manage personal collections of video games, movies, TV shows, and books. Built with Delphi and the UniGUI framework, it features a distinct Cyberpunk/Retro-Neon aesthetic and operates as a Single Page Application (SPA).

The system integrates with multiple external REST APIs to fetch metadata, allows users to track their "Wishlist" versus "Completed" status, and includes intelligent randomization features to assist with decision paralysis.

---

## Key Features

### Multi-Category Archiving
Centralized management for Games, Movies, TV Series, and Books.

### Dual-State Tracking
Distinguishes between "Wishlist" (To-Do) and "Completed" items with date tracking. Includes a revert mechanism to move items back to the wishlist if marked by mistake.

### Intelligent Randomizer
A "What should I do today?" engine that randomly selects an item exclusively from the user's wishlist.

### External API Integration
- **IGDB (Twitch):** For video game metadata and covers.
- **TMDB:** For movie and TV show details.
- **Google Books:** For book metadata and high-resolution cover retrieval.

### Dynamic UI / UX
- Custom CSS / JavaScript implementation over UniGUI.
- Toggleable Light / Dark themes with local storage persistence.
- Responsive design adapting to desktop and mobile interfaces.
- "Empty State" handling to guide new users.

### Security
OTP (One-Time Password) verification via Email (SMTP) during user registration.

---

## Technology Stack

- **Language:** Delphi (Object Pascal)
- **Framework:** UniGUI (Web Application Framework)
- **Database:** Microsoft SQL Server
- **Frontend:** HTML5, CSS3, JavaScript (Injected via UniHTMLFrame)

### Libraries
- REST.Client for API communication
- SweetAlert2 for modal interactions
- Flatpickr for date selection
- FontAwesome for iconography
- UniDAC for database

---

## Installation and Configuration

### Important Note on Security
To maintain security standards, this repository excludes files containing sensitive database credentials and API keys. Specifically, `MainModule.pas` and `SecretConsts.pas` are included in `.gitignore`. You must recreate these configurations locally for the application to compile and run.

---

### 1. Prerequisites
- Embarcadero Delphi (Version supporting UniGUI)
- UniGUI Framework installed
- Microsoft SQL Server instance

---

### 2. Database Setup

Create a SQL Server database containing the following tables and columns. And put this database to `MainModule.pas` and `MainModule.dfm` using UniDAC -used in the project- or a similar database component.

> Note: Column naming follows the original project implementation and is intentionally not normalized for consistency with the existing codebase.

#### Table: `kullanicilar` (Users)

| Column Name | Data Type | Description |
|---|---|---|
| id | INT (PK, IDENTITY) | Unique user identifier |
| kullanici_adi | NVARCHAR(50) | User nickname |
| sifre | NVARCHAR(64) | Hashed user password |
| RememberToken | NVARCHAR(64) | Encrypted Remember-me token |
| Email | NVARCHAR(100) | User e-mail address |
| IsActive | BIT | Account active status |
| reset_kod | VARCHAR(6) | OTP code |
| reset_kod_zaman | DATETIME | OTP code expiration date |
| tema | BIT | Theme preference |

#### Table: `kullanici_oyunlar` (Games)

| Column Name | Data Type | Description |
|---|---|---|
| id | INT (PK, IDENTITY) | Unique record identifier |
| kullanici_id | INT (FK) | Reference to `kullanicilar.id` |
| api_oyun_id | INT | IGDB game ID |
| eklenme_tarihi | DATETIME | Date added |
| istek_mi | BIT | Is in Wishlist? |
| bitirme_tarihi | DATE | Completion date |
| kisisel_not | NVARCHAR(MAX) | Personal notes |

#### Table: `kullanici_filmler` (Movies)

| Column Name | Data Type | Description |
|---|---|---|
| id | INT (PK, IDENTITY) | Unique record identifier |
| kullanici_id | INT (FK) | Reference to `kullanicilar.id` |
| api_film_id | INT | TMDB movie ID |
| eklenme_tarihi | DATETIME | Date added |
| istek_mi | BIT | Is in Wishlist? |
| bitirme_tarihi | DATE | Completion date |
| kisisel_not | NVARCHAR(MAX) | Personal notes |

#### Table: `kullanici_diziler` (TV Shows)

| Column Name | Data Type | Description |
|---|---|---|
| id | INT (PK, IDENTITY) | Unique record identifier |
| kullanici_id | INT (FK) | Reference to `kullanicilar.id` |
| api_dizi_id | INT | TMDB tv-show ID |
| eklenme_tarihi | DATETIME | Date added |
| istek_mi | BIT | Is in Wishlist? |
| bitirme_tarihi | DATE | Completion date |
| kisisel_not | NVARCHAR(MAX) | Personal notes |

#### Table: `kullanici_kitaplar` (Books)

| Column Name | Data Type | Description |
|---|---|---|
| id | INT (PK, IDENTITY) | Unique record identifier |
| kullanici_id | INT (FK) | Reference to `kullanicilar.id` |
| api_kitap_id | INT | Google Books book ID |
| eklenme_tarihi | DATETIME | Date added |
| istek_mi | BIT | Is in Wishlist? |
| bitirme_tarihi | DATE | Completion date |
| kisisel_not | NVARCHAR(MAX) | Personal notes |



---

### 3. Recreating Missing Files

#### A. SecretConsts.pas
Create a new unit named `SecretConsts.pas` in the project root directory. This unit handles external API authentication. Copy the following code and insert your specific API keys:

```pascal
unit SecretConsts;

interface

const
  // TMDB API Token (Read Access Token)
  API_TMDB_TOKEN = 'YOUR_TMDB_LONG_TOKEN_HERE';
  
  // Twitch/IGDB Credentials
  API_TWITCH_CLIENT_ID = 'YOUR_TWITCH_CLIENT_ID_HERE';
  API_TWITCH_SECRET = 'YOUR_TWITCH_SECRET_HERE';
  
  // Google App Password (for email notifications)
  GOOGLE_APP_PASS = 'YOUR_GOOGLE_APP_PASSWORD_HERE';

implementation

end.
```
#### B. MainModule.pas Configuration

The MainModule.pas file handles the database connection and session-specific logic. Since this file was excluded:

- Open the project in Delphi. (UniGUI v1597 required.)

- The IDE may prompt that MainModule.pas is missing. Create a new UniGUI MainModule.

- Add a `TUniConnection (UniDAC)` component to the MainModule.
- Add a `TSQLServerUniProvider (UniDAC)` component to the MainModule.
- Add a `TUniQuery (UniDAC) named 'GirisTable'` component to the MainModule.
- Add a `TUniQuery (UniDAC) named 'UpdateQuery'` component to the MainModule.
- Add a `TUniQuery (UniDAC) named 'GenelSorguTable'` component to the MainModule.
- Add a `TUniQuery (UniDAC) named 'KullaniciOyunlarTable'` component to the MainModule.
- Add a `TUniQuery (UniDAC) named 'KullaniciFilmlerTable'` component to the MainModule.
- Add a `TUniQuery (UniDAC) named 'KullaniciDizilerTable'` component to the MainModule.
- Add a `TUniQuery (UniDAC) named 'KullaniciKitaplarTable'` component to the MainModule.

- Configure the connection string to point to your local SQL Server instance.

---

### 4. API Requirements

To fully utilize the application, you must obtain your personal API keys from the following providers:

- `The Movie Database (TMDB): For Movies and TV Shows.` 
   <br>Here is the [link](https://www.themoviedb.org/)


- `IGDB (via Twitch Developer Console): For Games.`
  <br>Here is the [link](https://www.igdb.com/)

- `Google Books API: No key is strictly required for public queries, but recommended for higher quotas. This project uses public Google Books endpoints and does not require a dedicated API key.`

---

## Usage

- Open the project (.dproj) in Delphi.

- Build and Run the application.

- The UniGUI server will start.

- Access the application via the local browser: `http://localhost:8077`

- Register a new user (requires a valid email for OTP verification).

---
## Screenshots

![Picture1: Main Menu](/assets/screenshots/menu.png "Main Menu")

![Picture2: 'My Movies' section](/assets/screenshots/movies.png "'My Movies' section")

![Picture3: 'What do I play' result screen'](/assets/screenshots/result.png "'What do I play' result screen")

---

## License

This project is open-source and available for educational and personal use.

---
## Contact

Developer: Yuşa Göverdik

Portfolio: https://hasup.net
