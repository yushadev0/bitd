import * as Notifications from 'expo-notifications';
import { router, type Href } from 'expo-router';
import * as SecureStore from 'expo-secure-store';
import { useEffect, useSyncExternalStore } from 'react';

import { api } from '@/api/client';
import type { Category } from '@/api/types';
import { CATEGORY_ORDER } from '@/lib/categories';
import { t } from '@/lib/i18n';
import { getLibraryItems, useLibraries, useLibraryVersion } from '@/lib/library-store';

// The daily wishlist suggestion is a local notification: the phone schedules the next
// week's evenings itself, each with a random pick from its own library, so it works
// without an account and without a connection. It's rescheduled whenever the library
// changes and at every launch, so the picks stay current and never run out.

const PREF_KEY = 'bitd.push'; // 'off' once the user switches the daily suggestion off
// Builds up to 1.0 registered with the server instead (backend app/push.py); set when they did.
const LEGACY_TOKEN_KEY = 'bitd.push_token';

const SEND_HOUR = 19;
const DAYS_AHEAD = 7;
const ID_PREFIX = 'daily-suggestion-';

// Still show the banner when it fires while the app is open.
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldPlaySound: true,
    shouldSetBadge: false,
    shouldShowBanner: true,
    shouldShowList: true,
  }),
});

let enabled = true;
const listeners = new Set<() => void>();

function setEnabled(value: boolean) {
  enabled = value;
  listeners.forEach((l) => l());
}

export function usePushEnabled() {
  return useSyncExternalStore(
    (l) => {
      listeners.add(l);
      return () => listeners.delete(l);
    },
    () => enabled,
  );
}

/** Stops the server-sent pushes an earlier build signed this phone up for, so it doesn't get two a day. */
async function dropLegacyRegistration() {
  const token = await SecureStore.getItemAsync(LEGACY_TOKEN_KEY);
  if (!token) return;
  await api.post('/api/push/device/unregister', { token });
  await SecureStore.deleteItemAsync(LEGACY_TOKEN_KEY);
}

/** Restores the saved on/off choice; call once at launch. */
export async function restorePushPreference() {
  const saved = await SecureStore.getItemAsync(PREF_KEY).catch(() => null);
  setEnabled(saved !== 'off');
  dropLegacyRegistration().catch(() => {});
}

/** Asks iOS for permission if it hasn't asked yet. Resolves to whether notifications are allowed. */
export async function requestNotificationPermission(): Promise<boolean> {
  let { status } = await Notifications.getPermissionsAsync();
  if (status === 'undetermined') ({ status } = await Notifications.requestPermissionsAsync());
  return status === 'granted';
}

export async function notificationsAllowed() {
  return (await Notifications.getPermissionsAsync()).status === 'granted';
}

async function cancelScheduled() {
  const scheduled = await Notifications.getAllScheduledNotificationsAsync();
  await Promise.all(
    scheduled
      .filter((n) => n.identifier.startsWith(ID_PREFIX))
      .map((n) => Notifications.cancelScheduledNotificationAsync(n.identifier)),
  );
}

function shuffled<T>(items: T[]): T[] {
  const copy = [...items];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

/** Replaces the scheduled suggestions with fresh picks for the coming evenings. */
export async function rescheduleDailySuggestions(name: string | null) {
  await cancelScheduled();
  if (!enabled || !(await notificationsAllowed())) return;

  const wishlist = CATEGORY_ORDER.flatMap((category: Category) =>
    getLibraryItems(category)
      .filter((i) => i.istek_mi && i.detail?.title)
      .map((i) => ({ category, apiId: i.api_id, title: i.detail!.title })),
  );
  if (wishlist.length === 0) return;

  // A different pick each evening while the list allows; repeats only once it runs out.
  const picks = shuffled(wishlist);
  const first = new Date();
  first.setHours(SEND_HOUR, 0, 0, 0);
  if (first <= new Date()) first.setDate(first.getDate() + 1);

  for (let day = 0; day < DAYS_AHEAD; day++) {
    const pick = picks[day % picks.length];
    const date = new Date(first);
    date.setDate(first.getDate() + day);
    await Notifications.scheduleNotificationAsync({
      identifier: `${ID_PREFIX}${day}`,
      content: {
        title: t.push.title(name),
        body: t.push.body[pick.category](pick.title),
        sound: 'default',
        data: { url: `/${pick.category}/${encodeURIComponent(pick.apiId)}` },
      },
      trigger: { type: Notifications.SchedulableTriggerInputTypes.DATE, date },
    });
  }
}

const RESCHEDULE_DEBOUNCE_MS = 1500;

/** Keeps the scheduled suggestions in step with the library (and the greeting with the account). */
export function useDailySuggestions(active: boolean, name: string | null) {
  const libraries = useLibraries();
  const loaded = libraries.games.items !== null;
  const version = useLibraryVersion();
  const on = usePushEnabled();

  useEffect(() => {
    if (!active || !loaded) return;
    const timer = setTimeout(() => rescheduleDailySuggestions(name).catch(() => {}), RESCHEDULE_DEBOUNCE_MS);
    return () => clearTimeout(timer);
    // `libraries` changes when a sync or a detail fetch brings in new titles.
  }, [active, loaded, version, libraries, on, name]);
}

/** The settings toggle. Resolves to false if iOS permission is denied. */
export async function setPushEnabled(on: boolean): Promise<boolean> {
  const granted = on ? await requestNotificationPermission() : false;
  setEnabled(on && granted);
  await SecureStore.setItemAsync(PREF_KEY, on && granted ? 'on' : 'off');
  if (!on || !granted) await cancelScheduled();
  return !on || granted;
}

// Remembered so a cold-start tap isn't replayed when the navigator remounts.
let handledResponseId: string | null = null;

function openFromNotification(response: Notifications.NotificationResponse | null) {
  if (!response) return;
  const id = response.notification.request.identifier;
  if (id === handledResponseId) return;
  handledResponseId = id;
  const url = response.notification.request.content.data?.url;
  if (typeof url === 'string' && url.startsWith('/')) router.push(url as Href);
}

/** Opens the suggested item's detail screen when a notification is tapped, including on cold start. */
export function useNotificationDeepLinks(active: boolean) {
  useEffect(() => {
    if (!active) return;
    openFromNotification(Notifications.getLastNotificationResponse());
    const subscription = Notifications.addNotificationResponseReceivedListener(openFromNotification);
    return () => subscription.remove();
  }, [active]);
}
