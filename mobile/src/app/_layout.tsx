import { DarkTheme, DefaultTheme, Stack, ThemeProvider } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect } from 'react';
import { useColorScheme } from 'react-native';

import { AuthProvider, useAuth } from '@/context/auth';
import { t } from '@/lib/i18n';
import { restoreOnboarding, useOnboarded } from '@/lib/onboarding';
import { restorePushPreference, useDailySuggestions, useNotificationDeepLinks } from '@/lib/push';
import { restoreThemePreference } from '@/lib/theme-preference';

SplashScreen.preventAutoHideAsync();
// All local reads; the splash screen stays up only until they (and the library) are in.
restoreThemePreference();
restorePushPreference();
restoreOnboarding();

function RootNavigator() {
  const { status, user, sessionExpired } = useAuth();
  const onboarded = useOnboarded();
  const ready = status !== 'loading' && onboarded !== null;

  useEffect(() => {
    if (ready) SplashScreen.hideAsync();
  }, [ready]);

  useNotificationDeepLinks(ready && onboarded === true);
  useDailySuggestions(ready, user?.kullanici_adi ?? null);

  if (!ready) return null;

  // Nothing here needs an account: the sign-in screens are sheets that can be opened any
  // time (from the introduction or from Settings) and close themselves once signed in.
  const canSignIn = status !== 'signedIn' || sessionExpired;
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Protected guard={onboarded}>
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="account" options={{ presentation: 'modal' }} />
        <Stack.Screen name="add" options={{ presentation: 'modal', headerShown: true }} />
      </Stack.Protected>
      <Stack.Protected guard={!onboarded}>
        <Stack.Screen name="onboarding" />
      </Stack.Protected>
      <Stack.Protected guard={canSignIn}>
        <Stack.Screen
          name="login"
          options={{ presentation: 'modal', headerShown: true, title: t.auth.signIn }}
        />
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
