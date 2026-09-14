import { api } from "./client";
import type { Category, LibraryItem, SearchResult } from "./types";

const BASE_PATH: Record<Category, string> = {
  games: "/api/games",
  movies: "/api/movies",
  tv: "/api/tv",
  books: "/api/books",
};

export function libraryApi(category: Category) {
  const base = BASE_PATH[category];
  return {
    search: (q: string) => api.get<SearchResult[]>(`${base}/search?q=${encodeURIComponent(q)}`),
    list: () => api.get<LibraryItem[]>(base),
    random: () => api.get<LibraryItem>(`${base}/random`),
    add: (apiId: string, istekMi: boolean) =>
      api.post<{ ok: boolean }>(base, { api_id: apiId, istek_mi: istekMi }),
    updateStatus: (apiId: string, istekMi: boolean) =>
      api.patch<{ ok: boolean }>(`${base}/${encodeURIComponent(apiId)}/status`, { istek_mi: istekMi }),
    updateDate: (apiId: string, date: string) =>
      api.patch<{ ok: boolean }>(`${base}/${encodeURIComponent(apiId)}/date`, { bitirme_tarihi: date }),
    updateNote: (apiId: string, note: string) =>
      api.patch<{ ok: boolean }>(`${base}/${encodeURIComponent(apiId)}/note`, { kisisel_not: note }),
    remove: (apiId: string) => api.delete<{ ok: boolean }>(`${base}/${encodeURIComponent(apiId)}`),
  };
}
