// #user-data — a local→server user-data store migration (saved quote drafts →
// draftQuotes/{uid}). Two things pinned: (1) the migration is DORMANT with
// kUserDataServer OFF (the provider yields null → the drafts keep their
// SharedPreferences path, byte-identical), and (2) the DraftQuotesRepository
// round-trips the list through the neutral RemoteCollectionSource seam.
// Firebase-free — a hand-rolled fake source drives it, exactly like the
// carts/savedProjects suites (no fake_cloud_firestore).
import 'package:buildsmart/data/repositories/draft_quotes_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/state/draft_quote.dart' show DraftQuote;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled [RemoteCollectionSource] that actually STORES what `set` writes
/// and re-emits it from `snapshots()` — so a save→load round-trips (same fake
/// shape as the carts/savedProjects suites; the drafts repo also writes, so it
/// must persist).
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
  bool get isScoped => true; // scoped to the uid (documentId ==)
}

void main() {
  final q1 = DraftQuote(
    id: 'q-1',
    label: 'מקלחת ראשית',
    text: 'הצעת מחיר למקלחת — 4 פריטים',
    savedAt: DateTime.utc(2026, 1, 2),
  );
  final q2 = DraftQuote(
    id: 'q-2',
    label: 'מטבח',
    text: 'ברז מטבח + סיפון',
    savedAt: DateTime.utc(2026, 3, 4),
  );

  group('#user-data draft-quotes migration is DORMANT off', () {
    test(
        'draftQuotesRepositoryProvider OFF (kUserDataServer const-false) ⇒ null '
        '— the drafts stay on SharedPreferences, byte-identical to today', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(draftQuotesRepositoryProvider), isNull);
    });
  });

  group('#user-data DraftQuotesRepository round-trip (draftQuotes/{uid})', () {
    test('save writes {quotes,updatedAt}; load decodes the quotes back',
        () async {
      final src = _FakeSource();
      final repo = DraftQuotesRepository(src, currentUid: 'u1');

      await repo.save('u1', [q1, q2]);
      expect(src.docs['u1']!['quotes'], isA<List<dynamic>>());
      expect((src.docs['u1']!['quotes'] as List).length, 2);
      expect(src.docs['u1']!.containsKey('updatedAt'), isTrue);

      final back = await repo.load('u1');
      expect(back.length, 2);
      final one = back.firstWhere((q) => q.id == 'q-1');
      expect(one.label, 'מקלחת ראשית');
      expect(one.text, 'הצעת מחיר למקלחת — 4 פריטים');
      expect(one.savedAt, DateTime.utc(2026, 1, 2));
    });

    test('load with no doc ⇒ empty list (never throws)', () async {
      final repo = DraftQuotesRepository(_FakeSource(), currentUid: 'u1');
      expect(await repo.load('u1'), isEmpty);
    });
  });
}
