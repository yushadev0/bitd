import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { authApi } from "../api/auth";
import { ApiError } from "../api/client";

type Step = "login" | "forgot-email" | "forgot-code" | "forgot-password";

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

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 px-4 dark:bg-slate-950">
      <div className="card w-full max-w-sm p-6">
        <h1 className="mb-1 text-xl font-bold">B.I.T.D.</h1>
        <p className="mb-6 text-sm text-slate-500 dark:text-slate-400">Back In The Day — kişisel arşivin</p>

        {error && <div className="mb-4 rounded-lg bg-rose-50 px-3 py-2 text-sm text-rose-600 dark:bg-rose-950 dark:text-rose-300">{error}</div>}
        {info && <div className="mb-4 rounded-lg bg-emerald-50 px-3 py-2 text-sm text-emerald-600 dark:bg-emerald-950 dark:text-emerald-300">{info}</div>}

        {step === "login" && (
          <form onSubmit={handleLogin} className="flex flex-col gap-4">
            <div>
              <label className="label">Kullanıcı Adı</label>
              <input className="input" value={username} onChange={(e) => setUsername(e.target.value)} required />
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
            <label className="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-300">
              <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} />
              Beni hatırla
            </label>
            <button className="btn-primary" type="submit" disabled={busy}>
              Giriş Yap
            </button>
            <button
              type="button"
              className="text-sm text-brand-600 hover:underline"
              onClick={() => {
                setError(null);
                setInfo(null);
                setStep("forgot-email");
              }}
            >
              Şifremi unuttum
            </button>
            <div className="text-center text-sm text-slate-500 dark:text-slate-400">
              Hesabın yok mu? <Link to="/kayit" className="text-brand-600 hover:underline">Kayıt ol</Link>
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
              />
            </div>
            <button className="btn-primary" type="submit" disabled={busy}>
              Kod Gönder
            </button>
            <button type="button" className="text-sm text-slate-500 hover:underline" onClick={() => setStep("login")}>
              Girişe dön
            </button>
          </form>
        )}

        {step === "forgot-code" && (
          <form onSubmit={handleVerifyCode} className="flex flex-col gap-4">
            <div>
              <label className="label">Doğrulama Kodu</label>
              <input className="input" value={resetCode} onChange={(e) => setResetCode(e.target.value)} required />
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
              />
            </div>
            <button className="btn-primary" type="submit" disabled={busy}>
              Şifreyi Güncelle
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
