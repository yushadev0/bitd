import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from app.config import get_settings

settings = get_settings()

_HTML_TEMPLATE = """\
<html><head><meta charset="UTF-8"></head><body style="margin:0;padding:0;">
<div style="background-color:#0f172a;padding:40px;font-family:'Courier New',monospace;
color:#ffffff;text-align:center;border:2px solid #38bdf8;border-radius:10px;
max-width:500px;margin:0 auto;">
  <h1 style="color:#38bdf8;margin-bottom:5px;">B.I.T.D. - Erişim Talebi</h1>
  <div style="border-bottom:1px dashed #f472b6;margin-bottom:20px;width:50%;
  margin-left:auto;margin-right:auto;"></div>
  <p style="font-size:14px;color:#cbd5e1;line-height:1.6;">
    Merhaba <span style="color:#f472b6;">{username}</span>,<br>
    Şifreni sıfırlamak için bir talep aldık.<br>
    Tek kullanımlık doğrulama kodun aşağıdadır:
  </p>
  <div style="background-color:rgba(56,189,248,0.1);border:2px solid #f472b6;
  padding:15px;margin:30px auto;width:150px;font-size:32px;font-weight:bold;
  color:#f472b6;letter-spacing:5px;">{code}</div>
  <p style="font-size:12px;color:rgba(255,255,255,0.5);margin-top:30px;">
    Bu kod 15 dakika boyunca geçerlidir.<br>
    Bu talebi sen yapmadıysan bu e-postayı yok sayabilirsin.
  </p>
</div></body></html>
"""


def send_otp_email(to_email: str, username: str, code: str) -> tuple[bool, str]:
    if not settings.smtp_username or not settings.smtp_password:
        return False, "SMTP is not configured on the server."

    message = MIMEMultipart("alternative")
    message["Subject"] = "B.I.T.D. - Güvenlik Kodun"
    message["From"] = f"{settings.smtp_from_name} <{settings.smtp_username}>"
    message["To"] = to_email

    html_body = _HTML_TEMPLATE.format(username=username, code=code)
    message.attach(MIMEText(html_body, "html", "utf-8"))

    try:
        with smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=15) as server:
            server.starttls()
            server.login(settings.smtp_username, settings.smtp_password)
            server.sendmail(settings.smtp_username, [to_email], message.as_string())
        return True, ""
    except Exception as exc:  # noqa: BLE001 - surface the reason to the caller
        return False, str(exc)
