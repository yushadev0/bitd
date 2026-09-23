import * as SecureStore from 'expo-secure-store';
import { useSyncExternalStore } from 'react';
import { Appearance } from 'react-native';

import { api } from '@/api/client';
import type { CurrentUser } from '@/api/types';

export type ThemePreference = 'system' | 'light' | 'dark';

const KEY = 'bitd.theme';
let current: ThemePreference = 'system';
const listeners = new Set<() => void>();

function apply(pref: ThemePreference) {
  current = pref;
  // Overrides the whole app, native chrome included (tab bar glass, sheets, pickers).
  Appearance.setColorScheme(pref === 'system' ? 'unspecified' : pref);
  listeners.forEach((l) => l());
}

/** Restores the saved choice; call once at launch, before the splash screen hides. */
export async function restoreThemePreference() {
  const saved = await SecureStore.getItemAsync(KEY).catch(() => null);
  if (saved === 'light' || saved === 'dark') apply(saved);
}

export async function setThemePreference(pref: ThemePreference): Promise<CurrentUser | null> {
  apply(pref);
  await SecureStore.setItemAsync(KEY, pref);
  // The backend only knows light/dark (`tema`); keep the web app in step with explicit choices.
  if (pref === 'system') return null;
  return api.patch<CurrentUser>('/api/account/theme', { tema: pref === 'dark' });
}

export function useThemePreference() {
  return useSyncExternalStore(
    (l) => {
      listeners.add(l);
      return () => listeners.delete(l);
    },
    () => current,
  );
}
