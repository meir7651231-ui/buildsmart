import { PRODUCTS, CATEGORIES } from '../data/catalog';
import type { CatalogProduct, CatalogCategory } from '../data/catalog';

export type SearchKind = 'screen' | 'cat' | 'prod';

export type SearchHit = {
  id: string;
  kind: SearchKind;
  label: string;
  path: string;
  emoji: string;
  image?: string;
  /* Payload for the click handler */
  target:
    | { type: 'screen'; key: ScreenKey }
    | { type: 'cat'; categoryId: string }
    | { type: 'prod'; productId: string };
  /* Strings the engine matches against */
  keywords: string[];
};

export type ScreenKey =
  | 'home'
  | 'cart'
  | 'projects'
  | 'orders'
  | 'notifications'
  | 'profile'
  | 'settings';

const SCREENS: Array<{ key: ScreenKey; label: string; emoji: string; kw: string[] }> = [
  { key: 'home', label: 'בית', emoji: '⌂', kw: ['בית', 'דף הבית', 'home'] },
  { key: 'cart', label: 'עגלת רכש', emoji: '🛒', kw: ['עגלה', 'רכש', 'סל', 'מוצרים בעגלה'] },
  { key: 'projects', label: 'הפרויקטים שלי', emoji: '🏗️', kw: ['פרויקטים', 'אתרים', 'אתרי בנייה'] },
  { key: 'orders', label: 'הזמנות', emoji: '📦', kw: ['הזמנות', 'משלוח', 'מעקב'] },
  { key: 'notifications', label: 'התראות', emoji: '🔔', kw: ['התראות', 'עדכונים'] },
  { key: 'profile', label: 'הפרופיל שלי', emoji: '👤', kw: ['פרופיל', 'משתמש', 'דרגה'] },
  { key: 'settings', label: 'הגדרות', emoji: '⚙️', kw: ['הגדרות', 'העדפות', 'שפה'] },
];

function catPath(cat: CatalogCategory): string {
  if (!cat.parentId) return cat.name;
  const parent = CATEGORIES.find((c) => c.id === cat.parentId);
  return parent ? `${parent.name} / ${cat.name}` : cat.name;
}

function productPath(p: CatalogProduct): string {
  const leaf = CATEGORIES.find((c) => c.id === p.categoryLeafId);
  const top = CATEGORIES.find((c) => c.id === p.categoryTopId);
  if (leaf && top && leaf.id !== top.id) return `${top.name} / ${leaf.name}`;
  return top?.name ?? '';
}

let _index: SearchHit[] | null = null;

export function searchIndex(): SearchHit[] {
  if (_index) return _index;
  const hits: SearchHit[] = [];

  for (const s of SCREENS) {
    hits.push({
      id: `screen:${s.key}`,
      kind: 'screen',
      label: s.label,
      path: 'ניווט',
      emoji: s.emoji,
      target: { type: 'screen', key: s.key },
      keywords: [s.label, ...s.kw],
    });
  }

  for (const c of CATEGORIES) {
    hits.push({
      id: `cat:${c.id}`,
      kind: 'cat',
      label: c.name,
      path: c.parentId ? catPath(c) : 'קטגוריה',
      emoji: c.emoji,
      target: { type: 'cat', categoryId: c.id },
      keywords: [c.name],
    });
  }

  for (const p of PRODUCTS) {
    const kws: string[] = [p.name];
    if (p.productType) kws.push(p.productType);
    if (p.series) kws.push(p.series);
    if (p.material) kws.push(p.material);
    if (p.note) kws.push(p.note);
    hits.push({
      id: `prod:${p.id}`,
      kind: 'prod',
      label: p.name,
      path: productPath(p),
      emoji: p.emoji,
      image: p.image,
      target: { type: 'prod', productId: p.id },
      keywords: kws,
    });
  }

  _index = hits;
  return hits;
}
