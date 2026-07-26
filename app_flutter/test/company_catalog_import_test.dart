// COMPANY-CATALOG IMPORT contract (owner-approved flow, 2026-07-25 "כן"):
// template download → company fills CSV → upload → per-row honest Hebrew
// errors OR atomic commit into the ONE-point seam (resolvedCatalogProducts).
//
// Tiers (all define-less-provable; the hydration tier is TWO-WORLD — under
// demo it proves the no-op guard, under a profiled clean run it IS the
// import proof):
//   a. template — BOM-first, self-documenting, parses to zero rows;
//   b. parser — happy path (quoted commas, ; files, company-brand rule),
//      per-row Hebrew errors, dup-sku, numeric guard, missing column,
//      encoding guard, row cap, the atomic canCommit gate;
//   c. codec — round-trip, corrupt→null, tolerant per-item skip;
//   d. seam — overlay identity in/out, null/empty = OFF, demo default intact;
//   e. store — hydrate honors the clean-only guard, corrupt cache degrades,
//      persist/clear round-trip;
//   f. file-transfer seams — the providers are overridable test surfaces.

import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/company_catalog_import.dart';
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/services/file_transfer.dart';
import 'package:buildsmart/state/app_profile.dart';
import 'package:buildsmart/state/company_catalog_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _p1 = LipskeyCatalogProduct(
  sku: 'T-100',
  nameHe: 'ברז בדיקה',
  nameEn: 'Test Faucet',
  categoryHe: 'ברזים',
  categoryEn: 'Faucets',
  categoryEmoji: '🚰',
  page: 0,
  brand: '',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The seam is module state — every tier leaves it OFF for the next.
  tearDown(() => setCompanyCatalog(null));

  group('a · template', () {
    test('BOM-first (Hebrew-in-Excel is load-bearing) + self-documenting', () {
      final t = companyCatalogTemplateCsv();
      expect(t.codeUnitAt(0), 0xFEFF,
          reason: 'the BOM makes Hebrew columns open correctly in Excel');
      expect(t, contains('שם המוצר'));
      expect(t, contains('# חובה = מק"ט · שם המוצר · קטגוריה'));
      expect(t, contains('# מחירים — יתווספו בשלב חיבור-השרת'));
    });

    test('the template itself parses to ZERO rows (examples are # comments)',
        () {
      final r = parseCompanyCatalogCsv(companyCatalogTemplateCsv());
      expect(r.errors, isEmpty);
      expect(r.valid, isEmpty);
      expect(r.canCommit, isFalse, reason: 'nothing to commit — honest gate');
    });
  });

  group('b · parser', () {
    test('happy path: quoted comma name + the company-brand rule (never '
        'a silent ליפסקי)', () {
      final r = parseCompanyCatalogCsv(
        'מק"ט,שם המוצר,קטגוריה,מותג\n'
        'A-1,"ברז, נשלף",ברזים,אלפא\n'
        'A-2,כיור גרניט,כיורים,\n',
      );
      expect(r.errors, isEmpty);
      expect(r.valid.length, 2);
      expect(r.valid[0].nameHe, 'ברז, נשלף');
      expect(r.valid[0].brand, 'אלפא');
      expect(r.valid[1].brand, '',
          reason: 'empty brand cell must NOT fall back to ליפסקי');
      expect(r.canCommit, isTrue);
    });

    test('Hebrew-Excel ; separator auto-detected', () {
      final r = parseCompanyCatalogCsv(
        'מק"ט;שם המוצר;קטגוריה\nB-1;צינור 32;צנרת\n',
      );
      expect(r.errors, isEmpty);
      expect(r.valid.single.sku, 'B-1');
    });

    test('missing required COLUMN stops with a row-1 header error', () {
      final r = parseCompanyCatalogCsv('מק"ט,שם המוצר\nA-1,ברז\n');
      expect(r.valid, isEmpty);
      expect(r.errors.single.row, 1);
      expect(r.errors.single.messageHe, contains('חסרה עמודת חובה'));
      expect(r.errors.single.messageHe, contains('קטגוריה'));
    });

    test('per-row errors: missing cell · dup sku · non-numeric — physical '
        'row numbers (what the user sees in Excel)', () {
      final r = parseCompanyCatalogCsv(
        'מק"ט,שם המוצר,קטגוריה,כמות באריזה\n' // line 1
        'A-1,,ברזים,\n' // line 2 — missing name
        'A-2,כיור,כיורים,12\n' // line 3 — fine
        'A-2,ארון,ארונות,\n' // line 4 — dup sku
        'A-3,מראה,אביזרים,אבג\n', // line 5 — non-numeric qty
      );
      expect(r.valid.length, 1, reason: 'only the clean row (line 3) survives');
      final byRow = {for (final e in r.errors) e.row: e.messageHe};
      expect(byRow[2], contains('חסר'));
      expect(byRow[4], contains('מק"ט כפול'));
      expect(byRow[5], contains('חייב להיות מספר'));
      expect(r.canCommit, isFalse,
          reason: 'ANY error blocks the whole commit — atomic contract');
    });

    test('mojibake/non-UTF-8 rejected honestly (no silent garbage import)',
        () {
      final r = parseCompanyCatalogCsv('�קובץ שבור');
      expect(r.valid, isEmpty);
      expect(r.errors.single.row, 0);
      expect(r.errors.single.messageHe, contains('UTF-8'));
    });

    test('5,000-row cap fails honestly', () {
      final rows =
          List.generate(5001, (i) => 'S-$i,מוצר $i,קטגוריה').join('\n');
      final r = parseCompanyCatalogCsv('מק"ט,שם המוצר,קטגוריה\n$rows\n');
      expect(r.errors.any((e) => e.messageHe.contains('5,000')), isTrue);
      expect(r.canCommit, isFalse);
    });
  });

  group('c · codec', () {
    test('encode → decode round-trip preserves the company fields', () {
      final json = encodeCompanyCatalog(const [_p1]);
      final back = decodeCompanyCatalog(json);
      expect(back, isNotNull);
      expect(back!.single.sku, 'T-100');
      expect(back.single.nameHe, 'ברז בדיקה');
      expect(back.single.brand, '', reason: 'company-brand rule survives');
    });

    test('structural corruption → null (never throws)', () {
      expect(decodeCompanyCatalog('garbage{'), isNull);
      expect(decodeCompanyCatalog('{"v":2,"items":[]}'), isNull);
      expect(decodeCompanyCatalog('[]'), isNull);
    });

    test('tolerant per-item skip (iron-rule-1): one bad item never kills '
        'the catalog', () {
      final back = decodeCompanyCatalog(
        '{"v":1,"items":[{"sku":"S1","nameHe":"א"},{"nameHe":"בלי מקט"}]}',
      );
      expect(back!.length, 1);
      expect(back.single.sku, 'S1');
    });
  });

  group('d · the seam overlay', () {
    test('overlay serves the SAME objects (identity — the stage3 invariant)',
        () {
      setCompanyCatalog(const [_p1]);
      expect(resolvedCatalogProducts.length, 1);
      expect(identical(resolvedCatalogProducts.single, _p1), isTrue);
    });

    test('null AND empty turn the overlay OFF — default world intact', () {
      setCompanyCatalog(const [_p1]);
      setCompanyCatalog(const []);
      _expectDefaultWorld();
      setCompanyCatalog(const [_p1]);
      setCompanyCatalog(null);
      _expectDefaultWorld();
    });
  });

  group('e · the store (two-world hydration)', () {
    test('hydrate applies the overlay ONLY on the empty shell', () async {
      SharedPreferences.setMockInitialValues(
          {kCompanyCatalogKey: encodeCompanyCatalog(const [_p1])});
      await hydrateCompanyCatalog();
      if (catalogEmptyForProfile(kAppProfile)) {
        // profiled clean run: the import IS the catalog now.
        expect(resolvedCatalogProducts.single.sku, 'T-100');
      } else {
        // define-less suite (= demo): the guard exits — byte-identical world.
        _expectDefaultWorld();
      }
    });

    test('corrupt cache degrades silently (iron-rule-1) — never a crash, '
        'never an accidental overlay', () async {
      SharedPreferences.setMockInitialValues({kCompanyCatalogKey: 'garbage{'});
      await hydrateCompanyCatalog(); // must not throw
      _expectDefaultWorld();
    });

    test('persist → getString round-trip · clear removes + turns OFF',
        () async {
      SharedPreferences.setMockInitialValues({});
      expect(await persistCompanyCatalog(const [_p1]), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kCompanyCatalogKey),
          encodeCompanyCatalog(const [_p1]));
      await clearCompanyCatalog();
      expect(prefs.getString(kCompanyCatalogKey), isNull);
      _expectDefaultWorld();
    });
  });

  group('g · template v2 — the FULL product card from one file', () {
    test('every unrecognized column becomes a spec row (file order)', () {
      final r = parseCompanyCatalogCsv(
        'מק"ט,שם המוצר,קטגוריה,חומר,תקן ישראלי,קצה 1\n'
        'V-1,ברז קיר,ברזים,פליז,ת"י 1205,תבריג זכר 3/4\n',
      );
      expect(r.errors, isEmpty);
      expect(r.valid.single.dims, {
        'חומר': 'פליז',
        'תקן ישראלי': 'ת"י 1205',
        'קצה 1': 'תבריג זכר 3/4',
      });
    });

    test('image columns: single + |-lists, URL or filename stored AS-IS', () {
      final r = parseCompanyCatalogCsv(
        'מק"ט,שם המוצר,קטגוריה,תמונה,תמונות נוספות,תמונת מפרט\n'
        'V-2,כיור שיש,כיורים,https://x.co.il/a.jpg,b.jpg|https://x.co.il/c.jpg,'
        'שרטוט.png\n',
      );
      final p = r.valid.single;
      expect(p.imageFile, 'https://x.co.il/a.jpg');
      expect(p.imageFiles, ['b.jpg', 'https://x.co.il/c.jpg']);
      expect(p.specImageFile, 'שרטוט.png');
    });

    test('codec round-trips images + open spec rows (survives restart)', () {
      final r = parseCompanyCatalogCsv(
        'מק"ט,שם המוצר,קטגוריה,תמונה,תמונות נוספות,חומר\n'
        'V-3,מתאם,מתאמים,https://x.co.il/m.jpg,n1.jpg|n2.jpg,ניקל\n',
      );
      final back = decodeCompanyCatalog(encodeCompanyCatalog(r.valid))!;
      final p = back.single;
      expect(p.imageFile, 'https://x.co.il/m.jpg');
      expect(p.imageFiles, ['n1.jpg', 'n2.jpg']);
      expect(p.dims?['חומר'], 'ניקל');
    });

    test('URL passthrough: the model serves links verbatim, filenames keep '
        'the asset path (demo byte-identical)', () {
      final url = parseCompanyCatalogCsv(
        'מק"ט,שם המוצר,קטגוריה,תמונה\nV-4,ברז,ברזים,https://x.co.il/u.jpg\n',
      ).valid.single;
      expect(url.imageAsset, 'https://x.co.il/u.jpg');
      final file = parseCompanyCatalogCsv(
        'מק"ט,שם המוצר,קטגוריה,תמונה\nV-5,ברז,ברזים,u.jpg\n',
      ).valid.single;
      expect(file.imageAsset, 'assets/lipskey/products/u.jpg',
          reason: 'brand "" maps to the lipskey dir — the original path shape');
    });

    test('template v2: image columns + the open-columns legend, still zero '
        'rows', () {
      final t = companyCatalogTemplateCsv();
      expect(t, contains('תמונה'));
      expect(t, contains('כל עמודה נוספת שתוסיפו תופיע ככרטיס-מפרט'));
      final r = parseCompanyCatalogCsv(t);
      expect(r.errors, isEmpty);
      expect(r.valid, isEmpty);
    });
  });

  group('f · file-transfer seams', () {
    test('the providers are overridable test surfaces (no platform touched)',
        () async {
      String? downloaded;
      final c = ProviderContainer(overrides: [
        downloadTextFileProvider.overrideWithValue((name, text, mime) async {
          downloaded = '$name|$mime|${text.length}';
          return true;
        }),
        pickTextFileProvider.overrideWithValue(
            (accept) async => const PickedTextFile('a.csv', 'x')),
        reloadAppProvider.overrideWithValue(() {}),
      ]);
      addTearDown(c.dispose);
      final ok = await c.read(downloadTextFileProvider)(
          'catalog-template.csv', companyCatalogTemplateCsv(), 'text/csv');
      expect(ok, isTrue);
      expect(downloaded, startsWith('catalog-template.csv|text/csv|'));
      final picked = await c.read(pickTextFileProvider)('.csv');
      expect(picked!.name, 'a.csv');
    });
  });
}

/// The no-overlay world: on the empty shell the universe is empty; everywhere
/// else it is the SAME const object as always (identity — never a copy).
void _expectDefaultWorld() {
  if (catalogEmptyForProfile(kAppProfile)) {
    expect(resolvedCatalogProducts, isEmpty);
  } else {
    expect(identical(resolvedCatalogProducts, kCatalogProducts), isTrue);
  }
}
