// CATALOG-CONFIG · chip-taxonomy golden — `prioritizedSchema` RE-ORDERS the engine
// schema by the 18-chip priority (owner §5) so the POSITIONAL card lays the wheels
// out per §6 (attr[0]=🔩 side-A · attr[1]=🥇 ↕ · attr[2]=🥈 ↔), graduated (§7 — only
// value-carrying chips, so never more wheels than chips). Pins the five owner
// goldens (§8). Reuse only — the chips + aggregated values come from the existing
// `configSchemaFor`; this only sorts. Pure · exercised define-less (kCatalogConfig OFF).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/features/catalog_config/product_chips.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String nameHe, String categoryHe) =>
    LipskeyCatalogProduct(
      sku: 'T-$nameHe',
      nameHe: nameHe,
      nameEn: '',
      categoryHe: categoryHe,
      categoryEn: '',
      categoryEmoji: '🔧',
      page: 1,
    );

List<String> _ids(LipskeyCatalogProduct p, {List<LipskeyCatalogProduct>? universe}) =>
    chipRoster(p, universe: universe);

void main() {
  group('#catalog-config chips — prioritizedSchema goldens (§8 · positional §6)', () {
    test('ברך → [🔩 diameter · ↕ angle · ↔ length]', () {
      expect(_ids(_p('ברך PPR 90° 32', kPprElbows)),
          ['diameter', 'angle', 'length']);
    });

    test('מחלק → [🔩 diameter · ↕ ports · ↔ color]', () {
      const p = LipskeyCatalogProduct(
        sku: 'M-1',
        nameHe: 'מחלק PPR 3 דרך 25',
        nameEn: '',
        categoryHe: kPprCollars,
        categoryEn: '',
        categoryEmoji: '🔀',
        page: 34,
        color: 'כחול',
        dims: {'יציאות': '3'},
      );
      expect(_ids(p, universe: const [p]), ['diameter', 'ports', 'color']);
    });

    test('בושינג (מצרה) → [🔩 diameter · ↕ diameter-שני]', () {
      expect(_ids(_p('מצמד מעבר PPR 50x32', kPprCouplers)),
          ['diameter-large', 'diameter-small']);
    });

    test('ברז מעבר (מתאם) → [🔩 diameter · ↕ thread]', () {
      expect(_ids(_p('מתאם תבריג PPR 32', kPprAdapters)),
          ['diameter', 'thread']);
    });

    test('אלכסוני (base card) → [🔩 diameter] only', () {
      expect(_ids(_p('אביזר כלשהו 40', 'קטגוריה לא-ממופה')), ['diameter']);
    });
  });

  group('#catalog-config chips — priority + graduation invariants', () {
    test('§6: the priority-1 chip (diameter) always leads the roster', () {
      expect(_ids(_p('ברך PPR 45° פ.פ 25', kPprElbows)).first, 'diameter');
      expect(_ids(_p('מצמד PPR 32', kPprCouplers)).first, 'diameter');
    });

    test('§7 graduation: every rostered chip carries values (no empty wheel)', () {
      final s = prioritizedSchema(_p('ברך PPR 90° 32', kPprElbows));
      expect(s.attributes, isNotEmpty);
      expect(s.attributes.every((a) => a.values.isNotEmpty), isTrue);
    });

    test('the roster is a stable taxonomy sort (ascending priority)', () {
      final s = prioritizedSchema(_p('מתאם תבריג PPR 32', kPprAdapters));
      final priorities = [for (final a in s.attributes) chipPriority(a.id)];
      expect(priorities, orderedEquals([...priorities]..sort()));
    });
  });

  group('#catalog-config chips — §4 wheels FROM THE NAME (brass/threaded · non-PPR)', () {
    test('a threaded elbow gets זווית + תבריג from its NAME, not the PPR engine', () {
      // 'אביזרי תבריג' is NOT a PPR engine category ⇒ configSchemaFor makes a base
      // card; the name parser supplies the wheels (45° → angle, 1/2" → thread).
      final p = _p('ברך 45° תבריג צד אחד 1/2"', 'אביזרי תבריג');
      final roster = _ids(p, universe: [p]);
      expect(roster, contains('angle'));
      expect(roster, contains('thread'));
      expect(roster.first, isIn(['angle', 'thread'])); // priority-1 = highest present
    });

    test('§4: size-variants of the family supply a MULTI-value wheel', () {
      // Same frame ("מצמד", size stripped) ⇒ one variant family; the thread wheel
      // spans both inch sizes (aggregated over the siblings).
      final a = _p('מצמד 1/2"', 'אביזרי תבריג');
      final b = _p('מצמד 3/4"', 'אביזרי תבריג');
      final s = prioritizedSchema(a, universe: [a, b]);
      final thread = s.attributes.firstWhere((x) => x.id == 'thread');
      expect(thread.values.map((v) => v.labelHe), containsAll(['1/2"', '3/4"']));
    });

    test('§4 keeps the engine goldens intact (union, engine wins a shared id)', () {
      // The name parser must not disturb a PPR golden — the elbow still resolves to
      // exactly [diameter · angle · length].
      expect(_ids(_p('ברך PPR 90° 32', kPprElbows)),
          ['diameter', 'angle', 'length']);
    });
  });
}
