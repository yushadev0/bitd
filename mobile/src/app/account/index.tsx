import { Host, Picker, Text as SwiftText } from '@expo/ui/swift-ui';
import { pickerStyle, tag } from '@expo/ui/swift-ui/modifiers';
import * as Application from 'expo-application';
import { Stack, router } from 'expo-router';
import * as WebBrowser from 'expo-web-browser';
import { Alert, Linking, ScrollView, StyleSheet, Switch, View } from 'react-native';

import { API_ORIGIN } from '@/api/client';
import { SettingsGroup, SettingsRow, SettingsSection } from '@/components/settings-list';
import { describeSync } from '@/components/sync-status';
import { Radius, Spacing } from '@/constants/theme';
import { useAuth } from '@/context/auth';
import { useTheme } from '@/hooks/use-theme';
import { locale, localeTag, t } from '@/lib/i18n';
import { setPushEnabled, usePushEnabled } from '@/lib/push';
import { requestSync, useSyncStatus } from '@/lib/sync';
import { setThemePreference, useThemePreference, type ThemePreference } from '@/lib/theme-preference';

const PRIVACY_URL = `${API_ORIGIN}/bitd/privacy/?lang=${locale}`;
const VERSION = `${Application.nativeApplicationVersion ?? '?'} (${Application.nativeBuildVersion ?? '?'})`;

export default function AccountScreen() {
  const theme = useTheme();
  const { status, user, sessionExpired, signOut, setUser } = useAuth();
  const sync = useSyncStatus();
  const signedIn = status === 'signedIn';
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
    Alert.alert(
      t.account.signOutConfirm,
      sync.pending > 0 ? t.account.signOutPending(sync.pending) : t.account.signOutConfirmBody,
      [
        { text: t.common.cancel, style: 'cancel' },
        { text: t.account.signOut, style: 'destructive', onPress: signOut },
      ],
    );

  const syncInfo = describeSync(sync.state, sync.pending, sync.lastSync);

  return (
    <>
      <Stack.Toolbar placement="right">
        <Stack.Toolbar.Button icon="xmark" accessibilityLabel={t.common.close} onPress={() => router.back()} />
      </Stack.Toolbar>

      <ScrollView
        style={{ backgroundColor: theme.background }}
        contentContainerStyle={styles.content}
        contentInsetAdjustmentBehavior="automatic">
        {signedIn ? (
          <>
            <SettingsGroup>
              <SettingsRow label={t.account.username} value={user?.kullanici_adi ?? ''} />
              <SettingsRow label={t.account.email} value={user?.email ?? ''} />
            </SettingsGroup>

            <SettingsSection title={t.account.sync.toLocaleUpperCase(localeTag)} footer={syncInfo.message}>
              <SettingsGroup>
                {sessionExpired ? (
                  <SettingsRow label={t.account.signInAgain} accessory="chevron" onPress={() => router.push('/login')} />
                ) : (
                  <SettingsRow label={t.sync.syncNow} value={syncInfo.title} onPress={() => requestSync()} />
                )}
              </SettingsGroup>
            </SettingsSection>
          </>
        ) : (
          <SettingsSection title={t.account.accountSection} footer={t.account.guestFootnote}>
            <SettingsGroup>
              <SettingsRow label={t.account.signIn} accessory="chevron" onPress={() => router.push('/login')} />
              <SettingsRow label={t.account.createAccount} accessory="chevron" onPress={() => router.push('/register')} />
            </SettingsGroup>
          </SettingsSection>
        )}

        <SettingsSection title={t.account.appearance} footer={signedIn ? t.account.themeFootnote : undefined}>
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

        {signedIn ? (
          <SettingsGroup>
            <SettingsRow label={t.account.signOut} onPress={confirmSignOut} destructive />
          </SettingsGroup>
        ) : null}

        <SettingsSection title={t.account.about}>
          <SettingsGroup>
            <SettingsRow
              label={t.account.privacy}
              accessory="external"
              onPress={() => WebBrowser.openBrowserAsync(PRIVACY_URL)}
            />
            <SettingsRow label={t.account.dataSources} accessory="chevron" onPress={() => router.push('/account/credits')} />
            <SettingsRow label={t.account.version} value={VERSION} />
            {signedIn ? (
              <SettingsRow
                label={t.account.deleteAccount}
                accessory="chevron"
                destructive
                onPress={() => router.push('/account/delete')}
              />
            ) : null}
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
