import Constants from 'expo-constants';
import { getCalendars } from 'expo-localization';
import * as Notifications from 'expo-notifications';
import { router, type Href } from 'expo-router';
import * as SecureStore from 'expo-secure-store';
import { useEffect, useSyncExternalStore } from 'react';

import { api } from '@/api/client';
import { locale } from '@/lib/i18n';

// The daily wishlist suggestion is sent by the server (see backend app/push.py); the app
// only hands over its Expo push token, language and time zone, and opens the item on tap.

const PREF_KEY = 'bitd.push'; // 'off' once the user switches the daily suggestion off
const TOKEN_KEY = 'bitd.push_token'; // the token last registered, so sign-out can drop it

// Still show the banner when the push lands while the app is open.
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

/** Restores the saved on/off choice; call once at launch. */
export async function restorePushPreference() {
  const saved = await SecureStore.getItemAsync(PREF_KEY).catch(() => null);
  setEnabled(saved !== 'off');
}

/**
 * Registers this device for the daily suggestion. With `prompt`, asks for permission if
 * iOS hasn't asked yet. Returns false when notifications aren't allowed.
 */
export async function registerForPush({ prompt }: { prompt: boolean }): Promise<boolean> {
  let { status } = await Notifications.getPermissionsAsync();
  if (status === 'undetermined' && prompt) {
    ({ status } = await Notifications.requestPermissionsAsync());
  }
  if (status !== 'granted') return false;

  const projectId = Constants.expoConfig?.extra?.eas?.projectId;
  const { data: token } = await Notifications.getExpoPushTokenAsync({ projectId });
  await api.put('/api/push/device', {
    token,
    dil: locale,
    saat_dilimi: getCalendars()[0]?.timeZone ?? 'Europe/Istanbul',
  });
  await SecureStore.setItemAsync(TOKEN_KEY, token);
  return true;
}

/** Stops pushes to this device (sign-out, or the user switched them off). */
export async function unregisterPush() {
  const token = await SecureStore.getItemAsync(TOKEN_KEY);
  if (!token) return;
  await api.post('/api/push/device/unregister', { token });
  await SecureStore.deleteItemAsync(TOKEN_KEY);
}

/** Runs after sign-in: re-registers every launch so the token, language and time zone stay current. */
export async function syncPush() {
  if (enabled) await registerForPush({ prompt: true });
}

/** The account screen toggle. Resolves to false if iOS permission is denied. */
export async function setPushEnabled(on: boolean): Promise<boolean> {
  if (!on) {
    setEnabled(false);
    await SecureStore.setItemAsync(PREF_KEY, 'off');
    await unregisterPush();
    return true;
  }
  const granted = await registerForPush({ prompt: true });
  setEnabled(granted);
  await SecureStore.setItemAsync(PREF_KEY, granted ? 'on' : 'off');
  return granted;
}

// Remembered across sign-ins so a cold-start tap isn't replayed when someone signs in again.
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
