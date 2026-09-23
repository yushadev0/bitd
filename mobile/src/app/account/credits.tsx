import { Image } from 'expo-image';
import * as WebBrowser from 'expo-web-browser';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { SettingsGroup, SettingsRow, SettingsSection } from '@/components/settings-list';
import { Radius, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { localeTag, t } from '@/lib/i18n';

const open = (url: string) => () => WebBrowser.openBrowserAsync(url);

export default function CreditsScreen() {
  const theme = useTheme();

  return (
    <ScrollView
      style={{ backgroundColor: theme.background }}
      contentContainerStyle={styles.content}
      contentInsetAdjustmentBehavior="automatic">
      <Text style={[styles.intro, { color: theme.textSecondary }]}>{t.credits.intro}</Text>

      {/* TMDB's API terms ask for their logo plus this exact notice. */}
      <SettingsSection title={t.credits.tmdb.toLocaleUpperCase(localeTag)} footer={t.credits.tmdbNotice}>
        <View style={[styles.logoCard, { backgroundColor: theme.backgroundElement }]}>
          <Image
            source={require('../../../assets/images/credits/tmdb.svg')}
            style={styles.tmdbLogo}
            contentFit="contain"
            accessibilityLabel="The Movie Database (TMDB)"
          />
        </View>
        <SettingsGroup>
          <SettingsRow label="themoviedb.org" accessory="external" onPress={open('https://www.themoviedb.org')} />
        </SettingsGroup>
      </SettingsSection>

      <SettingsSection title={t.credits.igdb.toLocaleUpperCase(localeTag)}>
        <SettingsGroup>
          <SettingsRow label="IGDB.com" accessory="external" onPress={open('https://www.igdb.com')} />
        </SettingsGroup>
      </SettingsSection>

      <SettingsSection title={t.credits.googleBooks.toLocaleUpperCase(localeTag)}>
        <SettingsGroup>
          <SettingsRow label="Google Books" accessory="external" onPress={open('https://books.google.com')} />
        </SettingsGroup>
      </SettingsSection>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  content: { padding: Spacing.three, gap: Spacing.four },
  intro: { fontSize: 15, lineHeight: 21, marginHorizontal: Spacing.three },
  logoCard: {
    borderRadius: Radius.card,
    borderCurve: 'continuous',
    alignItems: 'center',
    paddingVertical: Spacing.four,
  },
  tmdbLogo: { width: 200, aspectRatio: 273.42 / 35.52 },
});
