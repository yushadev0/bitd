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
    <div className="flex min-h-screen">
      <aside className="hidden w-60 shrink-0 flex-col border-r border-slate-200 bg-white p-4 dark:border-slate-800 dark:bg-slate-900 sm:flex">
        <div className="mb-8 px-2 text-xl font-bold tracking-tight">B.I.T.D.</div>
        <nav className="flex flex-1 flex-col gap-1">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition ${
                  isActive
                    ? "bg-brand-600 text-white"
                    : "text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800"
                }`
              }
            >
              <span>{item.icon}</span>
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="mt-4 flex flex-col gap-2 border-t border-slate-200 pt-4 dark:border-slate-800">
          <div className="truncate px-2 text-sm text-slate-500 dark:text-slate-400">{user?.kullanici_adi}</div>
          <button className="btn-secondary justify-start" onClick={toggleTheme}>
            {user?.tema ? "☀️ Açık Tema" : "🌙 Koyu Tema"}
          </button>
          <button className="btn-danger justify-start" onClick={handleLogout}>
            Çıkış Yap
          </button>
        </div>
      </aside>

      <div className="flex flex-1 flex-col">
        <header className="flex items-center justify-between border-b border-slate-200 bg-white px-4 py-3 dark:border-slate-800 dark:bg-slate-900 sm:hidden">
          <span className="text-lg font-bold">B.I.T.D.</span>
          <button className="btn-danger" onClick={handleLogout}>
            Çıkış
          </button>
        </header>
        <nav className="flex gap-1 overflow-x-auto border-b border-slate-200 bg-white px-2 py-2 dark:border-slate-800 dark:bg-slate-900 sm:hidden">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `whitespace-nowrap rounded-lg px-3 py-1.5 text-sm font-medium ${
                  isActive ? "bg-brand-600 text-white" : "text-slate-600 dark:text-slate-300"
                }`
              }
            >
              {item.icon} {item.label}
            </NavLink>
          ))}
        </nav>

        <main className="flex-1 p-4 sm:p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
