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
  test('🔑 elbow 90° → [angle · diameter · length], diameters = engine kDepth ODs', () {
    final s = configSchemaFor(_p('ברך PPR 90° 32', kPprElbows));
    expect(s.familyId, 'ברך 90°');
    expect(_ids(s), ['angle', 'diameter', 'length']);

    final angle = s.attributes[0];
    expect(angle.kind, AttributeKind.choice);
    final angleCanon = angle.values.map((v) => v.canonical).toSet();
    expect(angleCanon.containsAll({'45', '90'}), isTrue);

    final diameter = s.attributes[1];
    expect(diameter.kind, AttributeKind.dimension);
    expect(diameter.unitHe, 'מ"מ');
    // 🔑 engine-derived: the diameter wheel is exactly the sorted kDepth ODs.
    final ods = kDepth.keys.toList()..sort();
    expect(diameter.values.map((v) => v.canonical).toList(),
        ods.map((o) => '$o').toList(),);

    final length = s.attributes[2];
    expect(length.values, hasLength(3));
  });

  test('elbow 45° (name carries 45) → family ברך 45°, same wheel shape', () {
    final s = configSchemaFor(_p('ברך PPR 45° פ.פ 25', kPprElbows));
    expect(s.familyId, 'ברך 45°');
    expect(_ids(s), ['angle', 'diameter', 'length']);
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

  test('🔑 manifold (מחלק) with a color → [ports · color · diameter]', () {
    const p = LipskeyCatalogProduct(
      sku: 'M-1',
      nameHe: 'מחלק PPR 3 דרך 25',
      nameEn: '',
      categoryHe: kPprCollars, // manifolds live under collars, keyed by name
      categoryEn: '',
      categoryEmoji: '🔀',
      page: 34,
      color: 'כחול',
    );
    final s = configSchemaFor(p);
    expect(s.familyId, 'מחלק');
    expect(_ids(s), ['ports', 'color', 'diameter']);
    final ports = s.attributes[0];
    expect(ports.kind, AttributeKind.number);
    expect(ports.values.map((v) => v.canonical).toList(), ['1', '2', '3', '4']);
    final color = s.attributes[1];
    expect(color.kind, AttributeKind.color);
    expect(color.values.single.labelHe, 'כחול'); // grounded in p.color, not invented
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
