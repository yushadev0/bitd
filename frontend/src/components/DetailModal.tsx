import { useState } from "react";
import type { Category, LibraryItem } from "../api/types";
import { libraryApi } from "../api/library";
import { ApiError } from "../api/client";
import Modal from "./Modal";

interface Props {
  category: Category;
  item: LibraryItem;
  onClose: () => void;
  onChanged: () => void;
}

export default function DetailModal({ category, item, onClose, onChanged }: Props) {
  const api = libraryApi(category);
  const detail = item.detail;

  const [note, setNote] = useState(item.kisisel_not ?? "");
  const [date, setDate] = useState(item.bitirme_tarihi ?? "");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function saveNote() {
    setBusy(true);
    setError(null);
    try {
      await api.updateNote(item.api_id, note);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Not kaydedilemedi.");
    } finally {
      setBusy(false);
    }
  }

  async function saveDate(newDate: string) {
    setDate(newDate);
    if (!newDate) return;
    try {
      await api.updateDate(item.api_id, newDate);
      onChanged();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Tarih kaydedilemedi.");
    }
  }

  async function toggleStatus() {
    setBusy(true);
    setError(null);
    try {
      await api.updateStatus(item.api_id, !item.istek_mi);
      onChanged();
      onClose();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Durum değiştirilemedi.");
      setBusy(false);
    }
  }

  async function handleDelete() {
    setBusy(true);
    setError(null);
    try {
      await api.remove(item.api_id);
      onChanged();
      onClose();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Silinemedi.");
      setBusy(false);
    }
  }

  return (
    <Modal title={detail?.title ?? `#${item.api_id}`} onClose={onClose}>
      {error && <p className="mb-3 text-sm text-rose-600">{error}</p>}

      <div className="mb-4 flex gap-4">
        {detail?.poster && <img src={detail.poster} alt={detail.title} className="h-40 w-28 shrink-0 rounded-lg object-cover" />}
        <div className="min-w-0 flex-1 text-sm text-slate-600 dark:text-slate-300">
          <p>
            <span className="font-medium text-slate-800 dark:text-slate-100">Yıl:</span> {detail?.year ?? "--"}
          </p>
          <p>
            <span className="font-medium text-slate-800 dark:text-slate-100">Tür:</span>{" "}
            {detail?.genres?.join(", ") ?? "--"}
          </p>
          {detail?.score !== undefined && detail?.score !== null && (
            <p>
              <span className="font-medium text-slate-800 dark:text-slate-100">Puan:</span> {detail.score}
            </p>
          )}
          {detail?.runtime_minutes !== undefined && (
            <p>
              <span className="font-medium text-slate-800 dark:text-slate-100">Süre:</span>{" "}
              {detail.runtime_minutes ? `${detail.runtime_minutes} dk` : "--"}
            </p>
          )}
          {detail?.director && (
            <p>
              <span className="font-medium text-slate-800 dark:text-slate-100">Yönetmen:</span> {detail.director}
            </p>
          )}
          {detail?.seasons !== undefined && (
            <p>
              <span className="font-medium text-slate-800 dark:text-slate-100">Sezon:</span> {detail.seasons ?? "--"}
            </p>
          )}
          {detail?.network && (
            <p>
              <span className="font-medium text-slate-800 dark:text-slate-100">Kanal:</span> {detail.network}
            </p>
          )}
          {detail?.platforms && (
            <p>
              <span className="font-medium text-slate-800 dark:text-slate-100">Platform:</span>{" "}
              {detail.platforms.join(", ")}
            </p>
          )}
          {detail?.authors && (
            <p>
              <span className="font-medium text-slate-800 dark:text-slate-100">Yazar:</span> {detail.authors.join(", ")}
            </p>
          )}
          {detail?.page_count !== undefined && detail.page_count !== null && (
            <p>
              <span className="font-medium text-slate-800 dark:text-slate-100">Sayfa:</span> {detail.page_count}
            </p>
          )}
        </div>
      </div>

      {detail?.summary && (
        <p className="mb-4 text-sm leading-relaxed text-slate-600 dark:text-slate-300">{detail.summary}</p>
      )}

      {detail?.screenshots && detail.screenshots.length > 0 && (
        <div className="mb-4 flex gap-2 overflow-x-auto">
          {detail.screenshots.map((src) => (
            <img key={src} src={src} className="h-20 w-32 shrink-0 rounded object-cover" />
          ))}
        </div>
      )}

      <div className="mb-4">
        <label className="label">Bitirme Tarihi</label>
        <input
          type="date"
          className="input"
          value={date}
          disabled={item.istek_mi}
          onChange={(e) => saveDate(e.target.value)}
        />
        {item.istek_mi && <p className="mt-1 text-xs text-slate-400">Önce "Tamamlandı" olarak işaretlemelisin.</p>}
      </div>

      <div className="mb-4">
        <label className="label">Kişisel Not</label>
        <textarea className="input min-h-[80px]" value={note} onChange={(e) => setNote(e.target.value)} />
        <button className="btn-secondary mt-2" onClick={saveNote} disabled={busy}>
          Notu Kaydet
        </button>
      </div>

      <div className="flex flex-wrap gap-2 border-t border-slate-200 pt-4 dark:border-slate-800">
        <button className="btn-primary" onClick={toggleStatus} disabled={busy}>
          {item.istek_mi ? "Tamamlandı Olarak İşaretle" : "İstek Listesine Taşı"}
        </button>
        <button className="btn-danger" onClick={handleDelete} disabled={busy}>
          Kütüphaneden Sil
        </button>
      </div>
    </Modal>
  );
}
