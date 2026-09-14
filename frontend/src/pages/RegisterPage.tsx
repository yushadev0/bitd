import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { ApiError } from "../api/client";
import AuthShell from "../components/AuthShell";

export default function RegisterPage() {
  const { register } = useAuth();
  const navigate = useNavigate();

  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [passwordConfirm, setPasswordConfirm] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    if (password !== passwordConfirm) {
      setError("Şifreler eşleşmiyor.");
      return;
    }

    setBusy(true);
    try {
      await register(username, email, password, passwordConfirm);
      navigate("/giris");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Kayıt oluşturulamadı.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <AuthShell>
      <h1 className="font-display text-3xl text-ink-900 dark:text-ink-50">Kayıt ol</h1>
      <p className="mb-6 mt-1 text-sm text-ink-500 dark:text-ink-400">Rafını bugün kurmaya başla.</p>

      {error && (
        <div className="mb-4 rounded-xl border border-stub-500/20 bg-stub-500/10 px-3.5 py-2.5 text-sm text-stub-600 dark:text-stub-400">
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <div>
          <label className="label">Kullanıcı Adı</label>
          <input
            className="input"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            required
            minLength={3}
            autoFocus
          />
        </div>
        <div>
          <label className="label">E-posta</label>
          <input className="input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        </div>
        <div>
          <label className="label">Şifre</label>
          <input
            className="input"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            minLength={6}
          />
        </div>
        <div>
          <label className="label">Şifre (Tekrar)</label>
          <input
            className="input"
            type="password"
            value={passwordConfirm}
            onChange={(e) => setPasswordConfirm(e.target.value)}
            required
            minLength={6}
          />
        </div>
        <button className="btn-primary mt-1" type="submit" disabled={busy}>
          Kayıt Ol
        </button>
        <div className="text-center text-sm text-ink-500 dark:text-ink-400">
          Zaten hesabın var mı?{" "}
          <Link to="/giris" className="font-medium text-marquee-600 hover:underline dark:text-marquee-400">
            Giriş yap
          </Link>
        </div>
      </form>
    </AuthShell>
  );
}
