import { Host, Picker, Text as SwiftText } from '@expo/ui/swift-ui';
import { pickerStyle, tag } from '@expo/ui/swift-ui/modifiers';
import * as Application from 'expo-application';
import { Stack, router } from 'expo-router';
import * as WebBrowser from 'expo-web-browser';
import { Alert, Linking, ScrollView, StyleSheet, Switch, View } from 'react-native';

import { API_ORIGIN } from '@/api/client';
import { SettingsGroup, SettingsRow, SettingsSection } from '@/components/settings-list';
import { Radius, Spacing } from '@/constants/theme';
import { useAuth } from '@/context/auth';
import { useTheme } from '@/hooks/use-theme';
import { locale, t } from '@/lib/i18n';
import { setPushEnabled, usePushEnabled } from '@/lib/push';
import { setThemePreference, useThemePreference, type ThemePreference } from '@/lib/theme-preference';

const PRIVACY_URL = `${API_ORIGIN}/bitd/privacy/?lang=${locale}`;
const VERSION = `${Application.nativeApplicationVersion ?? '?'} (${Application.nativeBuildVersion ?? '?'})`;

export default function AccountScreen() {
  const theme = useTheme();
  const { user, signOut, setUser } = useAuth();
  const themePreference = useThemePreference();
  const pushEnabled = usePushEnabled();

  const changeTheme = (pref: ThemePreference) =>
    setThemePreference(pref)
      .then((updated) => updated && setUser(updated))
      // The local switch already happened; only the web sync failed, which isn't worth an alert.
      .catch(() => {});

  const togglePush = async (on: boolean) => {
    const ok = await setPushEnabled(on).catch(() => false);
    if (on && !ok) {
      Alert.alert(t.account.notificationsDenied, t.account.notificationsDeniedBody, [
        { text: t.common.cancel, style: 'cancel' },
        { text: t.account.openSettings, onPress: () => Linking.openSettings() },
      ]);
    }
  };

  const confirmSignOut = () =>
    Alert.alert(t.account.signOutConfirm, undefined, [
      { text: t.common.cancel, style: 'cancel' },
      { text: t.account.signOut, style: 'destructive', onPress: signOut },
    ]);

  return (
    <>
      <Stack.Toolbar placement="right">
        <Stack.Toolbar.Button icon="xmark" accessibilityLabel={t.common.close} onPress={() => router.back()} />
      </Stack.Toolbar>

      <ScrollView
        style={{ backgroundColor: theme.background }}
        contentContainerStyle={styles.content}
        contentInsetAdjustmentBehavior="automatic">
        <SettingsGroup>
          <SettingsRow label={t.account.username} value={user?.kullanici_adi ?? ''} />
          <SettingsRow label={t.account.email} value={user?.email ?? ''} />
        </SettingsGroup>

        <SettingsSection title={t.account.appearance} footer={t.account.themeFootnote}>
          <View style={[styles.pickerGroup, { backgroundColor: theme.backgroundElement }]}>
            <Host matchContents={{ vertical: true }} style={styles.stretch}>
              <Picker
                selection={themePreference}
                onSelectionChange={(value) => changeTheme(value as ThemePreference)}
                modifiers={[pickerStyle('segmented')]}>
                <SwiftText modifiers={[tag('system')]}>{t.account.themeSystem}</SwiftText>
                <SwiftText modifiers={[tag('light')]}>{t.account.themeLight}</SwiftText>
                <SwiftText modifiers={[tag('dark')]}>{t.account.themeDark}</SwiftText>
              </Picker>
            </Host>
          </View>
        </SettingsSection>

        <SettingsSection title={t.account.notifications} footer={t.account.dailySuggestionFootnote}>
          <SettingsGroup>
            <SettingsRow
              label={t.account.dailySuggestion}
              control={
                <Switch value={pushEnabled} onValueChange={togglePush} trackColor={{ true: theme.accent }} />
              }
            />
          </SettingsGroup>
        </SettingsSection>

        <SettingsGroup>
          <SettingsRow label={t.account.signOut} onPress={confirmSignOut} destructive />
        </SettingsGroup>

        <SettingsSection title={t.account.about}>
          <SettingsGroup>
            <SettingsRow
              label={t.account.privacy}
              accessory="external"
              onPress={() => WebBrowser.openBrowserAsync(PRIVACY_URL)}
            />
            <SettingsRow label={t.account.dataSources} accessory="chevron" onPress={() => router.push('/account/credits')} />
            <SettingsRow label={t.account.version} value={VERSION} />
            <SettingsRow
              label={t.account.deleteAccount}
              accessory="chevron"
              destructive
              onPress={() => router.push('/account/delete')}
            />
          </SettingsGroup>
        </SettingsSection>
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  content: { padding: Spacing.three, gap: Spacing.four },
  pickerGroup: { borderRadius: Radius.card, borderCurve: 'continuous', padding: Spacing.three },
  stretch: { alignSelf: 'stretch' },
});
