import { Link } from 'expo-router';
import { useRef, useState } from 'react';
import { KeyboardAvoidingView, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';

import { ErrorText, Field, PrimaryButton } from '@/components/form';
import { Fonts, MaxWidth, Spacing } from '@/constants/theme';
import { useAuth } from '@/context/auth';
import { useTheme } from '@/hooks/use-theme';
import { t } from '@/lib/i18n';

export default function LoginScreen() {
  const theme = useTheme();
  const { signIn } = useAuth();
  const passwordRef = useRef<TextInput>(null);

  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const submit = async () => {
    if (!username || !password) return;
    setBusy(true);
    setError(null);
    try {
      await signIn(username.trim(), password);
    } catch (e) {
      setError(e instanceof Error ? e.message : t.auth.signInFailed);
      setBusy(false);
    }
  };

  return (
    <KeyboardAvoidingView behavior="padding" style={[styles.flex, { backgroundColor: theme.background }]}>
      <ScrollView
        contentContainerStyle={styles.content}
        keyboardShouldPersistTaps="handled"
        contentInsetAdjustmentBehavior="automatic">
        <View style={styles.brand}>
          <Text style={[styles.logo, { color: theme.accent }]}>B.I.T.D.</Text>
          <Text style={[styles.tagline, { color: theme.textSecondary }]}>Back In The Day</Text>
        </View>

        <View style={styles.form}>
          <Field
            placeholder={t.auth.username}
            value={username}
            onChangeText={setUsername}
            textContentType="username"
            autoComplete="username"
            returnKeyType="next"
            onSubmitEditing={() => passwordRef.current?.focus()}
          />
          <Field
            ref={passwordRef}
            placeholder={t.auth.password}
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            textContentType="password"
            autoComplete="current-password"
            returnKeyType="go"
            onSubmitEditing={submit}
          />
          <ErrorText>{error}</ErrorText>
          <PrimaryButton title={t.auth.signIn} onPress={submit} loading={busy} disabled={!username || !password} />
          <Link href="/forgot-password" style={[styles.forgot, { color: theme.accent }]}>
            {t.auth.forgotPassword}
          </Link>
        </View>

        <Link href="/register" style={[styles.link, { color: theme.textSecondary }]}>
          {t.auth.noAccount} <Text style={{ color: theme.accent, fontWeight: '600' }}>{t.auth.registerLink}</Text>
        </Link>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: {
    flexGrow: 1,
    justifyContent: 'center',
    padding: Spacing.four,
    gap: Spacing.five,
    width: '100%',
    maxWidth: MaxWidth.form,
    alignSelf: 'center',
  },
  brand: { alignItems: 'center', gap: Spacing.one },
  logo: { fontSize: 44, fontWeight: '800', letterSpacing: 2, fontFamily: Fonts.rounded },
  tagline: { fontSize: 15, letterSpacing: 1 },
  form: { gap: Spacing.three },
  link: { fontSize: 15, textAlign: 'center' },
  forgot: { fontSize: 15, textAlign: 'center', paddingVertical: Spacing.one },
});
