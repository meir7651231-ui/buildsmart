// Roadmap step 38 (acceptanceChecklistFor) + step 31 (stage progress).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/state/stage_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('acceptanceChecklistFor', () {
    test('never empty and de-duplicated for every product', () {
      for (final p in kLipskeyCatalog) {
        final c = acceptanceChecklistFor(p);
        expect(c, isNotEmpty, reason: p.sku);
        expect(c.toSet().length, c.length, reason: p.sku);
      }
    });

    test('supply products get a pressure test; drainage gets a flow test', () {
      for (final p in kLipskeyCatalog) {
        final s = kVerifiedSpecs[p.sku];
        if (s == null) continue;
        final c = acceptanceChecklistFor(p);
        if (s.endSystems.contains(WaterSystem.supply)) {
          expect(c.any((x) => x.contains('בדיקת לחץ')), isTrue, reason: p.sku);
        }
        if (s.endSystems.length == 1 &&
            s.endSystems.contains(WaterSystem.drainage)) {
          expect(c.any((x) => x.contains('ניקוז')), isTrue, reason: p.sku);
        }
      }
    });
  });

  group('stage progress', () {
    test('pure toggle adds then removes a key', () {
      final k = StageProgressNotifier.keyFor('faucet', 2);
      final added = stageProgressNext(const {}, k);
      expect(added, contains(k));
      final removed = stageProgressNext(added, k);
      expect(removed, isNot(contains(k)));
    });

    test('persists toggles + doneCount across a fresh notifier', () async {
      SharedPreferences.setMockInitialValues({});
      final n1 = StageProgressNotifier();
      n1.toggle('faucet', 0);
      n1.toggle('faucet', 2);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n1.doneCount('faucet', 4), 2);
      expect(n1.isDone('faucet', 1), isFalse);

      final n2 = StageProgressNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n2.isDone('faucet', 0), isTrue);
      expect(n2.isDone('faucet', 2), isTrue);
      expect(n2.doneCount('faucet', 4), 2);
    });
  });
}
