// CATALOG-CONFIG · chip-taxonomy golden — `prioritizedSchema` RE-ORDERS the engine
// schema UNION the §4 axis wheels by the 18-chip priority (owner §5) so the
// POSITIONAL card lays the wheels out per §6 (attr[0]=🔩 side-A · attr[1]=🥇 ↕ ·
// attr[2]=🥈 ↔), graduated (§7 — only value-carrying chips, so never more wheels
// than chips). Pins the five owner goldens (§8) on CONTROLLED universes — a golden
// isolates its intended axes so the priority→slot logic is pinned deterministically,
// independent of the whole-catalog aggregation (which the coverage test exercises).
// Pure · exercised define-less (kCatalogConfig OFF).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/features/catalog_config/product_chips.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(
  String nameHe,
  String categoryHe, {
  String? color,
  Map<String, Object?>? dims,
}) =>
    LipskeyCatalogProduct(
      sku: 'T-$nameHe',
      nameHe: nameHe,
      nameEn: '',
      categoryHe: categoryHe,
      categoryEn: '',
      categoryEmoji: '🔧',
      page: 1,
      color: color,
      dims: dims,
    );

List<String> _ids(LipskeyCatalogProduct p, List<LipskeyCatalogProduct> universe) =>
    chipRoster(p, universe: universe);

void main() {
  group('#catalog-config chips — prioritizedSchema goldens (§8 · positional §6)', () {
    test('ברך → [🔩 diameter · ↕ angle · ↔ length]', () {
      // A PPR elbow: the engine ([configSchemaFor]) supplies the canonical
      // diameter+angle+length schema; the priority sort lays them out per §6.
      final p = _p('ברך PPR 90° 32', kPprElbows);
      expect(_ids(p, [p]), ['diameter', 'angle', 'length']);
    });

    test('מחלק → [🔩 diameter · ↕ ports · ↔ color]', () {
      // A manifold: engine supplies diameter+ports; צבע is a §4 axis wheel that
      // surfaces because it VARIES across the type (כחול/אדום) — owner's model.
      final a = _p('מחלק PPR 2 דרך 25', kPprCollars,
          color: 'כחול', dims: {'יציאות': '2'});
      final b = _p('מחלק PPR 3 דרך 32', kPprCollars,
          color: 'אדום', dims: {'יציאות': '3'});
      expect(_ids(a, [a, b]), ['diameter', 'ports', 'color']);
    });

    test('בושינג (מצרה) → [🔩 diameter · ↕ diameter-שני]', () {
      final p = _p('מצמד מעבר PPR 50x32', kPprCouplers);
      expect(_ids(p, [p]), ['diameter-large', 'diameter-small']);
    });

    test('ברז מעבר (מתאם) → [🔩 diameter · ↕ thread]', () {
      final p = _p('מתאם תבריג PPR 32', kPprAdapters);
      expect(_ids(p, [p]), ['diameter', 'thread']);
    });

    test('אלכסוני (base + size variants) → [🔩 diameter] only', () {
      // a base category ⇒ no engine family; the §4 axis engine supplies ONE קוטר
      // wheel (always-shown — a size IS a diameter, owner) and nothing else varies.
      final a = _p('אלכסוני 1/2"', 'ניקוז');
      final b = _p('אלכסוני 3/4"', 'ניקוז');
      expect(_ids(a, [a, b]), ['diameter']);
    });
  });

  group('#catalog-config chips — priority + graduation invariants', () {
    test('§6: the priority-1 chip (diameter) always leads the roster', () {
      final elbow = _p('ברך PPR 45° פ.פ 25', kPprElbows);
      final coupler = _p('מצמד PPR 32', kPprCouplers);
      expect(_ids(elbow, [elbow]).first, 'diameter');
      expect(_ids(coupler, [coupler]).first, 'diameter');
    });

    test('§7 graduation: every rostered chip carries values (no empty wheel)', () {
      final p = _p('ברך PPR 90° 32', kPprElbows);
      final s = prioritizedSchema(p, universe: [p]);
      expect(s.attributes, isNotEmpty);
      expect(s.attributes.every((a) => a.values.isNotEmpty), isTrue);
    });

    test('the roster is a stable taxonomy sort (ascending priority)', () {
      final p = _p('מתאם תבריג PPR 32', kPprAdapters);
      final s = prioritizedSchema(p, universe: [p]);
      final priorities = [for (final a in s.attributes) chipPriority(a.id)];
      expect(priorities, orderedEquals([...priorities]..sort()));
    });
  });

  group('#catalog-config chips — §4 wheels from the AXIS ENGINE (catAxesOf)', () {
    test('a size-varying type gets a MULTI-value קוטר wheel', () {
      // same type ("מצמד"), two sizes ⇒ the axis engine's diameter varies across
      // the peers ⇒ a spinnable קוטר wheel.
      final a = _p('מצמד 1/2"', 'אביזרי תבריג');
      final b = _p('מצמד 3/4"', 'אביזרי תבריג');
      final diameter =
          prioritizedSchema(a, universe: [a, b]).attributes.firstWhere(
                (x) => x.id == 'diameter',
              );
      expect(diameter.values.length, greaterThanOrEqualTo(2)); // spans both sizes
    });

    test('the SIZE always shows (single-value ok); a descriptive axis only if it varies', () {
      // a singleton ⇒ nothing varies, but its size IS a diameter (owner) ⇒ one קוטר
      // wheel; a fixed descriptive axis stays context (not a wheel · §7).
      final p = _p('אלכסוני 1/2"', 'ניקוז');
      expect(_ids(p, [p]), ['diameter']);
    });

    test('§4: a color that VARIES across the type yields a צבע wheel (pipes)', () {
      // the type engine groups all pipes; the color field varies שחור/אפור across
      // the peers ⇒ a real צבע wheel (owner: "בצינורות יש לך צבעים").
      final a = _p('צינור DN40', 'צינורות אפורות', color: 'שחור');
      final b = _p('צינור DN40', 'צינורות אפורות', color: 'אפור');
      expect(_ids(a, [a, b]), contains('color'));
    });

    test('§4 color_truth: a metal FINISH miscoded as color is NOT a צבע wheel', () {
      // the catalog puts finishes (נחושת/כרום) in the color field; [isTrueColor]
      // keeps them off the צבע wheel — they belong on the material axis, not color.
      final a = _p('ניפל 1/2"', 'אביזרים', color: 'נחושת');
      final b = _p('ניפל 3/4"', 'אביזרים', color: 'כרום');
      expect(_ids(a, [a, b]), isNot(contains('color')));
    });

    test('§4 keeps the engine goldens intact (union, engine wins a shared id)', () {
      // The axis engine must not disturb a PPR golden — the elbow still resolves to
      // exactly [diameter · angle · length].
      final p = _p('ברך PPR 90° 32', kPprElbows);
      expect(_ids(p, [p]), ['diameter', 'angle', 'length']);
    });
  });
}
