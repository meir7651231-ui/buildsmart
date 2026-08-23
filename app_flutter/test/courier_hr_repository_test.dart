// #hr — COURIER HR ledgers local→server migration (courierAttendance /
// courierCerts / courierForms, each keyed by the courier's uid). The courier
// reuses the SAME repository classes as the worker (the shape is identical), so
// the round-trips are already pinned by the worker repo tests; this file pins the
// COURIER-SIDE wiring: (1) all three courierXRepositoryProvider are DORMANT with
// kUserDataServer OFF (→ null → SharedPreferences bs.courier-*.v1, byte-identical),
// and (2) a courier-scoped round-trip through the reused classes stays correct.
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/worker_attendance_repository.dart';
import 'package:buildsmart/data/repositories/worker_certs_repository.dart';
import 'package:buildsmart/data/repositories/worker_forms_repository.dart';
import 'package:buildsmart/state/worker_attendance.dart' show AttendanceDay;
import 'package:buildsmart/state/worker_certs.dart' show WorkerCert;
import 'package:buildsmart/state/worker_forms.dart';
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
  group('#hr courier HR providers are DORMANT off (byte-identical)', () {
    test('all three courierXRepositoryProvider ⇒ null with kUserDataServer OFF',
        () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(courierAttendanceRepositoryProvider), isNull);
      expect(c.read(courierCertsRepositoryProvider), isNull);
      expect(c.read(courierFormsRepositoryProvider), isNull);
    });
  });

  group('#hr courier-scoped round-trips through the reused repo classes', () {
    test('attendance: courierAttendance/{uid} round-trips a day', () async {
      final src = _FakeSource();
      final repo = WorkerAttendanceRepository(
        src,
        currentUid: 'c-uid-1',
        employerId: 'store-7',
      );
      final day = AttendanceDay(
        username: 'c-uid-1',
        date: '2026-08-03',
        inTs: DateTime.utc(2026, 8, 3, 8),
        outTs: DateTime.utc(2026, 8, 3, 17),
      );
      await repo.saveMine([day]);
      expect(src.docs['c-uid-1']!['employerId'], 'store-7');
      final back = await repo.loadMine();
      expect(back.length, 1);
    });

    test('certs: courierCerts/{uid} round-trips a driver cert', () async {
      final src = _FakeSource();
      final repo = WorkerCertsRepository(
        src,
        currentUid: 'c-uid-1',
        employerId: 'store-7',
      );
      final cert = WorkerCert(
        id: 'lic-1',
        username: 'c-uid-1',
        name: 'רישיון נהיגה',
        issuer: 'משרד התחבורה',
        expiry: DateTime.utc(2028, 3, 15),
        addedTs: DateTime.utc(2026, 8, 3),
        employerId: 'store-7',
      );
      await repo.saveMine([cert]);
      final back = await repo.loadMine();
      expect(back.single.name, 'רישיון נהיגה');
    });

    test('forms: courierForms/{uid} round-trips the compound state', () async {
      final src = _FakeSource();
      final repo = WorkerFormsRepository(src, currentUid: 'c-uid-1');
      final note = SickNote(
        id: 'sick-c1',
        username: 'c-uid-1',
        ts: DateTime.utc(2026, 8, 3),
        photo: 'data:image/png;base64,CCC=',
      );
      await repo.save(WorkerFormsState(sickNotes: [note]));
      final back = await repo.load();
      expect(back.sickNotes.single.photo, 'data:image/png;base64,CCC=');
    });
  });
}
