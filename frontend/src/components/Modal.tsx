import type { ReactNode } from "react";

interface Props {
  title: string;
  onClose: () => void;
  children: ReactNode;
}

export default function Modal({ title, onClose, children }: Props) {
  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-center bg-ink-950/60 backdrop-blur-sm sm:items-center sm:p-4"
      onClick={onClose}
    >
      <div
        className="card animate-sheet-up sm:animate-rise-in flex max-h-[88vh] w-full flex-col rounded-b-none rounded-t-2xl sm:max-h-[90vh] sm:max-w-lg sm:rounded-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="mx-auto mt-2 h-1.5 w-10 shrink-0 rounded-full bg-ink-200 dark:bg-ink-700 sm:hidden" />
        <div className="flex shrink-0 items-center justify-between border-b border-ink-100 px-5 py-4 dark:border-ink-800">
          <h2 className="font-display text-2xl text-ink-900 dark:text-ink-50">{title}</h2>
          <button
            className="rounded-full p-1.5 text-ink-400 hover:bg-ink-100 dark:hover:bg-ink-800"
            onClick={onClose}
            aria-label="Kapat"
          >
            ✕
          </button>
        </div>
        <div className="overflow-y-auto px-5 py-4">{children}</div>
      </div>
    </div>
  );
}
