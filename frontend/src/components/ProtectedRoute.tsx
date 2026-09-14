import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function ProtectedRoute() {
  const { user, loading } = useAuth();

  if (loading) {
    return <div className="flex min-h-screen items-center justify-center text-slate-400">Yükleniyor…</div>;
  }

  if (!user) {
    return <Navigate to="/giris" replace />;
  }

  return <Outlet />;
}
