import { Host, Picker, Text as SwiftText } from '@expo/ui/swift-ui';
import { pickerStyle, tag } from '@expo/ui/swift-ui/modifiers';
import { Stack, router } from 'expo-router';
import { Alert, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { Radius, Spacing } from '@/constants/theme';
import { useAuth } from '@/context/auth';
import { useTheme } from '@/hooks/use-theme';
import { setThemePreference, useThemePreference, type ThemePreference } from '@/lib/theme-preference';

function Row({ label, value }: { label: string; value: string }) {
  const theme = useTheme();
  return (
    <View style={styles.row}>
      <Text style={[styles.label, { color: theme.text }]}>{label}</Text>
      <Text style={[styles.value, { color: theme.textSecondary }]} numberOfLines={1}>
        {value}
      </Text>
    </View>
  );
}

export default function AccountScreen() {
  const theme = useTheme();
  const { user, signOut, setUser } = useAuth();
  const themePreference = useThemePreference();

  const changeTheme = (pref: ThemePreference) =>
    setThemePreference(pref)
      .then((updated) => updated && setUser(updated))
      // The local switch already happened; only the web sync failed, which isn't worth an alert.
      .catch(() => {});

  const confirmSignOut = () =>
    Alert.alert('Çıkış yapılsın mı?', undefined, [
      { text: 'Vazgeç', style: 'cancel' },
      { text: 'Çıkış Yap', style: 'destructive', onPress: signOut },
    ]);

  return (
    <>
      <Stack.Toolbar placement="right">
        <Stack.Toolbar.Button icon="xmark" accessibilityLabel="Kapat" onPress={() => router.back()} />
      </Stack.Toolbar>

      <ScrollView
        style={{ backgroundColor: theme.background }}
        contentContainerStyle={styles.content}
        contentInsetAdjustmentBehavior="automatic">
        <View style={[styles.group, { backgroundColor: theme.backgroundElement }]}>
          <Row label="Kullanıcı adı" value={user?.kullanici_adi ?? ''} />
          <View style={[styles.separator, { backgroundColor: theme.separator }]} />
          <Row label="E-posta" value={user?.email ?? ''} />
        </View>

        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: theme.textSecondary }]}>GÖRÜNÜM</Text>
          <View style={[styles.group, styles.pickerGroup, { backgroundColor: theme.backgroundElement }]}>
            <Host matchContents={{ vertical: true }} style={styles.stretch}>
              <Picker
                selection={themePreference}
                onSelectionChange={(value) => changeTheme(value as ThemePreference)}
                modifiers={[pickerStyle('segmented')]}>
                <SwiftText modifiers={[tag('system')]}>Sistem</SwiftText>
                <SwiftText modifiers={[tag('light')]}>Açık</SwiftText>
                <SwiftText modifiers={[tag('dark')]}>Koyu</SwiftText>
              </Picker>
            </Host>
          </View>
          <Text style={[styles.footnote, { color: theme.textSecondary }]}>
            Açık veya Koyu seçimi web uygulamasına da uygulanır.
          </Text>
        </View>

        <Pressable
          onPress={confirmSignOut}
          accessibilityRole="button"
          style={({ pressed }) => [
            styles.group,
            styles.signOut,
            { backgroundColor: theme.backgroundElement, opacity: pressed ? 0.7 : 1 },
          ]}>
          <Text style={[styles.signOutText, { color: theme.danger }]}>Çıkış Yap</Text>
        </Pressable>
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  content: { padding: Spacing.three, gap: Spacing.four },
  group: { borderRadius: Radius.card, borderCurve: 'continuous', overflow: 'hidden' },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: Spacing.three,
    paddingHorizontal: Spacing.three,
    paddingVertical: 14,
  },
  label: { fontSize: 17 },
  value: { fontSize: 17, flexShrink: 1 },
  separator: { height: StyleSheet.hairlineWidth, marginLeft: Spacing.three },
  signOut: { alignItems: 'center', paddingVertical: 14 },
  section: { gap: Spacing.two },
  sectionTitle: { fontSize: 13, marginLeft: Spacing.three },
  pickerGroup: { padding: Spacing.three },
  stretch: { alignSelf: 'stretch' },
  footnote: { fontSize: 13, marginHorizontal: Spacing.three },
  signOutText: { fontSize: 17, fontWeight: '600' },
});
