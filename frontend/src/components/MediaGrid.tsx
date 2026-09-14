import type { LibraryItem } from "../api/types";
import MediaCard from "./MediaCard";

interface Props {
  items: LibraryItem[];
  emptyLabel: string;
  onAddClick: () => void;
  onItemClick: (item: LibraryItem) => void;
}

export default function MediaGrid({ items, emptyLabel, onAddClick, onItemClick }: Props) {
  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
      <button
        onClick={onAddClick}
        className="flex aspect-[2/3] flex-col items-center justify-center gap-2 rounded-lg border-2 border-dashed border-slate-300 text-slate-400 transition hover:border-brand-500 hover:text-brand-600 dark:border-slate-700"
      >
        <span className="text-3xl">+</span>
        <span className="text-xs">Ekle</span>
      </button>

      {items.length === 0 && (
        <div className="col-span-full flex items-center justify-center py-6 text-sm text-slate-400 sm:col-span-2 md:col-span-3 lg:col-span-4">
          {emptyLabel}
        </div>
      )}

      {items.map((item) => (
        <MediaCard key={item.api_id} item={item} onClick={() => onItemClick(item)} />
      ))}
    </div>
  );
}
