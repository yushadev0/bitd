import * as Haptics from 'expo-haptics';
import { router } from 'expo-router';
import { SymbolView } from 'expo-symbols';
import { useRef, useState, type ReactNode } from 'react';
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useWindowDimensions,
  type NativeScrollEvent,
  type NativeSyntheticEvent,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import type { SFSymbol } from 'sf-symbols-typescript';

import { PrimaryButton } from '@/components/form';
import { Fonts, MaxWidth, Radius, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { CATEGORIES, CATEGORY_ORDER } from '@/lib/categories';
import { t } from '@/lib/i18n';
import { completeOnboarding } from '@/lib/onboarding';
import { requestNotificationPermission, setPushEnabled } from '@/lib/push';

// First-launch introduction. Everything works without an account, so the way out is
// "Get Started"; signing in is offered, never required.

function Badge({ icon }: { icon: SFSymbol }) {
  const theme = useTheme();
  return (
    <View style={[styles.badge, { backgroundColor: theme.backgroundElement }]}>
      <SymbolView name={icon} size={56} tintColor={theme.accent} />
    </View>
  );
}

function Shelves() {
  const theme = useTheme();
  return (
    <View style={styles.shelves}>
      {CATEGORY_ORDER.map((c) => (
        <View key={c} style={[styles.shelf, { backgroundColor: theme.backgroundElement }]}>
          <SymbolView name={CATEGORIES[c].iconSelected} size={30} tintColor={theme.accent} />
          <Text style={[styles.shelfLabel, { color: theme.textSecondary }]} numberOfLines={1}>
            {CATEGORIES[c].title}
          </Text>
        </View>
      ))}
    </View>
  );
}

function Page({ width, art, title, body, children }: { width: number; art: ReactNode; title: string; body: string; children?: ReactNode }) {
  const theme = useTheme();
  return (
    <View style={[styles.page, { width }]}>
      <View style={styles.pageInner}>
        {art}
        <Text style={[styles.title, { color: theme.text }]}>{title}</Text>
        <Text style={[styles.body, { color: theme.textSecondary }]}>{body}</Text>
        {children}
      </View>
    </View>
  );
}

function NotificationsButton() {
  const theme = useTheme();
  const [granted, setGranted] = useState(false);

  const allow = async () => {
    const ok = await requestNotificationPermission().catch(() => false);
    if (ok) {
      await setPushEnabled(true).catch(() => {});
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    }
    setGranted(ok);
  };

  if (granted) {
    return (
      <View style={styles.granted}>
        <SymbolView name="checkmark.circle.fill" size={20} tintColor={theme.accent} />
        <Text style={[styles.grantedText, { color: theme.text }]}>{t.onboarding.notificationsOn}</Text>
      </View>
    );
  }
  return (
    <Pressable
      onPress={allow}
      accessibilityRole="button"
      style={({ pressed }) => [styles.secondaryButton, { borderColor: theme.accent, opacity: pressed ? 0.6 : 1 }]}>
      <SymbolView name="bell.badge" size={18} tintColor={theme.accent} />
      <Text style={[styles.secondaryText, { color: theme.accent }]}>{t.onboarding.allowNotifications}</Text>
    </Pressable>
  );
}

export default function OnboardingScreen() {
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const scroller = useRef<ScrollView>(null);
  const [page, setPage] = useState(0);

  const pages = [
    <Page key="welcome" width={width} art={<Badge icon="archivebox.fill" />} title={t.onboarding.welcomeTitle} body={t.onboarding.welcomeBody} />,
    <Page key="shelves" width={width} art={<Shelves />} title={t.onboarding.shelvesTitle} body={t.onboarding.shelvesBody} />,
    <Page key="random" width={width} art={<Badge icon="dice.fill" />} title={t.onboarding.randomTitle} body={t.onboarding.randomBody} />,
    <Page key="notify" width={width} art={<Badge icon="bell.fill" />} title={t.onboarding.notifyTitle} body={t.onboarding.notifyBody}>
      <NotificationsButton />
    </Page>,
  ];
  const last = page === pages.length - 1;

  const goTo = (index: number) => {
    scroller.current?.scrollTo({ x: index * width, animated: true });
    setPage(index);
  };

  const onScrollEnd = (e: NativeSyntheticEvent<NativeScrollEvent>) =>
    setPage(Math.round(e.nativeEvent.contentOffset.x / width));

  return (
    <View style={[styles.flex, { backgroundColor: theme.background, paddingTop: insets.top, paddingBottom: insets.bottom + Spacing.three }]}>
      <View style={styles.topBar}>
        {!last ? (
          <Pressable onPress={() => goTo(pages.length - 1)} hitSlop={12} accessibilityRole="button">
            <Text style={[styles.skip, { color: theme.textSecondary }]}>{t.onboarding.skip}</Text>
          </Pressable>
        ) : null}
      </View>

      <ScrollView
        ref={scroller}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={onScrollEnd}
        style={styles.flex}>
        {pages}
      </ScrollView>

      <View style={styles.footer}>
        <View style={styles.dots}>
          {pages.map((_, i) => (
            <View
              key={i}
              style={[styles.dot, { backgroundColor: i === page ? theme.accent : theme.separator }, i === page && styles.dotActive]}
            />
          ))}
        </View>

        {last ? (
          <Text style={[styles.note, { color: theme.textSecondary }]}>{t.onboarding.noAccountNeeded}</Text>
        ) : null}

        <PrimaryButton title={last ? t.onboarding.start : t.onboarding.next} onPress={() => (last ? completeOnboarding() : goTo(page + 1))} />

        {last ? (
          <Pressable onPress={() => router.push('/login')} hitSlop={8} accessibilityRole="button">
            <Text style={[styles.link, { color: theme.accent }]}>{t.onboarding.haveAccount}</Text>
          </Pressable>
        ) : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  topBar: { height: 44, alignItems: 'flex-end', justifyContent: 'center', paddingHorizontal: Spacing.four },
  skip: { fontSize: 17 },
  page: { flex: 1, justifyContent: 'center', paddingHorizontal: Spacing.four },
  pageInner: { width: '100%', maxWidth: MaxWidth.form, alignSelf: 'center', alignItems: 'center', gap: Spacing.three },
  badge: {
    width: 120,
    height: 120,
    borderRadius: 32,
    borderCurve: 'continuous',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: Spacing.three,
  },
  shelves: { flexDirection: 'row', gap: Spacing.two, marginBottom: Spacing.three },
  shelf: {
    width: 76,
    paddingVertical: Spacing.three,
    borderRadius: Radius.card,
    borderCurve: 'continuous',
    alignItems: 'center',
    gap: Spacing.two,
  },
  shelfLabel: { fontSize: 12, fontWeight: '600' },
  title: { fontSize: 30, fontWeight: '800', textAlign: 'center', fontFamily: Fonts.rounded },
  body: { fontSize: 17, lineHeight: 24, textAlign: 'center' },
  secondaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.two,
    marginTop: Spacing.three,
    paddingHorizontal: Spacing.four,
    paddingVertical: 12,
    borderRadius: 999,
    borderWidth: 1.5,
  },
  secondaryText: { fontSize: 16, fontWeight: '600' },
  granted: { flexDirection: 'row', alignItems: 'center', gap: Spacing.two, marginTop: Spacing.three, paddingVertical: 12 },
  grantedText: { fontSize: 16, fontWeight: '600' },
  footer: {
    paddingHorizontal: Spacing.four,
    gap: Spacing.three,
    width: '100%',
    maxWidth: MaxWidth.form,
    alignSelf: 'center',
  },
  dots: { flexDirection: 'row', justifyContent: 'center', gap: Spacing.two, marginBottom: Spacing.one },
  dot: { width: 8, height: 8, borderRadius: 4 },
  dotActive: { width: 22 },
  note: { fontSize: 14, lineHeight: 20, textAlign: 'center' },
  link: { fontSize: 16, fontWeight: '600', textAlign: 'center', paddingVertical: Spacing.one },
});
