// FIRESTORE CACHE-PATTERN (Studio · Step 58) — unit coverage for the SINGLE
// pointer listener + VERSION-DIFF on [FirebaseStudioConfigRepository]: the
// client-side cache-bust signal. Every client opens ONE guarded `snapshots()`
// subscription over the `studioConfig/published` pointer (the base's, REUSED —
// never a second listen); a strictly-greater published `version` surfaces ONCE
// via `versionChanges` (the signal step 59 hooks its immutable-shard re-pull
// onto), an equal/smaller snapshot is a NO-OP (no redundant cache-bust), and a
// schema-newer pointer keeps the last-good + raises `needsAppUpdate` WITHOUT
// parsing (R2-7).
//
// NO Firebase here: the [RemoteCollectionSource] seam is driven by a HAND-ROLLED
// fake (the exact shape studio_config_firebase_test.dart uses) — no
// fake_cloud_firestore, no new packages.
//
// Pins (the Step-58 listener contract):
//   • cold-start is the born bundled seed (version 0) — non-empty before any snapshot;
//   • a bigger version surfaces ONCE (versionChanges advances + fires);
//   • an equal/smaller version (a publishedAt-only touch) is a NO-OP;
//   • schema > maxKnownSchema ⇒ keep-last-good + needsAppUpdate, NO advance (R2-7);
//   • no attach ⇒ no listener ⇒ the version-diff is DARK (OFF/local = no-op);
//   • the provider DEFAULTS to the local impl (flags OFF ⇒ it never attaches).

import 'dart:async';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/studio_config_firebase.dart';
import 'package:buildsmart/data/repositories/studio_config_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [RemoteCollectionSource] (the base-test fake, verbatim
/// shape): a broadcast stream we drive manually + an in-memory record of writes.
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();

  final List<MapEntry<String, Map<String, dynamic>>> sets = [];
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

/// A repo wired to two fakes (published listen + draft write), tear-downs
/// registered. Not attached by default — a test opts into the listener.
({FirebaseStudioConfigRepository repo, _FakeSource published, _FakeSource draft})
    _mk() {
  final published = _FakeSource();
  final draft = _FakeSource();
  final repo = FirebaseStudioConfigRepository(
    source: published,
    draftSource: draft,
    live: true,
  );
  addTearDown(published.close);
  addTearDown(draft.close);
  addTearDown(repo.dispose);
  return (repo: repo, published: published, draft: draft);
}

/// A `studioConfig/published` pointer doc with the given version/schema. An
/// optional [publishedAt] models an irrelevant field-touch that does NOT change
/// the version (§3.3).
RemoteDoc _ptr(int version,
        {int schema = 1, String ref = '', int? publishedAt}) =>
    RemoteDoc('published', {
      'version': version,
      'schema': schema,
      if (ref.isNotEmpty) 'ref': ref,
      if (publishedAt != null) 'publishedAt': publishedAt,
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Step 58 — single pointer listener + version-diff', () {
    test('cold-start: born bundled seed, version 0, no signal yet', () {
      final r = _mk();
      // Non-empty BEFORE any snapshot — the born bundled seed (byte-identical).
      expect(r.repo.published().isBundled, isTrue);
      expect(r.repo.published().version, 0);
      expect(r.repo.versionChanges.value, 0); // born-seed version
      expect(r.repo.lastSeenVersion, 0);
      expect(r.repo.needsAppUpdate.value, isFalse);
    });

    test(
        'a BIGGER version surfaces ONCE (the cache-bust signal) + replaces the '
        'in-memory pointer', () async {
      final r = _mk();
      r.repo.attach();
      var fired = 0;
      r.repo.versionChanges.addListener(() => fired++);

      r.published.emit([_ptr(7, ref: 'v7')]);
      await Future<void>.delayed(Duration.zero);

      expect(fired, 1); // surfaced EXACTLY once
      expect(r.repo.versionChanges.value, 7);
      expect(r.repo.lastSeenVersion, 7);
      expect(r.repo.published().version, 7); // in-memory pointer replaced
      expect(r.repo.published().ref, 'v7');
      expect(r.repo.needsAppUpdate.value, isFalse);
    });

    test(
        'an EQUAL version (a publishedAt-only touch) is a NO-OP — no redundant '
        'cache-bust (§3.3)', () async {
      final r = _mk();
      r.repo.attach();
      r.published.emit([_ptr(7)]);
      await Future<void>.delayed(Duration.zero);

      var firedAfter = 0;
      r.repo.versionChanges.addListener(() => firedAfter++);

      // Same version 7, only a `publishedAt` field changed → the base still
      // replaces its cache + notifies, but the version-diff surfaces NOTHING.
      r.published.emit([_ptr(7, publishedAt: 1720000000)]);
      await Future<void>.delayed(Duration.zero);

      expect(firedAfter, 0); // no redundant re-pull signal
      expect(r.repo.versionChanges.value, 7);
    });

    test('a SMALLER version is a NO-OP (monotonic — never regresses)', () async {
      final r = _mk();
      r.repo.attach();
      r.published.emit([_ptr(7)]);
      await Future<void>.delayed(Duration.zero);

      var firedAfter = 0;
      r.repo.versionChanges.addListener(() => firedAfter++);

      r.published.emit([_ptr(3)]); // stale / out-of-order delivery
      await Future<void>.delayed(Duration.zero);

      expect(firedAfter, 0);
      expect(r.repo.versionChanges.value, 7); // last-good held
    });

    test('two DISTINCT advances fire twice, in order (7 → 9)', () async {
      final r = _mk();
      r.repo.attach();
      final seen = <int>[];
      r.repo.versionChanges
          .addListener(() => seen.add(r.repo.versionChanges.value));

      r.published.emit([_ptr(7)]);
      await Future<void>.delayed(Duration.zero);
      r.published.emit([_ptr(9)]);
      await Future<void>.delayed(Duration.zero);

      expect(seen, [7, 9]);
      expect(r.repo.lastSeenVersion, 9);
    });

    test(
        'schema > maxKnownSchema ⇒ keep-last-good + needsAppUpdate, NO advance '
        '(R2-7)', () async {
      final r = _mk();
      r.repo.attach();
      // A good v7 (known schema) first…
      r.published.emit([_ptr(7)]);
      await Future<void>.delayed(Duration.zero);
      expect(r.repo.versionChanges.value, 7);

      var advancedAfter = 0;
      r.repo.versionChanges.addListener(() => advancedAfter++);

      // …then a NEWER-schema v8 from a newer app: DO NOT parse / advance.
      r.published.emit([
        _ptr(8, schema: FirebaseStudioConfigRepository.maxKnownSchema + 1),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(r.repo.needsAppUpdate.value, isTrue); // "update the app"
      expect(advancedAfter, 0); // the cache-bust signal did NOT advance
      expect(r.repo.versionChanges.value, 7); // kept the last-good version
    });

    test('a FIRST schema-newer event keeps the bundled seed + raises the flag',
        () async {
      final r = _mk();
      r.repo.attach();
      r.published.emit([
        _ptr(5, schema: FirebaseStudioConfigRepository.maxKnownSchema + 1),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(r.repo.needsAppUpdate.value, isTrue);
      expect(r.repo.versionChanges.value, 0); // never advanced past the born seed
    });

    test('NO attach ⇒ NO listener ⇒ the version-diff is DARK (OFF/local no-op)',
        () async {
      final r = _mk(); // deliberately NOT attached
      var fired = 0;
      r.repo.versionChanges.addListener(() => fired++);

      r.published.emit([_ptr(7)]); // nobody is subscribed to the stream
      await Future<void>.delayed(Duration.zero);

      expect(fired, 0);
      expect(r.repo.versionChanges.value, 0);
      expect(r.repo.published().isBundled, isTrue); // still the born seed
    });

    test(
        'the provider DEFAULTS to the LOCAL impl (flags OFF) — no firebase '
        'listener at all', () {
      // The suite runs without Firebase.initializeApp AND kStudioLive defaults
      // OFF → `kStudioLive && useFirebaseBackend` is false → the provider returns
      // the const local impl, which NEVER attaches a listener (byte-identical).
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final r = c.read(studioConfigRepositoryProvider);
      expect(r, isA<LocalStudioConfigRepository>());
      expect(r.changes, isNull); // static local path — nothing ever pushes
    });
  });
}
