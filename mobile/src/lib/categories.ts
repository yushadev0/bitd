import type { SFSymbol } from 'sf-symbols-typescript';

import type { Category, DashboardResponse } from '@/api/types';
import { t, type CategoryStrings } from '@/lib/i18n';

export interface CategoryMeta extends CategoryStrings {
  icon: SFSymbol;
  iconSelected: SFSymbol;
  statsKey: keyof DashboardResponse;
}

export const CATEGORIES: Record<Category, CategoryMeta> = {
  games: {
    ...t.categories.games,
    icon: 'gamecontroller',
    iconSelected: 'gamecontroller.fill',
    statsKey: 'oyunlar',
  },
  movies: {
    ...t.categories.movies,
    icon: 'film',
    iconSelected: 'film.fill',
    statsKey: 'filmler',
  },
  tv: {
    ...t.categories.tv,
    icon: 'tv',
    iconSelected: 'tv.fill',
    statsKey: 'diziler',
  },
  books: {
    ...t.categories.books,
    icon: 'book.closed',
    iconSelected: 'book.closed.fill',
    statsKey: 'kitaplar',
  },
};

export const CATEGORY_ORDER: Category[] = ['games', 'movies', 'tv', 'books'];
