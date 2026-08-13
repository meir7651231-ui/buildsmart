// #hr — worker digital-forms local→server migration (workerForms/{uid}),
// single-doc + self-only (the 101 form reaches the contractor via chat, so no
// employer roster). Pins: (1) DORMANT with kUserDataServer OFF (provider → null
// → SharedPreferences, byte-identical), and (2) the WorkerFormsRepository
// round-trips the WHOLE compound state (forms + sick-notes) through the neutral
// RemoteCollectionSource seam.
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/worker_forms_repository.dart';
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
  final form = Form101(
    username: 'w-uid-1',
    year: 2026,
    fullName: 'רן ישראלי',
    idNumber: '123456782',
    phone: '0501234567',
    specialty: 'אינסטלציה',
    maritalStatus: 'נשוי/אה',
    savedTs: DateTime.utc(2026, 6, 14, 10, 30),
    signature: 'data:image/png;base64,AAA=',
    declared: true,
    employerName: 'בנייה חכמה בע״מ',
  );
  final note = SickNote(
    id: 'sick-1',
    username: 'w-uid-1',
    ts: DateTime.utc(2026, 6, 2),
    photo: 'data:image/png;base64,BBB=',
    declared: true,
  );

  group('#hr worker-forms migration is DORMANT off', () {
    test(
        'workerFormsRepositoryProvider OFF (kUserDataServer const-false) ⇒ null '
        '— forms stay on SharedPreferences, byte-identical', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(workerFormsRepositoryProvider), isNull);
    });
  });

  group('#hr WorkerFormsRepository round-trip (workerForms/{uid})', () {
    test('save writes {forms,sick,updatedAt}; load decodes the whole state back',
        () async {
      final src = _FakeSource();
      final repo = WorkerFormsRepository(src, currentUid: 'w-uid-1');

      await repo.save(WorkerFormsState(forms: [form], sickNotes: [note]));
      final doc = src.docs['w-uid-1']!;
      expect((doc['forms'] as List).length, 1);
      expect((doc['sick'] as List).length, 1);
      expect(doc.containsKey('updatedAt'), isTrue);

      final back = await repo.load();
      expect(back.forms.length, 1);
      expect(back.forms.single.fullName, 'רן ישראלי');
      expect(back.forms.single.idNumber, '123456782');
      expect(back.forms.single.signature, 'data:image/png;base64,AAA=');
      expect(back.forms.single.declared, isTrue);
      expect(back.sickNotes.length, 1);
      expect(back.sickNotes.single.photo, 'data:image/png;base64,BBB=');
    });

    test('load with no doc ⇒ empty state (never throws)', () async {
      final repo = WorkerFormsRepository(_FakeSource(), currentUid: 'w-uid-1');
      final back = await repo.load();
      expect(back.forms, isEmpty);
      expect(back.sickNotes, isEmpty);
    });

    test('load tolerates a malformed row (per-entry drop via fromJson)',
        () async {
      final src = _FakeSource();
      src.docs['w-uid-1'] = {
        'forms': [
          {'username': 'w-uid-1', 'year': 2026, 'savedTs': '2026-06-14T10:30:00.000Z'},
          {'garbage': true}, // no username/year/savedTs → dropped
        ],
        'sick': 'not-a-list', // wrong type → empty
      };
      final back = await WorkerFormsRepository(src, currentUid: 'w-uid-1').load();
      expect(back.forms.length, 1, reason: 'only the valid 101 survives');
      expect(back.sickNotes, isEmpty);
    });
  });
}
