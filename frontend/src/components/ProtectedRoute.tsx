import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function ProtectedRoute() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-ink-50 dark:bg-ink-950">
        <div className="font-display animate-pulse text-2xl text-ink-400">B.I.T.D.</div>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/giris" replace />;
  }

  return <Outlet />;
}
