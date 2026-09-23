import { api } from './client';
import type {
  Category,
  CurrentUser,
  DashboardResponse,
  LibraryItem,
  RecentItem,
  SearchResult,
  TokenResponse,
} from './types';

export const authApi = {
  token: (kullanici_adi: string, sifre: string) =>
    api.post<TokenResponse>('/api/auth/token', { kullanici_adi, sifre }),

  register: (data: { kullanici_adi: string; email: string; sifre: string; sifre_tekrar: string }) =>
    api.post<CurrentUser>('/api/auth/register', data),

  sendResetCode: (email: string) => api.post<{ ok: boolean }>('/api/auth/forgot-password/send-code', { email }),

  verifyResetCode: (email: string, kod: string) =>
    api.post<{ ok: boolean }>('/api/auth/forgot-password/verify', { email, kod }),

  resetPassword: (email: string, kod: string, yeni_sifre: string) =>
    api.post<{ ok: boolean }>('/api/auth/forgot-password/reset', { email, kod, yeni_sifre }),

  deleteAccount: () => api.delete<void>('/api/auth/me'),
};

export function libraryApi(category: Category) {
  const base = `/api/${category}`;
  const item = (apiId: string) => `${base}/${encodeURIComponent(apiId)}`;
  return {
    search: (q: string) => api.get<SearchResult[]>(`${base}/search?q=${encodeURIComponent(q)}`),
    list: () => api.get<LibraryItem[]>(base),
    random: () => api.get<LibraryItem>(`${base}/random`),
    add: (apiId: string, istekMi: boolean) => api.post<{ ok: boolean }>(base, { api_id: apiId, istek_mi: istekMi }),
    updateStatus: (apiId: string, istekMi: boolean) =>
      api.patch<{ ok: boolean }>(`${item(apiId)}/status`, { istek_mi: istekMi }),
    updateDate: (apiId: string, date: string) =>
      api.patch<{ ok: boolean }>(`${item(apiId)}/date`, { bitirme_tarihi: date }),
    updateNote: (apiId: string, note: string) =>
      api.patch<{ ok: boolean }>(`${item(apiId)}/note`, { kisisel_not: note }),
    remove: (apiId: string) => api.delete<{ ok: boolean }>(item(apiId)),
  };
}

export const dashboardApi = {
  stats: () => api.get<DashboardResponse>('/api/dashboard'),
  recent: (category: Category) => api.get<RecentItem[]>(`/api/dashboard/recent/${category}`),
};

export const accountApi = {
  get: () => api.get<CurrentUser>('/api/account'),
  update: (data: { kullanici_adi: string; email: string }) => api.patch<CurrentUser>('/api/account', data),
};
