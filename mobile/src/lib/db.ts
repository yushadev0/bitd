import * as SQLite from 'expo-sqlite';

import type { Category, ItemDetail, LibraryItem } from '@/api/types';

// The library lives on the phone. Without an account this is the only copy; with one it
// is a full offline copy that the sync engine (lib/sync.ts) keeps in step with the server.

const SCHEMA_VERSION = 1;

let opening: Promise<SQLite.SQLiteDatabase> | null = null;

async function migrate(db: SQLite.SQLiteDatabase) {
  const row = await db.getFirstAsync<{ user_version: number }>('PRAGMA user_version');
  if ((row?.user_version ?? 0) >= SCHEMA_VERSION) return;
  await db.execAsync(`
    PRAGMA journal_mode = WAL;
    CREATE TABLE IF NOT EXISTS items (
      category TEXT NOT NULL,
      api_id TEXT NOT NULL,
      istek_mi INTEGER NOT NULL,
      eklenme_tarihi TEXT NOT NULL,
      bitirme_tarihi TEXT,
      kisisel_not TEXT,
      detail TEXT,       -- ItemDetail JSON
      detail_lang TEXT,  -- language of a complete detail; NULL while only the search result's basics are known
      PRIMARY KEY (category, api_id)
    );
    -- Items changed on this phone that the server hasn't seen yet (accounts only).
    -- The item's current row is what gets sent; no row in items means it was deleted.
    -- version lets a finished upload tell whether the item changed again meanwhile.
    CREATE TABLE IF NOT EXISTS pending (
      category TEXT NOT NULL,
      api_id TEXT NOT NULL,
      version INTEGER NOT NULL DEFAULT 1,
      PRIMARY KEY (category, api_id)
    );
    CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT);
    PRAGMA user_version = ${SCHEMA_VERSION};
  `);
}

export function getDb(): Promise<SQLite.SQLiteDatabase> {
  opening ??= SQLite.openDatabaseAsync('bitd.db').then(async (db) => {
    await migrate(db);
    return db;
  });
  return opening;
}

interface ItemRow {
  category: Category;
  api_id: string;
  istek_mi: number;
  eklenme_tarihi: string;
  bitirme_tarihi: string | null;
  kisisel_not: string | null;
  detail: string | null;
}

function toItem(row: ItemRow): LibraryItem {
  let detail: ItemDetail | null = null;
  try {
    detail = row.detail ? (JSON.parse(row.detail) as ItemDetail) : null;
  } catch {
    // A corrupt cache entry just means the detail gets fetched again.
  }
  return {
    api_id: row.api_id,
    istek_mi: row.istek_mi === 1,
    eklenme_tarihi: row.eklenme_tarihi,
    bitirme_tarihi: row.bitirme_tarihi,
    kisisel_not: row.kisisel_not,
    detail,
  };
}

export async function readAllItems(): Promise<Record<Category, LibraryItem[]>> {
  const db = await getDb();
  const rows = await db.getAllAsync<ItemRow>('SELECT * FROM items ORDER BY eklenme_tarihi DESC');
  const result: Record<Category, LibraryItem[]> = { games: [], movies: [], tv: [], books: [] };
  for (const row of rows) result[row.category]?.push(toItem(row));
  return result;
}

/** Writes an item's state; the cached detail is only replaced when one is given. */
export async function writeItem(
  db: SQLite.SQLiteDatabase,
  category: Category,
  item: Omit<LibraryItem, 'detail'> & { detail?: ItemDetail | null },
  detailLang: string | null = null,
) {
  await db.runAsync(
    `INSERT INTO items (category, api_id, istek_mi, eklenme_tarihi, bitirme_tarihi, kisisel_not, detail, detail_lang)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)
     ON CONFLICT (category, api_id) DO UPDATE SET
       istek_mi = excluded.istek_mi,
       eklenme_tarihi = excluded.eklenme_tarihi,
       bitirme_tarihi = excluded.bitirme_tarihi,
       kisisel_not = excluded.kisisel_not,
       detail = COALESCE(excluded.detail, items.detail),
       detail_lang = CASE WHEN excluded.detail IS NULL THEN items.detail_lang ELSE excluded.detail_lang END`,
    category,
    item.api_id,
    item.istek_mi ? 1 : 0,
    item.eklenme_tarihi,
    item.bitirme_tarihi,
    item.kisisel_not,
    item.detail ? JSON.stringify(item.detail) : null,
    item.detail ? detailLang : null,
  );
}

export async function writeDetail(category: Category, apiId: string, detail: ItemDetail, lang: string) {
  const db = await getDb();
  await db.runAsync(
    'UPDATE items SET detail = ?, detail_lang = ? WHERE category = ? AND api_id = ?',
    JSON.stringify(detail),
    lang,
    category,
    apiId,
  );
}

/** Items whose cached detail is missing, incomplete or in another language. */
export async function itemsNeedingDetail(lang: string): Promise<{ category: Category; api_id: string }[]> {
  const db = await getDb();
  return db.getAllAsync(
    'SELECT category, api_id FROM items WHERE detail_lang IS NULL OR detail_lang != ? ORDER BY eklenme_tarihi DESC',
    lang,
  );
}

export async function deleteItem(db: SQLite.SQLiteDatabase, category: Category, apiId: string) {
  await db.runAsync('DELETE FROM items WHERE category = ? AND api_id = ?', category, apiId);
}

export async function markPending(db: SQLite.SQLiteDatabase, category: Category, apiId: string) {
  await db.runAsync(
    `INSERT INTO pending (category, api_id) VALUES (?, ?)
     ON CONFLICT (category, api_id) DO UPDATE SET version = pending.version + 1`,
    category,
    apiId,
  );
}

export async function getMeta(key: string): Promise<string | null> {
  const db = await getDb();
  const row = await db.getFirstAsync<{ value: string | null }>('SELECT value FROM meta WHERE key = ?', key);
  return row?.value ?? null;
}

export async function setMeta(key: string, value: string | null) {
  const db = await getDb();
  if (value === null) await db.runAsync('DELETE FROM meta WHERE key = ?', key);
  else await db.runAsync('INSERT OR REPLACE INTO meta (key, value) VALUES (?, ?)', key, value);
}

/** Drops the whole library and anything still waiting to sync (sign-out, account deletion, switching accounts). */
export async function clearLibrary() {
  const db = await getDb();
  await db.execAsync('DELETE FROM items; DELETE FROM pending;');
}
