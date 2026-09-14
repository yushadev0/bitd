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

function SkeletonGrid() {
  return (
    <div className="grid grid-cols-3 gap-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6">
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className="aspect-[2/3] animate-pulse rounded-xl bg-ink-100 dark:bg-ink-800" />
      ))}
    </div>
  );
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
    <div className="mx-auto flex max-w-6xl flex-col gap-10">
      <h1 className="font-display text-4xl text-ink-900 dark:text-ink-50">{title}</h1>

      <section>
        <div className="mb-3 flex items-baseline gap-2">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-ink-500 dark:text-ink-400">
            {completedLabel}
          </h2>
          <span className="text-xs text-ink-400">{completed.length}</span>
        </div>
        {loading ? <SkeletonGrid /> : (
          <MediaGrid
            items={completed}
            emptyLabel="Henüz tamamlanan bir şey yok."
            onAddClick={() => setAddTarget("completed")}
            onItemClick={setSelected}
          />
        )}
      </section>

      <section>
        <div className="mb-3 flex items-baseline gap-2">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-ink-500 dark:text-ink-400">
            {wishlistLabel}
          </h2>
          <span className="text-xs text-ink-400">{wishlist.length}</span>
        </div>
        {loading ? <SkeletonGrid /> : (
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
