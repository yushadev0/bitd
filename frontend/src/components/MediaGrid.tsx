import type { LibraryItem } from "../api/types";
import MediaCard from "./MediaCard";

interface Props {
  items: LibraryItem[];
  emptyLabel: string;
  onAddClick: () => void;
  onItemClick: (item: LibraryItem, rect: DOMRect) => void;
}

export default function MediaGrid({ items, emptyLabel, onAddClick, onItemClick }: Props) {
  return (
    <div className="grid grid-cols-3 gap-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6">
      <button
        onClick={onAddClick}
        className="flex aspect-[2/3] flex-col items-center justify-center gap-2 rounded-xl border-2 border-dashed border-ink-300 text-ink-400 transition hover:border-marquee-400 hover:text-marquee-500 dark:border-ink-700 dark:hover:border-marquee-400"
      >
        <i className="fa-solid fa-plus text-xl" />
        <span className="text-xs font-medium">Ekle</span>
      </button>

      {items.length === 0 && (
        <div className="col-span-2 flex items-center px-2 text-sm text-ink-400 sm:col-span-3 md:col-span-4 lg:col-span-5">
          {emptyLabel}
        </div>
      )}

      {items.map((item) => (
        <MediaCard key={item.api_id} item={item} onClick={(rect) => onItemClick(item, rect)} />
      ))}
    </div>
  );
}
