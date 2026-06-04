// LIPSKEY PDF parity — gate 117.
//
// Source-of-truth: catalog PDF (pages 50–52) uploaded 2026-06-03.
// Each row asserted here is verified against the printed catalog.
// When this test goes RED, fix the data in lib/data/lipskey_catalog.dart
// to match the PDF — never the other way around.
//
// Scope (incremental): מיכלי הדחה — 23 SKUs (pages 50–52).
// Follow-ups: מושבי אסלה, מחסומים, ברכיים, etc.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _Expected {
  final String sku;
  final String nameHe;
  final String color;
  final int qtyPack;
  final String categoryHe;
  final String capacity; // "3/6 ליטר" or "4.5/9 ליטר"
  final String h;        // "35.5 ס\"מ"
  final String w;        // "43.5 ס\"מ"
  final String d;        // "15.5 ס\"מ"
  final int page;
  const _Expected({
    required this.sku,
    required this.nameHe,
    required this.color,
    required this.qtyPack,
    required this.categoryHe,
    required this.capacity,
    required this.h,
    required this.w,
    required this.d,
    required this.page,
  });
}

const _expectedToiletTanks = <_Expected>[
  // ── page 50 · התקנה גבוהה ──────────────────────────────────────────────────
  _Expected(sku: '152785', nameHe: 'מיכל הדחה טיטאן לבן',     color: 'לבן',    qtyPack: 60, categoryHe: 'התקנה גבוהה', capacity: '3/6 ליטר',   h: '35.5 ס"מ', w: '43.5 ס"מ', d: '15.5 ס"מ', page: 50),
  _Expected(sku: '152786', nameHe: 'מיכל הדחה טיטאן פרגמון',  color: 'פרגמון', qtyPack: 60, categoryHe: 'התקנה גבוהה', capacity: '3/6 ליטר',   h: '35.5 ס"מ', w: '43.5 ס"מ', d: '15.5 ס"מ', page: 50),
  _Expected(sku: '152787', nameHe: 'מיכל הדחה טיטאן אפור',    color: 'אפור',   qtyPack: 60, categoryHe: 'התקנה גבוהה', capacity: '3/6 ליטר',   h: '35.5 ס"מ', w: '43.5 ס"מ', d: '15.5 ס"מ', page: 50),
  _Expected(sku: '145629', nameHe: 'מיכל הדחה יהלום לבן',     color: 'לבן',    qtyPack: 50, categoryHe: 'התקנה גבוהה', capacity: '4.5/9 ליטר', h: '35.5 ס"מ', w: '44.5 ס"מ', d: '15.5 ס"מ', page: 50),
  _Expected(sku: '145630', nameHe: 'מיכל הדחה יהלום פרגמון',  color: 'פרגמון', qtyPack: 50, categoryHe: 'התקנה גבוהה', capacity: '4.5/9 ליטר', h: '35.5 ס"מ', w: '44.5 ס"מ', d: '15.5 ס"מ', page: 50),
  _Expected(sku: '145631', nameHe: 'מיכל הדחה יהלום אפור',    color: 'אפור',   qtyPack: 50, categoryHe: 'התקנה גבוהה', capacity: '4.5/9 ליטר', h: '35.5 ס"מ', w: '44.5 ס"מ', d: '15.5 ס"מ', page: 50),

  // ── page 51 · התקנה נמוכה ──────────────────────────────────────────────────
  _Expected(sku: '124848', nameHe: 'מיכל הדחה ספיר לבן',      color: 'לבן',    qtyPack: 56, categoryHe: 'התקנה נמוכה', capacity: '4.5/9 ליטר', h: '34 ס"מ',   w: '44 ס"מ',   d: '14 ס"מ',   page: 51),
  _Expected(sku: '124850', nameHe: 'מיכל הדחה ספיר פרגמון',   color: 'פרגמון', qtyPack: 56, categoryHe: 'התקנה נמוכה', capacity: '4.5/9 ליטר', h: '34 ס"מ',   w: '44 ס"מ',   d: '14 ס"מ',   page: 51),
  _Expected(sku: '124851', nameHe: 'מיכל הדחה ספיר אפור',     color: 'אפור',   qtyPack: 56, categoryHe: 'התקנה נמוכה', capacity: '4.5/9 ליטר', h: '34 ס"מ',   w: '44 ס"מ',   d: '14 ס"מ',   page: 51),
  _Expected(sku: '178862', nameHe: 'מיכל הדחה ברקת לבן',      color: 'לבן',    qtyPack: 56, categoryHe: 'התקנה נמוכה', capacity: '3/6 ליטר',   h: '41.5 ס"מ', w: '37 ס"מ',   d: '11.5 ס"מ', page: 51),
  _Expected(sku: '178866', nameHe: 'מיכל הדחה ברקת פרגמון',   color: 'פרגמון', qtyPack: 56, categoryHe: 'התקנה נמוכה', capacity: '3/6 ליטר',   h: '41.5 ס"מ', w: '37 ס"מ',   d: '11.5 ס"מ', page: 51),
  _Expected(sku: '178869', nameHe: 'מיכל הדחה ברקת אפור',     color: 'אפור',   qtyPack: 56, categoryHe: 'התקנה נמוכה', capacity: '3/6 ליטר',   h: '41.5 ס"מ', w: '37 ס"מ',   d: '11.5 ס"מ', page: 51),
  _Expected(sku: '116792', nameHe: 'מיכל הדחה טופז לבן',      color: 'לבן',    qtyPack: 70, categoryHe: 'התקנה נמוכה', capacity: '4.5/9 ליטר', h: '35 ס"מ',   w: '44 ס"מ',   d: '14 ס"מ',   page: 51),
  _Expected(sku: '116795', nameHe: 'מיכל הדחה טופז פרגמון',   color: 'פרגמון', qtyPack: 70, categoryHe: 'התקנה נמוכה', capacity: '4.5/9 ליטר', h: '35 ס"מ',   w: '44 ס"מ',   d: '14 ס"מ',   page: 51),
  _Expected(sku: '116798', nameHe: 'מיכל הדחה טופז אפור',     color: 'אפור',   qtyPack: 70, categoryHe: 'התקנה נמוכה', capacity: '4.5/9 ליטר', h: '35 ס"מ',   w: '44 ס"מ',   d: '14 ס"מ',   page: 51),
  _Expected(sku: '154068', nameHe: 'מיכל הדחה טיטאן נמוך לבן',    color: 'לבן',    qtyPack: 65, categoryHe: 'התקנה נמוכה', capacity: '3/6 ליטר', h: '35 ס"מ',   w: '43 ס"מ',   d: '15 ס"מ',   page: 51),
  _Expected(sku: '154069', nameHe: 'מיכל הדחה טיטאן נמוך פרגמון', color: 'פרגמון', qtyPack: 65, categoryHe: 'התקנה נמוכה', capacity: '3/6 ליטר', h: '35 ס"מ',   w: '43 ס"מ',   d: '15 ס"מ',   page: 51),
  _Expected(sku: '154413', nameHe: 'מיכל הדחה טיטאן נמוך אפור',   color: 'אפור',   qtyPack: 65, categoryHe: 'התקנה נמוכה', capacity: '3/6 ליטר', h: '35 ס"מ',   w: '43 ס"מ',   d: '15 ס"מ',   page: 51),

  // ── page 52 · התקנה צמודה (מונובלוק) ───────────────────────────────────────
  _Expected(sku: '168525', nameHe: 'מיכל הדחה כנרת מונובלוק לבן',    color: 'לבן',    qtyPack: 56, categoryHe: 'התקנה צמודה', capacity: '3/6 ליטר', h: '42.5 ס"מ', w: '37 ס"מ', d: '17 ס"מ',   page: 52),
  _Expected(sku: '169604', nameHe: 'מיכל הדחה כנרת מונובלוק פרגמון', color: 'פרגמון', qtyPack: 56, categoryHe: 'התקנה צמודה', capacity: '3/6 ליטר', h: '42.5 ס"מ', w: '37 ס"מ', d: '17 ס"מ',   page: 52),
  _Expected(sku: '178864', nameHe: 'מיכל הדחה ברקת מונובלוק לבן',    color: 'לבן',    qtyPack: 56, categoryHe: 'התקנה צמודה', capacity: '3/6 ליטר', h: '41.5 ס"מ', w: '37 ס"מ', d: '11.5 ס"מ', page: 52),
  _Expected(sku: '178867', nameHe: 'מיכל הדחה ברקת מונובלוק פרגמון', color: 'פרגמון', qtyPack: 56, categoryHe: 'התקנה צמודה', capacity: '3/6 ליטר', h: '41.5 ס"מ', w: '37 ס"מ', d: '11.5 ס"מ', page: 52),
  _Expected(sku: '178870', nameHe: 'מיכל הדחה ברקת מונובלוק אפור',   color: 'אפור',   qtyPack: 70, categoryHe: 'התקנה צמודה', capacity: '3/6 ליטר', h: '41.5 ס"מ', w: '37 ס"מ', d: '11.5 ס"מ', page: 52),
];

void main() {
  group('LIPSKEY PDF parity — מיכלי הדחה (gate 117)', () {
    final bySku = {
      for (final p in kLipskeyCatalog.where((p) => p.brand == 'ליפסקי'))
        p.sku: p,
    };

    for (final e in _expectedToiletTanks) {
      test('SKU ${e.sku} · ${e.nameHe}', () {
        final p = bySku[e.sku];
        expect(p, isNotNull, reason: 'SKU ${e.sku} מהקטלוג חסר ב-kLipskeyCatalog');
        expect(p!.nameHe,     e.nameHe,     reason: 'nameHe ל-${e.sku}');
        expect(p.color,       e.color,      reason: 'color ל-${e.sku}');
        expect(p.qtyPack,     e.qtyPack,    reason: 'qtyPack ל-${e.sku}');
        expect(p.categoryHe,  e.categoryHe, reason: 'categoryHe ל-${e.sku}');
        expect(p.page,        e.page,       reason: 'page ל-${e.sku}');
        expect(p.dims?['תכולה'], e.capacity, reason: 'dims[תכולה] ל-${e.sku}');
        expect(p.dims?['גובה'],  e.h, reason: 'dims[גובה] ל-${e.sku}');
        expect(p.dims?['רוחב'],  e.w, reason: 'dims[רוחב] ל-${e.sku}');
        expect(p.dims?['עומק'],  e.d, reason: 'dims[עומק] ל-${e.sku}');
      });
    }

    test('phantom SKUs in current data are gone (was 124040/124050/124051/170862/170866/170869/116752/154058)', () {
      const phantoms = ['124040', '124050', '124051', '170862', '170866', '170869', '116752', '154058'];
      for (final ghost in phantoms) {
        expect(bySku[ghost], isNull,
          reason: 'SKU $ghost לא קיים בקטלוג ה-PDF — להסיר מ-kLipskeyCatalog');
      }
    });
  });

  // ── מושבי אסלה — pages 53–55 (26 SKUs) ─────────────────────────────────────
  group('LIPSKEY PDF parity — מושבי אסלה (gate 117)', () {
    final bySku = {
      for (final p in kLipskeyCatalog.where((p) => p.brand == 'ליפסקי'))
        p.sku: p,
    };

    const seats = <_Seat>[
      // ── page 53 · תרמופלסטיים — מס. 1/3/3.5/4 ──────────────────────────────
      _Seat('171026', 'מושב אסלה מס. 1 לבן',    'לבן',    6, 240, 53),
      _Seat('171027', 'מושב אסלה מס. 1 פרגמון', 'פרגמון', 6, 240, 53),
      _Seat('171028', 'מושב אסלה מס. 1 אפור',   'אפור',   6, 240, 53),
      _Seat('116700', 'מושב אסלה מס. 3 לבן',    'לבן',    6, 216, 53),
      _Seat('116703', 'מושב אסלה מס. 3 פרגמון', 'פרגמון', 6, 216, 53),
      _Seat('116709', 'מושב אסלה מס. 3 אפור',   'אפור',   6, 216, 53),
      _Seat('220943', 'מושב אסלה מס. 3.5 משולב לבן',                  'לבן',    5, 260, 53),
      _Seat('217934', 'מושב אסלה מס. 4 ציר פלסטיק לבן',               'לבן',    6, 216, 53),
      _Seat('217935', 'מושב אסלה מס. 4 ציר פלסטיק פרגמון',            'פרגמון', 6, 216, 53),
      _Seat('218360', 'מושב אסלה מס. 4 ציר ניירוסטה לבן',             'לבן',    6, 216, 53),
      _Seat('218361', 'מושב אסלה מס. 4 ציר ניירוסטה פרגמון',          'פרגמון', 6, 216, 53),
      // ── page 54 · תרמופלסטיים — מס. 5/9 + ULTRA ────────────────────────────
      _Seat('116712', 'מושב אסלה מס. 5 לבן',    'לבן',    6, 216, 54),
      _Seat('116716', 'מושב אסלה מס. 5 פרגמון', 'פרגמון', 6, 216, 54),
      _Seat('116722', 'מושב אסלה מס. 5 אפור',   'אפור',   6, 216, 54),
      _Seat('179611', 'מושב אסלה מס. 9 ציר ניירוסטה אנטי ונדליזם לבן',     'לבן',    5, 160, 54),
      _Seat('179612', 'מושב אסלה מס. 9 ציר ניירוסטה אנטי ונדליזם פרגמון',  'פרגמון', 5, 160, 54),
      _Seat('179613', 'מושב אסלה מס. 9 ציר ניירוסטה אנטי ונדליזם אפור',    'אפור',   5, 160, 54),
      _Seat('224286', 'מושב אסלה טרמו ULTRA לבן', 'לבן', 100, 4500, 54),
      // ── page 55 · תרמוסטיים — חרמון/אדיר/תבור/כרמל/הגייני ──────────────────
      _Seat('179046', 'מושב אסלה חרמון לבן',    'לבן',    6, 216, 55),
      _Seat('186379', 'מושב אסלה חרמון פרגמון', 'פרגמון', 6, 216, 55),
      _Seat('220981', 'מושב אסלה אדיר לבן',     'לבן',    6, 216, 55),
      _Seat('187133', 'מושב אסלה תבור סגירה רכה לבן',     'לבן',    6, 216, 55),
      _Seat('187134', 'מושב אסלה תבור סגירה רכה פרגמון',  'פרגמון', 6, 216, 55),
      _Seat('195505', 'מושב אסלה כרמל סגירה רכה לבן',     'לבן',    5, 180, 55),
      _Seat('195506', 'מושב אסלה כרמל סגירה רכה פרגמון',  'פרגמון', 5, 180, 55),
      _Seat('197222', 'מושב אסלה הגייני אנטי ונדליזם ציר ניירוסטה לבן', 'לבן', 10, 300, 55),
    ];

    for (final s in seats) {
      test('SKU ${s.sku} · ${s.nameHe}', () {
        final p = bySku[s.sku];
        expect(p, isNotNull, reason: 'SKU ${s.sku} מהקטלוג חסר ב-kLipskeyCatalog');
        expect(p!.nameHe,    s.nameHe,    reason: 'nameHe ל-${s.sku}');
        expect(p.color,      s.color,     reason: 'color ל-${s.sku}');
        expect(p.qtyPack,    s.qtyPack,   reason: 'qtyPack ל-${s.sku}');
        expect(p.qtyPallet,  s.qtyPallet, reason: 'qtyPallet ל-${s.sku}');
        expect(p.categoryHe, 'מושבי אסלה', reason: 'categoryHe ל-${s.sku}');
        expect(p.page,       s.page,      reason: 'page ל-${s.sku}');
      });
    }

    test('phantom seat SKUs gone', () {
      // PDF SKUs: חרמון פרגמון=186379, תבור פרגמון=187134, כרמל לבן=195505, הגייני=197222.
      // Old code had: 179370 (fake חרמון פרגמון), 197134 (fake תבור פרגמון —
      // typo of 187134), 195425 (fake כרמל לבן), 107222 ("גנדלים" — not in PDF).
      const phantoms = ['179370', '197134', '195425', '107222'];
      for (final ghost in phantoms) {
        expect(bySku[ghost], isNull,
          reason: 'SKU $ghost לא קיים בקטלוג ה-PDF — להסיר מ-kLipskeyCatalog');
      }
    });
  });

  _runVisibleTrapGroup();
  _runInsertionBendGroup();
  _runInsertionBranchGroup();
  _runConnectorGroup();
  _runCollectorGroup();
  _runGasketPlugGroup();
  _runScrewOnGroup();
  _runPipeGroup();
}

// ── צינורות — pages 47–48 (~55 SKUs) ────────────────────────────────────────
class _Pipe {
  final String sku;
  final String color;   // אפור / שחור / כתום
  final String dn;
  final String l;       // L in cm
  final int page;
  const _Pipe(this.sku, this.color, this.dn, this.l, this.page);
}

const _pipes = <_Pipe>[
  // page 47 · אפור (gray) DN40
  _Pipe('116603', 'אפור', '40', '50',  47),
  _Pipe('116606', 'אפור', '40', '100', 47),
  _Pipe('116069', 'אפור', '40', '300', 47),
  _Pipe('116071', 'אפור', '40', '400', 47),
  // page 47 · אפור DN50
  _Pipe('116610', 'אפור', '50', '50',  47),
  _Pipe('119967', 'אפור', '50', '100', 47),
  _Pipe('116076', 'אפור', '50', '300', 47),
  _Pipe('116078', 'אפור', '50', '400', 47),
  // page 47 · אפור DN75
  _Pipe('116612', 'אפור', '75', '50',  47),
  _Pipe('116084', 'אפור', '75', '100', 47),
  _Pipe('116091', 'אפור', '75', '300', 47),
  _Pipe('116093', 'אפור', '75', '400', 47),
  // page 47 · אפור DN110
  _Pipe('116113', 'אפור', '110', '15',  47),
  _Pipe('116617', 'אפור', '110', '25',  47),
  _Pipe('116620', 'אפור', '110', '50',  47),
  _Pipe('116096', 'אפור', '110', '75',  47),
  _Pipe('116099', 'אפור', '110', '100', 47),
  _Pipe('116101', 'אפור', '110', '150', 47),
  _Pipe('116622', 'אפור', '110', '200', 47),
  _Pipe('116103', 'אפור', '110', '300', 47),
  _Pipe('116105', 'אפור', '110', '400', 47),
  // page 47 · שחור (black) DN40
  _Pipe('273227', 'שחור', '40', '50',  47),
  _Pipe('273226', 'שחור', '40', '100', 47),
  _Pipe('220278', 'שחור', '40', '300', 47),
  // page 47 · שחור DN50
  _Pipe('221022', 'שחור', '50', '50',  47),
  _Pipe('221021', 'שחור', '50', '100', 47),
  _Pipe('220280', 'שחור', '50', '300', 47),
  // page 47 · שחור DN75
  _Pipe('221085', 'שחור', '75', '50',  47),
  _Pipe('221084', 'שחור', '75', '100', 47),
  _Pipe('221415', 'שחור', '75', '300', 47),
  // page 47 · שחור DN110
  _Pipe('219791', 'שחור', '110', '25',  47),
  _Pipe('219792', 'שחור', '110', '50',  47),
  _Pipe('221083', 'שחור', '110', '100', 47),
  _Pipe('224205', 'שחור', '110', '150', 47),
  _Pipe('221414', 'שחור', '110', '200', 47),
  _Pipe('221082', 'שחור', '110', '300', 47),
  _Pipe('221086', 'שחור', '110', '400', 47),
  // page 48 · PP-MD-ML SN4 (כתום)
  _Pipe('224168', 'כתום', '110', '300', 48),
  _Pipe('224169', 'כתום', '110', '100', 48),
  _Pipe('224170', 'כתום', '110', '50',  48),
  _Pipe('224185', 'כתום', '160', '300', 48),
  _Pipe('224186', 'כתום', '160', '100', 48),
  _Pipe('224187', 'כתום', '160', '50',  48),
  // page 48 · PP-MD-ML SN8 (כתום)
  _Pipe('224345', 'כתום', '110', '300', 48),
  _Pipe('224344', 'כתום', '110', '100', 48),
  _Pipe('224348', 'כתום', '160', '300', 48),
  _Pipe('224347', 'כתום', '160', '100', 48),
  _Pipe('224346', 'כתום', '160', '50',  48),
  // page 48 · SUPER BETON/SILENT (שחור)
  _Pipe('273216', 'שחור', '75',  '300', 48),
  _Pipe('273217', 'שחור', '75',  '100', 48),
  _Pipe('273201', 'שחור', '110', '300', 48),
  _Pipe('273202', 'שחור', '110', '100', 48),
  _Pipe('273203', 'שחור', '110', '50',  48),
  _Pipe('273215', 'שחור', '110', '25',  48),
  _Pipe('273219', 'שחור', '160', '300', 48),
  _Pipe('273220', 'שחור', '160', '100', 48),
  _Pipe('273221', 'שחור', '160', '50',  48),
];

void _runPipeGroup() {
  group('LIPSKEY PDF parity — צינורות (gate 117)', () {
    final bySku = {
      for (final p in kLipskeyCatalog.where((p) => p.brand == 'ליפסקי'))
        p.sku: p,
    };

    for (final pipe in _pipes) {
      test('SKU ${pipe.sku} · צינור ${pipe.color} DN${pipe.dn} L=${pipe.l}', () {
        final p = bySku[pipe.sku];
        expect(p, isNotNull, reason: 'SKU ${pipe.sku} מהקטלוג חסר ב-kLipskeyCatalog');
        expect(p!.color,        pipe.color, reason: 'color ל-${pipe.sku}');
        expect(p.dims?['DN'],   pipe.dn,    reason: 'dims[DN] ל-${pipe.sku}');
        expect(p.dims?['L (cm)'], pipe.l,   reason: 'dims[L (cm)] ל-${pipe.sku}');
        expect(p.page,          pipe.page,  reason: 'page ל-${pipe.sku}');
      });
    }
  });
}

// ── אביזרי תבריג — pages 20–23 (32 SKUs) ────────────────────────────────────
class _So {
  final String sku;
  final String nameHe;
  final String dn;
  final int qtyPack;
  final int qtyPallet;
  final int page;
  const _So(this.sku, this.nameHe, this.dn, this.qtyPack, this.qtyPallet, this.page);
}

const _screwOn = <_So>[
  // ── page 20–21 · ברכים תבריג ──
  // ברך 90° תבריג צד אחד
  _So('197091', 'ברך 90° תבריג צד אחד 32/32', '32/32', 100, 4500, 20),
  _So('116186', 'ברך 90° תבריג צד אחד 40/40', '40/40', 100, 4500, 20),
  _So('116191', 'ברך 90° תבריג צד אחד 50/50', '50/50',  50, 2250, 20),
  // ברך 45° תבריג כפול
  _So('116668', 'ברך 45° תבריג כפול 32/32', '32/32', 100, 4500, 21),
  _So('116199', 'ברך 45° תבריג כפול 32/40', '32/40', 100, 4500, 21),
  _So('116197', 'ברך 45° תבריג כפול 40/40', '40/40',  80, 3600, 21),
  _So('116201', 'ברך 45° תבריג כפול 32/50', '32/50',  80, 3600, 21),
  _So('116670', 'ברך 45° תבריג כפול 40/50', '40/50',  50, 2250, 21),
  _So('116666', 'ברך 45° תבריג כפול 50/50', '50/50',  50, 2250, 21),
  // ברך 90° תבריג כפול
  _So('116656', 'ברך 90° תבריג כפול 32/32', '32/32', 100, 4500, 21),
  _So('116182', 'ברך 90° תבריג כפול 32/40', '32/40', 100, 4500, 21),
  _So('119934', 'ברך 90° תבריג כפול 40/40', '40/40',  80, 3600, 21),
  _So('116661', 'ברך 90° תבריג כפול 32/50', '32/50',  80, 3600, 21),
  _So('116663', 'ברך 90° תבריג כפול 40/50', '40/50',  50, 2250, 21),
  _So('116659', 'ברך 90° תבריג כפול 50/50', '50/50',  50, 2250, 21),
  // ברך 90° ש"ת לסיפון
  _So('116194', 'ברך 90° תבריג ש"ת לסיפון 32/40', '32/40', 100, 4500, 21),
  _So('204127', 'ברך 90° תבריג ש"ת לסיפון 32/50', '32/50',  80, 3600, 21),
  // ברך 15° / 30° / 45° תבריג צד אחד
  _So('213072', 'ברך 15° תבריג צד אחד 50/50', '50/50', 80, 3600, 20),
  _So('213073', 'ברך 30° תבריג צד אחד 50/50', '50/50', 80, 3600, 20),
  _So('116207', 'ברך 45° תבריג צד אחד 32/32', '32/32', 100, 4500, 20),
  _So('116203', 'ברך 45° תבריג צד אחד 40/49', '40/49', 100, 4500, 20),
  _So('116205', 'ברך 45° תבריג צד אחד 50/50', '50/50',  50, 2500, 20),
  // ברך 90° טלסקופית רב-תכליתית
  _So('170643', 'ברך 90° טלסקופית תבריג ש"ת 90/50/50', '90/50/50', 30, 1350, 20),
  _So('223101', 'ברך 90° טלסקופית 40/50/50',           '40/50/50', 50, 2250, 20),

  // ── page 22–23 · מסעפים + מחברים + מצרות תבריג ──
  // מסעף 45° תבריג
  _So('187463', 'מסעף 45° תבריג 32/32/32', '32/32/32', 50, 3600, 22),
  _So('116223', 'מסעף 45° תבריג 40/40/40', '40/40/40', 30, 1350, 22),
  _So('116225', 'מסעף 45° תבריג 50/50/40', '50/50/40', 30, 1350, 22),
  _So('116220', 'מסעף 45° תבריג 50/50/50', '50/50/50', 30, 1350, 22),
  // מסעף 45° צד ללא תבריג
  _So('116229', 'מסעף 45° צד ללא תבריג 40/40/40', '40/40/40', 30, 1350, 22),
  _So('116231', 'מסעף 45° צד ללא תבריג 50/40/50', '50/40/50', 30, 1350, 22),
  // מסעף 90° תבריג
  _So('116589', 'מסעף 90° תבריג 32/32', '32/32', 80, 3600, 22),
  _So('116682', 'מסעף 90° תבריג 40/40', '40/40', 50, 2250, 22),
  _So('116687', 'מסעף 90° תבריג 50/40', '50/40', 30, 1350, 22),
  _So('116684', 'מסעף 90° תבריג 50/50', '50/50', 30, 1350, 22),
  // מחבר כפול
  _So('116209', 'מחבר כפול תבריג 32/32', '32/32', 100, 4500, 23),
  _So('116672', 'מחבר כפול תבריג 40/40', '40/40',  80, 3600, 23),
  _So('116675', 'מחבר כפול תבריג 50/50', '50/50',  50, 2250, 23),
  // מצרות תבריג
  _So('116677', 'מצרה תבריג 40/32', '40/32', 100, 4500, 23),
  _So('116680', 'מצרה תבריג 50/32', '50/32', 100, 4500, 23),
  _So('116212', 'מצרה תבריג 50/40', '50/40',  80, 3600, 23),
  _So('116215', 'מצרה תבריג 50/60', '50/60',  50, 2250, 23),
];

void _runScrewOnGroup() {
  group('LIPSKEY PDF parity — אביזרי תבריג (gate 117)', () {
    final bySku = {
      for (final p in kLipskeyCatalog.where((p) => p.brand == 'ליפסקי'))
        p.sku: p,
    };

    for (final s in _screwOn) {
      test('SKU ${s.sku} · ${s.nameHe}', () {
        final p = bySku[s.sku];
        expect(p, isNotNull, reason: 'SKU ${s.sku} מהקטלוג חסר ב-kLipskeyCatalog');
        expect(p!.nameHe,    s.nameHe,    reason: 'nameHe ל-${s.sku}');
        expect(p.qtyPack,    s.qtyPack,   reason: 'qtyPack ל-${s.sku}');
        expect(p.qtyPallet,  s.qtyPallet, reason: 'qtyPallet ל-${s.sku}');
        expect(p.dims?['DN'], s.dn,       reason: 'dims[DN] ל-${s.sku}');
        expect(p.page,       s.page,      reason: 'page ל-${s.sku}');
      });
    }

    // Keys at page 23
    test('SKU 610893 · סט מפתחות', () {
      final p = bySku['610893'];
      expect(p, isNotNull);
      expect(p!.nameHe,   'סט מפתחות', reason: 'nameHe ל-610893');
      expect(p.qtyPack,   80,          reason: 'qtyPack ל-610893');
      expect(p.page,      23,          reason: 'page ל-610893');
    });
    test('SKU 610758 · מפתח לאביק', () {
      final p = bySku['610758'];
      expect(p, isNotNull);
      expect(p!.nameHe,   'מפתח לאביק', reason: 'nameHe ל-610758');
      expect(p.qtyPack,   350,          reason: 'qtyPack ל-610758');
      expect(p.page,      23,           reason: 'page ל-610758');
    });
  });
}

// ── אטמים אומים ופקקים — pages 36–37 (17 SKUs) ──────────────────────────────
class _Gp {
  final String sku;
  final String nameHe;
  final int? qtyPack;
  final int page;
  const _Gp(this.sku, this.nameHe, this.qtyPack, this.page);
}

const _gasketsPlugs = <_Gp>[
  // page 36
  _Gp('506539', 'אטם חתך שטוח', null, 36),
  _Gp('506521', 'אטם חתך שטוח', null, 36),
  _Gp('506537', 'אטם כדורי', 750, 36),
  _Gp('506540', 'אטם כדורי', 500, 36),
  _Gp('558463', 'אטם כדורי', 500, 36),
  _Gp('506525', 'אטם לכוס 2"', null, 36),
  // page 37
  _Gp('506510', 'אטם דו צדדי', null, 37),
  _Gp('506522', 'אטם דו צדדי', null, 37),
  _Gp('506527', 'אטם דו צדדי', null, 37),
  _Gp('555703', 'אטם דו צדדי', null, 37),
  _Gp('218127', 'פקק למאסף ולמחסום רצפה 2.5"', 50, 37),
  _Gp('218126', 'פקק למאסף ולמחסום רצפה 2"',   50, 37),
  _Gp('611051', 'פקק שטוח לתבריג 1.25"', null, 37),
  _Gp('614783', 'פקק שטוח לתבריג 1½"',   null, 37),
  _Gp('612386', 'פקק שטוח לתבריג 2" אפור', null, 37),
  _Gp('612385', 'פקק שטוח לתבריג 2" לבן',  null, 37),
  _Gp('610708', 'פקק שטוח לתבריג 2⅜"',   null, 37),
];

void _runGasketPlugGroup() {
  group('LIPSKEY PDF parity — אטמים/פקקים (gate 117)', () {
    final bySku = {
      for (final p in kLipskeyCatalog.where((p) => p.brand == 'ליפסקי'))
        p.sku: p,
    };

    for (final g in _gasketsPlugs) {
      test('SKU ${g.sku} · ${g.nameHe}', () {
        final p = bySku[g.sku];
        expect(p, isNotNull, reason: 'SKU ${g.sku} מהקטלוג חסר ב-kLipskeyCatalog');
        expect(p!.nameHe,  g.nameHe,  reason: 'nameHe ל-${g.sku}');
        expect(p.qtyPack,  g.qtyPack, reason: 'qtyPack ל-${g.sku}');
        expect(p.page,     g.page,    reason: 'page ל-${g.sku}');
      });
    }

    test('phantom plug 610706 gone (real SKU is 610708)', () {
      expect(bySku['610706'], isNull,
        reason: 'SKU 610706 phantom — הפקק 2⅜" האמיתי הוא 610708');
    });
  });
}

// ── מאספים/קולטים + כיסויים/רשתות — pages 30–33 (19 SKUs) ───────────────────
class _Coll {
  final String sku;
  final String nameHe;
  final String? color;
  final int? qtyPack;
  final int? qtyPallet;
  final int page;
  const _Coll(this.sku, this.nameHe, this.color, this.qtyPack, this.qtyPallet, this.page);
}

const _collectors = <_Coll>[
  // page 30–31 · מאספים/קולטים
  _Coll('116148', 'קולט A 40/70 למקלחת', null, 40, 2000, 31),
  _Coll('171191', 'קולט A 50/100 גבוה',  null, 30, 1200, 31),
  _Coll('116151', 'מחסום רצפה -130/40 לא תקני (מערכת C) כניסות 40', null, 25, 500, 31),
  _Coll('196687', 'מחסום רצפה -130/50 לא תקני (מערכת D) כניסות 50', null, 25, 500, 31),
  _Coll('116638', 'מאסף רצפה 130/50 מערכת B', null, 25, 500, 30),
  _Coll('217648', 'מערכת B נפילה 100',        null, 16, 320, 30),
  _Coll('116640', 'מאסף רצפה B נפילה 2"',     null, 25, 500, 30),
  _Coll('116175', 'מאסף רצפה B 110 נפילה 4"', null, 15, 300, 30),
  // page 32–33 · כיסויים/רשתות/הגבהה
  _Coll('122974', 'הגבהה גלילית',          null, 120, 2400, 33),
  _Coll('610933', 'רשת שרוול עגולה לבנה',  null,  90, 4050, 32),
  _Coll('610918', 'מכסה עגול עליון קבוע לבן',    'לבן',    120, 5400, 33),
  _Coll('635737', 'מכסה עגול עליון קבוע פרגמון', 'פרגמון', 120, 5400, 33),
  _Coll('610920', 'מכסה עגול עליון קבוע אפור',   'אפור',   120, 5400, 33),
  _Coll('610921', 'מכסה זמני',             null, null, null, 33),
  _Coll('610911', 'רשת עליונה לבן',        'לבן',    150, 6750, 32),
  _Coll('635736', 'רשת עליונה פרגמון',     'פרגמון', 150, 6750, 32),
  _Coll('610906', 'רשת פנימית עגולה לבן',     'לבן',    180, 8100, 32),
  _Coll('635735', 'רשת פנימית עגולה פרגמון',  'פרגמון', 180, 8100, 32),
  _Coll('661360', 'רשת פנימית עגולה אפור',    'אפור',   180, 8100, 32),
];

void _runCollectorGroup() {
  group('LIPSKEY PDF parity — מאספים/כיסויים (gate 117)', () {
    final bySku = {
      for (final p in kLipskeyCatalog.where((p) => p.brand == 'ליפסקי'))
        p.sku: p,
    };

    for (final c in _collectors) {
      test('SKU ${c.sku} · ${c.nameHe}', () {
        final p = bySku[c.sku];
        expect(p, isNotNull, reason: 'SKU ${c.sku} מהקטלוג חסר ב-kLipskeyCatalog');
        expect(p!.nameHe,   c.nameHe,    reason: 'nameHe ל-${c.sku}');
        expect(p.color,     c.color,     reason: 'color ל-${c.sku}');
        expect(p.qtyPack,   c.qtyPack,   reason: 'qtyPack ל-${c.sku}');
        expect(p.qtyPallet, c.qtyPallet, reason: 'qtyPallet ל-${c.sku}');
        expect(p.page,      c.page,      reason: 'page ל-${c.sku}');
      });
    }
  });
}

// ── מצמדים/מצרות/פקקים/כובע — pages 44–45 (21 SKUs) ─────────────────────────
// categoryHe intentionally NOT asserted — these span 3 existing taxonomy buckets
// (אביזרי שקע-תקע / מצמדים וצינורות / פקקים וצינורות); re-bucketing is a separate change.
class _Conn {
  final String sku;
  final String nameHe;
  final String dn;
  final int? qtyPack;   // null = "בבודדים"
  final int? qtyPallet;
  final int page;
  const _Conn(this.sku, this.nameHe, this.dn, this.qtyPack, this.qtyPallet, this.page);
}

const _connectors = <_Conn>[
  // מחבר כפול (page 44)
  _Conn('214533', 'מחבר כפול 50 עם מעצור',  '50',      100, 4500, 44),
  _Conn('214534', 'מחבר כפול 50 ללא מעצור', '50',      100, 4500, 44),
  _Conn('212937', 'מחבר כפול 75',           '75',      100, 4500, 44),
  _Conn('124842', 'מחבר כפול 110 עם מעצור', '110',      41,  820, 44),
  _Conn('116576', 'מחבר כפול 110 ללא מעצור','110',      41,  820, 44),
  _Conn('218567', 'מחבר כפול 160/160',      '160/160',   8,  300, 44),
  // מצרות (eccentric reducers, page 44)
  _Conn('116581', 'מצרה 110/50',  '110/50',   32, 1920, 44),
  _Conn('116058', 'מצרה 160/110', '160/110',  21,  630, 44),
  _Conn('217674', 'מצרה 110/75',  '110/75',   32, 1920, 44),
  _Conn('217531', 'מצרה 75/50',   '75/50',    90, 4050, 44),
  _Conn('218568', 'מצרה 50/40',   '50/40',   140, 6300, 44),
  _Conn('220316', 'מצרה 40/32',   '40/32',   200, 9000, 44),
  // מצמד ארוך לתיקון (telescopic) + מצרה לתיקון (page 44)
  _Conn('194898', 'מצמד ארוך לתיקון 110/110', '110/110', 12, 576, 44),
  _Conn('194897', 'מצרה לתיקון 110/100',      '110/100', 32, 960, 44),
  // כובע אויר + פקק חיצוני (page 45)
  _Conn('120311', 'כובע אויר 110',  '110', 108, 2160, 45),
  _Conn('218569', 'פקק חיצוני 110', '110',  95, 1900, 45),
  // פקק שקע-תקע — בבודדים (page 45)
  _Conn('218460', 'פקק שקע-תקע 50',  '50',  null, null, 45),
  _Conn('805024', 'פקק שקע-תקע 75',  '75',  null, null, 45),
  _Conn('218560', 'פקק שקע-תקע 160', '160', null, null, 45),
  _Conn('116628', 'פקק שקע-תקע 110', '110', null, null, 45),
  _Conn('220315', 'פקק שקע-תקע 40',  '40',  null, null, 45),
];

void _runConnectorGroup() {
  group('LIPSKEY PDF parity — מצמדים/מצרות/פקקים (gate 117)', () {
    final bySku = {
      for (final p in kLipskeyCatalog.where((p) => p.brand == 'ליפסקי'))
        p.sku: p,
    };

    for (final c in _connectors) {
      test('SKU ${c.sku} · ${c.nameHe}', () {
        final p = bySku[c.sku];
        expect(p, isNotNull, reason: 'SKU ${c.sku} מהקטלוג חסר ב-kLipskeyCatalog');
        expect(p!.nameHe,   c.nameHe,    reason: 'nameHe ל-${c.sku}');
        expect(p.qtyPack,   c.qtyPack,   reason: 'qtyPack ל-${c.sku}');
        expect(p.qtyPallet, c.qtyPallet, reason: 'qtyPallet ל-${c.sku}');
        expect(p.dims?['DN'], c.dn,      reason: 'dims[DN] ל-${c.sku}');
        expect(p.page,      c.page,      reason: 'page ל-${c.sku}');
      });
    }
  });
}

// ── מסעפים שקע-תקע — page 42 (13 SKUs) ──────────────────────────────────────
class _Branch {
  final String sku;
  final String nameHe;
  final String dn;
  final int qtyPack;
  final int qtyPallet; // -1 = don't assert
  const _Branch(this.sku, this.nameHe, this.dn, this.qtyPack, this.qtyPallet);
}

const _insertionBranches = <_Branch>[
  // מסעף 45°
  _Branch('116573', 'מסעף 45° 50/50',   '50/50',   45, 2025),
  _Branch('116056', 'מסעף 45° 110/50',  '110/50',  20,  600),
  _Branch('116571', 'מסעף 45° 110/110', '110/110',  9,  360),
  _Branch('220305', 'מסעף 45° 40/40',   '40/40',   45, 3150),
  // מסעף 87°
  _Branch('116569', 'מסעף 87° 50/50',   '50/50',   50, 2250),
  _Branch('116054', 'מסעף 87° 75/75',   '75/75',   25, 1000),
  _Branch('116558', 'מסעף 87° 110/50',  '110/50',  20,  600),
  _Branch('116556', 'מסעף 87° 110/110', '110/110', 12,  480),
  _Branch('116049', 'מסעף 87° 160/110', '160/110',  6,  168),
  _Branch('116051', 'מסעף 87° 160/160', '160/160',  6,  192),
  _Branch('217533', 'מסעף 87° 75/50',   '75/50',   25, 1000),
  // מסעף כפול
  _Branch('218564', 'מסעף כפול 110/50/50',   '110/50/50',   12, -1),
  _Branch('218176', 'מסעף כפול 110/110/110', '110/110/110', 12, -1),
];

void _runInsertionBranchGroup() {
  group('LIPSKEY PDF parity — מסעפים שקע-תקע (gate 117)', () {
    final bySku = {
      for (final p in kLipskeyCatalog.where((p) => p.brand == 'ליפסקי'))
        p.sku: p,
    };

    for (final b in _insertionBranches) {
      test('SKU ${b.sku} · ${b.nameHe}', () {
        final p = bySku[b.sku];
        expect(p, isNotNull, reason: 'SKU ${b.sku} מהקטלוג חסר ב-kLipskeyCatalog');
        expect(p!.nameHe,    b.nameHe, reason: 'nameHe ל-${b.sku}');
        expect(p.qtyPack,    b.qtyPack, reason: 'qtyPack ל-${b.sku}');
        if (b.qtyPallet >= 0) {
          expect(p.qtyPallet, b.qtyPallet, reason: 'qtyPallet ל-${b.sku}');
        }
        expect(p.categoryHe, 'מסעפים וחיבורי אסלה', reason: 'categoryHe ל-${b.sku}');
        expect(p.dims?['DN'], b.dn, reason: 'dims[DN] ל-${b.sku}');
        expect(p.page, 42, reason: 'page ל-${b.sku} צריך להיות 42');
      });
    }
  });
}

class _Seat {
  final String sku;
  final String nameHe;
  final String color;
  final int qtyPack;
  final int qtyPallet;
  final int page;
  const _Seat(this.sku, this.nameHe, this.color, this.qtyPack, this.qtyPallet, this.page);
}

// ── מחסומים גלויים — pages 8–15 (32 SKUs) ────────────────────────────────────
class _Trap {
  final String sku;
  final String nameHe;
  final int? qtyPack;
  final int? qtyPallet;
  final int page;
  const _Trap(this.sku, this.nameHe, this.qtyPack, this.qtyPallet, this.page);
}

const _visibleTraps = <_Trap>[
  // page 8–9 · 1.25" basin traps
  _Trap('217861', 'מחסום (סיפון) אמריקאי 1.25" לכיור רחצה', 20, 2250, 8),
  _Trap('218553', 'מחסום (סיפון) נסתר 1.25" לכיור אמבטיה',   30, 800,  8),
  _Trap('116632', 'מחסום (סיפון) 1.25" לכיור רחצה',          50, 1000, 8),
  _Trap('213054', 'מחסום (סיפון) 1.25" לכיור רחצה + יציאה למזגן',                    20, 2250, 8),
  _Trap('213055', 'מחסום (סיפון) אמריקאי 1.25" לכיור רחצה + יציאה למזגן',           20, 2250, 8),

  // page 10–11 · 2" kitchen + 1.5" american
  _Trap('116649', 'מחסום (סיפון) 2" לכיור מטבח בודד (מס. 1)',                                              20, 400, 10),
  _Trap('116124', 'מחסום (סיפון) 2" לכיור מטבח עם כניסה למדיח כלים/מכונת כביסה (מס. 2)',                  20, 400, 10),
  _Trap('116652', 'מחסום (סיפון) 2" לכיור מטבח כפול *עם אפשרות כניסה למדיח כלים/מכונת כביסה (מס. 3)',    15, 300, 10),
  _Trap('116127', 'מחסום (סיפון) 2" לכיור מטבח כפול עם כניסה למדיח כלים/מכונת כביסה (מס. 4)',            15, 300, 10),
  _Trap('209448', 'מחסום (סיפון) אמריקאי מס. 8 בודד 1.5"',                                                 30, 600, 10),
  _Trap('171189', 'מחסום (סיפון) אמריקאי 1.5" עם יציאה למדיח',                                            30, 600, 10),
  _Trap('171190', 'מחסום למכונת כביסה 1.5"',                                                              30, 600, 10),
  _Trap('218495', 'מחסום אמריקאי 1.5"',                                                                   20, 600, 10),

  // page 12–13 · 2" american single/double + side
  _Trap('209447', 'מחסום (סיפון) אמריקאי בודד 2" (מס. 7)',                                                20, 400, 12),
  _Trap('172349', 'מחסום (סיפון) אמריקאי בודד 2" + כניסה / למדיח כלים (מס. 5)',                          20, 400, 12),
  _Trap('116144', 'מחסום (סיפון) אמריקאי כפול 2" + כניסה / למדיח כלים (מס. 6)',                          15, 300, 12),
  _Trap('216984', 'מחסום (סיפון) אמריקאי כפול 1.5" + כניסה / למדיח כלים (מס. 9)',                        20, 400, 12),
  _Trap('217004', 'סיפון צד 2" עם כניסה למדיח כלים',                                                     20, 400, 12),
  _Trap('217005', 'סיפון צד 2" אמריקאי עם כניסה למדיח כלים',                                             20, 400, 12),
  _Trap('213056', 'סיפון צד 2"',                                                                          20, 400, 12),
  _Trap('213057', 'סיפון צד 2" אמריקאי',                                                                  20, 400, 12),

  // page 14–15 · extensions + accessories (qty may be null for "בבודדים")
  _Trap('172033', 'זרוע קומפלט לאגנית 1.5"',                                                              20,  1800, 14),
  _Trap('178700', 'ונטיל לכיור אמריקאי',                                                                   75,  1875, 14),
  _Trap('611045', 'פיה קומפלט למכונת כביסה 1.25" (לסיפון מס. 2,4)',                                       250, 1875, 14),
  _Trap('193420', 'פיה קומפלט למכונת כביסה 1.25" (לסיפון מס. 2,4)',                                       250, 1875, 14),
  _Trap('645975', 'צינור יציאה למדיח, שקית קומפלט (מתאימה לסיפון אמריקאי בלבד)',                          180, 8100, 14),
  _Trap('610949', 'מאריך למחסום (סיפון) 1.25" לבן',                                                       180, 8100, 14),
  _Trap('615301', 'מאריך למחסום מס. 4',                                                                   115, 5175, 14),
  _Trap('612812', 'מאריך למחסום 2"',                                                                      115, 5175, 14),
  _Trap('116233', 'משפך קומפלט 1.25"',                                                                    null, null, 14),
  _Trap('645971', 'משפך קומפלט 2"',                                                                       null, null, 14),
  _Trap('217675', 'משפך קומפלט 2"',                                                                       null, null, 14),
];

void _runVisibleTrapGroup() {
  group('LIPSKEY PDF parity — מחסומים גלויים (gate 117)', () {
    final bySku = {
      for (final p in kLipskeyCatalog.where((p) => p.brand == 'ליפסקי'))
        p.sku: p,
    };

    for (final t in _visibleTraps) {
      test('SKU ${t.sku} · ${t.nameHe}', () {
        final p = bySku[t.sku];
        expect(p, isNotNull, reason: 'SKU ${t.sku} מהקטלוג חסר ב-kLipskeyCatalog');
        expect(p!.nameHe,    t.nameHe,    reason: 'nameHe ל-${t.sku}');
        expect(p.color,      'לבן',       reason: 'color ל-${t.sku}');
        expect(p.qtyPack,    t.qtyPack,   reason: 'qtyPack ל-${t.sku}');
        expect(p.qtyPallet,  t.qtyPallet, reason: 'qtyPallet ל-${t.sku}');
        expect(p.categoryHe, 'מחסומים גלויים', reason: 'categoryHe ל-${t.sku}');
        expect(p.page,       t.page,      reason: 'page ל-${t.sku}');
      });
    }
  });
}

// ── ברכיים שקע-תקע — page 40–41 (15 SKUs) ───────────────────────────────────
class _Bend {
  final String sku;
  final String nameHe;
  final String dn;
  final int? qtyPack;
  final int? qtyPallet;
  const _Bend(this.sku, this.nameHe, this.dn, this.qtyPack, this.qtyPallet);
}

const _insertionBends = <_Bend>[
  // ברך 87° (5 sizes)
  _Bend('116624', 'ברך 87° 40',  '40',  120, 5400),
  _Bend('116601', 'ברך 87° 50',  '50',   75, 3375),
  _Bend('116033', 'ברך 87° 75',  '75',   50, 1200),
  _Bend('142289', 'ברך 87° 110', '110',  20,  720),
  _Bend('116028', 'ברך 87° 160', '160',   8,  240),
  // ברך 87° עם ביקורת גב
  _Bend('116031', 'ברך 87° עם ביקורת גב 50',          '50',  60, 2700),
  _Bend('124843', 'ברך 87° עם ביקורת גב 110',         '110', 20,  720),
  _Bend('116026', 'ברך 87° עם ביקורת גב 110 (4 פתחים)', '110', 20,  720),
  // ברך 15° / 30° 110
  _Bend('194899', 'ברך 15° 110', '110', 24, null),
  _Bend('194900', 'ברך 30° 110', '110', 24, null),
  // ברך 45° (5 sizes + white variant of 110)
  _Bend('116591', 'ברך 45° 50',     '50',   85, 3825),
  _Bend('116553', 'ברך 45° 75',     '75',   48, 1920),
  _Bend('161884', 'ברך 45° 110',    '110',  20, 1000),
  _Bend('190297', 'ברך 45° 110 לבן', '110', 20, 1000),
  _Bend('116037', 'ברך 45° 160',    '160',   8,  320),
];

void _runInsertionBendGroup() {
  group('LIPSKEY PDF parity — ברכיים שקע-תקע (gate 117)', () {
    final bySku = {
      for (final p in kLipskeyCatalog.where((p) => p.brand == 'ליפסקי'))
        p.sku: p,
    };

    for (final b in _insertionBends) {
      test('SKU ${b.sku} · ${b.nameHe}', () {
        final p = bySku[b.sku];
        expect(p, isNotNull, reason: 'SKU ${b.sku} מהקטלוג חסר ב-kLipskeyCatalog');
        expect(p!.nameHe,    b.nameHe,    reason: 'nameHe ל-${b.sku}');
        expect(p.qtyPack,    b.qtyPack,   reason: 'qtyPack ל-${b.sku}');
        expect(p.qtyPallet,  b.qtyPallet, reason: 'qtyPallet ל-${b.sku}');
        expect(p.categoryHe, 'ברכיים',    reason: 'categoryHe ל-${b.sku}');
        expect(p.dims?['DN'], b.dn,       reason: 'dims[DN] ל-${b.sku}');
        expect(p.page, 41,                reason: 'page ל-${b.sku} צריך להיות 41 (insertion bends)');
      });
    }
  });
}
