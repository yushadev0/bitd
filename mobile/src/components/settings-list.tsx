import { SymbolView } from 'expo-symbols';
import { Children, Fragment, type ReactNode } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { Radius, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

// Inset-grouped rows in the style of iOS Settings, shared by the account screens.

export function SettingsSection({
  title,
  footer,
  children,
}: {
  title?: string;
  footer?: string;
  children: ReactNode;
}) {
  const theme = useTheme();
  return (
    <View style={styles.section}>
      {title ? <Text style={[styles.sectionTitle, { color: theme.textSecondary }]}>{title}</Text> : null}
      {children}
      {footer ? <Text style={[styles.footer, { color: theme.textSecondary }]}>{footer}</Text> : null}
    </View>
  );
}

export function SettingsGroup({ children }: { children: ReactNode }) {
  const theme = useTheme();
  const rows = Children.toArray(children);
  return (
    <View style={[styles.group, { backgroundColor: theme.backgroundElement }]}>
      {rows.map((row, i) => (
        <Fragment key={i}>
          {i > 0 ? <View style={[styles.separator, { backgroundColor: theme.separator }]} /> : null}
          {row}
        </Fragment>
      ))}
    </View>
  );
}

export function SettingsRow({
  label,
  value,
  onPress,
  accessory,
  control,
  destructive,
}: {
  label: string;
  value?: string;
  onPress?: () => void;
  /** `chevron` pushes a screen, `external` opens a web page. */
  accessory?: 'chevron' | 'external';
  /** A trailing control such as a Switch. */
  control?: ReactNode;
  destructive?: boolean;
}) {
  const theme = useTheme();
  return (
    <Pressable
      onPress={onPress}
      disabled={!onPress}
      accessibilityRole={onPress ? (accessory === 'external' ? 'link' : 'button') : undefined}
      style={({ pressed }) => [styles.row, pressed && { backgroundColor: theme.backgroundSelected }]}>
      <Text style={[styles.label, { color: destructive ? theme.danger : theme.text }]}>{label}</Text>
      {value ? (
        <Text style={[styles.value, { color: theme.textSecondary }]} numberOfLines={1} selectable>
          {value}
        </Text>
      ) : null}
      {accessory ? (
        <SymbolView
          name={accessory === 'chevron' ? 'chevron.right' : 'arrow.up.right'}
          size={13}
          weight="semibold"
          tintColor={theme.textSecondary}
        />
      ) : null}
      {control}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  section: { gap: Spacing.two },
  sectionTitle: { fontSize: 13, marginLeft: Spacing.three },
  footer: { fontSize: 13, marginHorizontal: Spacing.three },
  group: { borderRadius: Radius.card, borderCurve: 'continuous', overflow: 'hidden' },
  separator: { height: StyleSheet.hairlineWidth, marginLeft: Spacing.three },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.two,
    paddingHorizontal: Spacing.three,
    paddingVertical: 14,
    minHeight: 50,
  },
  label: { fontSize: 17, flexGrow: 1 },
  value: { fontSize: 17, flexShrink: 1, textAlign: 'right' },
});
