import { Stack } from 'expo-router';

import { t } from '@/lib/i18n';

// Its own stack so the sub-pages push inside the account sheet instead of over it.
export default function AccountLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: t.account.title }} />
      <Stack.Screen name="credits" options={{ title: t.account.dataSources }} />
      <Stack.Screen name="delete" options={{ title: t.deleteAccount.title }} />
    </Stack>
  );
}
