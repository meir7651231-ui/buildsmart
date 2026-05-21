#!/usr/bin/env node
/**
 * Lifts product catalog, variant tables, supplier pricing, and tool
 * bundles from the legacy single-file prototype (../index.html) into
 * type-safe TS modules under src/data/, and decodes embedded base64
 * JPEGs to public/catalog/*.jpg.
 *
 *   node scripts/extract-catalog.mjs
 */
import fs from 'node:fs';
import path from 'node:path';
import url from 'node:url';

const here = path.dirname(url.fileURLToPath(import.meta.url));
const appRoot = path.resolve(here, '..');
const legacyHtml = path.resolve(appRoot, '../index.html');
const imagesDir = path.join(appRoot, 'public/catalog');
const dataDir = path.join(appRoot, 'src/data');

fs.mkdirSync(imagesDir, { recursive: true });
fs.mkdirSync(dataDir, { recursive: true });

const html = fs.readFileSync(legacyHtml, 'utf8');
const lines = html.split('\n');

/** Find a `const NAME = {...};` or `const NAME = [...];` block, return its source. */
function liftConst(name) {
  const re = new RegExp(`\\bconst\\s+${name}\\s*=`);
  const start = lines.findIndex((l) => re.test(l));
  if (start < 0) throw new Error(`const ${name} not found`);
  const openChar = lines[start].match(/=\s*\{/) ? '{' : '[';
  const closeChar = openChar === '{' ? '}' : ']';
  let depth = 0;
  let end = -1;
  for (let i = start; i < lines.length; i++) {
    for (const ch of lines[i]) {
      if (ch === openChar) depth++;
      else if (ch === closeChar) {
        depth--;
        if (depth === 0) {
          end = i;
          break;
        }
      }
    }
    if (end >= 0) break;
  }
  if (end < 0) throw new Error(`Could not close const ${name}`);
  return lines.slice(start, end + 1).join('\n');
}

const treesSrc = liftConst('TREES');
const variantsSrc = liftConst('VARIANTS');
const storePricingSrc = liftConst('STORE_PRICING');
const supplierStoresSrc = liftConst('SUPPLIER_STORES');
const toolsSrc = liftConst('TOOLS');

const sandbox = new Function(
  `${treesSrc};${variantsSrc};${storePricingSrc};${supplierStoresSrc};${toolsSrc};` +
    'return {TREES, VARIANTS, STORE_PRICING, SUPPLIER_STORES, TOOLS};',
);
const { TREES, VARIANTS, STORE_PRICING, SUPPLIER_STORES, TOOLS } = sandbox();

/* ============================================================
 *  Catalog products + categories + accessories
 * ============================================================ */

const slug = (s) =>
  s
    .replace(/[\s/]+/g, '-')
    .replace(/["'״׳]/g, '')
    .replace(/[^֐-׿a-zA-Z0-9-]/g, '')
    .toLowerCase();

let imagesWritten = 0;
const products = Object.entries(TREES).map(([id, raw]) => {
  let image;
  if (typeof raw.image === 'string' && raw.image.startsWith('data:image/jpeg;base64,')) {
    const base64 = raw.image.split(',', 2)[1];
    fs.writeFileSync(path.join(imagesDir, `${id}.jpg`), Buffer.from(base64, 'base64'));
    image = `/catalog/${id}.jpg`;
    imagesWritten++;
  }

  const accessories = Array.isArray(raw.acc)
    ? raw.acc.map((a) => ({
        name: String(a.name ?? ''),
        emoji: String(a.img ?? '🧩'),
        price: typeof a.price === 'number' ? a.price : 0,
        qty: typeof a.qty === 'number' ? a.qty : 1,
        why: typeof a.why === 'string' ? a.why : undefined,
        must: a.must === true,
        ...(Array.isArray(a.sizes) ? { sizes: a.sizes } : {}),
      }))
    : [];

  const out = {
    id,
    name: String(raw.name ?? id),
    emoji: String(raw.img ?? '📦'),
    categoryName: String(raw.cat ?? 'אחר'),
  };
  if (raw.secondary) out.subcategoryName = String(raw.secondary);
  if (raw.productType) out.productType = String(raw.productType);
  if (raw.series) out.series = String(raw.series);
  if (raw.material) out.material = String(raw.material);
  if (raw.note) out.note = String(raw.note);
  if (typeof raw.price === 'number') out.price = raw.price;
  if (image) out.image = image;
  if (raw.catalogProduct === true) out.catalogProduct = true;
  if (raw.accessoryProduct === true) out.accessoryProduct = true;
  if (accessories.length) out.accessories = accessories;
  return out;
});

/* === De-duplicate product NAMES by appending a context tag ===
 * Legacy TREES mixes catalog items, accessories and workflow stages
 * under similar-looking names. The regression test (dupes category)
 * flags these as collisions. Resolve by keeping the most "main"
 * product unchanged and tagging the others.
 */
const stageMatch = (s) => (typeof s === 'string' ? s.match(/שלב\s*\d+/) : null);

const nameGroups = new Map();
for (const p of products) {
  const list = nameGroups.get(p.name) ?? [];
  list.push(p);
  nameGroups.set(p.name, list);
}

const rank = (p) => {
  if (p.id.startsWith('pl_')) return 0;          // catalog main
  if (p.productType === 'מוצר ראשי') return 1;   // declared main
  if (p.id.startsWith('acc_')) return 2;          // accessory
  return 3;                                       // workflow stages, misc
};

for (const [name, list] of nameGroups) {
  if (list.length < 2) continue;
  list.sort((a, b) => rank(a) - rank(b));
  for (let i = 1; i < list.length; i++) {
    const p = list[i];
    const stage = stageMatch(p.note);
    let tag;
    if (stage) tag = stage[0];
    else if (p.id.startsWith('acc_')) tag = 'אביזר';
    else if (p.productType && p.productType !== 'מוצר ראשי') tag = p.productType;
    else tag = p.id;
    p.name = `${name} · ${tag}`;
  }
}

const categoryEmojiMap = {
  'אביזרים מכניים': '⚙️',
  'אביזרים נלווים': '🧰',
  'ברזים וכיורים': '🚰',
  'אסלות': '🚽',
  'מקלחות ואמבטיות': '🚿',
  'בנייה ומחיצות': '🧱',
  'גמר': '🎨',
  'אינסטלציה גסה': '🔧',
  'חימום מים': '🔥',
  'מטבח': '🍳',
  'ניקוז וצנרת': '🟢',
  'גופי תברואה': '🛁',
  'אביזרי קצה וחיבורים': '🔩',
  'אחר': '✨',
};
const subEmojiMap = {
  'ברזים ושסתומים': '🚰',
  'חיבורים ומחברים': '🔗',
  'צנרת וצינורות': '🟢',
  'חומרי איטום והדבקה': '🧴',
  'ברגים ועיגון': '🔩',
  'אטמים וגומיות': '⭕',
  'בנייה וריצוף': '🧱',
  'מיכלים וגופים סמויים': '📦',
  'חשמל וחימום': '⚡',
  'אחר': '✨',
};

const catMap = new Map();
for (const p of products) {
  if (!catMap.has(p.categoryName)) catMap.set(p.categoryName, new Set());
  if (p.subcategoryName) catMap.get(p.categoryName).add(p.subcategoryName);
}
const cats = [];
for (const [topName, subs] of catMap.entries()) {
  const topId = `top-${slug(topName)}`;
  cats.push({ id: topId, name: topName, emoji: categoryEmojiMap[topName] ?? '📁', parentId: null });
  for (const subName of subs) {
    cats.push({
      id: `${topId}/${slug(subName)}`,
      name: subName,
      emoji: subEmojiMap[subName] ?? '•',
      parentId: topId,
    });
  }
}

for (const p of products) {
  const topId = `top-${slug(p.categoryName)}`;
  p.categoryTopId = topId;
  p.categoryLeafId = p.subcategoryName ? `${topId}/${slug(p.subcategoryName)}` : topId;
  delete p.categoryName;
  delete p.subcategoryName;
}

/* ============================================================
 *  VARIANTS — size / diameter options per catalog product
 * ============================================================ */

const variants = {};
for (const [productId, def] of Object.entries(VARIANTS)) {
  if (!def || typeof def !== 'object') continue;
  variants[productId] = {
    label: typeof def.label === 'string' ? def.label : 'גרסה',
    sku: def.sku === true,
    opts: Array.isArray(def.opts)
      ? def.opts.map((o) => {
          const out = { name: String(o.name ?? '') };
          if (o.sku) out.sku = String(o.sku);
          if (o.unit) out.unit = String(o.unit);
          if (o.diameter) out.diameter = String(o.diameter);
          if (o.page) out.page = String(o.page);
          if (typeof o.delta === 'number') out.delta = o.delta;
          if (o.model) out.model = String(o.model);
          return out;
        })
      : [],
  };
}

/* ============================================================
 *  SUPPLIER_STORES + STORE_PRICING
 * ============================================================ */

const suppliers = {};
for (const [id, s] of Object.entries(SUPPLIER_STORES)) {
  suppliers[id] = {
    id,
    name: String(s.name ?? id),
    icon: String(s.icon ?? '🏪'),
    shipping: typeof s.shipping === 'number' ? s.shipping : 0,
    eta: String(s.eta ?? ''),
  };
}

const storePricing = {};
for (const [storeId, prices] of Object.entries(STORE_PRICING)) {
  storePricing[storeId] = {};
  for (const [sku, price] of Object.entries(prices)) {
    storePricing[storeId][sku] = price;
  }
}

/* ============================================================
 *  TOOLS — required / suggested tools per job type
 * ============================================================ */

const tools = {};
for (const [key, list] of Object.entries(TOOLS)) {
  if (!Array.isArray(list)) continue;
  tools[key] = list.map((t) => ({
    name: String(t.name ?? ''),
    emoji: String(t.img ?? '🛠️'),
    why: typeof t.why === 'string' ? t.why : undefined,
    price: typeof t.price === 'number' ? t.price : 0,
  }));
}

/* ============================================================
 *  Write output files
 * ============================================================ */

const banner = `/* Auto-generated by scripts/extract-catalog.mjs — do not edit by hand.
 * Source: /home/user/buildsmart/index.html
 * Regenerate: node scripts/extract-catalog.mjs
 */
`;

const catalogTs =
  banner +
  `export type Accessory = {
  name: string;
  emoji: string;
  price: number;
  qty: number;
  why?: string;
  must: boolean;
  sizes?: unknown[];
};

export type CatalogProduct = {
  id: string;
  name: string;
  emoji: string;
  categoryTopId: string;
  categoryLeafId: string;
  productType?: string;
  series?: string;
  material?: string;
  note?: string;
  price?: number;
  image?: string;
  catalogProduct?: boolean;
  accessoryProduct?: boolean;
  accessories?: Accessory[];
};

export type CatalogCategory = {
  id: string;
  name: string;
  emoji: string;
  parentId: string | null;
};

` +
  `export const CATEGORIES: CatalogCategory[] = ${JSON.stringify(cats, null, 2)};\n\n` +
  `export const PRODUCTS: CatalogProduct[] = ${JSON.stringify(products, null, 2)};\n` +
  `
export function childrenOf(parentId: string | null): CatalogCategory[] {
  return CATEGORIES.filter((c) => c.parentId === parentId);
}

export function categoryById(id: string): CatalogCategory | undefined {
  return CATEGORIES.find((c) => c.id === id);
}

export function productsForPath(path: string[]): CatalogProduct[] {
  if (path.length === 0) return PRODUCTS;
  const current = path[path.length - 1];
  return PRODUCTS.filter(
    (p) => p.categoryLeafId === current || p.categoryTopId === current,
  );
}

export function productById(id: string): CatalogProduct | undefined {
  return PRODUCTS.find((p) => p.id === id);
}
`;
fs.writeFileSync(path.join(dataDir, 'catalog.ts'), catalogTs);

const variantsTs =
  banner +
  `export type VariantOption = {
  name: string;
  sku?: string;
  unit?: string;
  diameter?: string;
  page?: string;
  delta?: number;
  model?: string;
};

export type VariantDef = {
  label: string;
  sku: boolean;
  opts: VariantOption[];
};

export const VARIANTS: Record<string, VariantDef> = ${JSON.stringify(variants, null, 2)};

export function variantsOf(productId: string): VariantDef | undefined {
  return VARIANTS[productId];
}
`;
fs.writeFileSync(path.join(dataDir, 'variants.ts'), variantsTs);

const suppliersTs =
  banner +
  `export type Supplier = {
  id: string;
  name: string;
  icon: string;
  shipping: number;
  eta: string;
};

export const SUPPLIERS: Record<string, Supplier> = ${JSON.stringify(suppliers, null, 2)};

export const STORE_PRICING: Record<string, Record<string, number>> = ${JSON.stringify(
    storePricing,
    null,
    2,
  )};

export const DEFAULT_SUPPLIER_ID = '${Object.keys(suppliers)[0] ?? ''}';

export function priceFor(sku: string | undefined, supplierId: string): number | undefined {
  if (!sku) return undefined;
  return STORE_PRICING[supplierId]?.[sku];
}

export function cheapestSupplier(sku: string | undefined): { supplierId: string; price: number } | undefined {
  if (!sku) return undefined;
  let best: { supplierId: string; price: number } | undefined;
  for (const [id, prices] of Object.entries(STORE_PRICING)) {
    const p = prices[sku];
    if (typeof p === 'number' && (!best || p < best.price)) {
      best = { supplierId: id, price: p };
    }
  }
  return best;
}
`;
fs.writeFileSync(path.join(dataDir, 'suppliers.ts'), suppliersTs);

const toolsTs =
  banner +
  `export type ToolItem = {
  name: string;
  emoji: string;
  why?: string;
  price: number;
};

export const TOOL_BUNDLES: Record<string, ToolItem[]> = ${JSON.stringify(tools, null, 2)};

export function toolsFor(key: string): ToolItem[] {
  return TOOL_BUNDLES[key] ?? [];
}
`;
fs.writeFileSync(path.join(dataDir, 'tools.ts'), toolsTs);

console.log('---');
console.log(`Products:            ${products.length}`);
console.log(`  with image:        ${imagesWritten}`);
console.log(`  with accessories:  ${products.filter((p) => p.accessories?.length).length}`);
console.log(`Categories:          ${cats.filter((c) => !c.parentId).length} top + ${cats.filter((c) => c.parentId).length} sub`);
console.log(`Variants:            ${Object.keys(variants).length} products with size pickers`);
console.log(`Suppliers:           ${Object.keys(suppliers).length}`);
console.log(`STORE_PRICING SKUs:  ${Object.values(storePricing).reduce((a, s) => a + Object.keys(s).length, 0)} total across ${Object.keys(storePricing).length} stores`);
console.log(`Tool bundles:        ${Object.keys(tools).length} keyed bundles (${Object.values(tools).reduce((a, t) => a + t.length, 0)} tool entries)`);
const sizeKb = (p) => Math.round(fs.statSync(p).size / 1024);
console.log('---');
for (const f of ['catalog.ts', 'variants.ts', 'suppliers.ts', 'tools.ts']) {
  console.log(`  ${f}: ${sizeKb(path.join(dataDir, f))} KB`);
}
