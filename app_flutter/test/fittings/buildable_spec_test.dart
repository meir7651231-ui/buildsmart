// 🔑🏁 Phase B (step 39 capstone + milestone 40) — the full buildable spec is
// assembled and complete, and the three milestone-40 claims hold together:
//   (1) a PP-R adapter connects to brass,  (2) a hot line gets auto-safety,
//   (3) a full execution spec is derived (dims + envelope + ends + weld + label
//   + safety + standards).
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/features/fittings/plan/buildable_spec.dart';
import 'package:buildsmart/features/fittings/plan/weld_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('spec-depth — a complete buildable spec per family (step 39)', () {
    test('every engine family assembles a complete spec', () {
      for (final fam in _kFamilies) {
        final s = buildableSpecFor(fam, 32,
            threadInch: '1/2"', threadMale: true,);
        expect(s, isNotNull, reason: fam);
        expect(s!.isComplete, isTrue,
            reason: '$fam: dims+envelope+ends+standards all present',);
        expect(s.connectionMethods.length, s.ends.length);
        expect(s.standards, contains('DVS 2207-11'));
      }
      expect(buildableSpecFor('לא-משפחה', 32), isNull); // M1
    });

    test('welded families derive the socket-weld method + reference weld params', () {
      final coupler = buildableSpecFor('מצמד', 32)!;
      expect(coupler.connectionMethods.every((m) => m.contains('ריתוך-שקע')), isTrue);
      expect(coupler.weld, isNotNull);
      expect(coupler.weld!.headTempC, 260);
      expect(coupler.weld!.caveat, isNotEmpty); // M5 caveat carried through
    });

    test('weld params are reference-only: an off-table OD → null weld (never invented)', () {
      final big = buildableSpecFor('ברך מחותכת', 200)!;
      expect(weldParamsFor(200), isNull);
      expect(big.weld, isNull, reason: 'no DVS reference at 200 → null, not invented');
      expect(big.isComplete, isTrue); // the rest of the spec still derives
    });
  });

  group('🏁 milestone 40 — buildable engine, the three claims together', () {
    test('(1) a PP-R adapter spec carries a BSP thread end → connects to brass', () {
      final adp = buildableSpecFor('מתאם תבריג', 20,
          threadInch: '1/2"', threadMale: true,);
      final threadEnd = adp!.ends.firstWhere((e) => e.type == EndType.bspMale);
      // the brass counterpart
      const brass = ConnectorEnd(EndType.bspFemale, '1/2"');
      expect(threadEnd.directMatesWith(brass), isTrue,
          reason: 'PP-R adapter male thread screws into brass female — cross-material',);
      expect(adp.connectionMethods, contains('תבריג BSP חיצוני (זכר)'));
    });

    test('(2) a hot line auto-derives safety; a cold line does not', () {
      final hot = buildableSpecFor('מצמד', 32, tempC: 70)!;
      expect(hot.hotLineSafety, isNotEmpty);
      expect(hot.hotLineSafety.every((a) => a.caveat.isNotEmpty), isTrue); // M5
      final cold = buildableSpecFor('מצמד', 32)!;
      expect(cold.hotLineSafety, isEmpty);
    });

    test('(3) a full execution spec is derived — every layer present', () {
      final s = buildableSpecFor('ברך 90°', 50, tempC: 70)!;
      expect(s.dims, isNotEmpty); // engine letters
      expect(s.envelope, isNotNull); // 3D bounding
      expect(s.ends, isNotEmpty); // precise ends
      expect(s.connectionMethods, isNotEmpty); // labels (step 30)
      expect(s.weld, isNotNull); // DVS reference (step 31)
      expect(s.hotLineSafety, isNotEmpty); // safety (step 32)
      expect(s.standards, isNotEmpty); // standards (step 34)
    });
  });
}

const List<String> _kFamilies = [
  'מצמד', 'ברך 90°', 'ברך 45°', 'מסעף (טי)', 'מתאם תבריג',
  'ברז כדורי', 'מצרה', 'רוכב', 'צווארון', 'פקק', 'ברך מחותכת',
];
