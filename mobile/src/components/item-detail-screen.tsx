import { DatePicker, Host, Picker, Text as SwiftText } from '@expo/ui/swift-ui';
import { datePickerStyle, labelsHidden, pickerStyle, tag, tint } from '@expo/ui/swift-ui/modifiers';
import { Image } from 'expo-image';
import * as Haptics from 'expo-haptics';
import { Link, Stack, router, useLocalSearchParams } from 'expo-router';
import * as WebBrowser from 'expo-web-browser';
import { useEffect, useState } from 'react';
import { ActivityIndicator, Alert, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';

import type { Category, ItemDetail, LibraryItem } from '@/api/types';
import { MaxWidth, Radius, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { CATEGORIES } from '@/lib/categories';
import { localeTag, t } from '@/lib/i18n';
import { posterUri } from '@/lib/image';
import { libraryActions, loadLibrary, useLibrary, useLibraryItem } from '@/lib/library-store';

function parseISODate(value: string | null) {
  if (!value) return new Date();
  const [y, m, d] = value.slice(0, 10).split('-').map(Number);
  return new Date(y, m - 1, d);
}

const dateFormat = new Intl.DateTimeFormat(localeTag, { day: 'numeric', month: 'long', year: 'numeric' });

function facts(detail: ItemDetail | null, item: LibraryItem): [string, string][] {
  const rows: [string, string | number | null | undefined][] = [
    [t.detail.score, detail?.score],
    [t.detail.runtime, detail?.runtime_minutes ? t.detail.minutes(detail.runtime_minutes) : undefined],
    [t.detail.director, detail?.director],
    [t.detail.seasons, detail?.seasons],
    [t.detail.network, detail?.network],
    [t.detail.platform, detail?.platforms?.join(', ')],
    [t.detail.author, detail?.authors?.join(', ')],
    [t.detail.pages, detail?.page_count],
    [t.detail.added, dateFormat.format(new Date(item.eklenme_tarihi))],
  ];
  return rows.filter((r): r is [string, string | number] => r[1] != null && r[1] !== '').map(([k, v]) => [k, String(v)]);
}

function showError(e: unknown) {
  Alert.alert(t.common.actionFailed, e instanceof Error ? e.message : undefined);
}

export function ItemDetailScreen({ category }: { category: Category }) {
  const theme = useTheme();
  const meta = CATEGORIES[category];
  const { id } = useLocalSearchParams<{ id: string }>();
  const library = useLibrary(category);
  const item = useLibraryItem(category, id);

  // Deep links or a cold random pick can land here before the tab ever loaded its list.
  useEffect(() => {
    if (!library.items) loadLibrary(category);
  }, [library.items, category]);

  if (!item) {
    return (
      <View style={styles.center}>
        <Stack.Screen options={{ title: '' }} />
        {library.items ? (
          <Text style={{ color: theme.textSecondary }}>{t.detail.notFound}</Text>
        ) : (
          <ActivityIndicator />
        )}
      </View>
    );
  }

  return <DetailBody key={item.api_id} category={category} item={item} completedLabel={meta.completedLabel} wishlistLabel={meta.wishlistLabel} />;
}

function DetailBody({
  category,
  item,
  completedLabel,
  wishlistLabel,
}: {
  category: Category;
  item: LibraryItem;
  completedLabel: string;
  wishlistLabel: string;
}) {
  const theme = useTheme();
  const detail = item.detail;
  const [note, setNote] = useState(item.kisisel_not ?? '');
  const [noteSaved, setNoteSaved] = useState(false);
  const [summaryOpen, setSummaryOpen] = useState(false);
  const longSummary = (detail?.summary?.length ?? 0) > 320;

  const setStatus = (istekMi: boolean) => {
    if (istekMi === item.istek_mi) return;
    Haptics.selectionAsync();
    libraryActions.setStatus(category, item.api_id, istekMi).catch(showError);
  };

  const saveNote = () => {
    if (note === (item.kisisel_not ?? '')) return;
    libraryActions
      .setNote(category, item.api_id, note)
      .then(() => {
        setNoteSaved(true);
        setTimeout(() => setNoteSaved(false), 1500);
      })
      .catch(showError);
  };

  const confirmDelete = () =>
    Alert.alert(t.detail.deleteConfirm(detail?.title ?? t.detail.thisItem), t.detail.irreversible, [
      { text: t.common.cancel, style: 'cancel' },
      {
        text: t.common.delete,
        style: 'destructive',
        onPress: () =>
          libraryActions
            .remove(category, item.api_id)
            .then(() => {
              Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
              router.back();
            })
            .catch(showError),
      },
    ]);

  return (
    <>
      <Stack.Screen options={{ title: '', headerLargeTitleEnabled: false }} />
      <Stack.Toolbar placement="right">
        <Stack.Toolbar.Menu icon="ellipsis" accessibilityLabel={t.detail.moreActions}>
          <Stack.Toolbar.MenuAction
            icon={item.istek_mi ? 'checkmark.circle' : 'bookmark'}
            onPress={() => setStatus(!item.istek_mi)}>
            {t.detail.moveTo(item.istek_mi ? completedLabel : wishlistLabel)}
          </Stack.Toolbar.MenuAction>
          {detail?.trailer_url ? (
            <Stack.Toolbar.MenuAction
              icon="play.rectangle"
              onPress={() => WebBrowser.openBrowserAsync(detail.trailer_url!)}>
              {t.detail.watchTrailer}
            </Stack.Toolbar.MenuAction>
          ) : null}
          {detail?.preview_link ? (
            <Stack.Toolbar.MenuAction
              icon="book"
              onPress={() => WebBrowser.openBrowserAsync(detail.preview_link!)}>
              {t.detail.openPreview}
            </Stack.Toolbar.MenuAction>
          ) : null}
          <Stack.Toolbar.MenuAction icon="trash" destructive onPress={confirmDelete}>
            {t.common.delete}
          </Stack.Toolbar.MenuAction>
        </Stack.Toolbar.Menu>
      </Stack.Toolbar>

      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        automaticallyAdjustKeyboardInsets
        keyboardDismissMode="interactive"
        contentContainerStyle={styles.content}>
        {/* Hero */}
        <View style={styles.hero}>
          <Link.AppleZoomTarget>
            <View style={[styles.poster, { backgroundColor: theme.backgroundElement }]}>
              <Image source={posterUri(detail?.poster)} style={StyleSheet.absoluteFill} contentFit="cover" />
            </View>
          </Link.AppleZoomTarget>
          <Text style={[styles.title, { color: theme.text }]} selectable>
            {detail?.title ?? '?'}
          </Text>
          <Text style={[styles.subtitle, { color: theme.textSecondary }]}>
            {[detail?.year, ...(detail?.genres?.slice(0, 3) ?? [])].filter(Boolean).join(' · ')}
          </Text>
        </View>

        {/* Status + date */}
        <View style={[styles.card, { backgroundColor: theme.backgroundElement }]}>
          <Host matchContents={{ vertical: true }} style={styles.stretch}>
            <Picker
              selection={item.istek_mi ? 'wish' : 'done'}
              onSelectionChange={(value) => setStatus(value === 'wish')}
              modifiers={[pickerStyle('segmented')]}>
              <SwiftText modifiers={[tag('done')]}>{completedLabel}</SwiftText>
              <SwiftText modifiers={[tag('wish')]}>{wishlistLabel}</SwiftText>
            </Picker>
          </Host>

          {!item.istek_mi ? (
            <View style={styles.dateRow}>
              <Text style={[styles.rowLabel, { color: theme.text }]}>{t.detail.finishDate}</Text>
              <Host matchContents>
                <DatePicker
                  selection={parseISODate(item.bitirme_tarihi)}
                  displayedComponents={['date']}
                  range={{ end: new Date() }}
                  onDateChange={(date) => libraryActions.setDate(category, item.api_id, date).catch(showError)}
                  modifiers={[datePickerStyle('compact'), labelsHidden(), tint(theme.accent)]}
                />
              </Host>
            </View>
          ) : null}
        </View>

        {/* Personal note */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={[styles.sectionTitle, { color: theme.text }]}>{t.detail.myNote}</Text>
            {noteSaved ? <Text style={[styles.saved, { color: theme.textSecondary }]}>{t.detail.saved}</Text> : null}
          </View>
          <TextInput
            value={note}
            onChangeText={setNote}
            onBlur={saveNote}
            multiline
            placeholder={t.detail.notePlaceholder}
            placeholderTextColor={theme.textSecondary}
            style={[styles.note, { backgroundColor: theme.backgroundElement, color: theme.text }]}
          />
        </View>

        {/* Summary */}
        {detail?.summary ? (
          <View style={styles.section}>
            <Text style={[styles.sectionTitle, { color: theme.text }]}>{t.detail.summary}</Text>
            <Pressable onPress={() => setSummaryOpen((o) => !o)}>
              <Text
                style={[styles.body, { color: theme.text }]}
                numberOfLines={summaryOpen || !longSummary ? undefined : 6}>
                {detail.summary}
              </Text>
              {longSummary && !summaryOpen ? (
                <Text style={[styles.more, { color: theme.accent }]}>{t.detail.readMore}</Text>
              ) : null}
            </Pressable>
          </View>
        ) : null}

        {/* Facts */}
        <View style={[styles.card, styles.facts, { backgroundColor: theme.backgroundElement }]}>
          {facts(detail, item).map(([label, value], i) => (
            <View key={label}>
              {i > 0 ? <View style={[styles.separator, { backgroundColor: theme.separator }]} /> : null}
              <View style={styles.factRow}>
                <Text style={[styles.rowLabel, { color: theme.text }]}>{label}</Text>
                <Text style={[styles.factValue, { color: theme.textSecondary }]} numberOfLines={2}>
                  {value}
                </Text>
              </View>
            </View>
          ))}
        </View>

        {/* Screenshots (games) */}
        {detail?.screenshots?.length ? (
          <View style={styles.section}>
            <Text style={[styles.sectionTitle, { color: theme.text }]}>{t.detail.screenshots}</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.shots}>
              {detail.screenshots.map((src) => (
                <Image
                  key={src}
                  source={posterUri(src)}
                  style={[styles.shot, { backgroundColor: theme.backgroundElement }]}
                  contentFit="cover"
                />
              ))}
            </ScrollView>
          </View>
        ) : null}
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  content: {
    padding: Spacing.three,
    gap: Spacing.four,
    paddingBottom: Spacing.six,
    width: '100%',
    maxWidth: MaxWidth.readable,
    alignSelf: 'center',
  },
  stretch: { alignSelf: 'stretch' },
  hero: { alignItems: 'center', gap: Spacing.two },
  poster: {
    width: 200,
    aspectRatio: 2 / 3,
    borderRadius: Radius.card,
    borderCurve: 'continuous',
    overflow: 'hidden',
    marginBottom: Spacing.two,
  },
  title: { fontSize: 26, fontWeight: '800', textAlign: 'center' },
  subtitle: { fontSize: 15, textAlign: 'center' },
  card: { borderRadius: Radius.card, borderCurve: 'continuous', padding: Spacing.three, gap: Spacing.three },
  dateRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  rowLabel: { fontSize: 17 },
  section: { gap: Spacing.two },
  sectionHeader: { flexDirection: 'row', alignItems: 'baseline', justifyContent: 'space-between' },
  sectionTitle: { fontSize: 20, fontWeight: '700' },
  saved: { fontSize: 13 },
  note: {
    minHeight: 96,
    fontSize: 17,
    padding: Spacing.three,
    paddingTop: Spacing.three,
    borderRadius: Radius.card,
    borderCurve: 'continuous',
    textAlignVertical: 'top',
  },
  body: { fontSize: 16, lineHeight: 23 },
  more: { fontSize: 15, fontWeight: '600', marginTop: Spacing.one },
  facts: { paddingVertical: Spacing.one, gap: 0 },
  factRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: Spacing.three,
    paddingVertical: 12,
  },
  factValue: { fontSize: 17, flexShrink: 1, textAlign: 'right' },
  separator: { height: StyleSheet.hairlineWidth },
  shots: { gap: Spacing.two },
  shot: { width: 280, aspectRatio: 16 / 9, borderRadius: Radius.poster, borderCurve: 'continuous' },
});
