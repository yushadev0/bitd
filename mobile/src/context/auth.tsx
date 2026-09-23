import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';

import { clearSession, refreshSession, setSessionExpiredHandler, storeSession } from '@/api/client';
import { authApi } from '@/api/endpoints';
import type { CurrentUser } from '@/api/types';
import { unregisterPush } from '@/lib/push';

type AuthStatus = 'loading' | 'signedOut' | 'signedIn';

interface AuthContextValue {
  status: AuthStatus;
  user: CurrentUser | null;
  signIn: (username: string, password: string) => Promise<void>;
  register: (data: { kullanici_adi: string; email: string; sifre: string; sifre_tekrar: string }) => Promise<void>;
  signOut: () => Promise<void>;
  setUser: (user: CurrentUser) => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [status, setStatus] = useState<AuthStatus>('loading');
  const [user, setUser] = useState<CurrentUser | null>(null);

  const signOut = useCallback(async () => {
    // Best effort: a failed unregister shouldn't keep anyone signed in.
    await unregisterPush().catch(() => {});
    await clearSession();
    setUser(null);
    setStatus('signedOut');
  }, []);

  // Restore the session from the Keychain on launch.
  useEffect(() => {
    refreshSession()
      .then((tokens) => {
        setUser(tokens?.user ?? null);
        setStatus(tokens ? 'signedIn' : 'signedOut');
      })
      // Offline or server down: fall back to the login screen rather than hanging on the splash.
      .catch(() => setStatus('signedOut'));
  }, []);

  useEffect(() => {
    setSessionExpiredHandler(() => {
      unregisterPush().catch(() => {});
      setUser(null);
      setStatus('signedOut');
    });
    return () => setSessionExpiredHandler(null);
  }, []);

  const signIn = useCallback(async (username: string, password: string) => {
    const tokens = await authApi.token(username, password);
    await storeSession(tokens);
    setUser(tokens.user);
    setStatus('signedIn');
  }, []);

  const register = useCallback<AuthContextValue['register']>(
    async (data) => {
      await authApi.register(data);
      await signIn(data.kullanici_adi, data.sifre);
    },
    [signIn],
  );

  const value = useMemo(
    () => ({ status, user, signIn, register, signOut, setUser }),
    [status, user, signIn, register, signOut],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
}
