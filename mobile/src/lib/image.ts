import { API_ORIGIN } from '@/api/client';

// TMDB posters come back as path-relative image-proxy URLs ("/bitd/api/image-proxy?src=…");
// everything else (IGDB, Google Books, placehold.co) is already absolute.
export function posterUri(poster: string | null | undefined): string | undefined {
  if (!poster) return undefined;
  return poster.startsWith('/') ? `${API_ORIGIN}${poster}` : poster;
}
