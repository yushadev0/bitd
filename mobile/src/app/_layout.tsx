import { DarkTheme, DefaultTheme, Stack, ThemeProvider } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect } from 'react';
import { useColorScheme } from 'react-native';

import { AuthProvider, useAuth } from '@/context/auth';
import { t } from '@/lib/i18n';
import { restorePushPreference, syncPush, useNotificationDeepLinks } from '@/lib/push';
import { restoreThemePreference } from '@/lib/theme-preference';

SplashScreen.preventAutoHideAsync();
// Resolves long before the session refresh round-trip that holds the splash screen.
restoreThemePreference();
restorePushPreference();

function RootNavigator() {
  const { status } = useAuth();

  useEffect(() => {
    if (status !== 'loading') SplashScreen.hideAsync();
    // Asks for notification permission the first time; afterwards just refreshes the registration.
    if (status === 'signedIn') syncPush().catch(() => {});
  }, [status]);

  useNotificationDeepLinks(status === 'signedIn');

  // The splash screen stays up while the stored session is being restored.
  if (status === 'loading') return null;

  const signedIn = status === 'signedIn';
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Protected guard={signedIn}>
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="account" options={{ presentation: 'modal' }} />
        <Stack.Screen name="add" options={{ presentation: 'modal', headerShown: true }} />
      </Stack.Protected>
      <Stack.Protected guard={!signedIn}>
        <Stack.Screen name="login" />
        <Stack.Screen
          name="register"
          options={{ presentation: 'modal', headerShown: true, title: t.auth.registerTitle }}
        />
        <Stack.Screen
          name="forgot-password"
          options={{ presentation: 'modal', headerShown: true, title: t.auth.forgotTitle }}
        />
      </Stack.Protected>
    </Stack>
  );
}

export default function RootLayout() {
  const colorScheme = useColorScheme();
  return (
    <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
      <AuthProvider>
        <RootNavigator />
      </AuthProvider>
    </ThemeProvider>
  );
}
