// familyOf / odOf (פאזה 0, שלבים 5–6) — קטלוג→{משפחה,OD} + דוח-כיסוי.
// Boundary-tests על מוצרים בנויים + כיסוי-אמת >95% על ה-`kPolyrollCatalog` החי.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/features/fittings/engine/catalog_map.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(
  String name,
  String category, {
  Map<String, dynamic>? dims,
}) =>
    LipskeyCatalogProduct(
      sku: 'TST-$name',
      nameHe: name,
      nameEn: name,
      categoryHe: category,
      categoryEn: category,
      categoryEmoji: '🔧',
      page: 1,
      brand: 'polyroll',
      dims: dims,
    );

void main() {
  group('familyOf — category/name → engine family', () {
    test('each fitting category maps to its engine family', () {
      expect(familyOf(_p('מצמד PPR 32', kPprCouplers)), 'מצמד');
      expect(familyOf(_p('מסעף PPR שווה 50', kPprTees)), 'מסעף (טי)');
      expect(familyOf(_p('מתאם PPR זכר 20', kPprAdapters)), 'מתאם תבריג');
      expect(familyOf(_p('רוכב PPR 63', kPprSaddles)), 'רוכב');
      expect(familyOf(_p('פקק PPR 40', kPprPlugs)), 'פקק');
      expect(familyOf(_p('ברז כדורי PPR 25', kPprValves)), 'ברז כדורי');
      expect(familyOf(_p('צווארון PPR 110', kPprCollars)), 'צווארון');
    });

    test('elbow 90 vs 45 resolved from the name', () {
      expect(familyOf(_p('ברך PPR 90° 32', kPprElbows)), 'ברך 90°');
      expect(familyOf(_p('ברך PPR 45° 32', kPprElbows)), 'ברך 45°');
      expect(familyOf(_p('ברך PPR פ.פ 20', kPprElbows)), 'ברך 90°'); // ברירת-מחדל
    });

    test('coupler vs reducer resolved from a two-diameter name', () {
      expect(familyOf(_p('מצמד PPR 32', kPprCouplers)), 'מצמד');
      expect(familyOf(_p('מצמד PPR מצרה 50x40', kPprCouplers)), 'מצרה');
      expect(familyOf(_p('מצמד PPR מצרה 50×40', kPprCouplers)), 'מצרה');
      expect(familyOf(_p('מצמד PPR 32x32', kPprCouplers)), 'מצמד'); // קטרים זהים
    });

    test('non-fitting categories → null (fallback, not engine failure · M1)', () {
      expect(familyOf(_p('צינור PPR 20', kPprPipesSupply)), isNull);
      expect(familyOf(_p('אומגה PPR 20', kPprOmega)), isNull);
      expect(familyOf(_p('מחבר ריתוך חשמלי 40', kPprElectrofusion)), isNull);
    });
  });

  group('odOf — name/dims → OD int', () {
    test('trailing DN in name', () {
      expect(odOf(_p('ברך PPR 45° פ.פ 20', kPprElbows)), 20);
      expect(odOf(_p('מסעף PPR שווה 110', kPprTees)), 110);
    });
    test('explicit dims win over name', () {
      expect(odOf(_p('ברך PPR 32', kPprElbows, dims: {'d': '40'})), 40);
      expect(odOf(_p('x', kPprCouplers, dims: {'מידה': '63x50'})), 63);
    });
    test('reducer → larger OD + od2Of → smaller', () {
      final r = _p('מצמד PPR מצרה 50x40', kPprCouplers);
      expect(odOf(r), 50);
      expect(od2Of(r), 40);
      expect(od2Of(_p('מצמד PPR 32', kPprCouplers)), isNull);
    });
    test('unparseable → null (fallback)', () {
      expect(odOf(_p('מצמד PPR', kPprCouplers)), isNull);
    });
  });

  group('🔑 coverage — >95% of PPR fitting products resolve to {family, od}', () {
    test('kPolyrollCatalog fitting products are engine-renderable', () {
      const fittingCats = {
        kPprElbows, kPprTees, kPprCouplers, kPprAdapters,
        kPprSaddles, kPprPlugs, kPprValves, kPprCollars,
      };
      final fittings =
          kPolyrollCatalog.where((p) => fittingCats.contains(p.categoryHe));
      final total = fittings.length;
      expect(total, greaterThan(0), reason: 'no fitting products found');

      final miss = <String>[];
      for (final p in fittings) {
        if (familyOf(p) == null || odOf(p) == null) {
          miss.add('${p.sku} · ${p.categoryHe} · ${p.nameHe}');
        }
      }
      final covered = total - miss.length;
      final pct = 100.0 * covered / total;
      // ignore: avoid_print — a coverage report is the deliverable of this test.
      print(
        '[coverage] PPR fittings: $covered/$total (${pct.toStringAsFixed(1)}%)'
        '${miss.isEmpty ? '' : ' · gaps:\n  ${miss.take(15).join('\n  ')}'}',
      );
      expect(
        pct,
        greaterThanOrEqualTo(95.0),
        reason: '${miss.length} unrecognised fitting products (<95%)',
      );
    });
  });
}
