import { PRODUCTS, CATEGORIES } from '../../data/catalog';
import type { TestResult, TestCheck } from '../types';

const VALID_TOPS = new Set(
  CATEGORIES.filter((c) => c.parentId === null).map((c) => c.id),
);
const VALID_LEAVES = new Set(CATEGORIES.map((c) => c.id));

export function testProducts(): TestResult[] {
  return PRODUCTS.map((p) => {
    const checks: TestCheck[] = [];
    const add = (name: string, pass: boolean, detail = '') =>
      checks.push({ name, pass, detail });

    add('שדה id קיים', !!p.id && p.id.length > 0);
    add('שדה name קיים', !!p.name && p.name.length > 0);
    add(
      'יש emoji או image',
      !!(p.emoji || p.image),
      p.emoji || p.image ? '' : 'אין ייצוג ויזואלי',
    );
    add(
      'categoryTopId קיים בעץ',
      VALID_TOPS.has(p.categoryTopId),
      VALID_TOPS.has(p.categoryTopId) ? '' : `לא מוכר: ${p.categoryTopId}`,
    );
    add(
      'categoryLeafId קיים בעץ',
      VALID_LEAVES.has(p.categoryLeafId),
      VALID_LEAVES.has(p.categoryLeafId) ? '' : `לא מוכר: ${p.categoryLeafId}`,
    );

    if (p.image) {
      add(
        'image מתחיל ב-/catalog/',
        p.image.startsWith('/catalog/'),
        p.image.startsWith('/catalog/') ? '' : `path: ${p.image}`,
      );
    }
    if (typeof p.price === 'number') {
      add('מחיר אינו שלילי', p.price >= 0, p.price < 0 ? `${p.price}` : '');
    }

    return {
      id: `product:${p.id}`,
      category: 'products' as const,
      label: p.name,
      checks,
    };
  });
}
