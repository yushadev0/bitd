import { router } from 'expo-router';
import { Alert } from 'react-native';
import type { SFSymbol } from 'sf-symbols-typescript';

import { useAuth } from '@/context/auth';
import { localeTag, t } from '@/lib/i18n';
import { requestSync, useSyncStatus, type SyncState } from '@/lib/sync';

const ICONS: Record<Exclude<SyncState, 'off'>, SFSymbol> = {
  synced: 'checkmark.icloud',
  syncing: 'arrow.triangle.2.circlepath.icloud',
  offline: 'icloud.slash',
  error: 'exclamationmark.icloud',
  expired: 'exclamationmark.icloud',
};

const timeFormat = new Intl.DateTimeFormat(localeTag, { dateStyle: 'medium', timeStyle: 'short' });

/** What the sync looks like right now, in words: a headline and a line of detail. */
export function describeSync(state: SyncState, pending: number, lastSync: Date | null) {
  const title = state === 'off' ? '' : t.sync[state];
  const lines: string[] = [];
  if (state === 'offline') lines.push(t.sync.offlineBody);
  if (state === 'error') lines.push(t.sync.errorBody);
  if (state === 'expired') lines.push(t.sync.expiredBody);
  if (pending > 0 && state !== 'synced') lines.push(t.sync.pending(pending));
  lines.push(lastSync ? t.sync.lastSync(timeFormat.format(lastSync)) : t.sync.never);
  return { title, message: lines.join('\n\n') };
}

/** The cloud button's icon and action; null without an account. */
export function useSyncIndicator(): { icon: SFSymbol; label: string; onPress: () => void } | null {
  const { status } = useAuth();
  const { state, pending, lastSync } = useSyncStatus();
  if (status !== 'signedIn' || state === 'off') return null;

  const onPress = () => {
    const { title, message } = describeSync(state, pending, lastSync);
    Alert.alert(title, message, [
      { text: t.common.ok, style: 'cancel' },
      state === 'expired'
        ? { text: t.account.signInAgain, onPress: () => router.push('/login') }
        : { text: t.sync.syncNow, onPress: () => requestSync() },
    ]);
  };

  return { icon: ICONS[state], label: `${t.sync.a11y}: ${t.sync[state]}`, onPress };
}
