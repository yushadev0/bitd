import * as Network from 'expo-network';
import { useSyncExternalStore } from 'react';
import { AppState } from 'react-native';

import { ApiError, NetworkError } from '@/api/client';
import { syncApi } from '@/api/endpoints';
import type { Category, SyncItem, SyncLibrary } from '@/api/types';
import { clearLibrary, deleteItem, getDb, getMeta, markPending, setMeta, writeItem } from '@/lib/db';
import { fetchMissingDetails, onLocalChange, reloadLibrary, setChangeTracking } from '@/lib/library-store';

// Keeps an account's library on the phone in step with the server.
//
// Every change is saved locally first and its item is marked in the `pending` table. A
// sync run then (1) uploads each pending item's current state — or deletes it on the
// server if it's gone locally — and (2) pulls the server's full list and applies it to
// every item that isn't pending, which brings in changes made on the web. Runs are
// triggered by local changes, the app coming to the foreground, the connection coming
// back and, after a failure, a backoff timer; one run at a time, with a follow-up run
// if something changed meanwhile.

export type SyncState =
  | 'off' // no account
  | 'syncing'
  | 'synced'
  | 'offline' // no connection; changes wait on the phone
  | 'error' // the server failed; retrying on a timer
  | 'expired'; // the session ended; changes wait until the user signs in again

interface SyncStatus {
  state: SyncState;
  pending: number;
  lastSync: Date | null;
}

let status: SyncStatus = { state: 'off', pending: 0, lastSync: null };
const listeners = new Set<() => void>();

function setStatus(patch: Partial<SyncStatus>) {
  status = { ...status, ...patch };
  listeners.forEach((l) => l());
}

export function useSyncStatus() {
  return useSyncExternalStore(
    (l) => {
      listeners.add(l);
      return () => listeners.delete(l);
    },
    () => status,
  );
}

const OWNER_KEY = 'owner'; // user id whose library is on the phone; absent for no account
const LAST_SYNC_KEY = 'last_sync';

const CHANGE_DEBOUNCE_MS = 800;
const MIN_RETRY_MS = 5_000;
const MAX_RETRY_MS = 5 * 60_000;

let userId: number | null = null;
let running: Promise<void> | null = null;
let runAgain = false;
let retryTimer: ReturnType<typeof setTimeout> | null = null;
let retryDelay = MIN_RETRY_MS;
let changeTimer: ReturnType<typeof setTimeout> | null = null;
let teardown: (() => void) | null = null;

const key = (category: string, apiId: string) => `${category}/${apiId}`;

// The server stores naive UTC timestamps; make them unambiguous for Date parsing.
function utc(timestamp: string) {
  return /[zZ]|[+-]\d\d:?\d\d$/.test(timestamp) ? timestamp : `${timestamp}Z`;
}

async function refreshPendingCount() {
  const db = await getDb();
  const row = await db.getFirstAsync<{ n: number }>('SELECT COUNT(*) AS n FROM pending');
  setStatus({ pending: row?.n ?? 0 });
}

/** Errors a retry can't fix (the item was rejected); the change is dropped rather than retried forever. */
function isPermanent(e: unknown) {
  return e instanceof ApiError && e.status >= 400 && e.status < 500 && ![401, 408, 429].includes(e.status);
}

async function push() {
  const db = await getDb();
  const queue = await db.getAllAsync<{ category: Category; api_id: string; version: number }>(
    'SELECT category, api_id, version FROM pending',
  );
  for (const change of queue) {
    const row = await db.getFirstAsync<{
      istek_mi: number;
      eklenme_tarihi: string;
      bitirme_tarihi: string | null;
      kisisel_not: string | null;
    }>(
      'SELECT istek_mi, eklenme_tarihi, bitirme_tarihi, kisisel_not FROM items WHERE category = ? AND api_id = ?',
      change.category,
      change.api_id,
    );
    try {
      if (row) {
        await syncApi.put(change.category, change.api_id, {
          istek_mi: row.istek_mi === 1,
          eklenme_tarihi: row.eklenme_tarihi,
          bitirme_tarihi: row.bitirme_tarihi,
          kisisel_not: row.kisisel_not,
        });
      } else {
        await syncApi.remove(change.category, change.api_id);
      }
    } catch (e) {
      if (!isPermanent(e)) throw e;
    }
    // If the item changed again while this was in flight, its version moved on and it stays queued.
    await db.runAsync(
      'DELETE FROM pending WHERE category = ? AND api_id = ? AND version = ?',
      change.category,
      change.api_id,
      change.version,
    );
    await refreshPendingCount();
  }
}

/** Applies the server's list to every item that has no local change waiting. */
async function applyRemote(remote: SyncLibrary) {
  const db = await getDb();
  await db.withExclusiveTransactionAsync(async (txn) => {
    const pendingRows = await txn.getAllAsync<{ category: string; api_id: string }>('SELECT category, api_id FROM pending');
    const pending = new Set(pendingRows.map((r) => key(r.category, r.api_id)));
    const remoteKeys = new Set<string>();

    for (const [category, items] of Object.entries(remote) as [Category, SyncItem[]][]) {
      for (const item of items) {
        remoteKeys.add(key(category, item.api_id));
        if (pending.has(key(category, item.api_id))) continue;
        await writeItem(txn, category, { ...item, eklenme_tarihi: utc(item.eklenme_tarihi), detail: null });
      }
    }

    const localRows = await txn.getAllAsync<{ category: Category; api_id: string }>('SELECT category, api_id FROM items');
    for (const { category, api_id } of localRows) {
      const k = key(category, api_id);
      if (!remoteKeys.has(k) && !pending.has(k)) await deleteItem(txn, category, api_id);
    }
  });
}

async function syncOnce(): Promise<boolean> {
  const network = await Network.getNetworkStateAsync().catch(() => null);
  if (network && (network.isConnected === false || network.isInternetReachable === false)) {
    setStatus({ state: 'offline' });
    return false;
  }

  setStatus({ state: 'syncing' });
  try {
    await push();
    await applyRemote(await syncApi.library());
    await reloadLibrary();
    // Details are nice to have; a failure there doesn't make the sync itself fail.
    await fetchMissingDetails().catch(() => {});

    const now = new Date();
    await setMeta(LAST_SYNC_KEY, now.toISOString());
    retryDelay = MIN_RETRY_MS;
    setStatus({ state: 'synced', lastSync: now });
    return true;
  } catch (e) {
    await refreshPendingCount().catch(() => {});
    if (e instanceof ApiError && e.status === 401) {
      setStatus({ state: 'expired' });
      return false;
    }
    setStatus({ state: e instanceof NetworkError ? 'offline' : 'error' });
    scheduleRetry();
    return false;
  }
}

function scheduleRetry() {
  if (retryTimer) clearTimeout(retryTimer);
  retryTimer = setTimeout(() => {
    retryTimer = null;
    requestSync();
  }, retryDelay);
  retryDelay = Math.min(retryDelay * 2, MAX_RETRY_MS);
}

/** Runs a sync now, or right after the one in progress. Resolves when the library is as fresh as it can get. */
export function requestSync(): Promise<void> {
  if (userId === null || status.state === 'expired') return Promise.resolve();
  if (running) {
    runAgain = true;
    return running;
  }
  running = (async () => {
    let ok = true;
    do {
      runAgain = false;
      ok = await syncOnce();
    } while (ok && runAgain && userId !== null);
  })().finally(() => {
    running = null;
  });
  return running;
}

function watch() {
  const offChange = onLocalChange(() => {
    refreshPendingCount().catch(() => {});
    if (changeTimer) clearTimeout(changeTimer);
    changeTimer = setTimeout(() => requestSync(), CHANGE_DEBOUNCE_MS);
  });
  const network = Network.addNetworkStateListener(({ isConnected, isInternetReachable }) => {
    if (isConnected && isInternetReachable !== false) {
      retryDelay = MIN_RETRY_MS;
      requestSync();
    }
  });
  const appState = AppState.addEventListener('change', (state) => {
    if (state === 'active') requestSync();
  });
  return () => {
    offChange();
    network.remove();
    appState.remove();
    if (changeTimer) clearTimeout(changeTimer);
    if (retryTimer) clearTimeout(retryTimer);
    changeTimer = retryTimer = null;
  };
}

/** Starts keeping `id`'s library in sync. The local copy must already belong to them (see adoptLocalLibrary). */
export async function startSync(id: number, { expired = false } = {}) {
  userId = id;
  setChangeTracking(true);
  const last = await getMeta(LAST_SYNC_KEY).catch(() => null);
  setStatus({ state: expired ? 'expired' : 'syncing', lastSync: last ? new Date(last) : null });
  await refreshPendingCount().catch(() => {});
  teardown?.();
  teardown = watch();
  if (!expired) requestSync();
}

/** The session ended on the server; keep everything on the phone until the user signs in again. */
export function markSessionExpired() {
  if (userId !== null) setStatus({ state: 'expired' });
}

/** Signing out (or deleting the account): the account's copy leaves the phone, including unsent changes. */
export async function stopSyncAndClear() {
  userId = null;
  setChangeTracking(false);
  teardown?.();
  teardown = null;
  await running?.catch(() => {});
  await clearLibrary();
  await setMeta(OWNER_KEY, null);
  await setMeta(LAST_SYNC_KEY, null);
  await reloadLibrary();
  setStatus({ state: 'off', pending: 0, lastSync: null });
}

/** Whose library is on the phone: a user id, or null for the no-account library. */
export async function localOwner(): Promise<number | null> {
  const owner = await getMeta(OWNER_KEY);
  return owner ? Number(owner) : null;
}

/**
 * Makes the phone's library belong to `id` right after signing in.
 * - Already theirs (signing back in after the session expired): nothing to do.
 * - Another account's copy: dropped; the pull brings in theirs.
 * - The no-account library: merged in. Items the account already has keep the account's
 *   version; everything else is queued for upload.
 */
export async function adoptLocalLibrary(id: number) {
  const owner = await localOwner();
  if (owner === id) return;

  const db = await getDb();
  if (owner !== null) {
    await clearLibrary();
  } else {
    // Offline or failing: upload everything and let the server keep both sides' items.
    const remote = await syncApi.library().catch(() => null);
    const remoteKeys = new Set(
      remote ? Object.entries(remote).flatMap(([c, items]) => items.map((i) => key(c, i.api_id))) : [],
    );
    await db.withExclusiveTransactionAsync(async (txn) => {
      const local = await txn.getAllAsync<{ category: Category; api_id: string }>('SELECT category, api_id FROM items');
      for (const { category, api_id } of local) {
        if (!remoteKeys.has(key(category, api_id))) await markPending(txn, category, api_id);
      }
    });
  }
  await setMeta(OWNER_KEY, String(id));
  await setMeta(LAST_SYNC_KEY, null);
}

/** Pull-to-refresh: a full sync with an account, otherwise just any missing details. */
export async function refreshLibrary() {
  if (userId !== null && status.state !== 'expired') await requestSync();
  else await fetchMissingDetails().catch(() => {});
}
