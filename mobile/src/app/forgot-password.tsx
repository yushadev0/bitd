import { router } from 'expo-router';
import { useState } from 'react';
import { Alert, KeyboardAvoidingView, ScrollView, StyleSheet, Text } from 'react-native';

import { authApi } from '@/api/endpoints';
import { ErrorText, Field, PrimaryButton } from '@/components/form';
import { MaxWidth, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { t } from '@/lib/i18n';

type Step = 'email' | 'code' | 'password';

const COPY: Record<Step, string> = {
  email: t.auth.forgotEmailCopy,
  code: t.auth.forgotCodeCopy,
  password: t.auth.forgotPasswordCopy,
};

export default function ForgotPasswordScreen() {
  const theme = useTheme();
  const [step, setStep] = useState<Step>('email');
  const [email, setEmail] = useState('');
  const [code, setCode] = useState('');
  const [password, setPassword] = useState('');
  const [passwordAgain, setPasswordAgain] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const run = async (action: () => Promise<void>) => {
    setBusy(true);
    setError(null);
    try {
      await action();
    } catch (e) {
      setError(e instanceof Error ? e.message : t.common.somethingWrong);
    } finally {
      setBusy(false);
    }
  };

  const sendCode = () =>
    run(async () => {
      await authApi.sendResetCode(email.trim());
      setStep('code');
    });

  const verifyCode = () =>
    run(async () => {
      await authApi.verifyResetCode(email.trim(), code.trim());
      setStep('password');
    });

  const resetPassword = () => {
    if (password !== passwordAgain) {
      setError(t.common.passwordsMismatch);
      return;
    }
    run(async () => {
      await authApi.resetPassword(email.trim(), code.trim(), password);
      Alert.alert(t.auth.passwordUpdated, t.auth.passwordUpdatedBody, [
        { text: t.common.ok, onPress: () => router.back() },
      ]);
    });
  };

  return (
    <KeyboardAvoidingView behavior="padding" style={[styles.flex, { backgroundColor: theme.background }]}>
      <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        <Text style={[styles.copy, { color: theme.textSecondary }]}>{COPY[step]}</Text>

        {step === 'email' ? (
          <>
            <Field
              placeholder={t.auth.email}
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              textContentType="emailAddress"
              autoFocus
              returnKeyType="send"
              onSubmitEditing={email ? sendCode : undefined}
            />
            <ErrorText>{error}</ErrorText>
            <PrimaryButton title={t.auth.sendCode} onPress={sendCode} loading={busy} disabled={!email} />
          </>
        ) : null}

        {step === 'code' ? (
          <>
            <Field
              placeholder="000000"
              value={code}
              onChangeText={setCode}
              keyboardType="number-pad"
              textContentType="oneTimeCode"
              autoComplete="one-time-code"
              maxLength={6}
              autoFocus
              style={styles.code}
            />
            <ErrorText>{error}</ErrorText>
            <PrimaryButton title={t.auth.verify} onPress={verifyCode} loading={busy} disabled={code.length !== 6} />
          </>
        ) : null}

        {step === 'password' ? (
          <>
            <Field
              placeholder={t.auth.newPassword}
              value={password}
              onChangeText={setPassword}
              secureTextEntry
              textContentType="newPassword"
              autoFocus
            />
            <Field
              placeholder={t.auth.newPasswordAgain}
              value={passwordAgain}
              onChangeText={setPasswordAgain}
              secureTextEntry
              textContentType="newPassword"
            />
            <ErrorText>{error}</ErrorText>
            <PrimaryButton
              title={t.auth.updatePassword}
              onPress={resetPassword}
              loading={busy}
              disabled={password.length < 6 || !passwordAgain}
            />
          </>
        ) : null}
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: { padding: Spacing.four, gap: Spacing.three, width: '100%', maxWidth: MaxWidth.form, alignSelf: 'center' },
  copy: { fontSize: 15, lineHeight: 21 },
  code: { fontSize: 28, letterSpacing: 10, textAlign: 'center', fontVariant: ['tabular-nums'] },
});
