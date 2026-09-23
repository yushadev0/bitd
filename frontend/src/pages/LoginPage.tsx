import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { authApi } from "../api/auth";
import { ApiError } from "../api/client";
import AuthShell from "../components/AuthShell";

type Step = "login" | "forgot-email" | "forgot-code" | "forgot-password";

const STEP_COPY: Record<Step, { title: string; subtitle: string }> = {
  login: { title: "Giriş yap", subtitle: "Rafına geri dön." },
  "forgot-email": { title: "Şifreni sıfırla", subtitle: "E-postana bir kod gönderelim." },
  "forgot-code": { title: "Kodu doğrula", subtitle: "Hesabın varsa e-postana 6 haneli bir kod gönderdik." },
  "forgot-password": { title: "Yeni şifre", subtitle: "Son adım — yeni şifreni belirle." },
};

export default function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();

  const [step, setStep] = useState<Step>("login");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [info, setInfo] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const [resetEmail, setResetEmail] = useState("");
  const [resetCode, setResetCode] = useState("");
  const [newPassword, setNewPassword] = useState("");

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setBusy(true);
    try {
      await login(username, password, remember);
      navigate("/");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Giriş yapılamadı.");
    } finally {
      setBusy(false);
    }
  }

  async function handleSendCode(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setBusy(true);
    try {
      await authApi.sendResetCode(resetEmail);
      setInfo("Doğrulama kodu e-postana gönderildi.");
      setStep("forgot-code");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Kod gönderilemedi.");
    } finally {
      setBusy(false);
    }
  }

  async function handleVerifyCode(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setBusy(true);
    try {
      await authApi.verifyResetCode(resetEmail, resetCode);
      setStep("forgot-password");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Kod doğrulanamadı.");
    } finally {
      setBusy(false);
    }
  }

  async function handleResetPassword(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setBusy(true);
    try {
      await authApi.resetPassword(resetEmail, resetCode, newPassword);
      setInfo("Şifren güncellendi. Şimdi giriş yapabilirsin.");
      setStep("login");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Şifre güncellenemedi.");
    } finally {
      setBusy(false);
    }
  }

  const copy = STEP_COPY[step];

  return (
    <AuthShell>
      <h1 className="font-display text-3xl text-ink-900 dark:text-ink-50">{copy.title}</h1>
      <p className="mb-6 mt-1 text-sm text-ink-500 dark:text-ink-400">{copy.subtitle}</p>

      {error && (
        <div className="mb-4 rounded-xl border border-stub-500/20 bg-stub-500/10 px-3.5 py-2.5 text-sm text-stub-600 dark:text-stub-400">
          {error}
        </div>
      )}
      {info && (
        <div className="mb-4 rounded-xl border border-ticket-500/20 bg-ticket-500/10 px-3.5 py-2.5 text-sm text-ticket-600 dark:text-ticket-400">
          {info}
        </div>
      )}

      {step === "login" && (
        <form onSubmit={handleLogin} className="flex flex-col gap-4">
          <div>
            <label className="label">Kullanıcı Adı</label>
            <input className="input" value={username} onChange={(e) => setUsername(e.target.value)} required autoFocus />
          </div>
          <div>
            <label className="label">Şifre</label>
            <input
              className="input"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <label className="flex items-center gap-2 text-sm text-ink-600 dark:text-ink-300">
            <input
              type="checkbox"
              className="h-4 w-4 rounded border-ink-300 text-marquee-500 focus:ring-marquee-400"
              checked={remember}
              onChange={(e) => setRemember(e.target.checked)}
            />
            Beni hatırla
          </label>
          <button className="btn-primary mt-1" type="submit" disabled={busy}>
            Giriş Yap
          </button>
          <button
            type="button"
            className="text-sm font-medium text-marquee-600 hover:underline dark:text-marquee-400"
            onClick={() => {
              setError(null);
              setInfo(null);
              setStep("forgot-email");
            }}
          >
            Şifremi unuttum
          </button>
          <div className="text-center text-sm text-ink-500 dark:text-ink-400">
            Hesabın yok mu?{" "}
            <Link to="/kayit" className="font-medium text-marquee-600 hover:underline dark:text-marquee-400">
              Kayıt ol
            </Link>
          </div>
        </form>
      )}

      {step === "forgot-email" && (
        <form onSubmit={handleSendCode} className="flex flex-col gap-4">
          <div>
            <label className="label">E-posta</label>
            <input
              className="input"
              type="email"
              value={resetEmail}
              onChange={(e) => setResetEmail(e.target.value)}
              required
              autoFocus
            />
          </div>
          <button className="btn-primary" type="submit" disabled={busy}>
            Kod Gönder
          </button>
          <button type="button" className="text-sm text-ink-500 hover:underline" onClick={() => setStep("login")}>
            Girişe dön
          </button>
        </form>
      )}

      {step === "forgot-code" && (
        <form onSubmit={handleVerifyCode} className="flex flex-col gap-4">
          <div>
            <label className="label">Doğrulama Kodu</label>
            <input
              className="input tracking-[0.3em]"
              value={resetCode}
              onChange={(e) => setResetCode(e.target.value)}
              required
              autoFocus
            />
          </div>
          <button className="btn-primary" type="submit" disabled={busy}>
            Kodu Doğrula
          </button>
        </form>
      )}

      {step === "forgot-password" && (
        <form onSubmit={handleResetPassword} className="flex flex-col gap-4">
          <div>
            <label className="label">Yeni Şifre</label>
            <input
              className="input"
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              required
              minLength={6}
              autoFocus
            />
          </div>
          <button className="btn-primary" type="submit" disabled={busy}>
            Şifreyi Güncelle
          </button>
        </form>
      )}
    </AuthShell>
  );
}
