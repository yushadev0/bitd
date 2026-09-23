import { useSyncExternalStore } from 'react';

import { libraryApi } from '@/api/endpoints';
import type { Category, LibraryItem } from '@/api/types';

// One shared cache per category, so the grid, the detail screen, the add sheet and
// the random picker all read and update the same items without refetching.

interface LibraryState {
  items: LibraryItem[] | null;
  error: string | null;
}

const EMPTY: LibraryState = { items: null, error: null };

const states: Record<Category, LibraryState> = { games: EMPTY, movies: EMPTY, tv: EMPTY, books: EMPTY };
const inFlight: Partial<Record<Category, Promise<void>>> = {};
const listeners = new Set<() => void>();

// Bumped on every mutation so screens that only show aggregates (the dashboard) know to refresh.
let version = 0;

function emit() {
  listeners.forEach((l) => l());
}

function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

function setState(category: Category, next: Partial<LibraryState>) {
  states[category] = { ...states[category], ...next };
  emit();
}

function setItems(category: Category, update: (items: LibraryItem[]) => LibraryItem[]) {
  const current = states[category].items;
  if (current) setState(category, { items: update(current) });
}

function touched() {
  version += 1;
  emit();
}

export function useLibrary(category: Category) {
  return useSyncExternalStore(subscribe, () => states[category]);
}

export function useLibraryItem(category: Category, apiId: string) {
  return useSyncExternalStore(subscribe, () => states[category].items?.find((i) => i.api_id === apiId));
}

export function useLibraryVersion() {
  return useSyncExternalStore(subscribe, () => version);
}

export function loadLibrary(category: Category): Promise<void> {
  inFlight[category] ??= libraryApi(category)
    .list()
    .then((items) => setState(category, { items, error: null }))
    .catch((e: unknown) => setState(category, { error: e instanceof Error ? e.message : 'Liste yüklenemedi.' }))
    .finally(() => {
      delete inFlight[category];
    });
  return inFlight[category];
}

/** Inserts or replaces an item fetched elsewhere (e.g. the random picker). */
export function upsertItem(category: Category, item: LibraryItem) {
  setItems(category, (items) =>
    items.some((i) => i.api_id === item.api_id)
      ? items.map((i) => (i.api_id === item.api_id ? item : i))
      : [item, ...items],
  );
}

/** Applies a local change immediately, then persists it; rolls back if the request fails. */
async function optimistic(
  category: Category,
  apiId: string,
  patch: Partial<LibraryItem>,
  request: () => Promise<unknown>,
) {
  const before = states[category].items;
  setItems(category, (items) => items.map((i) => (i.api_id === apiId ? { ...i, ...patch } : i)));
  try {
    await request();
    touched();
  } catch (e) {
    setState(category, { items: before });
    throw e;
  }
}

function today() {
  const d = new Date();
  return toISODate(d);
}

export function toISODate(d: Date) {
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

export const libraryActions = {
  setStatus: (category: Category, apiId: string, istekMi: boolean) =>
    // The backend stamps today's date when an item moves to "completed".
    optimistic(category, apiId, istekMi ? { istek_mi: true } : { istek_mi: false, bitirme_tarihi: today() }, () =>
      libraryApi(category).updateStatus(apiId, istekMi),
    ),

  setDate: (category: Category, apiId: string, date: Date) =>
    optimistic(category, apiId, { bitirme_tarihi: toISODate(date) }, () =>
      libraryApi(category).updateDate(apiId, toISODate(date)),
    ),

  setNote: (category: Category, apiId: string, note: string) =>
    optimistic(category, apiId, { kisisel_not: note }, () => libraryApi(category).updateNote(apiId, note)),

  remove: async (category: Category, apiId: string) => {
    await libraryApi(category).remove(apiId);
    setItems(category, (items) => items.filter((i) => i.api_id !== apiId));
    touched();
  },

  add: async (category: Category, apiId: string, istekMi: boolean) => {
    await libraryApi(category).add(apiId, istekMi);
    touched();
    // The list endpoint is what resolves titles/posters, so pull it again in the background.
    loadLibrary(category);
  },
};
