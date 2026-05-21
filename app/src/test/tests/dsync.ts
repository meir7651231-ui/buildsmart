/* dsync — data-to-display sync probes (legacy: lines 14759-14901).
 * The legacy probed DOM-vs-data; we use signals so this collapses to
 * "state invariants that must always hold".
 */
import { cart, cartCount, categoryPath } from '../../store/app-store';
import { activePersona } from '../../store/bs-store';
import { PRODUCTS, CATEGORIES } from '../../data/catalog';
import type { TestResult, TestCheck } from '../types';

const VALID_PERSONAS = ['contractor', 'manager', 'store', 'courier', 'worker'];

export function testDsync(): TestResult[] {
  const checks: TestCheck[] = [];

  const expectedCartCount = cart.value.reduce((s, l) => s + l.qty, 0);
  checks.push({
    name: 'cartCount מסונכרן עם sum(cart.qty)',
    pass: cartCount.value === expectedCartCount,
    expected: String(expectedCartCount),
    got: String(cartCount.value),
  });

  checks.push({
    name: 'categoryPath הוא מערך',
    pass: Array.isArray(categoryPath.value),
  });

  checks.push({
    name: 'activePersona ערך חוקי',
    pass: VALID_PERSONAS.includes(activePersona.value),
    expected: VALID_PERSONAS.join('|'),
    got: activePersona.value,
  });

  checks.push({
    name: 'PRODUCTS אינו ריק',
    pass: PRODUCTS.length > 0,
    got: String(PRODUCTS.length),
  });

  checks.push({
    name: 'CATEGORIES אינו ריק',
    pass: CATEGORIES.length > 0,
    got: String(CATEGORIES.length),
  });

  return [
    {
      id: 'dsync:core',
      category: 'dsync' as const,
      label: 'סנכרון נתונים-תצוגה (אינווריאנטים)',
      checks,
    },
  ];
}
