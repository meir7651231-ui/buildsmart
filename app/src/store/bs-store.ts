import { signal, computed } from '@preact/signals';

/* ===== Identity / persona ===== */

export type Persona = 'contractor' | 'manager' | 'store' | 'courier' | 'worker';

const PERSONAS: Persona[] = ['contractor', 'manager', 'store', 'courier', 'worker'];

const PERSONA_KEY = 'bs.persona.v1';

function loadPersona(): Persona {
  try {
    const raw = localStorage.getItem(PERSONA_KEY);
    if (raw && (PERSONAS as string[]).includes(raw)) return raw as Persona;
  } catch {
    /* ignore */
  }
  return 'contractor';
}

export const activePersona = signal<Persona>(loadPersona());

export function setPersona(p: Persona): void {
  activePersona.value = p;
  try {
    localStorage.setItem(PERSONA_KEY, p);
  } catch {
    /* ignore */
  }
}

const PERSONA_NAMES: Record<Persona, string> = {
  contractor: 'שלמה הקבלן',
  manager: 'מנהל המערכת',
  store: 'חנות הסניטריה',
  courier: 'שליח · משאית 14',
  worker: 'יוסי העובד',
};

export const personaName = computed<string>(() => PERSONA_NAMES[activePersona.value]);

/* ===== BS button open/closed state ===== */

export const bsOpen = signal(false);

/* ===== BS dial drill-in. When set, the dial shows the persona's
 * sub-sections (legacy screen → dial per R2/R3). Reset to null on
 * close. Picking a persona at L1 drills here; it does NOT change
 * activePersona — that stays as the user's chosen identity. */
export const bsDrillPersona = signal<Persona | null>(null);

export function toggleBs(): void {
  bsOpen.value = !bsOpen.value;
  if (!bsOpen.value) bsDrillPersona.value = null;
}
export function closeBs(): void {
  bsOpen.value = false;
  bsDrillPersona.value = null;
}
export function drillIntoPersona(p: Persona): void {
  bsDrillPersona.value = p;
}
export function popBsDrill(): void {
  bsDrillPersona.value = null;
}
