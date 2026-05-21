import { PRODUCTS, CATEGORIES } from '../../data/catalog';
import { variantsOf } from '../../data/variants';
import { STORE_PRICING } from '../../data/suppliers';
import type { TestResult, TestCheck } from '../types';

const VALID_TOPS = new Set(
  CATEGORIES.filter((c) => c.parentId === null).map((c) => c.id),
);
const VALID_LEAVES = new Set(CATEGORIES.map((c) => c.id));
const STORE_IDS = Object.keys(STORE_PRICING);

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

    /* Variant + SKU pricing — mirrors legacy regCheckProduct sku checks */
    const variant = variantsOf(p.id);
    if (variant) {
      add(
        'יש לפחות אופציית-וריאנט אחת',
        variant.opts.length > 0,
        variant.opts.length > 0 ? '' : 'opts ריק',
      );
      if (variant.sku) {
        const optsWithSku = variant.opts.filter((o) => !!o.sku);
        add(
          'כל אופציה כוללת sku',
          optsWithSku.length === variant.opts.length,
          optsWithSku.length === variant.opts.length
            ? ''
            : `${variant.opts.length - optsWithSku.length} ללא sku`,
        );
        let missing = 0;
        for (const opt of optsWithSku) {
          for (const sid of STORE_IDS) {
            const price = STORE_PRICING[sid]?.[opt.sku!];
            if (typeof price !== 'number') missing++;
          }
        }
        const totalPrices = optsWithSku.length * STORE_IDS.length;
        add(
          'כל sku מתומחר בכל הספקים',
          missing === 0,
          missing === 0 ? '' : `חסרים ${missing}/${totalPrices} מחירים`,
        );
      }
    }

    /* Accessory schema — mirrors legacy regCheckProduct acc checks */
    if (Array.isArray(p.accessories) && p.accessories.length > 0) {
      const bad = p.accessories.filter(
        (a) => !a.name || a.name.length === 0 || typeof a.must !== 'boolean',
      );
      add(
        'מערך accessories תקין (name + must)',
        bad.length === 0,
        bad.length === 0 ? '' : `${bad.length} פריטים פגומים`,
      );
    }

    return {
      id: `product:${p.id}`,
      category: 'products' as const,
      label: p.name,
      checks,
    };
  });
}
