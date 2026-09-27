import { useSyncExternalStore } from 'react';

import { catalogApi } from '@/api/endpoints';
import type { Category, ItemDetail, LibraryItem, SearchResult } from '@/api/types';
import {
  deleteItem,
  getDb,
  itemsNeedingDetail,
  markPending,
  readAllItems,
  writeDetail,
  writeItem,
} from '@/lib/db';
import { locale } from '@/lib/i18n';

// The library as the screens see it: an in-memory mirror of the SQLite tables, shared by
// the grid, the detail screen, the add sheet, the dashboard and the random picker.
// Every change lands here and on disk right away, online or not; lib/sync.ts carries it
// to the server afterwards when there's an account.

interface LibraryState {
  items: LibraryItem[] | null;
  error: string | null;
}

const EMPTY: LibraryState = { items: null, error: null };

let states: Record<Category, LibraryState> = { games: EMPTY, movies: EMPTY, tv: EMPTY, books: EMPTY };
const listeners = new Set<() => void>();

// Bumped on every local change, so the daily suggestion can reschedule.
let version = 0;

// With an account, every change is also queued for upload (see lib/sync.ts).
let trackChanges = false;
const changeListeners = new Set<() => void>();

function emit() {
  listeners.forEach((l) => l());
}

function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

function setItems(category: Category, items: LibraryItem[]) {
  states = { ...states, [category]: { items, error: null } };
}

function updateItems(category: Category, update: (items: LibraryItem[]) => LibraryItem[]) {
  const current = states[category].items;
  if (current) setItems(category, update(current));
}

export function useLibrary(category: Category) {
  return useSyncExternalStore(subscribe, () => states[category]);
}

/** All four categories at once (the dashboard). */
export function useLibraries() {
  return useSyncExternalStore(subscribe, () => states);
}

export function useLibraryItem(category: Category, apiId: string) {
  return useSyncExternalStore(subscribe, () => states[category].items?.find((i) => i.api_id === apiId));
}

export function useLibraryVersion() {
  return useSyncExternalStore(subscribe, () => version);
}

export function getLibraryItems(category: Category): LibraryItem[] {
  return states[category].items ?? [];
}

export function setChangeTracking(on: boolean) {
  trackChanges = on;
}

/** Called after every local change once it's on disk. */
export function onLocalChange(listener: () => void) {
  changeListeners.add(listener);
  return () => changeListeners.delete(listener);
}

async function readIntoMemory() {
  const all = await readAllItems();
  states = {
    games: { items: all.games, error: null },
    movies: { items: all.movies, error: null },
    tv: { items: all.tv, error: null },
    books: { items: all.books, error: null },
  };
  emit();
}

// Reads run one after another, so a reload always sees what was written before it was asked for.
let reloads: Promise<void> = Promise.resolve();

/** Re-reads the whole library from disk (at launch, and after a sync pulled server changes). */
export function reloadLibrary(): Promise<void> {
  const next = reloads.then(readIntoMemory, readIntoMemory);
  reloads = next.catch(() => {});
  return next;
}

/** Loads the library from disk if it isn't in memory yet. */
export function loadLibrary(): Promise<void> {
  return states.games.items ? Promise.resolve() : reloadLibrary();
}

/**
 * Applies a change in memory, then writes it to disk (queued for upload with an account);
 * rolls back if the write fails. The cached detail on disk is left alone unless
 * `newDetail` is given (a freshly added item's search-result basics).
 */
async function mutate(
  category: Category,
  apiId: string,
  update: (items: LibraryItem[]) => LibraryItem[],
  newDetail?: ItemDetail,
) {
  await loadLibrary();
  const before = states[category].items;
  updateItems(category, update);
  emit();

  const item = states[category].items?.find((i) => i.api_id === apiId);
  try {
    const db = await getDb();
    await db.withExclusiveTransactionAsync(async (txn) => {
      if (item) await writeItem(txn, category, { ...item, detail: newDetail ?? null });
      else await deleteItem(txn, category, apiId);
      if (trackChanges) await markPending(txn, category, apiId);
    });
  } catch (e) {
    if (before) setItems(category, before);
    emit();
    throw e;
  }

  version += 1;
  emit();
  changeListeners.forEach((l) => l());
}

function patchItem(category: Category, apiId: string, patch: Partial<LibraryItem>) {
  return mutate(category, apiId, (items) => items.map((i) => (i.api_id === apiId ? { ...i, ...patch } : i)));
}

function today() {
  return toISODate(new Date());
}

export function toISODate(d: Date) {
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

export const libraryActions = {
  setStatus: (category: Category, apiId: string, istekMi: boolean) =>
    // Moving an item to "completed" stamps today's date, as the web app does.
    patchItem(category, apiId, istekMi ? { istek_mi: true } : { istek_mi: false, bitirme_tarihi: today() }),

  setDate: (category: Category, apiId: string, date: Date) =>
    patchItem(category, apiId, { bitirme_tarihi: toISODate(date) }),

  setNote: (category: Category, apiId: string, note: string) => patchItem(category, apiId, { kisisel_not: note }),

  remove: (category: Category, apiId: string) =>
    mutate(category, apiId, (items) => items.filter((i) => i.api_id !== apiId)),

  add: async (category: Category, result: SearchResult, istekMi: boolean) => {
    await loadLibrary();
    if (getLibraryItems(category).some((i) => i.api_id === result.api_id)) return;

    // Show it right away with what the search already told us; the rest follows.
    const detail: ItemDetail = {
      title: result.title,
      poster: result.poster,
      score: null, // search scores use a different scale than detail scores
      year: result.year,
      genres: result.genres,
      summary: '',
    };
    const item: LibraryItem = {
      api_id: result.api_id,
      istek_mi: istekMi,
      eklenme_tarihi: new Date().toISOString(),
      bitirme_tarihi: istekMi ? null : today(),
      kisisel_not: null,
      detail,
    };
    // Written without a language, which marks it as still needing the full detail.
    await mutate(category, result.api_id, (items) => [item, ...items], detail);
    fetchMissingDetails().catch(() => {});
  },
};

const DETAIL_BATCH = 20;
let fetchingDetails: Promise<void> | null = null;

async function fetchDetailsOnce() {
  const missing = await itemsNeedingDetail(locale);
  const byCategory = new Map<Category, string[]>();
  for (const { category, api_id } of missing) {
    byCategory.set(category, [...(byCategory.get(category) ?? []), api_id]);
  }

  for (const [category, ids] of byCategory) {
    for (let i = 0; i < ids.length; i += DETAIL_BATCH) {
      // Offline or the server is down: stop here, the next sync or launch picks it up again.
      const details = await catalogApi.details(category, ids.slice(i, i + DETAIL_BATCH));
      for (const [apiId, detail] of Object.entries(details)) {
        await writeDetail(category, apiId, detail, locale);
        updateItems(category, (items) => items.map((it) => (it.api_id === apiId ? { ...it, detail } : it)));
      }
      emit();
    }
  }
}

/**
 * Fills in titles, posters and summaries for items that don't have them cached yet (just
 * added, pulled from the server, or cached in the other language). Throws when offline.
 */
export function fetchMissingDetails(): Promise<void> {
  fetchingDetails ??= fetchDetailsOnce().finally(() => {
    fetchingDetails = null;
  });
  return fetchingDetails;
}
