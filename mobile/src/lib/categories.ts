import type { SFSymbol } from 'sf-symbols-typescript';

import type { Category, DashboardResponse } from '@/api/types';

export interface CategoryMeta {
  title: string; // tab label
  screenTitle: string; // large navigation title
  completedLabel: string;
  wishlistLabel: string;
  icon: SFSymbol;
  iconSelected: SFSymbol;
  statsKey: keyof DashboardResponse;
}

export const CATEGORIES: Record<Category, CategoryMeta> = {
  games: {
    title: 'Oyunlar',
    screenTitle: 'Oyunlarım',
    completedLabel: 'Tamamlananlar',
    wishlistLabel: 'İstek Listesi',
    icon: 'gamecontroller',
    iconSelected: 'gamecontroller.fill',
    statsKey: 'oyunlar',
  },
  movies: {
    title: 'Filmler',
    screenTitle: 'Filmlerim',
    completedLabel: 'İzlenenler',
    wishlistLabel: 'İzleme Listesi',
    icon: 'film',
    iconSelected: 'film.fill',
    statsKey: 'filmler',
  },
  tv: {
    title: 'Diziler',
    screenTitle: 'Dizilerim',
    completedLabel: 'İzlenenler',
    wishlistLabel: 'İzleme Listesi',
    icon: 'tv',
    iconSelected: 'tv.fill',
    statsKey: 'diziler',
  },
  books: {
    title: 'Kitaplar',
    screenTitle: 'Kitaplarım',
    completedLabel: 'Okunanlar',
    wishlistLabel: 'Okuma Listesi',
    icon: 'book.closed',
    iconSelected: 'book.closed.fill',
    statsKey: 'kitaplar',
  },
};

export const CATEGORY_ORDER: Category[] = ['games', 'movies', 'tv', 'books'];
