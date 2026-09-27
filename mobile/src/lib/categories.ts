import type { SFSymbol } from 'sf-symbols-typescript';

import type { Category } from '@/api/types';
import { t, type CategoryStrings } from '@/lib/i18n';

export interface CategoryMeta extends CategoryStrings {
  icon: SFSymbol;
  iconSelected: SFSymbol;
}

export const CATEGORIES: Record<Category, CategoryMeta> = {
  games: {
    ...t.categories.games,
    icon: 'gamecontroller',
    iconSelected: 'gamecontroller.fill',
  },
  movies: {
    ...t.categories.movies,
    icon: 'film',
    iconSelected: 'film.fill',
  },
  tv: {
    ...t.categories.tv,
    icon: 'tv',
    iconSelected: 'tv.fill',
  },
  books: {
    ...t.categories.books,
    icon: 'book.closed',
    iconSelected: 'book.closed.fill',
  },
};

export const CATEGORY_ORDER: Category[] = ['games', 'movies', 'tv', 'books'];
