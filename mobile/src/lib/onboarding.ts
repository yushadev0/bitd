import * as SecureStore from 'expo-secure-store';
import { useSyncExternalStore } from 'react';

// Whether the first-launch introduction has been seen. Null until read at launch.

const KEY = 'bitd.onboarded';
let done: boolean | null = null;
const listeners = new Set<() => void>();

function set(value: boolean) {
  done = value;
  listeners.forEach((l) => l());
}

/** Call once at launch; the splash screen waits for it. */
export async function restoreOnboarding() {
  const saved = await SecureStore.getItemAsync(KEY).catch(() => null);
  set(saved === '1');
}

export function completeOnboarding() {
  if (done) return;
  set(true);
  SecureStore.setItemAsync(KEY, '1').catch(() => {});
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
