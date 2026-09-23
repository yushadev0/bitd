import { Stack } from 'expo-router';
import { Platform } from 'react-native';

// Every tab owns a native stack so it gets a large, collapsing title and can push
// detail screens without leaving the tab.
export function TabStack() {
  return (
    <Stack
      screenOptions={{
        headerLargeTitleEnabled: true,
        // Content scrolls under the bar; iOS 26 draws its own scroll-edge effect.
        headerTransparent: Platform.OS === 'ios',
        headerShadowVisible: false,
        headerLargeTitleShadowVisible: false,
      }}
    />
  );
}
