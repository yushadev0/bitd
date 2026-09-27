import { api } from './client';
import type { Category, CurrentUser, ItemDetail, SearchResult, SyncItemWrite, SyncLibrary, TokenResponse } from './types';

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

// No session needed for these two: the app works without an account.
export const catalogApi = {
  search: (category: Category, q: string) =>
    api.get<SearchResult[]>(`/api/${category}/search?q=${encodeURIComponent(q)}`),

  /** Up to 20 ids per call; items that couldn't be loaded are missing from the result. */
  details: (category: Category, ids: string[]) =>
    api.get<Record<string, ItemDetail>>(`/api/details/${category}?ids=${ids.map(encodeURIComponent).join(',')}`),
};

export const syncApi = {
  library: () => api.get<SyncLibrary>('/api/library'),
  put: (category: Category, apiId: string, item: SyncItemWrite) =>
    api.put<void>(`/api/library/${category}/${encodeURIComponent(apiId)}`, item),
  remove: (category: Category, apiId: string) => api.delete<void>(`/api/library/${category}/${encodeURIComponent(apiId)}`),
};

export const accountApi = {
  get: () => api.get<CurrentUser>('/api/account'),
  update: (data: { kullanici_adi: string; email: string }) => api.patch<CurrentUser>('/api/account', data),
};
