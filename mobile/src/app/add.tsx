import { Image } from 'expo-image';
import * as Haptics from 'expo-haptics';
import { Stack, router, useLocalSearchParams } from 'expo-router';
import { SymbolView } from 'expo-symbols';
import { useEffect, useMemo, useRef, useState } from 'react';
import { ActionSheetIOS, ActivityIndicator, Alert, FlatList, Platform, Pressable, StyleSheet, Text, View } from 'react-native';

import { libraryApi } from '@/api/endpoints';
import type { Category, SearchResult } from '@/api/types';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { CATEGORIES } from '@/lib/categories';
import { posterUri } from '@/lib/image';
import { t } from '@/lib/i18n';
import { libraryActions, useLibrary } from '@/lib/library-store';

const SEARCH_DELAY_MS = 400;

function chooseList(title: string, completedLabel: string, wishlistLabel: string): Promise<boolean | null> {
  const options = [t.add.addTo(completedLabel), t.add.addTo(wishlistLabel), t.common.cancel];
  return new Promise((resolve) => {
    if (Platform.OS === 'ios') {
      ActionSheetIOS.showActionSheetWithOptions({ title, options, cancelButtonIndex: 2 }, (i) =>
        resolve(i === 0 ? false : i === 1 ? true : null),
      );
    } else {
      Alert.alert(title, undefined, [
        { text: options[0], onPress: () => resolve(false) },
        { text: options[1], onPress: () => resolve(true) },
        { text: options[2], style: 'cancel', onPress: () => resolve(null) },
      ]);
    }
  });
}

export default function AddScreen() {
  const theme = useTheme();
  const { category } = useLocalSearchParams<{ category: Category }>();
  const meta = CATEGORIES[category];
  const api = useMemo(() => libraryApi(category), [category]);
  const { items } = useLibrary(category);

  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[] | null>(null);
  const [searching, setSearching] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [justAdded, setJustAdded] = useState<Set<string>>(new Set());
  const requestId = useRef(0);

  const owned = useMemo(() => new Set(items?.map((i) => i.api_id)), [items]);

  // Debounced search; stale responses from earlier keystrokes are dropped.
  useEffect(() => {
    const q = query.trim();
    const id = ++requestId.current;
    if (q.length < 2) return;
    const timer = setTimeout(() => {
      setSearching(true);
      api
        .search(q)
        .then((r) => {
          if (id !== requestId.current) return;
          setResults(r);
          setError(null);
        })
        .catch((e: unknown) => id === requestId.current && setError(e instanceof Error ? e.message : t.add.searchFailed))
        .finally(() => id === requestId.current && setSearching(false));
    }, SEARCH_DELAY_MS);
    return () => clearTimeout(timer);
  }, [query, api]);

  const add = async (result: SearchResult) => {
    const istekMi = await chooseList(result.title, meta.completedLabel, meta.wishlistLabel);
    if (istekMi === null) return;
    try {
      await libraryActions.add(category, result.api_id, istekMi);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      setJustAdded((s) => new Set(s).add(result.api_id));
    } catch (e) {
      Alert.alert(t.add.failed, e instanceof Error ? e.message : undefined);
    }
  };

  const showResults = query.trim().length >= 2 && results !== null;

  return (
    <>
      <Stack.Screen options={{ title: meta.addTitle }} />
      <Stack.Toolbar placement="right">
        <Stack.Toolbar.Button icon="checkmark" variant="done" accessibilityLabel={t.common.done} onPress={() => router.back()} />
      </Stack.Toolbar>
      <Stack.SearchBar
        placeholder={meta.searchPlaceholder}
        autoFocus
        hideWhenScrolling={false}
        onChangeText={(e) => setQuery(e.nativeEvent.text)}
        tintColor={theme.accent}
      />

      <FlatList
        data={showResults ? results : []}
        keyExtractor={(r) => r.api_id}
        contentInsetAdjustmentBehavior="automatic"
        keyboardDismissMode="on-drag"
        keyboardShouldPersistTaps="handled"
        style={{ backgroundColor: theme.background }}
        contentContainerStyle={styles.content}
        ListHeaderComponent={searching ? <ActivityIndicator style={styles.spinner} /> : null}
        ListEmptyComponent={
          searching ? null : (
            <View style={styles.empty}>
              <SymbolView name="magnifyingglass" size={40} tintColor={theme.textSecondary} />
              <Text style={[styles.emptyText, { color: theme.textSecondary }]}>
                {error ?? (showResults ? t.add.noResults : meta.searchHint)}
              </Text>
            </View>
          )
        }
        ItemSeparatorComponent={() => <View style={[styles.separator, { backgroundColor: theme.separator }]} />}
        renderItem={({ item: r }) => {
          const inLibrary = owned.has(r.api_id) || justAdded.has(r.api_id);
          return (
            <Pressable
              onPress={() => add(r)}
              disabled={inLibrary}
              style={({ pressed }) => [styles.row, pressed && { backgroundColor: theme.backgroundSelected }]}>
              <View style={[styles.thumb, { backgroundColor: theme.backgroundElement }]}>
                <Image source={posterUri(r.poster)} style={StyleSheet.absoluteFill} contentFit="cover" />
              </View>
              <View style={styles.info}>
                <Text numberOfLines={2} style={[styles.title, { color: theme.text }]}>
                  {r.title}
                </Text>
                <Text numberOfLines={1} style={[styles.meta, { color: theme.textSecondary }]}>
                  {[r.year, r.score != null ? `★ ${r.score}` : null, r.genres.slice(0, 2).join(', ')]
                    .filter(Boolean)
                    .join(' · ')}
                </Text>
              </View>
              <SymbolView
                name={inLibrary ? 'checkmark.circle.fill' : 'plus.circle'}
                size={26}
                tintColor={inLibrary ? theme.textSecondary : theme.accent}
              />
            </Pressable>
          );
        }}
      />
    </>
  );
}

const styles = StyleSheet.create({
  content: { paddingBottom: Spacing.six },
  spinner: { marginVertical: Spacing.three },
  empty: { alignItems: 'center', gap: Spacing.three, paddingTop: Spacing.six, paddingHorizontal: Spacing.five },
  emptyText: { fontSize: 16, textAlign: 'center' },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.three,
    paddingHorizontal: Spacing.three,
    paddingVertical: Spacing.two,
  },
  thumb: { width: 52, aspectRatio: 2 / 3, borderRadius: 6, borderCurve: 'continuous', overflow: 'hidden' },
  info: { flex: 1, gap: 2 },
  title: { fontSize: 17, fontWeight: '600' },
  meta: { fontSize: 14 },
  separator: { height: StyleSheet.hairlineWidth, marginLeft: Spacing.three + 52 + Spacing.three },
});

