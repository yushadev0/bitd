import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import { AuthProvider } from "./context/AuthContext";
import { ToastProvider } from "./context/ToastContext";
import ProtectedRoute from "./components/ProtectedRoute";
import Layout from "./components/Layout";
import LoginPage from "./pages/LoginPage";
import RegisterPage from "./pages/RegisterPage";
import DashboardPage from "./pages/DashboardPage";
import GamesPage from "./pages/GamesPage";
import MoviesPage from "./pages/MoviesPage";
import TvPage from "./pages/TvPage";
import BooksPage from "./pages/BooksPage";
import AccountPage from "./pages/AccountPage";

export default function App() {
  return (
    <BrowserRouter>
      <ToastProvider>
        <AuthProvider>
          <Routes>
            <Route path="/giris" element={<LoginPage />} />
            <Route path="/kayit" element={<RegisterPage />} />

            <Route element={<ProtectedRoute />}>
              <Route element={<Layout />}>
                <Route path="/" element={<DashboardPage />} />
                <Route path="/oyunlar" element={<GamesPage />} />
                <Route path="/filmler" element={<MoviesPage />} />
                <Route path="/diziler" element={<TvPage />} />
                <Route path="/kitaplar" element={<BooksPage />} />
                <Route path="/hesabim" element={<AccountPage />} />
              </Route>
            </Route>

            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </AuthProvider>
      </ToastProvider>
    </BrowserRouter>
  );
}
