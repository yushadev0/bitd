"""Per-request language for native clients.

The web app is Turkish-only, so Turkish stays the default. The mobile app opts into
English with an explicit `X-App-Lang: en` header rather than Accept-Language, which
browsers send on their own and would flip the web app's messages.
"""

from contextvars import ContextVar

current_lang: ContextVar[str] = ContextVar("current_lang", default="tr")


def set_lang_from_header(value: str | None) -> None:
    current_lang.set("en" if (value or "").lower().startswith("en") else "tr")


def is_en() -> bool:
    return current_lang.get() == "en"


def t(tr: str, en: str) -> str:
    return en if is_en() else tr


def tmdb_language() -> str:
    return "en-US" if is_en() else "tr-TR"


# Error details are written in Turkish at the raise site; English clients get them
# translated on the way out (see the HTTPException handler in main.py).
_EN_ERRORS: dict[str, str] = {
    "Bu dizi zaten listenizde mevcut.": "This show is already in your library.",
    "Bu film zaten listenizde mevcut.": "This movie is already in your library.",
    "Bu kitap zaten listenizde mevcut.": "This book is already in your library.",
    "Bu oyun zaten listenizde mevcut.": "This game is already in your library.",
    "Bu kodun süresi (15 dk) dolmuş.": "This code has expired (15 min).",
    "Bu kullanıcı adı veya e-posta zaten kayıtlı.": "That username or email is already registered.",
    "Bu kullanıcı adı veya e-posta zaten kullanımda.": "That username or email is already in use.",
    "Desteklenmeyen görsel kaynağı.": "Unsupported image source.",
    "Görsel alınamadı.": "Couldn't load the image.",
    "Hatalı kod girdiniz.": "The code you entered is incorrect.",
    "Hatırlatma oturumu bulunamadı.": "No remembered session found.",
    "Hatırlatma oturumu geçersiz.": "The remembered session is invalid.",
    "İstek listeniz boş.": "Your wishlist is empty.",
    "İzleme listeniz boş.": "Your watchlist is empty.",
    "Okuma listeniz boş.": "Your reading list is empty.",
    "Kayıt bulunamadı.": "Item not found.",
    "Kullanıcı adı veya şifre hatalı.": "Incorrect username or password.",
    "Kullanıcı bulunamadı.": "User not found.",
    "Oturum bulunamadı.": "No session found.",
    "Oturum geçersiz.": "Your session is invalid.",
    "Şifreler eşleşmiyor.": "Passwords don't match.",
    "Sistemde böyle bir e-posta kayıtlı değil.": "No account is registered with that email.",
    "Geçersiz bildirim anahtarı.": "Invalid notification token.",
    "Çok fazla deneme yaptın. Lütfen biraz sonra tekrar dene.": "Too many attempts. Please try again in a little while.",
    "Dış servise şu an ulaşılamıyor, lütfen birazdan tekrar dene.": "The external service is unavailable right now, please try again shortly.",
    "Dış servise bağlanılamadı, lütfen birazdan tekrar dene.": "Couldn't reach the external service, please try again shortly.",
}

_EN_PREFIXES: dict[str, str] = {
    "E-posta gönderilemedi:": "Couldn't send the email:",
}


def translate_error(detail: object) -> object:
    if not is_en() or not isinstance(detail, str):
        return detail
    if detail in _EN_ERRORS:
        return _EN_ERRORS[detail]
    for tr_prefix, en_prefix in _EN_PREFIXES.items():
        if detail.startswith(tr_prefix):
            return en_prefix + detail[len(tr_prefix):]
    return detail
