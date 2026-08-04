// 🔑 CATALOG-CONFIG · פאזה 0 golden — ProductConfigSchema נגזר-מהמנוע. הברך (elbow)
// היא הזהב המרכזי: [זווית · קוטר · אורך], ערכי-הקוטר = מפתחות-`kDepth` של המנוע.
// מאמת גם: מצמד=קוטר · מצרה=2-קטרים · מתאם=קוטר+תבריג · null-fallback · השומר
// "אין תכונה בלי ערכים" לכל משפחה. אפס-רינדור/UI — סכמה טהורה.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/catalog_config/product_config_schema.dart';
import 'package:buildsmart/features/fittings/engine/fitting_dims.dart' show kDepth;
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String nameHe, String categoryHe) => LipskeyCatalogProduct(
      sku: 'T-$nameHe',
      nameHe: nameHe,
      nameEn: '',
      categoryHe: categoryHe,
      categoryEn: '',
      categoryEmoji: '🔧',
      page: 1,
    );

List<String> _ids(ProductConfigSchema s) => s.attributes.map((a) => a.id).toList();

void main() {
  test('🔑 elbow 90° → [angle · length · diameter], diameters = engine kDepth ODs', () {
    final s = configSchemaFor(_p('ברך PPR 90° 32', kPprElbows));
    expect(s.familyId, 'ברך 90°');
    // dive-bs2b order: attr[0]=angle (↕) · attr[1]=length (↔) · attr[2]=diameter.
    expect(_ids(s), ['angle', 'length', 'diameter']);

    final angle = s.attributes[0];
    expect(angle.kind, AttributeKind.choice);
    // assert via the ° LABELS (canonical stays °-less) so a bare 45/90 never
    // appears — stuck_log RULE: angles always carry ° (else parsed as a size).
    final angleLabels = angle.values.map((v) => v.labelHe).toSet();
    expect(angleLabels.containsAll({'45°', '90°'}), isTrue);

    final diameter = s.attributes.last;
    expect(diameter.kind, AttributeKind.dimension);
    expect(diameter.unitHe, 'מ"מ');
    // 🔑 phase-F fold (real-vs-template): the diameter wheel is now the REAL
    // AGGREGATED DN ladder of the elbow family (distinct `odOf` across the live
    // 'ברך 90°' siblings), NOT the bare template `kDepth` set. Assert the shape
    // that holds for real-aggregated values — non-empty, distinct, sorted
    // ascending — and that it is NOT merely the template ladder.
    final canon = [for (final v in diameter.values) v.canonical!];
    expect(canon, isNotEmpty);
    final nums = [for (final c in canon) int.parse(c)];
    expect(nums, orderedEquals([...nums]..sort())); // sorted ascending
    expect(nums.toSet().length, nums.length); // distinct
    final template = kDepth.keys.toList()..sort();
    expect(nums, isNot(orderedEquals(template))); // real ⇒ diverges from template

    final length = s.attributes[1];
    expect(length.values, hasLength(3));
  });

  test('elbow 45° (name carries 45) → family ברך 45°, same wheel shape', () {
    final s = configSchemaFor(_p('ברך PPR 45° פ.פ 25', kPprElbows));
    expect(s.familyId, 'ברך 45°');
    expect(_ids(s), ['angle', 'length', 'diameter']);
  });

  test('coupler → single diameter wheel', () {
    final s = configSchemaFor(_p('מצמד PPR 32', kPprCouplers));
    expect(s.familyId, 'מצמד');
    expect(_ids(s), ['diameter']);
  });

  test('🔑 reducer (50×32) → two diameter wheels (large, small)', () {
    final s = configSchemaFor(_p('מצמד מעבר PPR 50x32', kPprCouplers));
    expect(s.familyId, 'מצרה');
    expect(_ids(s), ['diameter-large', 'diameter-small']);
    expect(s.attributes.every((a) => a.kind == AttributeKind.dimension), isTrue);
  });

  test('adapter → diameter + thread', () {
    final s = configSchemaFor(_p('מתאם תבריג PPR 32', kPprAdapters));
    expect(s.familyId, 'מתאם תבריג');
    expect(_ids(s), ['diameter', 'thread']);
  });

  test('🔑 manifold (מחלק) with a color → [ports · color · diameter], REAL-aggregated', () {
    const p = LipskeyCatalogProduct(
      sku: 'M-1',
      nameHe: 'מחלק PPR 3 דרך 25',
      nameEn: '',
      categoryHe: kPprCollars, // manifolds live under collars, keyed by name
      categoryEn: '',
      categoryEmoji: '🔀',
      page: 34,
      color: 'כחול',
      dims: {'יציאות': '3'},
    );
    // A CONTROLLED manifold universe → ports {2,3}, colors {כחול,אדום}: the fold
    // aggregates the REAL values from the siblings, NOT the template 1-4 / a
    // single degenerate color (the owner's "real values, not generic").
    const universe = [
      p,
      LipskeyCatalogProduct(
        sku: 'M-2',
        nameHe: 'מחלק PPR 2 דרך 25',
        nameEn: '',
        categoryHe: kPprCollars,
        categoryEn: '',
        categoryEmoji: '🔀',
        page: 34,
        color: 'אדום',
        dims: {'יציאות': '2'},
      ),
    ];
    final s = configSchemaFor(p, universe: universe);
    expect(s.familyId, 'מחלק');
    expect(_ids(s), ['ports', 'color', 'diameter']);
    final ports = s.attributes[0];
    expect(ports.kind, AttributeKind.number);
    // REAL, aggregated from dims['יציאות'] = {2,3} — NOT the template [1,2,3,4].
    expect(ports.values.map((v) => v.canonical).toList(), ['2', '3']);
    final color = s.attributes[1];
    expect(color.kind, AttributeKind.color);
    // REAL color CHOICE (כחול/אדום), not a single degenerate value.
    expect(color.values.map((v) => v.labelHe).toList(), ['כחול', 'אדום']);
  });

  test('🔑 manifold without color → [ports · diameter] (no invented swatches)', () {
    final s = configSchemaFor(_p('סעפת למונים PPR 4', kPprCollars));
    expect(s.familyId, 'מחלק');
    expect(_ids(s), ['ports', 'diameter']); // color omitted — data-grounded
    for (final a in s.attributes) {
      expect(a.values, isNotEmpty);
    }
  });

  test('a plain collar (not a manifold) still derives as צווארון → [diameter]', () {
    final s = configSchemaFor(_p('צווארון PPR 40', kPprCollars));
    expect(s.familyId, 'צווארון');
    expect(_ids(s), ['diameter']);
  });

  test('🔑 null-fallback: no engine family & no OD → base card, no crash', () {
    final s = configSchemaFor(_p('צינור PPR', 'צינורות PPR'));
    expect(s.hasWheels, isFalse);
    expect(s.attributes, isEmpty);
  });

  test('fallback with a readable OD → diameter-only base card', () {
    // category not mapped to an engine family, but the name carries an OD.
    final s = configSchemaFor(_p('אביזר PPR כלשהו 40', 'קטגוריה לא-ממופה'));
    expect(s.familyId, 'קטגוריה לא-ממופה');
    expect(_ids(s), ['diameter']);
  });

  test('🔑 GUARD — no attribute is ever value-less, across every engine family', () {
    final products = <LipskeyCatalogProduct>[
      _p('מצמד PPR 32', kPprCouplers),
      _p('מצמד מעבר PPR 50x32', kPprCouplers),
      _p('ברך PPR 90° 32', kPprElbows),
      _p('ברך PPR 45° 25', kPprElbows),
      _p('מסעף PPR 32', kPprTees),
      _p('מתאם תבריג PPR 32', kPprAdapters),
      _p('ברז כדורי PPR 32', kPprValves),
      _p('פקק PPR 32', kPprPlugs),
      _p('רוכב PPR 40', kPprSaddles),
      _p('צווארון PPR 40', kPprCollars),
    ];
    for (final p in products) {
      final s = configSchemaFor(p);
      expect(s.attributes, isNotEmpty, reason: '${p.nameHe} → no wheels');
      for (final a in s.attributes) {
        expect(a.values, isNotEmpty, reason: '${p.nameHe} · ${a.id} value-less');
      }
    }
  });

  test('diameterValues are engine-sorted and non-empty', () {
    final vs = diameterValues();
    expect(vs, isNotEmpty);
    final canon = vs.map((v) => int.parse(v.canonical!)).toList();
    final sorted = [...canon]..sort();
    expect(canon, sorted);
  });
}
