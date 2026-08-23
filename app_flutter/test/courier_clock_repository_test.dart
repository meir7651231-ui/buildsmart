// #hr — courier delivery-clock local→server migration (courierClock/{uid}),
// single-doc + self-only. Pins: (1) DORMANT with kUserDataServer OFF (provider →
// null → SharedPreferences bs.courier-clock.v1, byte-identical), (2) the repo
// round-trips the clock map wrapped under `entries`, and (3) stampClockEntry is
// write-once (the shared pure stamp both paths use) — an existing stamp survives.
import 'package:buildsmart/data/repositories/courier_clock_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/state/courier_clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements RemoteCollectionSource {
  final Map<String, Map<String, dynamic>> docs = {};

  @override
  Stream<List<RemoteDoc>> snapshots() => Stream<List<RemoteDoc>>.value(
        [for (final e in docs.entries) RemoteDoc(e.key, e.value)],
      );

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    docs[id] = {...?docs[id], ...data};
  }

  @override
  Future<void> delete(String id) async => docs.remove(id);

  @override
  bool get isScoped => true;
}

void main() {
  group('#hr courier-clock migration is DORMANT off', () {
    test('courierClockRepositoryProvider OFF (kUserDataServer const-false) ⇒ '
        'null — the clock stays on SharedPreferences, byte-identical', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(courierClockRepositoryProvider), isNull);
    });
  });

  group('#hr CourierClockRepository round-trip (courierClock/{uid})', () {
    test('save wraps the map under entries; load returns it back', () async {
      final src = _FakeSource();
      final repo = CourierClockRepository(src, uid: 'c-uid-1');

      final map = <String, dynamic>{};
      stampClockEntry(map, 'BS-1', pickedUp: true, delivered: false);
      stampClockEntry(map, 'BS-1', pickedUp: false, delivered: true);
      await repo.save(map);

      expect(src.docs['c-uid-1']!.containsKey('entries'), isTrue);
      expect(src.docs['c-uid-1']!.containsKey('updatedAt'), isTrue);

      final back = await repo.load();
      expect(back.containsKey('BS-1'), isTrue);
      final e = back['BS-1'] as Map;
      expect(e['pickedUpAt'], isNotNull);
      expect(e['deliveredAt'], isNotNull);
    });

    test('load with no doc ⇒ empty map (never throws)', () async {
      final repo = CourierClockRepository(_FakeSource(), uid: 'c-uid-1');
      expect(await repo.load(), isEmpty);
    });
  });

  group('#hr stampClockEntry is write-once (the shared pure stamp)', () {
    test('an already-valid stamp is PRESERVED (no double-call falsification)',
        () {
      final map = <String, dynamic>{
        'BS-1': {'pickedUpAt': '2026-08-01T08:00:00.000Z'},
      };
      stampClockEntry(map, 'BS-1', pickedUp: true, delivered: false);
      // The pre-existing pickup stamp must NOT be overwritten by a later call.
      expect((map['BS-1'] as Map)['pickedUpAt'], '2026-08-01T08:00:00.000Z');
    });

    test('a fresh delivered stamp is added, other fields untouched', () {
      final map = <String, dynamic>{
        'BS-1': {'pickedUpAt': '2026-08-01T08:00:00.000Z'},
      };
      stampClockEntry(map, 'BS-1', pickedUp: false, delivered: true);
      final e = map['BS-1'] as Map;
      expect(e['pickedUpAt'], '2026-08-01T08:00:00.000Z'); // kept
      expect(e['deliveredAt'], isNotNull); // added
    });
  });
}
