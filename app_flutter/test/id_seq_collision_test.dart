// Round-2 correctness — timestamp-only ids must carry a monotonic _seq suffix.
//
// On Flutter web DateTime is ~1ms-precise, so two creates in the same
// millisecond mint the SAME timestamp-only id; a later delete (which keeps every
// row whose id != target) then removes BOTH. The fix mirrors the guard already
// in vacation_requests / material_requests / worker_trainings / worker_notifs /
// store_stock: append `-${_seq++}` so the last id segment is a 0,1,2 sequence.
//
// Deterministic RED→GREEN: the last '-' segment of each id must be a sequential
// integer (0 then 1). Without the guard that segment is the raw timestamp (or
// the two ids collide outright), so the increment assertion fails.
import 'package:buildsmart/state/cart_lists_state.dart';
import 'package:buildsmart/state/saved_projects.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

int _seqOf(String id) => int.parse(id.split('-').last);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('timestamp-only ids carry a monotonic _seq suffix (no same-ms collision)',
      () {
    test('worker_certs cert id', () async {
      final n = WorkerCertsNotifier();
      final a = await n.add(
          username: 'ran', name: 'עבודה בגובה', issuer: 'x', expiry: DateTime(2030));
      final b = await n.add(
          username: 'ran', name: 'מתח גבוה', issuer: 'y', expiry: DateTime(2030));
      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(a!.id, isNot(b!.id));
      expect(_seqOf(b.id), _seqOf(a.id) + 1);
    });

    test('worker_forms sick-note id', () async {
      final n = WorkerFormsNotifier();
      final a = await n.addSickNote(username: 'ran', photo: 'p1');
      final b = await n.addSickNote(username: 'ran', photo: 'p2');
      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(a!.id, isNot(b!.id));
      expect(_seqOf(b.id), _seqOf(a.id) + 1);
    });

    test('cart_lists id', () async {
      final n = CartListsNotifier();
      await n.saveCart('סל 1', const []);
      await n.saveCart('סל 2', const []);
      final ids = n.state.map((c) => c.id).toList();
      expect(ids.toSet(), hasLength(2));
      expect(_seqOf(ids[1]), _seqOf(ids[0]) + 1);
    });

    test('saved_projects id', () async {
      final n = SavedProjectsNotifier();
      final a = await n.save(
          name: 'פרויקט 1', anchorSkus: const ['x'], tempC: 60, accessories: const {});
      final b = await n.save(
          name: 'פרויקט 2', anchorSkus: const ['y'], tempC: 60, accessories: const {});
      expect(a.id, isNot(b.id));
      expect(_seqOf(b.id), _seqOf(a.id) + 1);
    });
  });
}
