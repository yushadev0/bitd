import { Stack, router, useFocusEffect, type Href } from 'expo-router';
import { SymbolView } from 'expo-symbols';
import { useCallback, useRef, useState } from 'react';
import { ActivityIndicator, Pressable, RefreshControl, ScrollView, StyleSheet, Text, View } from 'react-native';

import { dashboardApi } from '@/api/endpoints';
import type { Category, DashboardResponse, RecentItem } from '@/api/types';
import { PosterCard } from '@/components/poster-card';
import { Radius, Spacing } from '@/constants/theme';
import { useAuth } from '@/context/auth';
import { useTheme } from '@/hooks/use-theme';
import { CATEGORIES, CATEGORY_ORDER } from '@/lib/categories';
import { useLibraryVersion } from '@/lib/library-store';

type Recent = Partial<Record<Category, RecentItem[]>>;

function StatCard({ category, stats }: { category: Category; stats: DashboardResponse | null }) {
  const theme = useTheme();
  const meta = CATEGORIES[category];
  const s = stats?.[meta.statsKey];

  return (
    <Pressable
      onPress={() => router.navigate(`/${category}` as Href)}
      accessibilityRole="button"
      style={({ pressed }) => [
        styles.statCard,
        { backgroundColor: theme.backgroundElement, opacity: pressed ? 0.7 : 1 },
      ]}>
      <SymbolView name={meta.iconSelected} tintColor={theme.accent} size={22} />
      <Text style={[styles.statNumber, { color: theme.text }]}>{s ? s.total - s.wishlist : '–'}</Text>
      <Text style={[styles.statLabel, { color: theme.text }]}>{meta.title}</Text>
      <Text style={[styles.statSub, { color: theme.textSecondary }]}>
        {s ? `${s.wishlist} listede bekliyor` : ' '}
      </Text>
    </Pressable>
  );
}

export default function HomeScreen() {
  const theme = useTheme();
  const { user } = useAuth();

  const [stats, setStats] = useState<DashboardResponse | null>(null);
  const [recent, setRecent] = useState<Recent>({});
  const [refreshing, setRefreshing] = useState(false);

  const load = useCallback(async () => {
    // Stats and each category's recent strip load independently so one slow
    // upstream API (IGDB, TMDB…) doesn't hold back the rest.
    const statsP = dashboardApi.stats().then(setStats);
    const recentP = CATEGORY_ORDER.map((c) =>
      dashboardApi.recent(c).then((items) => setRecent((r) => ({ ...r, [c]: items }))),
    );
    await Promise.allSettled([statsP, ...recentP]);
  }, []);

  // Refetch when this tab comes back into view after something changed elsewhere
  // (an item added, moved or deleted), instead of on every mutation in the background.
  const version = useLibraryVersion();
  const loadedVersion = useRef<number | null>(null);
  useFocusEffect(
    useCallback(() => {
      if (loadedVersion.current === version) return;
      loadedVersion.current = version;
      load();
    }, [version, load]),
  );

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await load();
    setRefreshing(false);
  }, [load]);

  return (
    <>
      <Stack.Screen options={{ title: user ? `Merhaba, ${user.kullanici_adi}` : 'Özet' }} />
      <Stack.Toolbar placement="right">
        <Stack.Toolbar.Button
          icon="person.crop.circle"
          accessibilityLabel="Hesap"
          onPress={() => router.push('/account')}
        />
      </Stack.Toolbar>

      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        contentContainerStyle={styles.content}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}>
        <View style={styles.grid}>
          {CATEGORY_ORDER.map((c) => (
            <StatCard key={c} category={c} stats={stats} />
          ))}
        </View>

        {CATEGORY_ORDER.map((c) => {
          const items = recent[c];
          if (items && items.length === 0) return null;
          return (
            <View key={c} style={styles.recentSection}>
              <Text style={[styles.sectionTitle, { color: theme.text }]}>Son {CATEGORIES[c].title}</Text>
              {items ? (
                <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.strip}>
                  {items.map((item) => (
                    <PosterCard
                      key={item.api_id}
                      title={item.title}
                      poster={item.poster}
                      width={110}
                      onPress={() => router.push(`/${c}/${encodeURIComponent(item.api_id)}` as Href)}
                    />
                  ))}
                </ScrollView>
              ) : (
                <ActivityIndicator style={styles.stripLoading} />
              )}
            </View>
          );
        })}
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  content: { paddingBottom: Spacing.six },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.three,
    paddingHorizontal: Spacing.three,
    paddingTop: Spacing.two,
  },
  statCard: {
    // two columns: (100% - one gap) / 2
    flexBasis: '47%',
    flexGrow: 1,
    padding: Spacing.three,
    borderRadius: Radius.card,
    borderCurve: 'continuous',
    gap: Spacing.half,
  },
  statNumber: { fontSize: 34, fontWeight: '700', fontVariant: ['tabular-nums'], marginTop: Spacing.two },
  statLabel: { fontSize: 15, fontWeight: '600' },
  statSub: { fontSize: 13 },
  recentSection: { marginTop: Spacing.four, gap: Spacing.two },
  sectionTitle: { fontSize: 20, fontWeight: '700', paddingHorizontal: Spacing.three },
  strip: { paddingHorizontal: Spacing.three, gap: Spacing.three },
  stripLoading: { height: 190 },
});
