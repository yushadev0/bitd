import { useState } from 'react';
import { KeyboardAvoidingView, ScrollView, StyleSheet } from 'react-native';

import { ErrorText, Field, PrimaryButton } from '@/components/form';
import { MaxWidth, Spacing } from '@/constants/theme';
import { useAuth } from '@/context/auth';
import { useTheme } from '@/hooks/use-theme';
import { t } from '@/lib/i18n';

export default function RegisterScreen() {
  const theme = useTheme();
  const { register } = useAuth();

  const [form, setForm] = useState({ kullanici_adi: '', email: '', sifre: '', sifre_tekrar: '' });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const set = (key: keyof typeof form) => (value: string) => setForm((f) => ({ ...f, [key]: value }));
  const complete = Object.values(form).every(Boolean);

  const submit = async () => {
    if (form.sifre !== form.sifre_tekrar) {
      setError(t.common.passwordsMismatch);
      return;
    }
    setBusy(true);
    setError(null);
    try {
      // On success the auth guard swaps this modal out for the tabs.
      await register({ ...form, kullanici_adi: form.kullanici_adi.trim(), email: form.email.trim() });
    } catch (e) {
      setError(e instanceof Error ? e.message : t.auth.registerFailed);
      setBusy(false);
    }
  };

  return (
    <KeyboardAvoidingView behavior="padding" style={[styles.flex, { backgroundColor: theme.background }]}>
      <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        <Field
          placeholder={t.auth.username}
          value={form.kullanici_adi}
          onChangeText={set('kullanici_adi')}
          textContentType="username"
        />
        <Field
          placeholder={t.auth.email}
          value={form.email}
          onChangeText={set('email')}
          keyboardType="email-address"
          textContentType="emailAddress"
        />
        <Field
          placeholder={t.auth.passwordNew}
          value={form.sifre}
          onChangeText={set('sifre')}
          secureTextEntry
          textContentType="newPassword"
        />
        <Field
          placeholder={t.auth.passwordAgain}
          value={form.sifre_tekrar}
          onChangeText={set('sifre_tekrar')}
          secureTextEntry
          textContentType="newPassword"
          returnKeyType="go"
          onSubmitEditing={complete ? submit : undefined}
        />
        <ErrorText>{error}</ErrorText>
        <PrimaryButton title={t.auth.registerTitle} onPress={submit} loading={busy} disabled={!complete} />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: { padding: Spacing.four, gap: Spacing.three, width: '100%', maxWidth: MaxWidth.form, alignSelf: 'center' },
});
