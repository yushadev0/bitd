import type { ReactNode } from "react";

const REELS = [
  { icon: "🎮", label: "Oyunlar" },
  { icon: "🎬", label: "Filmler" },
  { icon: "📺", label: "Diziler" },
  { icon: "📚", label: "Kitaplar" },
];

export default function AuthShell({ children }: { children: ReactNode }) {
  return (
    <div className="grid min-h-screen bg-ink-50 dark:bg-ink-950 lg:grid-cols-2">
      <div className="grain relative hidden flex-col justify-between overflow-hidden bg-ink-950 px-12 py-14 text-ink-50 lg:flex">
        <div className="pointer-events-none absolute -left-24 -top-24 h-72 w-72 rounded-full bg-marquee-400/20 blur-3xl" />
        <div className="pointer-events-none absolute bottom-[-6rem] right-[-4rem] h-80 w-80 rounded-full bg-ticket-500/10 blur-3xl" />

        <div className="relative">
          <div className="font-display text-4xl leading-none">
            B.I.T.D<span className="text-marquee-400">.</span>
          </div>
          <div className="mt-1 text-sm text-ink-400">Back In The Day</div>
        </div>

        <div className="relative">
          <p className="font-display text-5xl leading-[1.05] text-ink-50 sm:text-6xl">
            Bugün ne
            <br />
            yapmalıyım<span className="text-marquee-400">?</span>
          </p>
          <p className="mt-5 max-w-sm text-sm leading-relaxed text-ink-300">
            Oynadığın, izlediğin ve okuduğun her şeyi tek bir rafta topla. İstek listeni doldur,
            karar veremediğinde zarı sen atma, B.I.T.D. atsın.
          </p>
        </div>

        <div className="relative flex gap-3">
          {REELS.map((r) => (
            <div
              key={r.label}
              className="flex flex-1 flex-col items-center gap-1 rounded-xl border border-ink-700/80 bg-ink-900/60 py-3 text-xs text-ink-300"
            >
              <span className="text-lg">{r.icon}</span>
              {r.label}
            </div>
          ))}
        </div>
      </div>

      <div className="flex items-center justify-center px-4 py-10 sm:px-8">
        <div className="w-full max-w-sm animate-rise-in">
          <div className="mb-8 lg:hidden">
            <div className="font-display text-3xl leading-none text-ink-900 dark:text-ink-50">
              B.I.T.D<span className="text-marquee-400">.</span>
            </div>
            <div className="mt-1 text-sm text-ink-400">Back In The Day</div>
          </div>
          {children}
        </div>
      </div>
    </div>
  );
}
