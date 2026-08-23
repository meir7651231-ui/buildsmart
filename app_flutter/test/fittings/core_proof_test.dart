// 🔑 מוכיח-ליבה (פאזה 0, שלב 12): מוצר-קטלוג → משפחה+OD → dims+קצוות, מקצה-לקצה,
// על מוצרים אמיתיים מ-`kPolyrollCatalog`. + value-objects (§2). אפס נגיעה בחי.
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/features/fittings/engine/catalog_map.dart';
import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('value-objects (§2)', () {
    test('Family ↔ label round-trips for every engine family', () {
      for (final f in Family.values) {
        expect(Family.fromLabel(f.label), f, reason: f.label);
      }
      expect(Family.fromLabel('לא-קיים'), isNull);
      // every generate() family name has a Family enum member
      for (final name in kFittingFamilies) {
        expect(Family.fromLabel(name), isNotNull, reason: name);
      }
    });

    test('RunElement.dims() delegates to generate() (single + reducer)', () {
      const coupler = RunElement(Family.coupler, 32);
      expect(coupler.dims().letters, generate('מצמד', 32));
      const red = RunElement(Family.reducer, 50, od2: 40);
      expect(red.dims().letters, generate('מצרה', 50, od2: 40));
      expect(red.dims()['A'], isNotNull);
    });

    test('Route holds the sequence; empty is empty', () {
      const r = Route([RunElement(Family.tee, 50), RunElement(Family.elbow90, 32)]);
      expect(r.length, 2);
      expect(const Route([]).isEmpty, isTrue);
    });
  });

  group('🔑 core-proof — product → {family,od} → dims+ends, end-to-end', () {
    test('every renderable PPR product yields a non-empty, engine-true dims map',
        () {
      final renderable =
          kPolyrollCatalog.where(engineCanRender).toList();
      expect(renderable.length, greaterThan(100),
          reason: 'expected the bulk of the PPR catalog to be renderable',);

      var proven = 0;
      for (final p in renderable) {
        final fam = Family.fromLabel(familyOf(p)!);
        expect(fam, isNotNull, reason: '${p.sku}: familyOf not a Family');
        final el = RunElement(fam!, odOf(p)!, od2: od2Of(p));
        final dims = el.dims();
        // non-vacuous: real letters came out
        expect(dims.letters, isNotEmpty, reason: '${p.sku}: empty dims');
        // engine-true: identical to calling the engine directly
        expect(dims.letters, generate(fam.label, odOf(p)!, od2: od2Of(p)),
            reason: '${p.sku}: dims != engine',);
        // has flow bore + at least one welding socket depth (the "ends") —
        // except the two-diameter reducer, whose bore/depth are per-side (F1/F2).
        if (fam == Family.reducer) {
          expect(dims['F1'], isNotNull, reason: '${p.sku}: reducer missing F1');
          expect(dims['F2'], isNotNull, reason: '${p.sku}: reducer missing F2');
        } else {
          expect(dims['ID'], isNotNull, reason: '${p.sku}: missing flow bore ID');
          expect(dims['F'], isNotNull, reason: '${p.sku}: missing socket depth F');
        }
        proven++;
      }
      // ignore: avoid_print — the core-proof headline number.
      print('[core-proof] product → family+OD → dims+ends: $proven products');
      expect(proven, renderable.length);
    });
  });
}
