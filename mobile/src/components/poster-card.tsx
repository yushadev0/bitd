import { Image } from 'expo-image';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { Radius, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { posterUri } from '@/lib/image';

interface Props {
  title: string;
  poster: string | null | undefined;
  subtitle?: string;
  width?: number;
  onPress?: () => void;
}

export function PosterCard({ title, poster, subtitle, width, onPress }: Props) {
  const theme = useTheme();

  return (
    <Pressable
      onPress={onPress}
      disabled={!onPress}
      style={({ pressed }) => [styles.card, width ? { width } : styles.flex, pressed && styles.pressed]}
      accessibilityRole={onPress ? 'button' : undefined}
      accessibilityLabel={title}>
      <View style={[styles.posterFrame, { backgroundColor: theme.backgroundElement }]}>
        <Image
          source={posterUri(poster)}
          style={StyleSheet.absoluteFill}
          contentFit="cover"
          transition={200}
          recyclingKey={poster ?? title}
        />
      </View>
      <Text numberOfLines={1} style={[styles.title, { color: theme.text }]}>
        {title}
      </Text>
      {subtitle ? (
        <Text numberOfLines={1} style={[styles.subtitle, { color: theme.textSecondary }]}>
          {subtitle}
        </Text>
      ) : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  card: { gap: Spacing.one },
  pressed: { opacity: 0.7 },
  posterFrame: {
    aspectRatio: 2 / 3,
    borderRadius: Radius.poster,
    borderCurve: 'continuous',
    overflow: 'hidden',
  },
  title: { fontSize: 13, fontWeight: '600', marginTop: Spacing.half },
  subtitle: { fontSize: 12 },
});
