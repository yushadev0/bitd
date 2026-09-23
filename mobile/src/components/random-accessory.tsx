import { NativeTabs } from 'expo-router/unstable-native-tabs';
import { SymbolView } from 'expo-symbols';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';

import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

interface Props {
  wishlistLabel: string;
  picking: boolean;
  onPick: () => void;
}

// Rendered twice by the system (regular + inline/minimized placements), so it must stay
// stateless — `picking` lives in the tabs layout.
export function RandomAccessory({ wishlistLabel, picking, onPick }: Props) {
  const theme = useTheme();
  const inline = NativeTabs.BottomAccessory.usePlacement() === 'inline';

  return (
    <Pressable
      onPress={onPick}
      disabled={picking}
      accessibilityRole="button"
      accessibilityLabel={`${wishlistLabel} içinden rastgele seç`}
      style={({ pressed }) => [styles.container, pressed && styles.pressed]}>
      {picking ? (
        <ActivityIndicator />
      ) : (
        <SymbolView name="dice.fill" size={inline ? 18 : 22} tintColor={theme.accent} />
      )}
      <View style={styles.text}>
        <Text style={[styles.title, { color: theme.text }]} numberOfLines={1}>
          Rastgele seç
        </Text>
        {!inline ? (
          <Text style={[styles.subtitle, { color: theme.textSecondary }]} numberOfLines={1}>
            {wishlistLabel} içinden
          </Text>
        ) : null}
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.three,
    paddingHorizontal: Spacing.four,
  },
  pressed: { opacity: 0.6 },
  text: { flex: 1 },
  title: { fontSize: 15, fontWeight: '600' },
  subtitle: { fontSize: 12 },
});
