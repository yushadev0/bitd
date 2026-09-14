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
        <button className="btn-primary" type="submit" disabled={searching}>
          Ara
        </button>
      </form>

      <div className="mb-4 flex gap-4 text-sm">
        <label className="flex items-center gap-2">
          <input type="radio" checked={wishlist} onChange={() => setWishlist(true)} />
          İstek listesine ekle
        </label>
        <label className="flex items-center gap-2">
          <input type="radio" checked={!wishlist} onChange={() => setWishlist(false)} />
          Tamamlandı olarak ekle
        </label>
      </div>

      {error && <p className="mb-3 text-sm text-rose-600">{error}</p>}

      <div className="flex max-h-[50vh] flex-col gap-2 overflow-y-auto">
        {results.map((r) => (
          <div key={r.api_id} className="flex items-center gap-3 rounded-lg border border-slate-200 p-2 dark:border-slate-800">
            <img src={r.poster} alt={r.title} className="h-20 w-14 shrink-0 rounded object-cover" />
            <div className="min-w-0 flex-1">
              <p className="truncate font-medium">{r.title}</p>
              <p className="text-xs text-slate-500 dark:text-slate-400">
                {r.year} · {r.genres.join(", ")}
                {r.score !== null ? ` · ${r.score}` : ""}
              </p>
            </div>
            <button className="btn-primary shrink-0" onClick={() => handleAdd(r.api_id)}>
              Ekle
            </button>
          </div>
        ))}
        {!searching && results.length === 0 && (
          <p className="py-6 text-center text-sm text-slate-400">Aramak için bir kelime yaz.</p>
        )}
      </div>
    </Modal>
  );
}
