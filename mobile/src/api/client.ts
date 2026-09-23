import * as SecureStore from 'expo-secure-store';

import { locale, t } from '@/lib/i18n';

import type { TokenResponse } from './types';

// Origin + path prefix of the deployed API, e.g. https://yusa.app/bitd
export const API_ORIGIN = 'https://yusa.app';
export const API_BASE = process.env.EXPO_PUBLIC_API_BASE ?? `${API_ORIGIN}/bitd`;

const REFRESH_KEY = 'bitd.refresh_token';

// Asks the API for English error messages and TMDB content; it defaults to Turkish.
const LANG_HEADER = { 'X-App-Lang': locale };

export class ApiError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

// The access token lives only in memory; the refresh token is the durable
// credential and sits in the Keychain.
let accessToken: string | null = null;
let refreshInFlight: Promise<boolean> | null = null;
let onSessionExpired: (() => void) | null = null;

export function setSessionExpiredHandler(handler: (() => void) | null) {
  onSessionExpired = handler;
}

export async function storeSession(tokens: TokenResponse) {
  accessToken = tokens.access_token;
  await SecureStore.setItemAsync(REFRESH_KEY, tokens.refresh_token);
}

export async function clearSession() {
  accessToken = null;
  await SecureStore.deleteItemAsync(REFRESH_KEY);
}

export async function hasStoredSession() {
  return (await SecureStore.getItemAsync(REFRESH_KEY)) !== null;
}

async function parseError(response: Response): Promise<ApiError> {
  let message = t.common.requestFailed(response.status);
  try {
    const body = await response.json();
    if (typeof body.detail === 'string') message = body.detail;
    // FastAPI's field validation errors come back as a list, not a sentence.
    else if (response.status === 422) message = t.common.invalidInput;
  } catch {
    // ignore body parse failure
  }
  return new ApiError(response.status, message);
}

/** Exchanges the stored refresh token for a new pair. Returns the fresh response, or null if the session is gone. */
export async function refreshSession(): Promise<TokenResponse | null> {
  const refreshToken = await SecureStore.getItemAsync(REFRESH_KEY);
  if (!refreshToken) return null;

  const response = await fetch(`${API_BASE}/api/auth/token/refresh`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...LANG_HEADER },
    body: JSON.stringify({ refresh_token: refreshToken }),
  });
  if (response.status === 401) {
    await clearSession();
    return null;
  }
  if (!response.ok) throw await parseError(response);

  const tokens = (await response.json()) as TokenResponse;
  await storeSession(tokens);
  return tokens;
}

// Concurrent 401s share one refresh round-trip instead of racing each other.
function refreshOnce(): Promise<boolean> {
  refreshInFlight ??= refreshSession()
    .then((tokens) => tokens !== null)
    .finally(() => {
      refreshInFlight = null;
    });
  return refreshInFlight;
}

async function request<T>(path: string, init: RequestInit = {}, retry = true): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...LANG_HEADER,
      ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}),
      ...(init.headers ?? {}),
    },
  });

  if (response.status === 401 && retry && (await hasStoredSession())) {
    if (await refreshOnce()) return request<T>(path, init, false);
    onSessionExpired?.();
  }

  if (!response.ok) throw await parseError(response);
  if (response.status === 204) return undefined as T;
  return (await response.json()) as T;
}

const body = (value: unknown) => (value !== undefined ? JSON.stringify(value) : undefined);

export const api = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, data?: unknown) => request<T>(path, { method: 'POST', body: body(data) }),
  put: <T>(path: string, data?: unknown) => request<T>(path, { method: 'PUT', body: body(data) }),
  patch: <T>(path: string, data?: unknown) => request<T>(path, { method: 'PATCH', body: body(data) }),
  delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
};
