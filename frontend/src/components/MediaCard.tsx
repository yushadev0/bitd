import type { LibraryItem } from "../api/types";

interface Props {
  item: LibraryItem;
  onClick: (rect: DOMRect) => void;
}

export default function MediaCard({ item, onClick }: Props) {
  const title = item.detail?.title ?? `#${item.api_id}`;
  const poster = item.detail?.poster;
  const score = item.detail?.score;

  return (
    <button
      onClick={(e) => onClick(e.currentTarget.getBoundingClientRect())}
      className="group relative aspect-[2/3] shrink-0 overflow-hidden rounded-xl border border-ink-200/70 bg-ink-100 text-left shadow-stub transition duration-200 hover:-translate-y-1 hover:shadow-lg dark:border-ink-800 dark:bg-ink-800"
    >
      {poster ? (
        <img
          src={poster}
          alt={title}
          loading="lazy"
          className="h-full w-full object-cover transition duration-300 group-hover:scale-[1.04]"
        />
      ) : (
        <div className="skeleton h-full w-full rounded-none" />
      )}

      {score !== null && score !== undefined && (
        <div className="absolute right-1.5 top-1.5 flex h-8 w-8 items-center justify-center rounded-full bg-ink-950/80 text-[11px] font-bold text-marquee-300 backdrop-blur">
          {score}
        </div>
      )}

      <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-ink-950/90 via-ink-950/40 to-transparent px-2 pb-2 pt-6">
        <p className="line-clamp-2 text-xs font-semibold leading-tight text-ink-50">{title}</p>
      </div>
    </button>
  );
}
