import { useSyncExternalStore } from 'react';

import { getMeta, setMeta } from '@/lib/db';

// Whether the first-launch introduction has been seen. Null until read at launch.
// Kept in the app's own database rather than the Keychain, so deleting the app brings
// the introduction back on reinstall.

const KEY = 'onboarded';
let done: boolean | null = null;
const listeners = new Set<() => void>();

function set(value: boolean) {
  done = value;
  listeners.forEach((l) => l());
}

/** Call once at launch; the splash screen waits for it. */
export async function restoreOnboarding() {
  set((await getMeta(KEY).catch(() => null)) === '1');
}

export function completeOnboarding() {
  if (done) return;
  set(true);
  setMeta(KEY, '1').catch(() => {});
}

/** Settings → Show Introduction. */
export function showOnboardingAgain() {
  set(false);
  setMeta(KEY, null).catch(() => {});
}

export function useOnboarded() {
  return useSyncExternalStore(
    (l) => {
      listeners.add(l);
      return () => listeners.delete(l);
    },
    () => done,
  );
}
