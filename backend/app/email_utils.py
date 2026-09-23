import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from html import escape

from app.config import get_settings
from app.i18n import is_en, t

settings = get_settings()

# The web app's "video store at night" palette. Email clients ignore <style> blocks
# and web fonts unevenly, so everything is inline, table-based, with system fallbacks.
_INK = "#1D1C1F"
_CARD = "#28262B"
_RULE = "#37353C"
_TEXT = "#F7F4EE"
_MUTED = "#B8AFA0"
_AMBER = "#E8A33D"
_DISPLAY = "'Bebas Neue', Impact, 'Arial Narrow', sans-serif"
_SANS = "Inter, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"

_LAYOUT = """\
<!doctype html>
<html lang="{lang}">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="dark light">
<title>{title}</title>
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Inter:wght@400;600&display=swap" rel="stylesheet">
</head>
<body style="margin:0;padding:0;background:{ink};">
<div style="display:none;max-height:0;overflow:hidden;opacity:0;">{preheader}</div>
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="{ink}" style="background:{ink};">
<tr><td align="center" style="padding:40px 16px;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="max-width:480px;">
    <tr><td style="padding:0 4px 20px;">
      <div style="font-family:{display};font-size:40px;line-height:1;letter-spacing:3px;color:{amber};">B.I.T.D.</div>
      <div style="font-family:{sans};font-size:11px;letter-spacing:2px;text-transform:uppercase;color:{muted};padding-top:4px;">Back In The Day</div>
    </td></tr>
    <tr><td bgcolor="{card}" style="background:{card};border-radius:16px;padding:32px 28px;border-top:4px solid {amber};">
      <div style="font-family:{display};font-size:30px;line-height:1.1;letter-spacing:1px;color:{text};margin:0 0 16px;">{heading}</div>
      {body}
    </td></tr>
    <tr><td style="padding:20px 4px 0;font-family:{sans};font-size:12px;line-height:1.6;color:{muted};">
      {footer}<br>
      <a href="https://yusa.app/bitd/" style="color:{amber};text-decoration:none;">yusa.app/bitd</a>
    </td></tr>
  </table>
</td></tr>
</table>
</body>
</html>
"""


def _paragraph(html: str, muted: bool = False) -> str:
    color = _MUTED if muted else _TEXT
    size = 13 if muted else 15
    return f'<p style="font-family:{_SANS};font-size:{size}px;line-height:1.6;color:{color};margin:0 0 14px;">{html}</p>'


def _render(title: str, preheader: str, heading: str, body: str) -> str:
    return _LAYOUT.format(
        lang="en" if is_en() else "tr",
        title=escape(title),
        preheader=escape(preheader),
        heading=escape(heading),
        body=body,
        footer=escape(t(
            "Bu e-posta B.I.T.D. hesabınla ilgili bir işlem nedeniyle otomatik olarak gönderildi.",
            "This email was sent automatically because of an action on your B.I.T.D. account.",
        )),
        ink=_INK, card=_CARD, amber=_AMBER, text=_TEXT, muted=_MUTED, display=_DISPLAY, sans=_SANS,
    )


def _compose(to_email: str, subject: str, html: str, text: str) -> MIMEMultipart:
    message = MIMEMultipart("alternative")
    message["Subject"] = subject
    message["From"] = f"{settings.smtp_from_name} <{settings.smtp_username}>"
    message["To"] = to_email
    # Clients show the last part they can render, so plain text goes first.
    message.attach(MIMEText(text, "plain", "utf-8"))
    message.attach(MIMEText(html, "html", "utf-8"))
    return message


def send_email(message: MIMEMultipart) -> tuple[bool, str]:
    if not settings.smtp_username or not settings.smtp_password:
        return False, "SMTP is not configured on the server."
    try:
        with smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=15) as server:
            server.starttls()
            server.login(settings.smtp_username, settings.smtp_password)
            server.sendmail(settings.smtp_username, [message["To"]], message.as_string())
        return True, ""
    except Exception as exc:  # noqa: BLE001 - surface the reason to the caller
        return False, str(exc)


def send_otp_email(to_email: str, username: str, code: str) -> tuple[bool, str]:
    subject = t("B.I.T.D. - Şifre sıfırlama kodun", "B.I.T.D. - Your password reset code")
    heading = t("Şifre sıfırlama", "Password reset")
    hello = t(f"Merhaba {username},", f"Hi {username},")
    request = t(
        "Şifreni sıfırlamak için bir talep aldık. Tek kullanımlık kodun:",
        "We received a request to reset your password. Your one-time code is:",
    )
    validity = t("Kod 15 dakika boyunca geçerli.", "The code is valid for 15 minutes.")
    ignore = t(
        "Bu talebi sen yapmadıysan bu e-postayı yok sayabilirsin; şifren değişmeyecek.",
        "If you didn't request this, you can ignore this email — your password won't change.",
    )

    code_block = (
        f'<table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin:6px 0 20px;">'
        f'<tr><td bgcolor="{_INK}" style="background:{_INK};border:1px solid {_RULE};border-radius:12px;padding:14px 22px;">'
        f'<span style="font-family:\'SF Mono\',Menlo,Consolas,monospace;font-size:32px;font-weight:700;'
        f'letter-spacing:10px;color:{_AMBER};">{escape(code)}</span>'
        f"</td></tr></table>"
    )
    body = (
        _paragraph(escape(hello))
        + _paragraph(escape(request))
        + code_block
        + _paragraph(escape(validity))
        + _paragraph(escape(ignore), muted=True)
    )
    html = _render(subject, f"{request} {code}", heading, body)
    text = f"{hello}\n\n{request}\n\n    {code}\n\n{validity}\n\n{ignore}\n\n— B.I.T.D.\nhttps://yusa.app/bitd/\n"
    return send_email(_compose(to_email, subject, html, text))


def compose_account_deleted_email(to_email: str, username: str) -> MIMEMultipart:
    """Built inside the request (so it picks up the request's language), sent afterwards."""
    subject = t("B.I.T.D. - Hesabın silindi", "B.I.T.D. - Your account has been deleted")
    heading = t("Hesabın silindi", "Your account is deleted")
    hello = t(f"Merhaba {username},", f"Hi {username},")
    done = t(
        "B.I.T.D. hesabın ve kütüphanendeki tüm oyun, film, dizi ve kitap kayıtların — notların ve tarihlerinle "
        "birlikte — kalıcı olarak silindi. Bu işlem geri alınamaz.",
        "Your B.I.T.D. account and every game, movie, show and book in your library — along with your notes and "
        "dates — have been permanently deleted. This can't be undone.",
    )
    thanks = t(
        "Bu zamana kadar arşivini bizimle tuttuğun için teşekkürler. İstersen aynı e-postayla her zaman yeniden "
        "kayıt olabilirsin.",
        "Thanks for keeping your archive with us. You're always welcome to sign up again with the same email.",
    )
    not_you = t(
        "Bu işlemi sen yapmadıysan lütfen hemen yusa.app üzerinden bize ulaş.",
        "If you didn't do this, please contact us right away via yusa.app.",
    )
    body = (
        _paragraph(escape(hello))
        + _paragraph(escape(done))
        + _paragraph(escape(thanks))
        + _paragraph(escape(not_you), muted=True)
    )
    html = _render(subject, done, heading, body)
    text = f"{hello}\n\n{done}\n\n{thanks}\n\n{not_you}\n\n— B.I.T.D.\nhttps://yusa.app/bitd/\n"
    return _compose(to_email, subject, html, text)
