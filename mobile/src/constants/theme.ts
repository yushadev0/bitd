import { Platform } from 'react-native';

// Chrome (bars, tabs, sheets) stays system-drawn so Liquid Glass can do its job;
// these colors are only for our own content. The accent is the web app's marquee amber.
export const Colors = {
  light: {
    text: '#1C1917',
    textSecondary: '#6B645C',
    background: '#FFFFFF',
    backgroundElement: '#EBE4D8',
    backgroundSelected: '#DED5C6',
    separator: '#D6CCBC',
    accent: '#C97A1D',
    danger: '#C2410C',
  },
  dark: {
    text: '#F5F2ED',
    textSecondary: '#A8A097',
    background: '#000000',
    backgroundElement: '#1C1A18',
    backgroundSelected: '#2A2724',
    separator: '#2F2B27',
    accent: '#E8A33D',
    danger: '#FB923C',
  },
} as const;

export type ThemeColors = (typeof Colors)['light'] | (typeof Colors)['dark'];

export const Spacing = {
  half: 2,
  one: 4,
  two: 8,
  three: 16,
  four: 24,
  five: 32,
  six: 64,
} as const;

export const Radius = {
  poster: 10,
  card: 16,
  field: 12,
} as const;

export const Fonts = Platform.select({
  ios: { rounded: 'ui-rounded', sans: 'system-ui' },
  default: { rounded: 'normal', sans: 'normal' },
});
