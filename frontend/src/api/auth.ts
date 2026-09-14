import { api } from "./client";
import type { CurrentUser } from "./types";

export const authApi = {
  register: (data: { kullanici_adi: string; email: string; sifre: string; sifre_tekrar: string }) =>
    api.post<CurrentUser>("/api/auth/register", data),

  login: (data: { kullanici_adi: string; sifre: string; beni_hatirla: boolean }) =>
    api.post<CurrentUser>("/api/auth/login", data),

  logout: () => api.post<{ ok: boolean }>("/api/auth/logout"),

  me: () => api.get<CurrentUser>("/api/auth/me"),

  rememberLogin: () => api.post<CurrentUser>("/api/auth/remember-login"),

  sendResetCode: (email: string) => api.post<{ ok: boolean }>("/api/auth/forgot-password/send-code", { email }),

  verifyResetCode: (email: string, kod: string) =>
    api.post<{ ok: boolean }>("/api/auth/forgot-password/verify", { email, kod }),

  resetPassword: (email: string, kod: string, yeni_sifre: string) =>
    api.post<{ ok: boolean }>("/api/auth/forgot-password/reset", { email, kod, yeni_sifre }),
};
