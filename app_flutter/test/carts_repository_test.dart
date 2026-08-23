// #user-data — the FIRST local→server store migration (smart cart → carts/{uid}).
// Two things pinned: (1) the migration is DORMANT with kUserDataServer OFF (the
// provider yields null → the cart keeps its SharedPreferences path, byte-
// identical), and (2) the CartsRepository round-trips a cart through the neutral
// RemoteCollectionSource seam. Firebase-free — a hand-rolled fake source drives
// it, exactly like the users/orders suites (no fake_cloud_firestore).
import 'package:buildsmart/data/repositories/carts_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/state/smart_cart.dart' show SmartCartLine;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled [RemoteCollectionSource] that actually STORES what `set` writes
/// and re-emits it from `snapshots()` — so a save→load round-trips (the users
/// suite's fake only reads; the cart repo also writes, so this one persists).
class _FakeCartSource implements RemoteCollectionSource {
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
  bool get isScoped => true; // scoped to the uid (documentId ==)
}

void main() {
  const line = SmartCartLine(
    productKey: 'p1',
    productName: 'צינור',
    productEmoji: '🔧',
    brandName: 'חוליות',
    brandPrice: 100,
    productQty: 2,
    accessories: [],
  );

  group('#user-data carts migration is DORMANT off', () {
    test(
        'cartsRepositoryProvider OFF (kUserDataServer const-false) ⇒ null — the '
        'cart stays on SharedPreferences, byte-identical to today', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(cartsRepositoryProvider), isNull);
    });
  });

  group('#user-data CartsRepository round-trip (carts/{uid})', () {
    test('save writes {lines,updatedAt}; load decodes the lines back', () async {
      final src = _FakeCartSource();
      final repo = CartsRepository(src, currentUid: 'u1');

      await repo.save('u1', const [line]);
      expect(src.docs['u1']!['lines'], isA<List<dynamic>>());
      expect(src.docs['u1']!.containsKey('updatedAt'), isTrue);

      final back = await repo.load('u1');
      expect(back.length, 1);
      expect(back.first.productKey, 'p1');
      expect(back.first.productQty, 2);
      expect(back.first.brandName, 'חוליות');
    });

    test('load with no doc ⇒ empty cart (never throws)', () async {
      final repo = CartsRepository(_FakeCartSource(), currentUid: 'u1');
      expect(await repo.load('u1'), isEmpty);
    });
  });
}
