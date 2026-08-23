// FIRESTORE CACHE-PATTERN (Studio · Step 55) — unit coverage for the
// `ConfigSink` draft-write on [FirebaseStudioConfigRepository]: the optimistic
// owner draft that rides the base's guarded `set` (firestore_cached_repo.dart
// :344), writing ONLY to `studioConfigSnapshots/draft-<uid>` — NEVER to the
// callable-only `studioConfig/published`.
//
// NO Firebase here: the Firestore seam ([RemoteCollectionSource]) is driven by a
// HAND-ROLLED fake ([_FakeSource]) — no fake_cloud_firestore, no new packages
// (the exact shape `studio_config_repository_test.dart` / `chat_firebase_repo_test.dart`
// use). TWO fakes back the repo: one for the published `studioConfig` listen
// (to drive the reconcile snapshot + prove it is never written), one for the
// `studioConfigSnapshots` draft-write target (captures every `set`, and can be
// told to throw so the SWALLOW path is asserted).
//
// Pins (the Step-55 sink contract):
//   • saveDraft writes ONLY to `studioConfigSnapshots/draft-<uid>` — never to
//     `studioConfig/published` (callable-only-write, step 56);
//   • it is OPTIMISTIC: the cache updates + notifies synchronously (local-only
//     twin), the pointer-only tree stays the bundled default;
//   • a LATE `studioConfig` snapshot RECONCILES the cache (LWW, base :241 —
//     reused, not reimplemented);
//   • a write error is SWALLOWED → onResult(false), never thrown, cache intact;
//   • OFF (the flag) ⇒ NO write, NO cache mutation (byte-identical).

import 'dart:async';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/studio_config_firebase.dart';
import 'package:buildsmart/data/repositories/studio_config_repository.dart';
import 'package:buildsmart/state/studio/config_doc.dart' show ConfigLayer;
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [RemoteCollectionSource] (the base-test fake, verbatim
/// shape): a broadcast stream we drive manually + an in-memory record of writes,
/// with an opt-in throw on the next `set` to exercise the guarded-write path.
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();

  /// Captured `set` calls (id → last field-map written), in arrival order.
  final List<MapEntry<String, Map<String, dynamic>>> sets = [];

  /// Captured `delete` calls (ids).
  final List<String> deletes = [];

  /// When true, the next [set] throws — to exercise the guarded write path.
  bool failNextSet = false;

  /// Push a snapshot event to listeners.
  void emit(List<RemoteDoc> docs) => _controller.add(docs);

  @override
  Stream<List<RemoteDoc>> snapshots() => _controller.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    if (failNextSet) {
      failNextSet = false;
      throw StateError('boom (simulated draft write failure)');
    }
    sets.add(MapEntry(id, data));
  }

  @override
  Future<void> delete(String id) async => deletes.add(id);

  @override
  bool get isScoped => false;

  Future<void> close() => _controller.close();
}

/// A repo wired to two fakes (published listen + draft write), tear-downs
/// registered. [live] drives the Step-55 sink kill-switch.
({FirebaseStudioConfigRepository repo, _FakeSource published, _FakeSource draft})
    _mk({bool live = true}) {
  final published = _FakeSource();
  final draft = _FakeSource();
  final repo = FirebaseStudioConfigRepository(
    source: published,
    draftSource: draft,
    live: live,
  );
  addTearDown(published.close);
  addTearDown(draft.close);
  addTearDown(repo.dispose);
  return (repo: repo, published: published, draft: draft);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfigSink.saveDraft — optimistic owner draft (Step 55)', () {
    test(
        'writes ONLY to studioConfigSnapshots/draft-<uid> — never to '
        'studioConfig/published; optimistic cache + notify', () async {
      final r = _mk();
      var notified = 0;
      r.repo.addListener(() => notified++);

      r.repo.saveDraft(
        const StudioConfigPointer(
            version: 5, schema: 2, ref: 'dref', checksum: 'ck'),
        ownerUid: 'u1',
      );

      // Optimistic — the draft is visible SYNCHRONOUSLY (cache + one notify),
      // carrying NO tree (pointer-only, exactly as the step-54 mapping).
      expect(r.repo.published().version, 5);
      expect(notified, 1);
      expect(r.repo.publishedTree(), ConfigLayer.empty);

      await Future<void>.delayed(Duration.zero);

      // The ONE write landed on the DRAFT collection, doc `draft-u1`…
      expect(r.draft.sets.length, 1);
      final entry = r.draft.sets.single;
      expect(entry.key, 'draft-u1');
      expect(entry.value['version'], 5);
      expect(entry.value['schema'], 2);
      expect(entry.value['ref'], 'dref');
      expect(entry.value['checksum'], 'ck');
      expect(entry.value.containsKey('tree'), isFalse); // pointer-only
      // …and the published pointer was NEVER written (callable-only-write).
      expect(r.published.sets, isEmpty);
    });

    test(
        'a late studioConfig snapshot RECONCILES the optimistic draft '
        '(LWW, base :241 — not reimplemented)', () async {
      final r = _mk();
      r.repo.attach();

      // Optimistic draft (version 5) shown locally…
      r.repo.saveDraft(const StudioConfigPointer(version: 5), ownerUid: 'u1');
      expect(r.repo.published().version, 5);

      // …then the authoritative published pointer arrives on the studioConfig
      // listener → the base's _onSnapshot replaces the cache (LWW reconcile of
      // the local stream — the existing base behaviour, reused).
      r.published.emit(const [
        RemoteDoc(
            'published', {'version': 9, 'schema': 1, 'ref': 'v9', 'checksum': 'c9'}),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(r.repo.published().version, 9); // the late snapshot won
      expect(r.repo.published().ref, 'v9');
    });

    test(
        'a write error is SWALLOWED → onResult(false), NOT thrown; optimistic '
        'cache intact', () async {
      final r = _mk();
      r.draft.failNextSet = true;

      bool? ok;
      r.repo.saveDraft(
        const StudioConfigPointer(version: 5),
        ownerUid: 'u1',
        onResult: (v) => ok = v,
      );
      // Optimistic cache is there synchronously, before the write settles.
      expect(r.repo.published().version, 5);

      await Future<void>.delayed(Duration.zero);

      expect(ok, isFalse); // guardWrite swallowed the failure → onResult(false)
      expect(r.draft.sets, isEmpty); // the failing set recorded nothing
      expect(r.repo.published().version, 5); // intact — nothing threw into the UI
    });

    test('OFF (live:false) ⇒ NO write, NO cache mutation (byte-identical)',
        () async {
      final r = _mk(live: false);
      var notified = 0;
      r.repo.addListener(() => notified++);

      r.repo.saveDraft(const StudioConfigPointer(version: 5), ownerUid: 'u1');
      await Future<void>.delayed(Duration.zero);

      expect(r.draft.sets, isEmpty); // OFF = no write at all
      expect(r.published.sets, isEmpty); // and never the published pointer
      expect(notified, 0); // no cache mutation / notify
      expect(r.repo.published().isBundled, isTrue); // still the bundled seed
    });

    test('a missing ownerUid ⇒ NO write (an owner-scoped draft needs an owner)',
        () async {
      final r = _mk();
      r.repo.saveDraft(const StudioConfigPointer(version: 5), ownerUid: '');
      await Future<void>.delayed(Duration.zero);

      expect(r.draft.sets, isEmpty);
      expect(r.published.sets, isEmpty);
      expect(r.repo.published().isBundled, isTrue);
    });
  });
}
