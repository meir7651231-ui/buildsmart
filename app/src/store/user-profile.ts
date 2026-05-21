/* @legacy index.html:6946-6960 (editAccountField cfg + userProfile).
 * Profile fields kept separate from AppSettings because they're identity
 * data, not preferences. Persisted to localStorage under 'bs.profile.v1'. */
import { signal, effect } from '@preact/signals';

const STORAGE_KEY = 'bs.profile.v1';

export type ProfileKey = 'name' | 'phone' | 'business' | 'trade' | 'payment';

export type UserProfile = Record<ProfileKey, string>;

const DEFAULTS: UserProfile = {
  name: '',
  phone: '',
  business: '',
  trade: '',
  payment: '',
};

function load(): UserProfile {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return DEFAULTS;
    const p = JSON.parse(raw);
    return {
      name: typeof p?.name === 'string' ? p.name : '',
      phone: typeof p?.phone === 'string' ? p.phone : '',
      business: typeof p?.business === 'string' ? p.business : '',
      trade: typeof p?.trade === 'string' ? p.trade : '',
      payment: typeof p?.payment === 'string' ? p.payment : '',
    };
  } catch {
    return DEFAULTS;
  }
}

export const userProfile = signal<UserProfile>(load());

export function setProfileField(key: ProfileKey, value: string): void {
  userProfile.value = { ...userProfile.value, [key]: value.trim() };
}

if (typeof document !== 'undefined') {
  effect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(userProfile.value));
    } catch {
      /* storage unavailable — keep in-memory */
    }
  });
}
