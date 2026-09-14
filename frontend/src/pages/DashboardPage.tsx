import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { dashboardApi } from "../api/dashboard";
import { libraryApi } from "../api/library";
import type { Category, DashboardResponse, LibraryItem, RecentItem } from "../api/types";
import { ApiError } from "../api/client";
import { useToast } from "../context/ToastContext";
import DetailModal from "../components/DetailModal";

const SECTIONS: { category: Category; label: string; icon: string; link: string; diceLabel: string }[] = [
  { category: "games", label: "Oyunlar", icon: "fa-solid fa-gamepad", link: "/oyunlar", diceLabel: "Bugün ne oynamalıyım?" },
  { category: "movies", label: "Filmler", icon: "fa-solid fa-film", link: "/filmler", diceLabel: "Bugün ne izlemeliyim?" },
  { category: "tv", label: "Diziler", icon: "fa-solid fa-tv", link: "/diziler", diceLabel: "Bugün ne izlemeliyim?" },
  { category: "books", label: "Kitaplar", icon: "fa-solid fa-book", link: "/kitaplar", diceLabel: "Sırada hangi kitap var?" },
];

function statsFor(stats: DashboardResponse | null, category: Category) {
  if (!stats) return { total: 0, wishlist: 0 };
  return {
    games: stats.oyunlar,
    movies: stats.filmler,
    tv: stats.diziler,
    books: stats.kitaplar,
  }[category];
}

const TODAY = new Date().toLocaleDateString("tr-TR", { day: "2-digit", month: "long", year: "numeric" });

export default function DashboardPage() {
  const { user } = useAuth();
  const toast = useToast();
  const [stats, setStats] = useState<DashboardResponse | null>(null);
  const [statsLoading, setStatsLoading] = useState(true);
  const [recent, setRecent] = useState<Record<Category, RecentItem[] | null>>({
    games: null,
    movies: null,
    tv: null,
    books: null,
  });
  const [randomItem, setRandomItem] = useState<{ category: Category; item: LibraryItem; rect: DOMRect } | null>(null);
  const [rollingFor, setRollingFor] = useState<Category | null>(null);

  useEffect(() => {
    dashboardApi.stats().then((data) => {
      setStats(data);
      setStatsLoading(false);
    });
    (["games", "movies", "tv", "books"] as Category[]).forEach((category) => {
      dashboardApi.recent(category).then((data) => setRecent((prev) => ({ ...prev, [category]: data })));
    });
  }, []);

  async function handleRandom(category: Category, e: React.MouseEvent<HTMLButtonElement>) {
    const rect = e.currentTarget.getBoundingClientRect();
    setRollingFor(category);
    try {
      const item = await libraryApi(category).random();
      setRandomItem({ category, item, rect });
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "Rastgele seçim yapılamadı.", "error");
    } finally {
      setRollingFor(null);
    }
  }

  return (
    <div className="mx-auto flex max-w-6xl flex-col gap-10">
      <div className="grain relative overflow-hidden rounded-2xl bg-gradient-to-br from-marquee-100 via-ticket-100 to-marquee-50 px-6 py-8 text-ink-900 dark:from-ink-950 dark:via-ink-950 dark:to-ink-900 dark:text-ink-50 sm:px-10 sm:py-10">
        <div className="pointer-events-none absolute -right-16 -top-16 h-56 w-56 rounded-full bg-marquee-400/20 blur-3xl" />
        <p className="text-xs font-medium uppercase tracking-wide text-ink-500 dark:text-ink-400">{TODAY}</p>
        <h1 className="mt-2 font-display text-4xl leading-none sm:text-5xl">
          Hoş geldin, {user?.kullanici_adi}
          <span className="text-marquee-500 dark:text-marquee-400">.</span>
        </h1>
        <p className="mt-3 max-w-md text-sm text-ink-600 dark:text-ink-300">
          Rafına genel bir bakış — bugün ne yapacağına birlikte karar verelim.
        </p>
      </div>

      <div className="grid grid-cols-2 gap-3 sm:gap-4 lg:grid-cols-4">
        {SECTIONS.map(({ category, label, icon }) => {
          const s = statsFor(stats, category);
          return (
            <div key={category} className="card p-4 sm:p-5">
              <i className={`${icon} mb-1 text-lg text-marquee-500 dark:text-marquee-400`} />
              {statsLoading ? (
                <div className="skeleton mt-1 h-9 w-12" />
              ) : (
                <div className="font-display text-4xl leading-none text-ink-900 dark:text-ink-50">{s.total}</div>
              )}
              <div className="mt-1 text-xs text-ink-500 dark:text-ink-400">
                {label} <span className="text-marquee-500 dark:text-marquee-400">+{s.wishlist} istek</span>
              </div>
            </div>
          );
        })}
      </div>

      {SECTIONS.map(({ category, label, icon, link, diceLabel }) => (
        <section key={category}>
          <div className="mb-3 flex items-center justify-between">
            <h2 className="flex items-center gap-2 font-display text-2xl text-ink-900 dark:text-ink-50">
              <i className={`${icon} text-lg text-marquee-500 dark:text-marquee-400`} />
              {label}
            </h2>
            <Link to={link} className="text-sm font-medium text-marquee-600 hover:underline dark:text-marquee-400">
              Tümünü Gör
            </Link>
          </div>
          <div className="-mx-4 flex snap-x gap-3 overflow-x-auto px-4 pb-2 sm:mx-0 sm:px-0">
            <button
              onClick={(e) => handleRandom(category, e)}
              disabled={rollingFor === category}
              className="flex aspect-[2/3] w-28 shrink-0 snap-start flex-col items-center justify-center gap-2 rounded-xl border border-marquee-400/40 bg-marquee-400/10 p-3 text-center text-xs font-semibold text-marquee-600 transition hover:bg-marquee-400/20 disabled:opacity-70 dark:text-marquee-300 sm:w-32"
            >
              <i className={`fa-solid fa-dice text-2xl ${rollingFor === category ? "animate-spin" : ""}`} />
              {diceLabel}
            </button>

            {recent[category] === null &&
              Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="skeleton aspect-[2/3] w-28 shrink-0 sm:w-32" />
              ))}

            {recent[category]?.length === 0 && (
              <div className="flex w-64 shrink-0 items-center rounded-xl border border-dashed border-ink-200 px-4 text-sm text-ink-400 dark:border-ink-800">
                Henüz {label.toLowerCase()} eklemedin.{" "}
                <Link to={link} className="ml-1 font-medium text-marquee-600 hover:underline dark:text-marquee-400">
                  Kütüphaneye git
                </Link>
              </div>
            )}

            {recent[category]?.map((r) => (
              <div
                key={r.api_id}
                className="aspect-[2/3] w-28 shrink-0 snap-start overflow-hidden rounded-xl border border-ink-200/70 shadow-stub dark:border-ink-800 sm:w-32"
              >
                <img src={r.poster} alt={r.title} className="h-full w-full object-cover" loading="lazy" />
              </div>
            ))}
          </div>
        </section>
      ))}

      {randomItem && (
        <DetailModal
          category={randomItem.category}
          item={randomItem.item}
          originRect={randomItem.rect}
          onClose={() => setRandomItem(null)}
          onChanged={() => {}}
        />
      )}
    </div>
  );
}
