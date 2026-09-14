import { useCallback, useEffect, useState } from "react";
import type { Category, LibraryItem } from "../api/types";
import { libraryApi } from "../api/library";
import MediaGrid from "./MediaGrid";
import SearchAddModal from "./SearchAddModal";
import DetailModal from "./DetailModal";

interface Props {
  category: Category;
  title: string;
  completedLabel: string;
  wishlistLabel: string;
}

export default function LibraryPage({ category, title, completedLabel, wishlistLabel }: Props) {
  const api = libraryApi(category);
  const [items, setItems] = useState<LibraryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [addTarget, setAddTarget] = useState<"wishlist" | "completed" | null>(null);
  const [selected, setSelected] = useState<LibraryItem | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await api.list();
      setItems(data);
    } finally {
      setLoading(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [category]);

  useEffect(() => {
    load();
  }, [load]);

  const completed = items.filter((i) => !i.istek_mi);
  const wishlist = items.filter((i) => i.istek_mi);

  return (
    <div className="flex flex-col gap-8">
      <h1 className="text-2xl font-bold">{title}</h1>

      <section>
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-slate-500 dark:text-slate-400">
          {completedLabel}
        </h2>
        {loading ? (
          <p className="text-sm text-slate-400">Yükleniyor…</p>
        ) : (
          <MediaGrid
            items={completed}
            emptyLabel="Henüz tamamlanan bir şey yok."
            onAddClick={() => setAddTarget("completed")}
            onItemClick={setSelected}
          />
        )}
      </section>

      <section>
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-slate-500 dark:text-slate-400">
          {wishlistLabel}
        </h2>
        {loading ? (
          <p className="text-sm text-slate-400">Yükleniyor…</p>
        ) : (
          <MediaGrid
            items={wishlist}
            emptyLabel="İstek listen boş."
            onAddClick={() => setAddTarget("wishlist")}
            onItemClick={setSelected}
          />
        )}
      </section>

      {addTarget && (
        <SearchAddModal
          category={category}
          defaultWishlist={addTarget === "wishlist"}
          onClose={() => setAddTarget(null)}
          onAdded={load}
        />
      )}

      {selected && (
        <DetailModal category={category} item={selected} onClose={() => setSelected(null)} onChanged={load} />
      )}
    </div>
  );
}
