// FIRESTORE CACHE-PATTERN (Studio · Step 59) — unit coverage for the immutable
// SHARD PULL on [FirebaseStudioConfigRepository]: on a real version-bump (step
// 58's `versionChanges`) the repo pulls the snapshot named by the pointer's
// `ref`, VERIFIES the checksum, ASSEMBLES the `ConfigLayer`, and swaps it in
// ATOMICALLY — with R2-7 keep-last-good on every failure (never a blank app).
//
// NO Firebase here: BOTH seams are hand-rolled fakes — the published-pointer
// listener ([_FakeSource], the base-test shape) AND the Step-59 snapshot read
// port ([_FakeSnapshotSource]). No fake_cloud_firestore, no new packages.
//
// Pins (the Step-59 pull contract):
//   • a real pull ASSEMBLES the tree (publishedTree goes non-empty);
//   • a multi-shard pull MERGES fragments + swaps ATOMICALLY (no partial tree);
//   • checksum-mismatch ⇒ keep-last-good + retry-ONCE (never empties, R2-7);
//   • a parse/jsonDecode throw ⇒ fall back to last-good/seed, app NOT blank (R2-7);
//   • a schema-newer pointer ⇒ step-58 gate ⇒ NO pull + needsAppUpdate (R2-7);
//   • re-pull ONLY on a strictly-greater version (equal/smaller = no fetch);
//   • OFF (never attached) ⇒ NO pull at all (dormant / byte-identical).

import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/studio_config_firebase.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_node.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [RemoteCollectionSource] for the published-pointer listen —
/// a broadcast stream we drive manually (the base-test fake, verbatim shape).
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();

  /// Push a snapshot event to listeners.
  void emit(List<RemoteDoc> docs) => _controller.add(docs);

  @override
  Stream<List<RemoteDoc>> snapshots() => _controller.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  bool get isScoped => false;

  Future<void> close() => _controller.close();
}

/// A hand-rolled [ConfigSnapshotSource]: serves the shards registered per `ref`,
/// records every `fetchShards(ref)` call (so a test asserts the retry-count), and
/// can be told to throw on the next fetch (the transient-error path).
class _FakeSnapshotSource implements ConfigSnapshotSource {
  final Map<String, List<RemoteDoc>> shardsByRef = {};
  final List<String> fetchedRefs = [];
  bool failNextFetch = false;

  int fetchCountFor(String ref) => fetchedRefs.where((r) => r == ref).length;

  @override
  Future<List<RemoteDoc>> fetchShards(String ref) async {
    fetchedRefs.add(ref);
    if (failNextFetch) {
      failNextFetch = false;
      throw StateError('boom (simulated shard fetch failure)');
    }
    return shardsByRef[ref] ?? const [];
  }
}

/// A repo wired to the published fake + the snapshot fake (+ an unused draft
/// fake), tear-downs registered. Not attached by default — a test opts in.
({
  FirebaseStudioConfigRepository repo,
  _FakeSource published,
  _FakeSnapshotSource snapshots,
}) _mk() {
  final published = _FakeSource();
  final draft = _FakeSource();
  final snapshots = _FakeSnapshotSource();
  final repo = FirebaseStudioConfigRepository(
    source: published,
    draftSource: draft,
    snapshotSource: snapshots,
    live: true,
  );
  addTearDown(published.close);
  addTearDown(draft.close);
  addTearDown(repo.dispose);
  return (repo: repo, published: published, snapshots: snapshots);
}

/// A single-node `global` layer fragment (proves an assembled tree).
ConfigLayer _layer(String id, String text) =>
    ConfigLayer(global: {id: CfgNode(text: text)});

/// A shard doc: index [n] + the layer fragment [layer] serialized as the `data`
/// JSON string (the assumed shard shape — `{n, data}`).
RemoteDoc _shard(int n, ConfigLayer layer) =>
    RemoteDoc('$n', {'n': n, 'data': jsonEncode(layer.toJson())});

/// A shard doc carrying a RAW (possibly malformed) `data` string.
RemoteDoc _rawShard(int n, String data) =>
    RemoteDoc('$n', {'n': n, 'data': data});

/// A `studioConfig/published` pointer doc.
RemoteDoc _ptr(int version,
        {int schema = 1, String ref = '', String checksum = ''}) =>
    RemoteDoc('published', {
      'version': version,
      'schema': schema,
      if (ref.isNotEmpty) 'ref': ref,
      if (checksum.isNotEmpty) 'checksum': checksum,
    });

/// The digest the repo derives for [shards] — what a real pointer's `checksum`
/// carries for a matching (verified) pull.
String _ck(List<RemoteDoc> shards) =>
    FirebaseStudioConfigRepository.checksumOf(shards);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Step 59 — immutable-shard pull · verify · atomic swap', () {
    test('a real pull ASSEMBLES the tree (publishedTree goes non-empty)',
        () async {
      final r = _mk();
      r.repo.attach();

      // Cold-start is the bundled seed (empty ⇒ byte-identical), before any pull.
      expect(r.repo.publishedTree(), ConfigLayer.empty);

      final layer = _layer('home.title', 'שלום עולם');
      final shards = [_shard(0, layer)];
      r.snapshots.shardsByRef['v7'] = shards;

      r.published.emit([_ptr(7, ref: 'v7', checksum: _ck(shards))]);
      await pumpEventQueue();

      // After the pull the tree is the assembled fragment.
      expect(r.repo.publishedTree().isEmpty, isFalse);
      expect(r.repo.publishedTree(), layer);
      expect(r.repo.publishedTree().global['home.title']!.text, 'שלום עולם');
      expect(r.snapshots.fetchCountFor('v7'), 1); // one read on the version-bump
      expect(r.repo.versionChanges.value, 7);
      expect(r.repo.needsAppUpdate.value, isFalse);
    });

    test(
        'a MULTI-shard pull merges fragments + swaps ATOMICALLY (no partial tree)',
        () async {
      final r = _mk();
      r.repo.attach();

      // Snapshot publishedTree() on EVERY notify — assert it is NEVER a partial
      // (one-entry) tree: it goes empty(0) → full(2) in a single atomic swap.
      final observed = <int>[];
      r.repo.addListener(
          () => observed.add(r.repo.publishedTree().global.length));

      final shards = [
        _shard(0, _layer('a.node', 'A')),
        _shard(1, _layer('b.node', 'B')),
      ];
      r.snapshots.shardsByRef['v9'] = shards;
      r.published.emit([_ptr(9, ref: 'v9', checksum: _ck(shards))]);
      await pumpEventQueue();

      final tree = r.repo.publishedTree();
      expect(tree.global.keys, containsAll(<String>['a.node', 'b.node']));
      expect(tree.global.length, 2); // both shards merged
      expect(observed, isNot(contains(1))); // never a half-assembled tree
    });

    test('checksum-mismatch ⇒ keep-last-good + retry-ONCE (never empties, R2-7)',
        () async {
      final r = _mk();
      r.repo.attach();

      // A GOOD v7 assembles + becomes the last-good tree.
      final good = _layer('keep.me', 'שמור');
      final goodShards = [_shard(0, good)];
      r.snapshots.shardsByRef['v7'] = goodShards;
      r.published.emit([_ptr(7, ref: 'v7', checksum: _ck(goodShards))]);
      await pumpEventQueue();
      expect(r.repo.publishedTree(), good);

      // Then v9 whose pointer.checksum does NOT match its shards (corruption).
      r.snapshots.shardsByRef['v9'] = [_shard(0, _layer('should.not.show', 'X'))];
      r.published.emit([_ptr(9, ref: 'v9', checksum: 'WRONG-CHECKSUM')]);
      await pumpEventQueue();

      // The pointer moved to v9, but the TREE held the last-good v7 (never blank)…
      expect(r.repo.published().version, 9);
      expect(r.repo.publishedTree(), good);
      expect(r.repo.publishedTree().isEmpty, isFalse);
      // …and the mismatch triggered exactly ONE retry (two fetches for v9).
      expect(r.snapshots.fetchCountFor('v9'), 2);
    });

    test('a parse/jsonDecode throw ⇒ fall back to last-good, app NOT blank (R2-7)',
        () async {
      final r = _mk();
      r.repo.attach();

      // GOOD v7 first…
      final good = _layer('keep.me', 'שמור');
      final goodShards = [_shard(0, good)];
      r.snapshots.shardsByRef['v7'] = goodShards;
      r.published.emit([_ptr(7, ref: 'v7', checksum: _ck(goodShards))]);
      await pumpEventQueue();
      expect(r.repo.publishedTree(), good);

      // …then v11 whose shard `data` is MALFORMED JSON, but whose checksum MATCHES
      // (so verification passes and we reach the GUARDED parse, which throws).
      final badShards = [_rawShard(0, '{ this is : not json')];
      r.snapshots.shardsByRef['v11'] = badShards;
      r.published.emit([_ptr(11, ref: 'v11', checksum: _ck(badShards))]);
      await pumpEventQueue();

      expect(r.repo.publishedTree(), good); // kept last-good (not blank)
      expect(r.repo.publishedTree().isEmpty, isFalse);
      // Parse-throw does NOT retry (re-fetching verified-but-unparseable bytes
      // cannot help) — exactly one fetch for v11.
      expect(r.snapshots.fetchCountFor('v11'), 1);
    });

    test('a schema-newer pointer ⇒ step-58 gate ⇒ NO pull + needsAppUpdate (R2-7)',
        () async {
      final r = _mk();
      r.repo.attach();

      r.snapshots.shardsByRef['v13'] = [_shard(0, _layer('nope', 'X'))];
      r.published.emit([
        _ptr(13,
            schema: FirebaseStudioConfigRepository.maxKnownSchema + 1,
            ref: 'v13',
            checksum: 'anything'),
      ]);
      await pumpEventQueue();

      expect(r.repo.needsAppUpdate.value, isTrue); // "update the app"
      expect(r.snapshots.fetchCountFor('v13'), 0); // never pulled (never parsed)
      expect(r.repo.publishedTree(), ConfigLayer.empty); // last-good held (seed)
      expect(r.repo.versionChanges.value, 0); // the re-pull signal never advanced
    });

    test('re-pull ONLY on a strictly-greater version (equal/smaller = no fetch)',
        () async {
      final r = _mk();
      r.repo.attach();

      final shards = [_shard(0, _layer('v.node', 'V'))];
      r.snapshots.shardsByRef['v7'] = shards;
      final ck = _ck(shards);

      r.published.emit([_ptr(7, ref: 'v7', checksum: ck)]);
      await pumpEventQueue();
      expect(r.snapshots.fetchCountFor('v7'), 1);

      // Same version 7 re-delivered (no bump) → NO new fetch.
      r.published.emit([_ptr(7, ref: 'v7', checksum: ck)]);
      await pumpEventQueue();
      expect(r.snapshots.fetchCountFor('v7'), 1); // re-pull suppressed

      // A smaller version (stale / out-of-order) → NO fetch either.
      r.snapshots.shardsByRef['v3'] = [_shard(0, _layer('x', 'x'))];
      r.published.emit([_ptr(3, ref: 'v3', checksum: 'whatever')]);
      await pumpEventQueue();
      expect(r.snapshots.fetchCountFor('v3'), 0);
    });

    test('a transient fetch ERROR ⇒ keep-last-good (never blank)', () async {
      final r = _mk();
      r.repo.attach();

      // GOOD v7 first…
      final good = _layer('keep.me', 'שמור');
      final goodShards = [_shard(0, good)];
      r.snapshots.shardsByRef['v7'] = goodShards;
      r.published.emit([_ptr(7, ref: 'v7', checksum: _ck(goodShards))]);
      await pumpEventQueue();
      expect(r.repo.publishedTree(), good);

      // …then v9 whose FIRST fetch throws; the second returns nothing registered
      // (empty) — either way the pull fails cleanly and keeps the last-good tree.
      r.snapshots.failNextFetch = true;
      r.published.emit([_ptr(9, ref: 'v9', checksum: 'x')]);
      await pumpEventQueue();

      expect(r.repo.publishedTree(), good); // never blank
      expect(r.repo.publishedTree().isEmpty, isFalse);
    });

    test('OFF (never attached) ⇒ NO pull, NO fetch (dormant / byte-identical)',
        () async {
      final r = _mk(); // deliberately NOT attached

      r.snapshots.shardsByRef['v7'] = [_shard(0, _layer('x', 'x'))];
      r.published.emit([_ptr(7, ref: 'v7', checksum: 'x')]); // nobody subscribed
      await pumpEventQueue();

      expect(r.snapshots.fetchedRefs, isEmpty); // the snapshot port never touched
      expect(r.repo.publishedTree(), ConfigLayer.empty); // still the born seed
      expect(r.repo.versionChanges.value, 0);
    });
  });
}
