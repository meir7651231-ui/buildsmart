export type Product = {
  id: string;
  name: string;
  emoji: string;
  supplier: string;
  unit: string;
  price: number;
  categoryId: string;
  recommended?: boolean;
};

export const PRODUCTS: Product[] = [
  {
    id: 'p-block-20',
    name: 'בלוק איטונג 20×25×60',
    emoji: '🧱',
    supplier: 'איטונג ישראל',
    unit: 'יח׳',
    price: 12.9,
    categoryId: 'build.block',
    recommended: true,
  },
  {
    id: 'p-cement-50',
    name: 'שק מלט 50 ק״ג',
    emoji: '🪨',
    supplier: 'נשר',
    unit: 'שק',
    price: 28,
    categoryId: 'build.cement',
    recommended: true,
  },
  {
    id: 'p-rebar-10',
    name: 'מוט ברזל זיון Ø10 מ״מ',
    emoji: '🪵',
    supplier: 'מפעלי פלדה',
    unit: 'מוט',
    price: 34.5,
    categoryId: 'build.rebar',
    recommended: true,
  },
  {
    id: 'p-pipe-25',
    name: 'צינור PEX 25 מ״מ',
    emoji: '🟢',
    supplier: 'פלסאון',
    unit: 'מטר',
    price: 9.8,
    categoryId: 'plumb.pipe',
    recommended: true,
  },
  {
    id: 'p-tap-1',
    name: 'ברז כיור מטבח',
    emoji: '🚰',
    supplier: 'חמת',
    unit: 'יח׳',
    price: 245,
    categoryId: 'plumb.tap',
  },
  {
    id: 'p-cable-3x25',
    name: 'כבל NYM 3×2.5',
    emoji: '🔌',
    supplier: 'תרמוקבל',
    unit: 'מטר',
    price: 4.2,
    categoryId: 'elec.cable',
    recommended: true,
  },
  {
    id: 'p-socket-1',
    name: 'שקע קיר כפול',
    emoji: '◽',
    supplier: 'גוויס',
    unit: 'יח׳',
    price: 18,
    categoryId: 'elec.socket',
  },
  {
    id: 'p-board-12',
    name: 'לוח חשמל 12 מודולים',
    emoji: '🔲',
    supplier: 'שניידר',
    unit: 'יח׳',
    price: 320,
    categoryId: 'elec.board',
  },
  {
    id: 'p-drill-18v',
    name: 'מקדחה נטענת 18V',
    emoji: '🪛',
    supplier: 'מקיטה',
    unit: 'יח׳',
    price: 599,
    categoryId: 'tools.power',
    recommended: true,
  },
  {
    id: 'p-hammer-1',
    name: 'פטיש 16 oz',
    emoji: '🔨',
    supplier: 'STANLEY',
    unit: 'יח׳',
    price: 79,
    categoryId: 'tools.hand',
  },
  {
    id: 'p-ladder-3m',
    name: 'סולם אלומיניום 3 מ׳',
    emoji: '🪜',
    supplier: 'דאקו',
    unit: 'יח׳',
    price: 459,
    categoryId: 'tools.ladder',
  },
  {
    id: 'p-paint-10',
    name: 'צבע אקרילי לבן 10 ליטר',
    emoji: '🎨',
    supplier: 'טמבור',
    unit: 'פח',
    price: 199,
    categoryId: 'finish.paint',
    recommended: true,
  },
  {
    id: 'p-tile-60',
    name: 'אריח גרניט פורצלן 60×60',
    emoji: '⬛',
    supplier: 'נגב',
    unit: 'מ״ר',
    price: 89,
    categoryId: 'finish.tile',
  },
  {
    id: 'p-gypsum-12',
    name: 'לוח גבס 12.5 מ״מ',
    emoji: '⬜',
    supplier: 'אורבונד',
    unit: 'לוח',
    price: 34,
    categoryId: 'finish.gypsum',
  },
  {
    id: 'p-helmet-1',
    name: 'קסדת בטיחות תקן ANSI',
    emoji: '⛑️',
    supplier: '3M',
    unit: 'יח׳',
    price: 55,
    categoryId: 'safety.helmet',
    recommended: true,
  },
  {
    id: 'p-boots-42',
    name: 'נעלי בטיחות S3',
    emoji: '🥾',
    supplier: 'דלתא פלוס',
    unit: 'זוג',
    price: 219,
    categoryId: 'safety.boots',
  },
];

export function productsForPath(path: string[], recommendedOnly = false): Product[] {
  if (path.length === 0) {
    return recommendedOnly ? PRODUCTS.filter((p) => p.recommended) : PRODUCTS;
  }
  const current = path[path.length - 1];
  return PRODUCTS.filter((p) => p.categoryId === current || p.categoryId.startsWith(current + '.'));
}

export function productById(id: string): Product | undefined {
  return PRODUCTS.find((p) => p.id === id);
}
