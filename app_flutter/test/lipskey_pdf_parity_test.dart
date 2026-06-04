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
