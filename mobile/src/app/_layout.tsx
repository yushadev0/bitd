import { DarkTheme, DefaultTheme, Stack, ThemeProvider } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect } from 'react';
import { useColorScheme } from 'react-native';

import { AuthProvider, useAuth } from '@/context/auth';
import { restoreThemePreference } from '@/lib/theme-preference';

SplashScreen.preventAutoHideAsync();
// Resolves long before the session refresh round-trip that holds the splash screen.
restoreThemePreference();

function RootNavigator() {
  const { status } = useAuth();

  useEffect(() => {
    if (status !== 'loading') SplashScreen.hideAsync();
  }, [status]);

  // The splash screen stays up while the stored session is being restored.
  if (status === 'loading') return null;

  const signedIn = status === 'signedIn';
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Protected guard={signedIn}>
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="account" options={{ presentation: 'modal', headerShown: true, title: 'Hesap' }} />
        <Stack.Screen name="add" options={{ presentation: 'modal', headerShown: true }} />
      </Stack.Protected>
      <Stack.Protected guard={!signedIn}>
        <Stack.Screen name="login" />
        <Stack.Screen
          name="register"
          options={{ presentation: 'modal', headerShown: true, title: 'Kayıt Ol' }}
        />
        <Stack.Screen
          name="forgot-password"
          options={{ presentation: 'modal', headerShown: true, title: 'Şifremi Unuttum' }}
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
