// Roadmap step 34 (installEffortFor) + step 35 (installTipsFor) + step 24
// (systemSafetyNoteHe). All pure heuristics over the verified spec.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('installEffortFor', () {
    test('every spec product gets a positive time + known difficulty', () {
      const known = {'DIY', 'בינוני', 'מקצועי'};
      for (final p in kLipskeyCatalog) {
        final e = installEffortFor(p);
        if (kVerifiedSpecs[p.sku] == null) {
          expect(e, isNull);
          continue;
        }
        expect(e, isNotNull, reason: p.sku);
        expect(e!.minutes, greaterThan(0));
        expect(known, contains(e.difficulty), reason: '${p.sku}=${e.difficulty}');
      }
    });

    test('copper-press products are rated מקצועי', () {
      for (final p in kLipskeyCatalog) {
        final s = kVerifiedSpecs[p.sku];
        if (s != null && s.ends.any((e) => e.type == EndType.copperPress)) {
          expect(installEffortFor(p)!.difficulty, 'מקצועי', reason: p.sku);
        }
      }
    });
  });

  group('installTipsFor', () {
    test('threaded products warn about over-tightening + teflon', () {
      for (final p in kLipskeyCatalog) {
        final s = kVerifiedSpecs[p.sku];
        if (s != null &&
            s.ends.any((e) =>
                e.type == EndType.bspMale || e.type == EndType.bspFemale)) {
          final tips = installTipsFor(p);
          expect(tips.any((t) => t.contains('טפלון')), isTrue, reason: p.sku);
          break;
        }
      }
    });

    test('tips are de-duplicated', () {
      for (final p in kLipskeyCatalog) {
        final tips = installTipsFor(p);
        expect(tips.toSet().length, tips.length, reason: p.sku);
      }
    });
  });

  group('systemSafetyNoteHe', () {
    test('drainage-only products warn about gravity / not tying to pressure',
        () {
      for (final p in kLipskeyCatalog) {
        final s = kVerifiedSpecs[p.sku];
        if (s != null &&
            s.endSystems.length == 1 &&
            s.endSystems.contains(WaterSystem.drainage)) {
          expect(systemSafetyNoteHe(p), contains('ניקוז'), reason: p.sku);
          break;
        }
      }
    });

    test('supply products mention an upstream shutoff', () {
      for (final p in kLipskeyCatalog) {
        final s = kVerifiedSpecs[p.sku];
        if (s != null && s.endSystems.contains(WaterSystem.supply)) {
          expect(systemSafetyNoteHe(p), contains('ניתוק'), reason: p.sku);
          break;
        }
      }
    });
  });
}
