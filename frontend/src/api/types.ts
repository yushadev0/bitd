export interface CurrentUser {
  id: number;
  kullanici_adi: string;
  email: string;
  tema: boolean;
}

export interface SearchResult {
  api_id: string;
  title: string;
  poster: string;
  year: string;
  score: number | null;
  genres: string[];
}

export interface ItemDetail {
  title: string;
  poster: string;
  score: number | null;
  year: string;
  genres: string[];
  summary: string;
  // category-specific extras
  runtime_minutes?: number | null;
  director?: string;
  seasons?: number | null;
  network?: string;
  platforms?: string[];
  screenshots?: string[];
  authors?: string[];
  page_count?: number | null;
  preview_link?: string | null;
}

export interface LibraryItem {
  api_id: string;
  istek_mi: boolean;
  eklenme_tarihi: string;
  bitirme_tarihi: string | null;
  kisisel_not: string | null;
  detail: ItemDetail | null;
}

export interface DashboardStats {
  total: number;
  wishlist: number;
}

export interface DashboardResponse {
  oyunlar: DashboardStats;
  filmler: DashboardStats;
  diziler: DashboardStats;
  kitaplar: DashboardStats;
}

export interface RecentItem {
  api_id: string;
  title: string;
  poster: string;
}

export type Category = "games" | "movies" | "tv" | "books";
