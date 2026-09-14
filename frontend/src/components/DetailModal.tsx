import { useEffect, useLayoutEffect, useRef, useState } from "react";
import { animate, cubicBezier } from "animejs";

const ENTRANCE_EASE = cubicBezier(0.22, 1, 0.36, 1);
import type { Category, LibraryItem } from "../api/types";
import { libraryApi } from "../api/library";
import { ApiError } from "../api/client";
import { useToast } from "../context/ToastContext";

interface Props {
  category: Category;
  item: LibraryItem;
  originRect: DOMRect | null;
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

function prefersReducedMotion() {
  return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
}

export default function DetailModal({ category, item, originRect, onClose, onChanged }: Props) {
  const api = libraryApi(category);
  const toast = useToast();
  const detail = item.detail;

  const overlayRef = useRef<HTMLDivElement>(null);
  const cardRef = useRef<HTMLDivElement>(null);

  const [note, setNote] = useState(item.kisisel_not ?? "");
  const [date, setDate] = useState(item.bitirme_tarihi ?? "");
  const [busy, setBusy] = useState(false);
  const [confirmingDelete, setConfirmingDelete] = useState(false);

  useLayoutEffect(() => {
    const overlay = overlayRef.current;
    const card = cardRef.current;
    if (!overlay || !card) return;
    const reduced = prefersReducedMotion();

    animate(overlay, { opacity: [0, 1], duration: reduced ? 1 : 200, ease: "linear" });

    if (originRect && !reduced) {
      const finalRect = card.getBoundingClientRect();
      const scaleX = originRect.width / finalRect.width;
      const scaleY = originRect.height / finalRect.height;
      const translateX = originRect.left + originRect.width / 2 - (finalRect.left + finalRect.width / 2);
      const translateY = originRect.top + originRect.height / 2 - (finalRect.top + finalRect.height / 2);

      animate(card, {
        translateX: [translateX, 0],
        translateY: [translateY, 0],
        scaleX: [scaleX, 1],
        scaleY: [scaleY, 1],
        opacity: [0.4, 1],
        duration: 450,
        ease: ENTRANCE_EASE,
      });
    } else {
      animate(card, { scale: [0.94, 1], opacity: [0, 1], duration: reduced ? 1 : 220, ease: "outQuad" });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function handleClose() {
    const overlay = overlayRef.current;
    const card = cardRef.current;
    const reduced = prefersReducedMotion();

    if (!overlay || !card || reduced) {
      onClose();
      return;
    }

    if (originRect) {
      const finalRect = card.getBoundingClientRect();
      const scaleX = originRect.width / finalRect.width;
      const scaleY = originRect.height / finalRect.height;
      const translateX = originRect.left + originRect.width / 2 - (finalRect.left + finalRect.width / 2);
      const translateY = originRect.top + originRect.height / 2 - (finalRect.top + finalRect.height / 2);
      animate(card, {
        translateX: [0, translateX],
        translateY: [0, translateY],
        scaleX: [1, scaleX],
        scaleY: [1, scaleY],
        opacity: [1, 0.3],
        duration: 260,
        ease: "inQuad",
      });
    } else {
      animate(card, { scale: [1, 0.94], opacity: [1, 0], duration: 200, ease: "inQuad" });
    }
    animate(overlay, { opacity: [1, 0], duration: 260, ease: "linear" });
    setTimeout(onClose, 260);
  }

  useEffect(() => {
    function onKeyDown(e: KeyboardEvent) {
      if (e.key === "Escape") handleClose();
    }
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function saveNote() {
    setBusy(true);
    try {
      await api.updateNote(item.api_id, note);
      toast.show("Not kaydedildi.");
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "Not kaydedilemedi.", "error");
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
      toast.show("Tarih güncellendi.");
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "Tarih kaydedilemedi.", "error");
    }
  }

  async function toggleStatus() {
    setBusy(true);
    try {
      await api.updateStatus(item.api_id, !item.istek_mi);
      onChanged();
      toast.show(item.istek_mi ? "Tamamlandı olarak işaretlendi." : "İstek listesine taşındı.");
      handleClose();
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "Durum değiştirilemedi.", "error");
      setBusy(false);
    }
  }

  async function handleDelete() {
    setBusy(true);
    try {
      await api.remove(item.api_id);
      onChanged();
      toast.show("Kütüphaneden silindi.");
      handleClose();
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "Silinemedi.", "error");
      setBusy(false);
    }
  }

  return (
    <div
      ref={overlayRef}
      className="fixed inset-0 z-50 flex items-center justify-center bg-ink-950/60 p-3 backdrop-blur-sm sm:p-6"
      onClick={handleClose}
    >
      <div
        ref={cardRef}
        onClick={(e) => e.stopPropagation()}
        className="card flex max-h-[92vh] w-full max-w-4xl flex-col overflow-hidden"
      >
        <header className="flex shrink-0 items-center justify-between gap-3 border-b border-ink-100 px-5 py-3.5 dark:border-ink-800">
          <h2 className="min-w-0 truncate font-display text-2xl text-ink-900 dark:text-ink-50">
            {detail?.title ?? `#${item.api_id}`}
          </h2>
          <div className="flex shrink-0 items-center gap-1">
            <button
              className="icon-btn"
              title={item.istek_mi ? "Tamamlandı olarak işaretle" : "İstek listesine taşı"}
              onClick={toggleStatus}
              disabled={busy}
            >
              <i className={item.istek_mi ? "fa-solid fa-check" : "fa-solid fa-rotate-left"} />
            </button>
            {confirmingDelete ? (
              <>
                <button className="icon-btn text-stub-500" title="Silmeyi onayla" onClick={handleDelete} disabled={busy}>
                  <i className="fa-solid fa-check" />
                </button>
                <button className="icon-btn" title="Vazgeç" onClick={() => setConfirmingDelete(false)}>
                  <i className="fa-solid fa-xmark" />
                </button>
              </>
            ) : (
              <button className="icon-btn text-stub-500" title="Kütüphaneden sil" onClick={() => setConfirmingDelete(true)}>
                <i className="fa-solid fa-trash" />
              </button>
            )}
            <button className="icon-btn" title="Kapat" onClick={handleClose}>
              <i className="fa-solid fa-xmark" />
            </button>
          </div>
        </header>

        <div className="grid flex-1 gap-6 overflow-y-auto p-5 lg:grid-cols-[220px_1fr_260px] lg:gap-8">
          <div className="flex flex-col gap-4">
            {detail?.poster && (
              <img
                src={detail.poster}
                alt={detail.title}
                className="aspect-[2/3] w-full rounded-xl object-cover shadow-stub"
              />
            )}
            <dl className="grid grid-cols-2 gap-x-3 gap-y-2.5">
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

            {detail?.genres && (
              <div className="flex flex-wrap gap-1.5">
                {detail.genres.map((g) => (
                  <span key={g} className="stamp border-marquee-500/30 text-marquee-600 dark:text-marquee-400">
                    {g}
                  </span>
                ))}
              </div>
            )}

            <div className="flex flex-wrap gap-2">
              {detail?.trailer_url && (
                <a
                  href={detail.trailer_url}
                  target="_blank"
                  rel="noreferrer"
                  className="btn-secondary !px-3 !py-2 text-xs"
                >
                  <i className="fa-brands fa-youtube" /> Fragman
                </a>
              )}
              {detail?.preview_link && (
                <a
                  href={detail.preview_link}
                  target="_blank"
                  rel="noreferrer"
                  className="btn-secondary !px-3 !py-2 text-xs"
                >
                  <i className="fa-solid fa-book-open" /> Önizleme
                </a>
              )}
            </div>
          </div>

          <div className="min-w-0">
            <h3 className="mb-2 text-[11px] font-semibold uppercase tracking-wide text-ink-400">Açıklama</h3>
            <p className="text-sm leading-relaxed text-ink-600 dark:text-ink-300">
              {detail?.summary ?? "Açıklama bulunamadı."}
            </p>

            {detail?.screenshots && detail.screenshots.length > 0 && (
              <div className="mt-4 flex gap-2 overflow-x-auto pb-1">
                {detail.screenshots.map((src) => (
                  <img key={src} src={src} className="h-20 w-32 shrink-0 rounded-lg object-cover" />
                ))}
              </div>
            )}
          </div>

          <div className="flex flex-col gap-5 lg:border-l lg:border-ink-100 lg:pl-6 lg:dark:border-ink-800">
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

            <div className="flex flex-1 flex-col">
              <label className="label">Kişisel Not</label>
              <textarea
                className="input min-h-[100px] flex-1"
                value={note}
                onChange={(e) => setNote(e.target.value)}
              />
              <button className="btn-secondary mt-2 self-start !px-4 !py-2 text-xs" onClick={saveNote} disabled={busy}>
                Notu Kaydet
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
