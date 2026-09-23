import { forwardRef } from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, TextInput, type TextInputProps } from 'react-native';

import { Radius, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

export const Field = forwardRef<TextInput, TextInputProps>(function Field({ style, ...props }, ref) {
  const theme = useTheme();
  return (
    <TextInput
      ref={ref}
      placeholderTextColor={theme.textSecondary}
      autoCapitalize="none"
      autoCorrect={false}
      style={[styles.field, { backgroundColor: theme.backgroundElement, color: theme.text }, style]}
      {...props}
    />
  );
});

export function PrimaryButton({
  title,
  onPress,
  loading,
  disabled,
  destructive,
}: {
  title: string;
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
  destructive?: boolean;
}) {
  const theme = useTheme();
  const inactive = disabled || loading;
  const foreground = destructive ? '#FFFFFF' : '#1C1917';
  return (
    <Pressable
      onPress={onPress}
      disabled={inactive}
      accessibilityRole="button"
      style={({ pressed }) => [
        styles.button,
        { backgroundColor: destructive ? theme.danger : theme.accent, opacity: inactive ? 0.5 : pressed ? 0.8 : 1 },
      ]}>
      {loading ? (
        <ActivityIndicator color={foreground} />
      ) : (
        <Text style={[styles.buttonText, { color: foreground }]}>{title}</Text>
      )}
    </Pressable>
  );
}

export function ErrorText({ children }: { children: string | null }) {
  const theme = useTheme();
  if (!children) return null;
  return <Text style={[styles.error, { color: theme.danger }]}>{children}</Text>;
}

const styles = StyleSheet.create({
  field: {
    fontSize: 17,
    paddingHorizontal: Spacing.three,
    paddingVertical: 14,
    borderRadius: Radius.field,
    borderCurve: 'continuous',
  },
  button: {
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 50,
    borderRadius: 999,
    marginTop: Spacing.two,
  },
  buttonText: { fontSize: 17, fontWeight: '600' },
  error: { fontSize: 15, textAlign: 'center' },
});
