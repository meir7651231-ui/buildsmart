/* @legacy index.html:6499-6543. Identity: ranks ladder, stats helper,
 * achievement checks. Demo values: orders=0, sites=PROJECTS.length=3,
 * trees=0, spent=0, autoSaved=0. */
import { PROJECTS } from './projects';

export type Rank = {
  key: 'new' | 'regular' | 'pref' | 'plat';
  name: string;
  ic: string;
  min: number;
  color: string;
  perk: string;
};

export const RANKS: Rank[] = [
  { key: 'new',     name: 'קבלן חדש',     ic: '🔰', min: 0,  color: '#8b8d8f', perk: 'גישה מלאה לקטלוג ולעץ המוצרים החכם' },
  { key: 'regular', name: 'קבלן קבוע',    ic: '🔨', min: 3,  color: '#1f8a4c', perk: '2% הנחה על כל הזמנה · עדיפות בזמני משלוח' },
  { key: 'pref',    name: 'קבלן מועדף',   ic: '⭐', min: 8,  color: '#f2a516', perk: '5% הנחה · משלוח אקספרס חינם פעם בשבוע' },
  { key: 'plat',    name: 'קבלן פלטינום', ic: '💎', min: 15, color: '#1f6f6b', perk: '8% הנחה · אקספרס חינם תמיד · מנהל לקוח אישי' },
];

export type IdentityStats = {
  orders: number;
  sites: number;
  trees: number;
  spent: number;
  autoSaved: number;
};

export function identityStats(): IdentityStats {
  /* No live order data yet; in demo mode the prototype shows zeros
   * with the exception of `sites` which mirrors PROJECTS.length. */
  return {
    orders: 0,
    sites: PROJECTS.length,
    trees: 0,
    spent: 0,
    autoSaved: 0,
  };
}

export function currentRank(orders: number): Rank {
  let r = RANKS[0]!;
  for (const x of RANKS) {
    if (orders >= x.min) r = x;
  }
  return r;
}

export function nextRank(orders: number): Rank | null {
  for (const r of RANKS) {
    if (orders < r.min) return r;
  }
  return null;
}

export type Achievement = {
  ic: string;
  name: string;
  desc: string;
  on: boolean;
};

export function identityAchievements(s: IdentityStats): Achievement[] {
  return [
    { ic: '🚀',  name: 'הזמנה ראשונה',   desc: 'ביצעת את ההזמנה הראשונה',  on: s.orders >= 1 },
    { ic: '📦',  name: '10 הזמנות',       desc: '10 הזמנות דרך BuildSmart', on: s.orders >= 10 },
    { ic: '🏗️', name: 'ריבוי אתרים',     desc: '3 אתרים פעילים במקביל',    on: s.sites >= 3 },
    { ic: '🌳',  name: 'חובב עץ מוצרים', desc: '5 עצי מוצרים בעבודה',       on: s.trees >= 5 },
    { ic: '🧠',  name: 'לא שוכח כלום',   desc: '25 אביזרים שהעץ הציל',      on: s.autoSaved >= 25 },
    { ic: '💰',  name: 'מחזור ₪10K',     desc: '₪10,000 דרך האפליקציה',     on: s.spent >= 10000 },
  ];
}

export function formatIls(n: number): string {
  /* @legacy index.html:6556 — `'₪' + Math.round(n).toLocaleString()`. */
  return '₪' + Math.round(n).toLocaleString('he-IL');
}
