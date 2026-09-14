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

function Fact({ label, value }: { label: string; value: string | number | undefined | null }) {
  if (value === undefined || value === null || value === "") return null;
  return (
    <div>
      <dt className="text-[11px] font-medium uppercase tracking-wide text-ink-400">{label}</dt>
      <dd className="text-sm text-ink-800 dark:text-ink-100">{value}</dd>
    </div>
  );
}

export default function DetailModal({ category, item, onClose, onChanged }: Props) {
  const api = libraryApi(category);
  const detail = item.detail;

  const [note, setNote] = useState(item.kisisel_not ?? "");
  const [date, setDate] = useState(item.bitirme_tarihi ?? "");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [noteSaved, setNoteSaved] = useState(false);

  async function saveNote() {
    setBusy(true);
    setError(null);
    try {
      await api.updateNote(item.api_id, note);
      setNoteSaved(true);
      setTimeout(() => setNoteSaved(false), 1600);
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
      {error && <p className="mb-3 text-sm text-stub-500">{error}</p>}

      <div className="mb-4 flex gap-4">
        {detail?.poster && (
          <img
            src={detail.poster}
            alt={detail.title}
            className="h-40 w-28 shrink-0 rounded-xl object-cover shadow-stub"
          />
        )}
        <dl className="grid min-w-0 flex-1 grid-cols-2 gap-x-3 gap-y-2.5">
          <Fact label="Yıl" value={detail?.year} />
          <Fact label="Puan" value={detail?.score} />
          <Fact label="Süre" value={detail?.runtime_minutes ? `${detail.runtime_minutes} dk` : undefined} />
          <Fact label="Yönetmen" value={detail?.director} />
          <Fact label="Sezon" value={detail?.seasons} />
          <Fact label="Kanal" value={detail?.network} />
          <Fact label="Platform" value={detail?.platforms?.join(", ")} />
          <Fact label="Yazar" value={detail?.authors?.join(", ")} />
          <Fact label="Sayfa" value={detail?.page_count} />
        </dl>
      </div>

      {detail?.genres && (
        <div className="mb-4 flex flex-wrap gap-1.5">
          {detail.genres.map((g) => (
            <span key={g} className="stamp border-marquee-500/30 text-marquee-600 dark:text-marquee-400">
              {g}
            </span>
          ))}
        </div>
      )}

      {detail?.summary && (
        <p className="mb-4 text-sm leading-relaxed text-ink-600 dark:text-ink-300">{detail.summary}</p>
      )}

      {detail?.screenshots && detail.screenshots.length > 0 && (
        <div className="mb-4 flex gap-2 overflow-x-auto pb-1">
          {detail.screenshots.map((src) => (
            <img key={src} src={src} className="h-20 w-32 shrink-0 rounded-lg object-cover" />
          ))}
        </div>
      )}

      <div className="mb-4 grid grid-cols-2 gap-3 border-t border-ink-100 pt-4 dark:border-ink-800">
        <div>
          <label className="label">Bitirme Tarihi</label>
          <input
            type="date"
            className="input"
            value={date}
            disabled={item.istek_mi}
            onChange={(e) => saveDate(e.target.value)}
          />
          {item.istek_mi && <p className="mt-1 text-xs text-ink-400">Önce tamamlandı işaretle.</p>}
        </div>
      </div>

      <div className="mb-5">
        <label className="label">Kişisel Not</label>
        <textarea className="input min-h-[80px]" value={note} onChange={(e) => setNote(e.target.value)} />
        <button className="btn-secondary mt-2 !px-4 !py-2 text-xs" onClick={saveNote} disabled={busy}>
          {noteSaved ? "Kaydedildi ✓" : "Notu Kaydet"}
        </button>
      </div>

      <div className="flex flex-wrap gap-2 border-t border-ink-100 pt-4 dark:border-ink-800">
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
