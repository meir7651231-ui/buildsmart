/* dsync — data-to-display sync probes (legacy: lines 14759-14901).
 * The legacy probed DOM-vs-data; we use signals so this collapses to
 * "state invariants that must always hold".
 */
import { cart, cartCount, categoryPath } from '../../store/app-store';
import { activePersona } from '../../store/bs-store';
import { PRODUCTS, CATEGORIES } from '../../data/catalog';
import { VARIANTS } from '../../data/variants';
import { SUPPLIERS, STORE_PRICING } from '../../data/suppliers';
import { TOOL_BUNDLES } from '../../data/tools';
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

  /* Cross-data integrity — variants/suppliers/tools all reference real
   * entities. Mirrors the spirit of legacy "audit" pass that confirms
   * STORE_PRICING / VARIANTS / TOOLS keys link to products.
   */
  const productIds = new Set(PRODUCTS.map((p) => p.id));
  const orphanVariants = Object.keys(VARIANTS).filter(
    (id) => !productIds.has(id),
  );
  checks.push({
    name: 'כל מפתח ב-VARIANTS שייך למוצר קיים',
    pass: orphanVariants.length === 0,
    expected: '0 חסרים',
    got: `${orphanVariants.length} חסרים${orphanVariants.length ? `: ${orphanVariants.slice(0, 3).join(', ')}` : ''}`,
  });

  const knownSkus = new Set<string>();
  for (const v of Object.values(VARIANTS)) {
    for (const opt of v.opts) {
      if (opt.sku) knownSkus.add(opt.sku);
    }
  }
  const orphanSkus = [];
  for (const sid of Object.keys(STORE_PRICING)) {
    for (const sku of Object.keys(STORE_PRICING[sid] ?? {})) {
      if (!knownSkus.has(sku)) orphanSkus.push(`${sid}/${sku}`);
    }
  }
  checks.push({
    name: 'כל SKU ב-STORE_PRICING שייך לוריאנט קיים',
    pass: orphanSkus.length === 0,
    expected: '0 SKUs יתומים',
    got: `${orphanSkus.length}${orphanSkus.length ? ` (דוגמה: ${orphanSkus[0]})` : ''}`,
  });

  checks.push({
    name: 'SUPPLIERS מכיל 3 ספקים (s1/s2/s3)',
    pass: Object.keys(SUPPLIERS).length === 3,
    expected: '3',
    got: String(Object.keys(SUPPLIERS).length),
  });

  const badBundles = Object.entries(TOOL_BUNDLES).filter(([, list]) =>
    list.some((t) => !t.name || !t.emoji),
  );
  checks.push({
    name: 'כל TOOL_BUNDLES בעלי name + emoji',
    pass: badBundles.length === 0,
    expected: '0 חבילות פגומות',
    got: String(badBundles.length),
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
