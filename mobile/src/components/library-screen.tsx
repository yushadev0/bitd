import { Link, Stack, router, type Href } from 'expo-router';
import { useCallback, useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, Pressable, RefreshControl, SectionList, StyleSheet, Text, View } from 'react-native';

import type { Category, LibraryItem } from '@/api/types';
import { PosterCard } from '@/components/poster-card';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { CATEGORIES } from '@/lib/categories';
import { loadLibrary, useLibrary } from '@/lib/library-store';

const COLUMNS = 3;

interface Section {
  title: string;
  count: number;
  emptyLabel: string;
  data: LibraryItem[][]; // rows of COLUMNS items
}

function toRows(items: LibraryItem[]): LibraryItem[][] {
  const rows: LibraryItem[][] = [];
  for (let i = 0; i < items.length; i += COLUMNS) rows.push(items.slice(i, i + COLUMNS));
  return rows;
}

function finishedYear(item: LibraryItem) {
  return item.bitirme_tarihi ? item.bitirme_tarihi.slice(0, 4) : item.detail?.year;
}

export function LibraryScreen({ category }: { category: Category }) {
  const theme = useTheme();
  const meta = CATEGORIES[category];
  const { items, error } = useLibrary(category);

  const [refreshing, setRefreshing] = useState(false);
  const [query, setQuery] = useState('');

  useEffect(() => {
    loadLibrary(category);
  }, [category]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadLibrary(category);
    setRefreshing(false);
  }, [category]);

  const sections = useMemo<Section[]>(() => {
    const needle = query.trim().toLocaleLowerCase('tr');
    const visible = (items ?? []).filter(
      (i) => !needle || (i.detail?.title ?? '').toLocaleLowerCase('tr').includes(needle),
    );
    const completed = visible.filter((i) => !i.istek_mi);
    const wishlist = visible.filter((i) => i.istek_mi);
    return [
      {
        title: meta.completedLabel,
        count: completed.length,
        emptyLabel: needle ? 'Eşleşen yok.' : 'Henüz tamamlanan bir şey yok.',
        data: toRows(completed),
      },
      {
        title: meta.wishlistLabel,
        count: wishlist.length,
        emptyLabel: needle ? 'Eşleşen yok.' : 'Listen boş.',
        data: toRows(wishlist),
      },
    ];
  }, [items, query, meta]);

  return (
    <>
      <Stack.Screen options={{ title: meta.screenTitle }} />
      <Stack.Toolbar placement="right">
        <Stack.Toolbar.Button
          icon="plus"
          accessibilityLabel={`${meta.title} ekle`}
          onPress={() => router.push({ pathname: '/add', params: { category } })}
        />
      </Stack.Toolbar>
      <Stack.SearchBar
        placeholder={`${meta.title} içinde ara`}
        onChangeText={(e) => setQuery(e.nativeEvent.text)}
        onCancelButtonPress={() => setQuery('')}
        tintColor={theme.accent}
      />

      {items === null ? (
        <View style={styles.center}>
          {error ? (
            <>
              <Text style={[styles.message, { color: theme.textSecondary }]}>{error}</Text>
              <Pressable onPress={() => loadLibrary(category)} hitSlop={12}>
                <Text style={[styles.retry, { color: theme.accent }]}>Tekrar dene</Text>
              </Pressable>
            </>
          ) : (
            <ActivityIndicator />
          )}
        </View>
      ) : (
        <SectionList
          sections={sections}
          keyExtractor={(row) => row.map((i) => i.api_id).join('|')}
          contentInsetAdjustmentBehavior="automatic"
          contentContainerStyle={styles.content}
          stickySectionHeadersEnabled={false}
          keyboardDismissMode="on-drag"
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
          renderSectionHeader={({ section }) => (
            <View style={styles.sectionHeader}>
              <Text style={[styles.sectionTitle, { color: theme.text }]}>{section.title}</Text>
              <Text style={[styles.sectionCount, { color: theme.textSecondary }]}>{section.count}</Text>
            </View>
          )}
          renderSectionFooter={({ section }) =>
            section.data.length === 0 ? (
              <Text style={[styles.empty, { color: theme.textSecondary }]}>{section.emptyLabel}</Text>
            ) : null
          }
          renderItem={({ item: row }) => (
            <View style={styles.row}>
              {row.map((item) => (
                <View key={item.api_id} style={styles.flex}>
                  {/* The poster zooms into the detail screen's hero poster (iOS 18+). */}
                  <Link href={`/${category}/${encodeURIComponent(item.api_id)}` as Href} asChild>
                    <Link.AppleZoom>
                      <PosterCard
                        title={item.detail?.title ?? '?'}
                        poster={item.detail?.poster}
                        subtitle={finishedYear(item)}
                      />
                    </Link.AppleZoom>
                  </Link>
                </View>
              ))}
              {/* keep the last row's cards the same width as full rows */}
              {Array.from({ length: COLUMNS - row.length }).map((_, i) => (
                <View key={`pad-${i}`} style={styles.flex} />
              ))}
            </View>
          )}
        />
      )}
    </>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: Spacing.three, padding: Spacing.four },
  message: { fontSize: 15, textAlign: 'center' },
  retry: { fontSize: 15, fontWeight: '600' },
  content: { paddingHorizontal: Spacing.three, paddingBottom: Spacing.six },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: Spacing.two,
    paddingTop: Spacing.four,
    paddingBottom: Spacing.two,
  },
  sectionTitle: { fontSize: 20, fontWeight: '700' },
  sectionCount: { fontSize: 15, fontVariant: ['tabular-nums'] },
  row: { flexDirection: 'row', gap: Spacing.three, marginBottom: Spacing.three },
  empty: { fontSize: 15, paddingVertical: Spacing.two },
});
