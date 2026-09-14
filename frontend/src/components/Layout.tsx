import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { accountApi } from "../api/account";

const NAV_ITEMS = [
  { to: "/", label: "Ana Sayfa", icon: "🏠", end: true },
  { to: "/oyunlar", label: "Oyunlar", icon: "🎮" },
  { to: "/filmler", label: "Filmler", icon: "🎬" },
  { to: "/diziler", label: "Diziler", icon: "📺" },
  { to: "/kitaplar", label: "Kitaplar", icon: "📚" },
  { to: "/hesabim", label: "Hesabım", icon: "⚙️" },
];

// Mobile keeps the four media shelves one tap away; account settings live under "Ana Sayfa" on small screens.
const MOBILE_NAV_ITEMS = NAV_ITEMS.filter((item) => item.to !== "/hesabim");

export default function Layout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    document.documentElement.classList.toggle("dark", Boolean(user?.tema));
  }, [user?.tema]);

  async function handleLogout() {
    await logout();
    navigate("/giris");
  }

  async function toggleTheme() {
    if (!user) return;
    const updated = await accountApi.updateTheme(!user.tema);
    document.documentElement.classList.toggle("dark", updated.tema);
    window.location.reload();
  }

  return (
    <div className="flex min-h-screen bg-ink-50 dark:bg-ink-950">
      <aside className="hidden w-64 shrink-0 flex-col border-r border-ink-200/70 bg-white px-4 py-6 dark:border-ink-800 dark:bg-ink-900 sm:flex">
        <div className="mb-10 px-2">
          <div className="font-display text-3xl leading-none text-ink-900 dark:text-ink-50">
            B.I.T.D<span className="text-marquee-400">.</span>
          </div>
          <div className="mt-1 text-[11px] font-medium text-ink-400">Back In The Day</div>
        </div>

        <nav className="flex flex-1 flex-col gap-1">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `group flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition ${
                  isActive
                    ? "bg-marquee-400 text-ink-950"
                    : "text-ink-600 hover:bg-ink-100 dark:text-ink-300 dark:hover:bg-ink-800"
                }`
              }
            >
              <span className="text-base">{item.icon}</span>
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="mt-4 flex flex-col gap-2 border-t border-ink-200/70 pt-4 dark:border-ink-800">
          <div className="truncate px-2 text-sm text-ink-400">@{user?.kullanici_adi}</div>
          <button className="btn-secondary justify-start" onClick={toggleTheme}>
            {user?.tema ? "☀️ Açık Tema" : "🌙 Koyu Tema"}
          </button>
          <button className="btn-ghost justify-start" onClick={handleLogout}>
            Çıkış Yap
          </button>
        </div>
      </aside>

      <div className="flex flex-1 flex-col">
        <header className="flex items-center justify-between border-b border-ink-200/70 bg-white px-4 py-3 dark:border-ink-800 dark:bg-ink-900 sm:hidden">
          <div className="font-display text-2xl leading-none text-ink-900 dark:text-ink-50">
            B.I.T.D<span className="text-marquee-400">.</span>
          </div>
          <div className="flex items-center gap-1">
            <button className="btn-ghost !px-2.5 !py-2" onClick={toggleTheme} aria-label="Temayı değiştir">
              {user?.tema ? "☀️" : "🌙"}
            </button>
            <NavLink to="/hesabim" className="btn-ghost !px-2.5 !py-2" aria-label="Hesabım">
              ⚙️
            </NavLink>
          </div>
        </header>

        <main className="flex-1 px-4 pb-24 pt-4 sm:px-8 sm:pb-8 sm:pt-8">
          <Outlet />
        </main>

        <nav className="fixed inset-x-0 bottom-0 z-30 flex border-t border-ink-200/70 bg-white/95 backdrop-blur dark:border-ink-800 dark:bg-ink-900/95 sm:hidden">
          {MOBILE_NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `flex flex-1 flex-col items-center gap-0.5 py-2.5 text-[11px] font-medium ${
                  isActive ? "text-marquee-500 dark:text-marquee-400" : "text-ink-400"
                }`
              }
            >
              <span className="text-lg leading-none">{item.icon}</span>
              {item.label}
            </NavLink>
          ))}
        </nav>
      </div>
    </div>
  );
}
