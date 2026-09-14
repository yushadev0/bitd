import { api } from "./client";
import type { Category, DashboardResponse, RecentItem } from "./types";

const RECENT_PATH: Record<Category, string> = {
  games: "/api/dashboard/recent/games",
  movies: "/api/dashboard/recent/movies",
  tv: "/api/dashboard/recent/tv",
  books: "/api/dashboard/recent/books",
};

export const dashboardApi = {
  stats: () => api.get<DashboardResponse>("/api/dashboard"),
  recent: (category: Category) => api.get<RecentItem[]>(RECENT_PATH[category]),
};
