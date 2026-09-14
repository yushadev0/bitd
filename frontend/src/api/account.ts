import { api } from "./client";
import type { CurrentUser } from "./types";

export const accountApi = {
  get: () => api.get<CurrentUser>("/api/account"),
  update: (data: { kullanici_adi: string; email: string }) => api.patch<CurrentUser>("/api/account", data),
  updateTheme: (tema: boolean) => api.patch<CurrentUser>("/api/account/theme", { tema }),
};
