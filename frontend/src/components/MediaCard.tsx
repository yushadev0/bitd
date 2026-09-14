import type { LibraryItem } from "../api/types";

interface Props {
  item: LibraryItem;
  onClick: () => void;
}

export default function MediaCard({ item, onClick }: Props) {
  const title = item.detail?.title ?? `#${item.api_id}`;
  const poster = item.detail?.poster;

  return (
    <button
      onClick={onClick}
      className="group relative aspect-[2/3] overflow-hidden rounded-lg border border-slate-200 bg-slate-100 text-left shadow-sm transition hover:shadow-md dark:border-slate-800 dark:bg-slate-800"
    >
      {poster ? (
        <img src={poster} alt={title} className="h-full w-full object-cover transition group-hover:scale-105" />
      ) : (
        <div className="flex h-full w-full items-center justify-center text-sm text-slate-400">Yükleniyor…</div>
      )}
      <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/80 to-transparent p-2">
        <p className="line-clamp-2 text-xs font-medium text-white">{title}</p>
      </div>
    </button>
  );
}
