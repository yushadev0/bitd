import { useState } from "react";
import type { Category, SearchResult } from "../api/types";
import { libraryApi } from "../api/library";
import { ApiError } from "../api/client";
import Modal from "./Modal";

interface Props {
  category: Category;
  defaultWishlist: boolean;
  onClose: () => void;
  onAdded: () => void;
}

export default function SearchAddModal({ category, defaultWishlist, onClose, onAdded }: Props) {
  const api = libraryApi(category);
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [searched, setSearched] = useState(false);
  const [searching, setSearching] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [wishlist, setWishlist] = useState(defaultWishlist);

  async function handleSearch(e: React.FormEvent) {
    e.preventDefault();
    if (!query.trim()) return;
    setSearching(true);
    setError(null);
    try {
      const items = await api.search(query.trim());
      setResults(items);
      setSearched(true);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Arama başarısız oldu.");
    } finally {
      setSearching(false);
    }
  }

  async function handleAdd(apiId: string) {
    setError(null);
    try {
      await api.add(apiId, wishlist);
      onAdded();
      onClose();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Eklenemedi.");
    }
  }

  return (
    <Modal title="Kütüphaneye Ekle" onClose={onClose}>
      <form onSubmit={handleSearch} className="mb-4 flex gap-2">
        <input
          className="input"
          placeholder="Ara…"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          autoFocus
        />
        <button className="btn-primary shrink-0" type="submit" disabled={searching}>
          {searching ? "…" : "Ara"}
        </button>
      </form>

      <div className="mb-4 inline-flex rounded-full bg-ink-100 p-1 text-sm dark:bg-ink-800">
        <button
          type="button"
          onClick={() => setWishlist(true)}
          className={`rounded-full px-3.5 py-1.5 font-medium transition ${
            wishlist ? "bg-white text-ink-900 shadow-sm dark:bg-ink-950 dark:text-ink-50" : "text-ink-500"
          }`}
        >
          İstek listesine ekle
        </button>
        <button
          type="button"
          onClick={() => setWishlist(false)}
          className={`rounded-full px-3.5 py-1.5 font-medium transition ${
            !wishlist ? "bg-white text-ink-900 shadow-sm dark:bg-ink-950 dark:text-ink-50" : "text-ink-500"
          }`}
        >
          Tamamlandı olarak ekle
        </button>
      </div>

      {error && <p className="mb-3 text-sm text-stub-500">{error}</p>}

      <div className="flex flex-col gap-2">
        {results.map((r) => (
          <div
            key={r.api_id}
            className="flex items-center gap-3 rounded-xl border border-ink-100 p-2 dark:border-ink-800"
          >
            <img src={r.poster} alt={r.title} className="h-20 w-14 shrink-0 rounded-lg object-cover" />
            <div className="min-w-0 flex-1">
              <p className="truncate font-semibold text-ink-800 dark:text-ink-100">{r.title}</p>
              <p className="text-xs text-ink-500 dark:text-ink-400">
                {r.year} · {r.genres.join(", ")}
                {r.score !== null ? ` · ${r.score}` : ""}
              </p>
            </div>
            <button className="btn-primary shrink-0 !px-4 !py-2 text-xs" onClick={() => handleAdd(r.api_id)}>
              Ekle
            </button>
          </div>
        ))}
        {!searching && results.length === 0 && (
          <p className="py-8 text-center text-sm text-ink-400">
            {searched ? "Eşleşen bir sonuç bulunamadı." : "Aramak için bir kelime yaz."}
          </p>
        )}
      </div>
    </Modal>
  );
}
