import { useState } from "react";
import { useAuth } from "../context/AuthContext";
import { accountApi } from "../api/account";
import { authApi } from "../api/auth";
import { ApiError } from "../api/client";
import { useToast } from "../context/ToastContext";

export default function AccountPage() {
  const { user, setUser, logout } = useAuth();
  const toast = useToast();
  const [username, setUsername] = useState(user?.kullanici_adi ?? "");
  const [email, setEmail] = useState(user?.email ?? "");
  const [profileMsg, setProfileMsg] = useState<string | null>(null);
  const [profileErr, setProfileErr] = useState<string | null>(null);

  const [pwStep, setPwStep] = useState<"idle" | "code" | "new-password">("idle");
  const [pwCode, setPwCode] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [pwMsg, setPwMsg] = useState<string | null>(null);
  const [pwErr, setPwErr] = useState<string | null>(null);

  async function handleProfileSubmit(e: React.FormEvent) {
    e.preventDefault();
    setProfileErr(null);
    setProfileMsg(null);
    try {
      const updated = await accountApi.update({ kullanici_adi: username, email });
      setUser(updated);
      setProfileMsg("Profil güncellendi.");
      toast.show("Profil güncellendi.");
    } catch (err) {
      setProfileErr(err instanceof ApiError ? err.message : "Güncellenemedi.");
    }
  }

  async function handleSendCode() {
    setPwErr(null);
    setPwMsg(null);
    if (!user) return;
    try {
      await authApi.sendResetCode(user.email);
      setPwMsg("Doğrulama kodu e-postana gönderildi.");
      setPwStep("code");
    } catch (err) {
      setPwErr(err instanceof ApiError ? err.message : "Kod gönderilemedi.");
    }
  }

  async function handleVerifyCode(e: React.FormEvent) {
    e.preventDefault();
    setPwErr(null);
    if (!user) return;
    try {
      await authApi.verifyResetCode(user.email, pwCode);
      setPwStep("new-password");
    } catch (err) {
      setPwErr(err instanceof ApiError ? err.message : "Kod doğrulanamadı.");
    }
  }

  async function handleResetPassword(e: React.FormEvent) {
    e.preventDefault();
    setPwErr(null);
    if (!user) return;
    try {
      await authApi.resetPassword(user.email, pwCode, newPassword);
      setPwMsg("Şifren güncellendi.");
      toast.show("Şifren güncellendi.");
      setPwStep("idle");
      setPwCode("");
      setNewPassword("");
    } catch (err) {
      setPwErr(err instanceof ApiError ? err.message : "Şifre güncellenemedi.");
    }
  }

  return (
    <div className="mx-auto flex max-w-lg flex-col gap-6">
      <h1 className="font-display text-4xl text-ink-900 dark:text-ink-50">Hesabım</h1>

      <section className="card p-5">
        <h2 className="mb-4 font-semibold text-ink-800 dark:text-ink-100">Profil Bilgileri</h2>
        {profileErr && <p className="mb-3 text-sm text-stub-500">{profileErr}</p>}
        {profileMsg && <p className="mb-3 text-sm text-ticket-600 dark:text-ticket-400">{profileMsg}</p>}
        <form onSubmit={handleProfileSubmit} className="flex flex-col gap-4">
          <div>
            <label className="label">Kullanıcı Adı</label>
            <input className="input" value={username} onChange={(e) => setUsername(e.target.value)} required />
          </div>
          <div>
            <label className="label">E-posta</label>
            <input className="input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          </div>
          <button className="btn-primary self-start" type="submit">
            Kaydet
          </button>
        </form>
      </section>

      <section className="card p-5">
        <h2 className="mb-4 font-semibold text-ink-800 dark:text-ink-100">Şifre Değiştir</h2>
        {pwErr && <p className="mb-3 text-sm text-stub-500">{pwErr}</p>}
        {pwMsg && <p className="mb-3 text-sm text-ticket-600 dark:text-ticket-400">{pwMsg}</p>}

        {pwStep === "idle" && (
          <button className="btn-secondary" onClick={handleSendCode}>
            E-postama doğrulama kodu gönder
          </button>
        )}

        {pwStep === "code" && (
          <form onSubmit={handleVerifyCode} className="flex flex-col gap-4">
            <div>
              <label className="label">Doğrulama Kodu</label>
              <input
                className="input tracking-[0.3em]"
                value={pwCode}
                onChange={(e) => setPwCode(e.target.value)}
                required
                autoFocus
              />
            </div>
            <button className="btn-primary self-start" type="submit">
              Kodu Doğrula
            </button>
          </form>
        )}

        {pwStep === "new-password" && (
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
            <button className="btn-primary self-start" type="submit">
              Şifreyi Güncelle
            </button>
          </form>
        )}
      </section>

      <button className="btn-danger self-start sm:hidden" onClick={logout}>
        Çıkış Yap
      </button>
    </div>
  );
}
