// #user-data — a local→server user-data store migration (personal saved-customers
// CRM → savedCustomers/{uid}). Two things pinned: (1) the migration is DORMANT
// with kUserDataServer OFF (the provider yields null → the CRM keeps its
// SharedPreferences path, byte-identical), and (2) the SavedCustomersRepository
// round-trips the list through the neutral RemoteCollectionSource seam, per-entry
// tolerant. Firebase-free — a hand-rolled fake source drives it (no fake_cloud_firestore).
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/saved_customers_repository.dart';
import 'package:buildsmart/state/customers_store.dart' show SavedCustomer;
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
    docs[id] = {...?docs[id], ...data}; // merge:true contract
  }

  @override
  Future<void> delete(String id) async => docs.remove(id);

  @override
  bool get isScoped => true;
}

void main() {
  const c1 = SavedCustomer(
    id: 'c-1',
    name: 'דוד לוי',
    phone: '050-1234567',
    email: 'david@example.com',
    notes: 'קבלן ותיק',
    tags: ['VIP'],
  );
  const c2 = SavedCustomer(id: 'c-2', name: 'שרה כהן');

  group('#user-data saved-customers migration is DORMANT off', () {
    test(
        'savedCustomersRepositoryProvider OFF (kUserDataServer const-false) ⇒ null '
        '— the CRM stays on SharedPreferences, byte-identical to today', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(savedCustomersRepositoryProvider), isNull);
    });
  });

  group('#user-data SavedCustomersRepository round-trip (savedCustomers/{uid})',
      () {
    test('save writes {customers,updatedAt}; load decodes the list back',
        () async {
      final src = _FakeSource();
      final repo = SavedCustomersRepository(src, currentUid: 'u1');

      await repo.save('u1', [c1, c2]);
      expect((src.docs['u1']!['customers'] as List).length, 2);
      expect(src.docs['u1']!.containsKey('updatedAt'), isTrue);

      final back = await repo.load('u1');
      expect(back.length, 2);
      final one = back.firstWhere((c) => c.id == 'c-1');
      expect(one.name, 'דוד לוי');
      expect(one.phone, '050-1234567');
      expect(one.email, 'david@example.com');
      expect(one.notes, 'קבלן ותיק');
      expect(one.tags, ['VIP']);
    });

    test('load with no doc ⇒ empty list (never throws)', () async {
      final repo = SavedCustomersRepository(_FakeSource(), currentUid: 'u1');
      expect(await repo.load('u1'), isEmpty);
    });

    test('a malformed row is skipped (per-entry tolerant)', () async {
      final src = _FakeSource();
      await src.set('u1', {
        'customers': [
          {'id': 'ok', 'name': 'תקין'},
          {'id': '', 'name': 'ריק'}, // structural-invalid → dropped
          'not-a-map', // wrong type → dropped
        ],
      });
      final repo = SavedCustomersRepository(src, currentUid: 'u1');
      final back = await repo.load('u1');
      expect(back.length, 1);
      expect(back.single.id, 'ok');
    });
  });
}
