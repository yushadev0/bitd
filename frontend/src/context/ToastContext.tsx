import { createContext, useCallback, useContext, useRef, useState, type ReactNode } from "react";

type ToastKind = "success" | "error" | "info";

interface Toast {
  id: number;
  kind: ToastKind;
  message: string;
}

interface ToastContextValue {
  show: (message: string, kind?: ToastKind) => void;
}

const ToastContext = createContext<ToastContextValue | undefined>(undefined);

const ICONS: Record<ToastKind, string> = {
  success: "fa-solid fa-circle-check",
  error: "fa-solid fa-circle-exclamation",
  info: "fa-solid fa-circle-info",
};

const STYLES: Record<ToastKind, string> = {
  success: "border-ticket-500/30 text-ticket-700 dark:text-ticket-300",
  error: "border-stub-500/30 text-stub-600 dark:text-stub-400",
  info: "border-marquee-400/30 text-marquee-700 dark:text-marquee-300",
};

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const nextId = useRef(0);

  const show = useCallback((message: string, kind: ToastKind = "success") => {
    const id = nextId.current++;
    setToasts((prev) => [...prev, { id, kind, message }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 3000);
  }, []);

  return (
    <ToastContext.Provider value={{ show }}>
      {children}
      <div className="pointer-events-none fixed inset-x-0 top-3 z-[100] flex flex-col items-center gap-2 px-4 sm:top-4 sm:items-end sm:px-6">
        {toasts.map((t) => (
          <div
            key={t.id}
            className={`animate-rise-in pointer-events-auto flex max-w-sm items-center gap-2.5 rounded-xl border bg-white px-4 py-3 text-sm font-medium shadow-stub dark:bg-ink-900 ${STYLES[t.kind]}`}
          >
            <i className={ICONS[t.kind]} />
            {t.message}
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export function useToast() {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error("useToast must be used within ToastProvider");
  return ctx;
}
