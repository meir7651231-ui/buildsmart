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

    test('phantom seat SKUs gone (was 179370/197134-as-typo/195425/107222)', () {
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
