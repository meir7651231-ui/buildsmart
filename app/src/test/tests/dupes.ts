/* dupes — duplicate detection. Legacy reference: findDuplicates()
 * (lines 12984-13061). Detects identical product names with different
 * keys and other dataset collisions.
 */
import { PRODUCTS, CATEGORIES } from '../../data/catalog';
import { BUTTON_REGISTRY } from '../registry';
import type { TestResult, TestCheck } from '../types';

export function testDupes(): TestResult[] {
  const checks: TestCheck[] = [];

  /* Identical product NAME across different ids */
  const byName = new Map<string, string[]>();
  for (const p of PRODUCTS) {
    const existing = byName.get(p.name) ?? [];
    existing.push(p.id);
    byName.set(p.name, existing);
  }
  const nameClashes = [...byName.entries()].filter(([, ids]) => ids.length > 1);
  checks.push({
    name: 'אין מוצרים עם שם זהה ומזהים שונים',
    pass: nameClashes.length === 0,
    detail:
      nameClashes.length === 0
        ? ''
        : nameClashes
            .slice(0, 3)
            .map(([nm, ids]) => `"${nm}" → ${ids.join(', ')}`)
            .join(' · '),
  });

  /* Identical category NAME under different parent ids */
  const catKey = (c: { name: string; parentId: string | null }) =>
    `${c.parentId ?? '~root'}::${c.name}`;
  const catByKey = new Map<string, string[]>();
  for (const c of CATEGORIES) {
    const k = catKey(c);
    const existing = catByKey.get(k) ?? [];
    existing.push(c.id);
    catByKey.set(k, existing);
  }
  const catClashes = [...catByKey.entries()].filter(([, ids]) => ids.length > 1);
  checks.push({
    name: 'אין קטגוריות בעלות שם זהה תחת אותו הורה',
    pass: catClashes.length === 0,
    detail:
      catClashes.length === 0
        ? ''
        : catClashes
            .slice(0, 3)
            .map(([k, ids]) => `${k} → ${ids.length}`)
            .join(' · '),
  });

  /* Identical button registry entries (same fn registered twice) */
  const fnNames = BUTTON_REGISTRY.map((b) => b.fn);
  const fnSet = new Set(fnNames);
  checks.push({
    name: 'אין כפילות בשמות פונקציות ב-BUTTON_REGISTRY',
    pass: fnSet.size === fnNames.length,
    expected: String(fnNames.length),
    got: String(fnSet.size),
  });

  return [
    {
      id: 'dupes:core',
      category: 'dupes' as const,
      label: 'בדיקת זהויות וכפילויות',
      checks,
    },
  ];
}
