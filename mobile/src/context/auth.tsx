import * as SecureStore from 'expo-secure-store';
import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';

import { clearSession, hasStoredSession, refreshSession, setSessionExpiredHandler, storeSession } from '@/api/client';
import { authApi } from '@/api/endpoints';
import type { CurrentUser, TokenResponse } from '@/api/types';
import { loadLibrary } from '@/lib/library-store';
import { completeOnboarding } from '@/lib/onboarding';
import { adoptLocalLibrary, localOwner, markSessionExpired, startSync, stopSyncAndClear } from '@/lib/sync';

// An account is optional. Without one ('guest') the library lives only on this phone;
// with one it's also kept on the server (see lib/sync.ts), which is what the web app shows.

type AuthStatus = 'loading' | 'guest' | 'signedIn';

interface AuthContextValue {
  status: AuthStatus;
  user: CurrentUser | null;
  /** Signed in, but the server no longer accepts the session: sync is paused until the user signs in again. */
  sessionExpired: boolean;
  signIn: (username: string, password: string) => Promise<void>;
  register: (data: { kullanici_adi: string; email: string; sifre: string; sifre_tekrar: string }) => Promise<void>;
  signOut: () => Promise<void>;
  setUser: (user: CurrentUser) => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

// The last known profile, so the app can open signed in without reaching the server.
const USER_KEY = 'bitd.user';

async function readCachedUser(): Promise<CurrentUser | null> {
  try {
    const raw = await SecureStore.getItemAsync(USER_KEY);
    return raw ? (JSON.parse(raw) as CurrentUser) : null;
  } catch {
    return null;
  }
}

function cacheUser(user: CurrentUser | null) {
  const write = user ? SecureStore.setItemAsync(USER_KEY, JSON.stringify(user)) : SecureStore.deleteItemAsync(USER_KEY);
  write.catch(() => {});
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [status, setStatus] = useState<AuthStatus>('loading');
  const [user, setUserState] = useState<CurrentUser | null>(null);
  const [sessionExpired, setSessionExpired] = useState(false);

  const setUser = useCallback((next: CurrentUser) => {
    setUserState(next);
    cacheUser(next);
  }, []);

  const expire = useCallback(() => {
    setSessionExpired(true);
    markSessionExpired();
  }, []);

  /** Takes a fresh session and makes the phone's library this account's. */
  const beginSession = useCallback(
    async (tokens: TokenResponse) => {
      await storeSession(tokens);
      await adoptLocalLibrary(tokens.user.id);
      setUser(tokens.user);
      setSessionExpired(false);
      setStatus('signedIn');
      completeOnboarding();
      startSync(tokens.user.id);
    },
    [setUser],
  );

  // Open straight from what's on the phone; the server is only asked in the background.
  useEffect(() => {
    (async () => {
      await loadLibrary().catch(() => {});
      const [cached, owner, hasSession] = await Promise.all([
        readCachedUser(),
        localOwner().catch(() => null),
        hasStoredSession(),
      ]);

      if (cached && owner === cached.id) {
        setUserState(cached);
        setSessionExpired(!hasSession);
        setStatus('signedIn');
        startSync(cached.id, { expired: !hasSession });
        if (hasSession) {
          refreshSession()
            .then((tokens) => (tokens ? setUser(tokens.user) : expire()))
            .catch(() => {}); // offline: sync retries once the connection is back
        }
        return;
      }

      if (hasSession) {
        // Signed in on a build that predates the offline library: this needs the server once.
        try {
          const tokens = await refreshSession();
          if (tokens) {
            await beginSession(tokens);
            return;
          }
        } catch {
          // Offline: carry on without an account for now and try again next launch.
        }
      }
      setStatus('guest');
    })();
  }, [beginSession, expire, setUser]);

  useEffect(() => {
    setSessionExpiredHandler(expire);
    return () => setSessionExpiredHandler(null);
  }, [expire]);

  const signIn = useCallback(
    async (username: string, password: string) => {
      await beginSession(await authApi.token(username, password));
    },
    [beginSession],
  );

  const register = useCallback<AuthContextValue['register']>(
    async (data) => {
      await authApi.register(data);
      await signIn(data.kullanici_adi, data.sifre);
    },
    [signIn],
  );

  const signOut = useCallback(async () => {
    await clearSession();
    await stopSyncAndClear();
    cacheUser(null);
    setUserState(null);
    setSessionExpired(false);
    setStatus('guest');
  }, []);

  const value = useMemo(
    () => ({ status, user, sessionExpired, signIn, register, signOut, setUser }),
    [status, user, sessionExpired, signIn, register, signOut, setUser],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
}
