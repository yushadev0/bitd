import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { dashboardApi } from "../api/dashboard";
import { libraryApi } from "../api/library";
import type { Category, DashboardResponse, LibraryItem, RecentItem } from "../api/types";
import { ApiError } from "../api/client";
import DetailModal from "../components/DetailModal";

const SECTIONS: { category: Category; label: string; icon: string; link: string; diceLabel: string }[] = [
  { category: "games", label: "Oyunlar", icon: "🎮", link: "/oyunlar", diceLabel: "Bugün ne oynamalıyım?" },
  { category: "movies", label: "Filmler", icon: "🎬", link: "/filmler", diceLabel: "Bugün ne izlemeliyim?" },
  { category: "tv", label: "Diziler", icon: "📺", link: "/diziler", diceLabel: "Bugün ne izlemeliyim?" },
  { category: "books", label: "Kitaplar", icon: "📚", link: "/kitaplar", diceLabel: "Sırada hangi kitap var?" },
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

export default function DashboardPage() {
  const { user } = useAuth();
  const [stats, setStats] = useState<DashboardResponse | null>(null);
  const [recent, setRecent] = useState<Record<Category, RecentItem[]>>({
    games: [],
    movies: [],
    tv: [],
    books: [],
  });
  const [randomItem, setRandomItem] = useState<{ category: Category; item: LibraryItem } | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    dashboardApi.stats().then(setStats);
    (["games", "movies", "tv", "books"] as Category[]).forEach((category) => {
      dashboardApi.recent(category).then((data) => setRecent((prev) => ({ ...prev, [category]: data })));
    });
  }, []);

  async function handleRandom(category: Category) {
    setError(null);
    try {
      const item = await libraryApi(category).random();
      setRandomItem({ category, item });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Rastgele seçim yapılamadı.");
    }
  }

  return (
    <div className="flex flex-col gap-8">
      <div>
        <h1 className="text-2xl font-bold">Hoş geldin, {user?.kullanici_adi}</h1>
        <p className="text-sm text-slate-500 dark:text-slate-400">Arşivine genel bakış</p>
      </div>

      {error && <p className="text-sm text-rose-600">{error}</p>}

      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {SECTIONS.map(({ category, label, icon }) => {
          const s = statsFor(stats, category);
          return (
            <div key={category} className="card p-4">
              <div className="mb-1 text-2xl">{icon}</div>
              <div className="text-2xl font-bold">{s.total}</div>
              <div className="text-xs text-slate-500 dark:text-slate-400">
                {label} (+{s.wishlist} istek)
              </div>
            </div>
          );
        })}
      </div>

      {SECTIONS.map(({ category, label, icon, link, diceLabel }) => (
        <section key={category}>
          <div className="mb-3 flex items-center justify-between">
            <h2 className="text-lg font-semibold">
              {icon} {label}
            </h2>
            <Link to={link} className="text-sm text-brand-600 hover:underline">
              Tümünü Gör
            </Link>
          </div>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6">
            <button
              onClick={() => handleRandom(category)}
              className="flex aspect-[2/3] flex-col items-center justify-center gap-2 rounded-lg border border-brand-200 bg-brand-50 p-2 text-center text-xs font-medium text-brand-700 transition hover:bg-brand-100 dark:border-brand-900 dark:bg-brand-950 dark:text-brand-300"
            >
              <span className="text-2xl">🎲</span>
              {diceLabel}
            </button>
            {recent[category].length === 0 && (
              <div className="col-span-full flex items-center justify-center py-4 text-sm text-slate-400 sm:col-span-2 md:col-span-3 lg:col-span-5">
                Henüz {label.toLowerCase()} eklemedin.{" "}
                <Link to={link} className="ml-1 text-brand-600 hover:underline">
                  Kütüphaneye git
                </Link>
              </div>
            )}
            {recent[category].map((r) => (
              <div key={r.api_id} className="aspect-[2/3] overflow-hidden rounded-lg border border-slate-200 dark:border-slate-800">
                <img src={r.poster} alt={r.title} className="h-full w-full object-cover" />
              </div>
            ))}
          </div>
        </section>
      ))}

      {randomItem && (
        <DetailModal
          category={randomItem.category}
          item={randomItem.item}
          onClose={() => setRandomItem(null)}
          onChanged={() => {}}
        />
      )}
    </div>
  );
}
