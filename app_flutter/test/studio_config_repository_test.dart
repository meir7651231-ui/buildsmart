// FIRESTORE CACHE-PATTERN (Studio · Step 54) — unit coverage for the
// `StudioConfigRepository` seam: the const local impl (the OFF default = the
// bundled config tree) + the Firestore-backed `_firebase` impl over the
// offline-first cache base, plus the dormant provider switch.
//
// NO Firebase here: the Firestore seam ([RemoteCollectionSource]) is driven by a
// HAND-ROLLED fake ([_FakeSource]) — no fake_cloud_firestore, no new packages
// (the exact shape `firestore_cached_repo_test.dart` uses). The fake captures
// every `set` and lets a test push snapshot events, so the ON branch is proven
// to MAP without Firebase (the `kUidScopedQueries` testability pattern), and the
// OFF branch is proven to return the bundled tree.
//
// Pins (the Step-54 seam contract):
//   • the local impl returns the BUNDLED default (version 0, empty tree) — today;
//   • the firebase cache is BORN with the bundled pointer (cold-start non-empty);
//   • a snapshot MAPS ONLY the pointer (version/schema/ref/checksum); the tree
//     stays the bundled default (empty) — the shard pull is step 59;
//   • mapping is TOLERANT (a missing-field doc → bundled default, never blanks);
//   • toDoc∘fromDoc round-trips the pointer;
//   • the client does NOT seed the published pointer (callable-only-write);
//   • the provider DEFAULTS to the local impl (flags OFF ⇒ byte-identical).

import 'dart:async';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/studio_config_firebase.dart';
import 'package:buildsmart/data/repositories/studio_config_local.dart';
import 'package:buildsmart/data/repositories/studio_config_repository.dart';
import 'package:buildsmart/state/studio/config_doc.dart'
    show ConfigLayer, kSchemaVersion;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [RemoteCollectionSource]. Backs the cache base in tests
/// with a broadcast stream we drive manually + an in-memory record of writes.
/// (Identical contract to the fake in `firestore_cached_repo_test.dart`.)
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();

  /// Captured `set` calls (id → last field-map written), in arrival order.
  final List<MapEntry<String, Map<String, dynamic>>> sets = [];

  /// Captured `delete` calls (ids).
  final List<String> deletes = [];

  /// Push a snapshot event to listeners.
  void emit(List<RemoteDoc> docs) => _controller.add(docs);

  @override
  Stream<List<RemoteDoc>> snapshots() => _controller.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async =>
      sets.add(MapEntry(id, data));

  @override
  Future<void> delete(String id) async => deletes.add(id);

  @override
  bool get isScoped => false;

  Future<void> close() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStudioConfigRepository — the OFF default (bundled tree)', () {
    test('published() is the bundled default: version 0, empty tree', () {
      const r = LocalStudioConfigRepository();
      final p = r.published();
      expect(p.version, 0); // never server-published
      expect(p.isBundled, isTrue);
      expect(p.channel, kStudioConfigChannel); // 'published'
      expect(p.schema, kSchemaVersion);
      // The bundled tree is the EMPTY layer ⇒ the merge yields identity ⇒
      // byte-identical to today (every wrapper renders its verbatim fallback).
      expect(r.publishedTree().isEmpty, isTrue);
      expect(r.publishedTree(), ConfigLayer.empty);
      expect(p, StudioConfigPointer.bundled);
    });

    test('changes is null — nothing pushes on the static local path', () {
      const r = LocalStudioConfigRepository();
      expect(r.changes, isNull);
    });
  });

  group('FirebaseStudioConfigRepository — seed · single-doc mapping', () {
    FirebaseStudioConfigRepository repo(_FakeSource src) =>
        FirebaseStudioConfigRepository(source: src);

    test('cache BORN with the bundled pointer — non-empty before snapshot 1', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      // Cold-start is the bundled default — identical to the local impl's answer.
      expect(r.published().version, 0);
      expect(r.published().isBundled, isTrue);
      expect(r.publishedTree(), ConfigLayer.empty);
      expect(r.changes, same(r)); // the base is a Listenable (ChangeNotifier)
    });

    test('a snapshot MAPS ONLY the pointer; the tree stays the bundled default',
        () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      var notified = 0;
      r.addListener(() => notified++);

      // A published-pointer doc lands (single doc in the `studioConfig`
      // collection). fromDoc reads only the pointer fields.
      src.emit([
        const RemoteDoc('published', {
          'version': 7,
          'schema': 2, // non-default → proves the field is READ, not defaulted
          'ref': 'v7',
          'checksum': 'abc123',
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(notified, 1); // one snapshot-driven cache replacement
      final p = r.published();
      expect(p.channel, 'published'); // doc-id → channel
      expect(p.version, 7);
      expect(p.schema, 2);
      expect(p.ref, 'v7');
      expect(p.checksum, 'abc123');
      expect(p.isBundled, isFalse); // version 7 ≠ 0
      // DORMANT: the pointer maps but the TREE is not carried by it — it stays
      // the bundled default (empty). The shard pull is step 59, so a freshly-
      // published pointer changes NOTHING that renders (byte-identical).
      expect(r.publishedTree(), ConfigLayer.empty);
    });

    test('mapping is TOLERANT — a missing-field doc decodes to defaults', () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      // A doc with no pointer fields: every field defaults (never throws → never
      // blanks — the R2-7 "never brick" spirit), so the app stays non-empty.
      src.emit([const RemoteDoc('published', <String, dynamic>{})]);
      await Future<void>.delayed(Duration.zero);

      final p = r.published();
      expect(p.channel, 'published');
      expect(p.version, 0); // defaulted
      expect(p.schema, kSchemaVersion); // defaulted
      expect(p.ref, isEmpty);
      expect(p.checksum, isEmpty);
      expect(r.publishedTree(), ConfigLayer.empty); // still non-empty app
    });

    test('toDoc∘fromDoc round-trips the pointer (guarded ref/checksum)', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      const p = StudioConfigPointer(version: 12, schema: 2, ref: 'v12', checksum: 'z9');
      final doc = r.toDoc(p);
      expect(doc['version'], 12);
      expect(doc['schema'], 2);
      expect(doc['ref'], 'v12');
      expect(doc['checksum'], 'z9');
      // toDoc writes ONLY the pointer — never the tree (it lives in the shards).
      expect(doc.containsKey('tree'), isFalse);

      final back = r.fromDoc(RemoteDoc('published', doc));
      expect(back.version, 12);
      expect(back.schema, 2);
      expect(back.ref, 'v12');
      expect(back.checksum, 'z9');

      // Empty ref/checksum are OMITTED (guarded), so the bundled pointer + any
      // legacy doc round-trip unchanged.
      final bundledDoc = r.toDoc(StudioConfigPointer.bundled);
      expect(bundledDoc.containsKey('ref'), isFalse);
      expect(bundledDoc.containsKey('checksum'), isFalse);
      expect(bundledDoc['version'], 0);
    });

    test('a first EMPTY snapshot keeps the bundled seed — client never seeds it',
        () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      src.emit(const []); // fresh backend
      await Future<void>.delayed(Duration.zero);

      // Unlike orders/customers, config is callable-only-write (step 56/65): the
      // client must NOT push `studioConfig/published`. So the seed is NOT written
      // to the remote, and the cache keeps the born bundled default (non-empty).
      expect(src.sets, isEmpty);
      expect(r.published().isBundled, isTrue);
      expect(r.publishedTree(), ConfigLayer.empty);
    });
  });

  group('studioConfigRepositoryProvider — dormant default (byte-identical)', () {
    test('resolves to the LOCAL impl when the flags are OFF / Firebase is off',
        () {
      // The suite runs without Firebase.initializeApp AND kStudioLive defaults
      // OFF → `kStudioLive && useFirebaseBackend` is false → the provider must
      // return the const local impl (never touch Firestore). This is what keeps
      // the build byte-identical to today.
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final r = c.read(studioConfigRepositoryProvider);
      expect(r, isA<LocalStudioConfigRepository>());
      // And it behaves: the bundled default is reachable through the sync seam.
      expect(r.published().isBundled, isTrue);
      expect(r.publishedTree(), ConfigLayer.empty);
      expect(r.changes, isNull);
    });
  });
}
