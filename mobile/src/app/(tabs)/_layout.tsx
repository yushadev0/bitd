import * as Haptics from 'expo-haptics';
import { router, useSegments, type Href } from 'expo-router';
import { NativeTabs } from 'expo-router/unstable-native-tabs';
import { useState } from 'react';
import { Alert } from 'react-native';

import { libraryApi } from '@/api/endpoints';
import type { Category } from '@/api/types';
import { RandomAccessory } from '@/components/random-accessory';
import { useTheme } from '@/hooks/use-theme';
import { CATEGORIES, CATEGORY_ORDER } from '@/lib/categories';
import { t } from '@/lib/i18n';
import { upsertItem } from '@/lib/library-store';

function isCategory(value: string | undefined): value is Category {
  return CATEGORY_ORDER.includes(value as Category);
}

// No backgroundColor / blurEffect here on purpose: leaving the bar unstyled is what
// gives it the system Liquid Glass material on iOS 26.
export default function TabsLayout() {
  const theme = useTheme();
  const segments = useSegments() as string[];
  const [picking, setPicking] = useState(false);

  // Only offer the random pick on a category's grid, not on the dashboard or a detail page.
  const tab = segments[1];
  const category = isCategory(tab) && segments.length === 2 ? tab : null;

  const pickRandom = async () => {
    if (!category) return;
    setPicking(true);
    try {
      const item = await libraryApi(category).random();
      upsertItem(category, item);
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      router.push(`/${category}/${encodeURIComponent(item.api_id)}` as Href);
    } catch (e) {
      Alert.alert(t.random.failed, e instanceof Error ? e.message : undefined);
    } finally {
      setPicking(false);
    }
  };

  return (
    <NativeTabs minimizeBehavior="onScrollDown" tintColor={theme.accent}>
      {category ? (
        <NativeTabs.BottomAccessory>
          <RandomAccessory
            wishlistLabel={CATEGORIES[category].wishlistLabel}
            picking={picking}
            onPick={pickRandom}
          />
        </NativeTabs.BottomAccessory>
      ) : null}

      <NativeTabs.Trigger name="(home)">
        <NativeTabs.Trigger.Label>{t.home.tab}</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon sf={{ default: 'square.grid.2x2', selected: 'square.grid.2x2.fill' }} />
      </NativeTabs.Trigger>

      {CATEGORY_ORDER.map((c) => {
        const meta = CATEGORIES[c];
        return (
          <NativeTabs.Trigger key={c} name={c}>
            <NativeTabs.Trigger.Label>{meta.title}</NativeTabs.Trigger.Label>
            <NativeTabs.Trigger.Icon sf={{ default: meta.icon, selected: meta.iconSelected }} />
          </NativeTabs.Trigger>
        );
      })}
    </NativeTabs>
  );
}
