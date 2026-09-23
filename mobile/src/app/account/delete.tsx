import * as Haptics from 'expo-haptics';
import { SymbolView } from 'expo-symbols';
import { useState } from 'react';
import { Alert, KeyboardAvoidingView, ScrollView, StyleSheet, Text, View } from 'react-native';

import { authApi } from '@/api/endpoints';
import { Field, PrimaryButton } from '@/components/form';
import { MaxWidth, Radius, Spacing } from '@/constants/theme';
import { useAuth } from '@/context/auth';
import { useTheme } from '@/hooks/use-theme';
import { localeTag, t } from '@/lib/i18n';

// Case and extra spaces don't matter; the words do — like GitHub's repo deletion.
const normalize = (value: string) => value.trim().replace(/\s+/g, ' ').toLocaleLowerCase(localeTag);

export default function DeleteAccountScreen() {
  const theme = useTheme();
  const { user, signOut } = useAuth();
  const [typed, setTyped] = useState('');
  const [busy, setBusy] = useState(false);

  const confirmed = normalize(typed) === normalize(t.deleteAccount.phrase);

  const deleteAccount = async () => {
    if (!confirmed) return;
    setBusy(true);
    try {
      await authApi.deleteAccount();
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      // Dropping the session makes the auth guard swap everything out for the login screen.
      await signOut();
    } catch (e) {
      setBusy(false);
      Alert.alert(t.deleteAccount.failed, e instanceof Error ? e.message : undefined);
    }
  };

  return (
    <KeyboardAvoidingView behavior="padding" style={[styles.flex, { backgroundColor: theme.background }]}>
      <ScrollView
        contentContainerStyle={styles.content}
        contentInsetAdjustmentBehavior="automatic"
        keyboardShouldPersistTaps="handled">
        <View style={styles.header}>
          <SymbolView name="exclamationmark.triangle.fill" size={44} tintColor={theme.danger} />
          <Text style={[styles.warning, { color: theme.text }]}>{t.deleteAccount.warning}</Text>
          <Text style={[styles.body, { color: theme.textSecondary }]}>
            {t.deleteAccount.body(user?.kullanici_adi ?? '')}
          </Text>
        </View>

        <View style={styles.confirm}>
          <Text style={[styles.prompt, { color: theme.text }]}>{t.deleteAccount.prompt}</Text>
          <View style={[styles.phraseBox, { backgroundColor: theme.backgroundElement }]}>
            <Text style={[styles.phrase, { color: theme.text }]} selectable>
              {t.deleteAccount.phrase}
            </Text>
          </View>
          <Field
            value={typed}
            onChangeText={setTyped}
            placeholder={t.deleteAccount.phrase}
            returnKeyType="done"
            onSubmitEditing={deleteAccount}
            accessibilityLabel={t.deleteAccount.prompt}
            editable={!busy}
          />
          <PrimaryButton
            title={t.deleteAccount.button}
            onPress={deleteAccount}
            loading={busy}
            disabled={!confirmed}
            destructive
          />
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: { padding: Spacing.four, gap: Spacing.five, width: '100%', maxWidth: MaxWidth.form, alignSelf: 'center' },
  header: { alignItems: 'center', gap: Spacing.three },
  warning: { fontSize: 22, fontWeight: '700', textAlign: 'center' },
  body: { fontSize: 15, lineHeight: 21, textAlign: 'center' },
  confirm: { gap: Spacing.three },
  prompt: { fontSize: 15 },
  phraseBox: {
    borderRadius: Radius.field,
    borderCurve: 'continuous',
    paddingHorizontal: Spacing.three,
    paddingVertical: Spacing.two,
    alignSelf: 'flex-start',
  },
  phrase: { fontSize: 17, fontWeight: '700' },
});
