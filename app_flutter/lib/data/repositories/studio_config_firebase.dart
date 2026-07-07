// ─────────────────────────────────────────────────────────────────────────────
// FirebaseStudioConfigRepository — the Firestore-backed implementation of
// [StudioConfigRepository], built on the offline-first cache base
// ([FirestoreCachedRepo]). Pillar 5 · Steps 54-59 — DORMANT until the flags flip.
// A DROP-IN for [LocalStudioConfigRepository]: the eventual consumers + the
// provider are unchanged — only which class `studioConfigRepositoryProvider`
// returns changes (see the switch in `studio_config_local.dart`).
//
// THE SINGLE-DOC TWIST (the headline gotcha, spec §54.3-4): the cache base is
// built around a `snapshots()` listener over a WHOLE collection, but the config
// is ONE doc — `studioConfig/published`. So we listen to the `studioConfig`
// collection that holds exactly that one pointer doc; the cache is a one-element
// `List<StudioConfigPointer>`, `idOf` is the fixed channel, and `fromDoc` maps
// ONLY the pointer (version/schema/ref/checksum) — the config TREE is not
// carried by the pointer doc (it lives in the immutable shards step 59 pulls),
// so in this step the tree stays the bundled default (empty ⇒ merge identity ⇒
// byte-identical). A freshly-published pointer therefore changes nothing that
// renders until step 59 wires the shard pull.
//
// SEED CONTRACT (cold-start non-empty): the cache is BORN with
// [StudioConfigPointer.bundled] (version 0) so `published()` is non-empty before
// snapshot 1 — identical to what the local impl answers. Unlike orders/customers
// this repo does NOT seed a fresh backend: `studioConfig/published` is
// callable-only-write (rules `allow write: if false`, step 65; publish rides the
// `publishConfig` callable, step 56), so `onFirstSnapshotEmpty` stays the base's
// NO-OP — the client never writes the published pointer. A first EMPTY snapshot
// just keeps the born bundled seed.
//
// STEP 59 — the shard→tree PULL: when step 58's `versionChanges` fires (a real
// publish), the immutable snapshot named by the pointer's `ref` is pulled (its
// `/shards` subcollection), its checksum VERIFIED over the raw bytes, the
// `ConfigLayer` ASSEMBLED, and swapped in ATOMICALLY. R2-7 governs failure:
// checksum-mismatch → retry-once then keep-last-good; a parse/`fromJson` throw →
// fall back to the last-good/seed (NEVER a blank app); a schema-newer pointer was
// already gated by step 58 (kept last-good + `needsAppUpdate`, no pull). The
// last-good tree is held SEPARATELY (a new pointer arrives tree-less), so a failed
// pull keeps rendering the previous good tree instead of blanking.
//
// No direct `cloud_firestore` import — the live handle is resolved lazily inside
// [FirestoreCollectionSource] (from `firestore_cached_repo.dart`), exactly as
// `orders_firebase.dart` does; a fake source drives the whole bridge in tests.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert' show jsonDecode, utf8;

import 'package:buildsmart/data/repositories/backend.dart' show kStudioLive;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/studio_config_repository.dart';
import 'package:buildsmart/state/studio/config_doc.dart'
    show ConfigLayer, kSchemaVersion;
import 'package:flutter/foundation.dart'
    show Listenable, ValueListenable, ValueNotifier, debugPrint;

/// The immutable-snapshot READ port (Step 59). Given a published pointer's
/// [StudioConfigPointer.ref] (a snapshot id under `studioConfigSnapshots`), it
/// returns that snapshot's ordered SHARD docs — the sharded blob the config tree
/// is assembled from. Kept SEPARATE from the base [RemoteCollectionSource] (a
/// whole-collection listen) because a snapshot pull is a one-shot BY-ID read of
/// an IMMUTABLE doc's `/shards` subcollection — exactly the read Step 59 needs,
/// and nothing the base offers. Firebase-free by the same trick as the base seam:
/// a fake drives the tests; the real adapter resolves Firestore lazily.
// A deliberate one-member seam port (the [RemoteCollectionSource] idiom) — kept
// abstract so a fake drives the tests instead of a real Firestore subcollection.
// ignore: one_member_abstracts
abstract class ConfigSnapshotSource {
  /// Fetch the shard docs of the immutable snapshot named [ref]. Each [RemoteDoc]
  /// carries its shard index (`n`) + the serialized layer fragment (`data`, a JSON
  /// string). Returns an EMPTY list when the snapshot is missing; a failure throws
  /// (the caller catches it → keep last-good, never blank).
  Future<List<RemoteDoc>> fetchShards(String ref);
}

/// The REAL snapshot adapter — a one-shot read of `studioConfigSnapshots/{ref}/
/// shards`. Delegates to the base's lazy [FirestoreCollectionSource] so THIS file
/// still imports NO `cloud_firestore` (the handle resolves lazily there, exactly
/// as the header promises); `snapshots().first` takes a single settled read, and
/// Firestore serves an immutable snapshot from its id-cache on any re-pull.
class FirestoreConfigSnapshotSource implements ConfigSnapshotSource {
  /// Const so the default is a `const` in the repo constructor (dormant path).
  const FirestoreConfigSnapshotSource();

  @override
  Future<List<RemoteDoc>> fetchShards(String ref) async =>
      FirestoreCollectionSource('studioConfigSnapshots/$ref/shards')
          .snapshots()
          .first;
}

/// The Firestore document-map mapper lives inline here (not in the model) so the
/// pure [StudioConfigPointer] value-object stays Firebase-free — drop-in is
/// preserved, exactly as `orders_firebase.dart` keeps `Order` untouched.
class FirebaseStudioConfigRepository
    extends FirestoreCachedRepo<StudioConfigPointer>
    implements StudioConfigRepository {
  /// Constructs the repo over the `studioConfig` collection (the single
  /// `published` pointer doc, the read/listen surface) PLUS the owner-writable
  /// `studioConfigSnapshots` collection ([_draftSource], the Step-55 draft-write
  /// target). Both real Firestore instances are resolved LAZILY by
  /// [FirestoreCollectionSource] (never here), so construction does not require
  /// Firebase to be initialised. Pass [source]/[draftSource]/[snapshotSource] in
  /// tests to drive the caches + the Step-59 shard pull with fakes; [live] injects
  /// the Step-55 sink kill-switch (defaults to [kStudioLive]) so the ON path is
  /// exercised in the define-less suite.
  FirebaseStudioConfigRepository({
    RemoteCollectionSource? source,
    RemoteCollectionSource? draftSource,
    ConfigSnapshotSource? snapshotSource,
    bool? live,
  })  : _draftSource =
            draftSource ?? FirestoreCollectionSource('studioConfigSnapshots'),
        _snapshotSource =
            snapshotSource ?? const FirestoreConfigSnapshotSource(),
        _live = live ?? kStudioLive,
        super(source ?? FirestoreCollectionSource('studioConfig'));

  /// The owner-writable DRAFT collection — `studioConfigSnapshots`. The Step-55
  /// sink ([saveDraft]) writes ONLY here (doc `draft-<uid>`, owner-write §5); the
  /// published pointer (`studioConfig/published`) is callable-only-write (step 56)
  /// and is NEVER touched by the client. Resolved LAZILY by
  /// [FirestoreCollectionSource] (never at construction) and driven by a fake in
  /// tests — exactly like the base `_source`. Its `snapshots()` is never listened
  /// to (no `attach`); the sink uses only its guarded `set`.
  final RemoteCollectionSource _draftSource;

  /// The Step-59 immutable-snapshot read port — pulls the `studioConfigSnapshots/
  /// {ref}/shards` blob a published pointer names. Resolved LAZILY by the default
  /// [FirestoreConfigSnapshotSource] (never at construction) and driven by a fake
  /// in tests. Read ONLY on a version-bump (never listened to).
  final ConfigSnapshotSource _snapshotSource;

  /// Step-55 sink kill-switch — mirrors [kStudioLive] (the master flag the
  /// provider already gates the whole repo on, `studio_config_local.dart`).
  /// Default [kStudioLive]; a test injects `true` to exercise the ON path in the
  /// define-less suite (the `kServerCallables` testability idiom). OFF ⇒ [saveDraft]
  /// is a complete NO-OP (no write, no cache mutation) ⇒ byte-identical.
  final bool _live;

  // ── base contract: seed · mapping · fresh-backend hook ──────────────────────

  /// The cache is born with the bundled default pointer (version 0, empty tree),
  /// so `published()` is non-empty before the first snapshot — identical genesis
  /// to the local path (cold-start byte-identical).
  @override
  List<StudioConfigPointer> get seed =>
      const <StudioConfigPointer>[StudioConfigPointer.bundled];

  /// doc-id = the fixed channel (`published`) — the single pointer doc.
  @override
  String idOf(StudioConfigPointer value) => value.channel;

  /// `StudioConfigPointer` → the `studioConfig/published` field-map. Writes ONLY
  /// the pointer (the tree lives in the immutable shards, step 59); `ref`/
  /// `checksum` are written only when non-empty so the bundled pointer + any
  /// legacy doc round-trip unchanged (mirrors `orders`' guarded fields). NOTE:
  /// the client never actually writes this doc in prod — publish is callable-only
  /// (step 56) — but the mapper is defined for round-trip symmetry + tests.
  @override
  Map<String, dynamic> toDoc(StudioConfigPointer p) => {
        'version': p.version,
        'schema': p.schema,
        if (p.ref.isNotEmpty) 'ref': p.ref,
        if (p.checksum.isNotEmpty) 'checksum': p.checksum,
      };

  /// The `studioConfig/published` doc → `StudioConfigPointer`. Maps ONLY the
  /// pointer (version/schema/ref/checksum); the TREE is not in the pointer doc —
  /// it defaults to the bundled [ConfigLayer.empty] (step 59 pulls the real tree
  /// from the shards named by `ref`). TOLERANT: every field defaults, so a
  /// malformed pointer decodes to the bundled default (never throws → never
  /// blanks — the R2-7 "never brick" spirit) rather than being skipped.
  @override
  StudioConfigPointer fromDoc(RemoteDoc doc) {
    final j = doc.data;
    return StudioConfigPointer(
      channel: doc.id,
      version: (j['version'] as num?)?.toInt() ?? 0,
      schema: (j['schema'] as num?)?.toInt() ?? kSchemaVersion,
      ref: (j['ref'] as String?) ?? '',
      checksum: (j['checksum'] as String?) ?? '',
      // tree stays ConfigLayer.empty (bundled default) — populated in step 59.
    );
  }

  // NOTE: onFirstSnapshotEmpty is intentionally NOT overridden — it stays the
  // base's NO-OP. The client must never seed `studioConfig/published` (it is
  // callable-only-write, step 56/65), so a fresh/empty backend simply keeps the
  // born bundled seed rather than pushing it (unlike orders/customers/stock).

  // ── reads (SYNCHRONOUS — served from the cache) + listen ────────────────────

  /// The current published pointer — the single cached doc, or the bundled
  /// default when the cache is (defensively) empty, so this NEVER returns blank.
  @override
  StudioConfigPointer published() {
    final c = cached();
    return c.isEmpty ? StudioConfigPointer.bundled : c.first;
  }

  /// The live published TREE — the last VERIFIED, atomically-swapped assembly
  /// (Step 59), held in [_lastGoodTree]. Born [ConfigLayer.empty] (the bundled
  /// seed ⇒ merge identity ⇒ byte-identical), and a failed pull never empties it
  /// (R2-7 keep-last-good). NOTE: this is NOT `published().tree` — the pointer doc
  /// is tree-less, so reading it would blank whenever a new pointer arrives before
  /// its shard pull completes; the separate field is what keeps the last-good tree.
  @override
  ConfigLayer publishedTree() => _lastGoodTree;

  /// LISTEN — the base is a [ChangeNotifier] (a [Listenable]); it notifies on
  /// every snapshot-driven cache replacement, so a consumer can watch pointer
  /// changes through it. (Step 58 formalises the single-listener kill-switch.)
  @override
  Listenable? get changes => this;

  // ── Step 55 — ConfigSink: optimistic owner DRAFT write (DORMANT) ─────────────

  /// Save the owner's work-in-progress config [draft] as an OPTIMISTIC draft.
  ///
  /// Writes ONLY to `studioConfigSnapshots/draft-<ownerUid>` (owner-write §5) via
  /// the base's guarded background write ([guardWrite], firestore_cached_repo.dart
  /// :344) — NEVER to `studioConfig/published`, which is callable-only-write (step
  /// 56) and would be blocked by rules / reverted by the step-57 trigger (a "looks
  /// saved" lie). The optimistic cache update is the base's LOCAL-ONLY twin
  /// ([upsertLocalOnly]): it replaces the single cached pointer + [notifyListeners]
  /// WITHOUT a write to the published `_source`, so the UI sees the draft
  /// synchronously. A later `studioConfig` snapshot then RECONCILES the cache (LWW)
  /// through the base's existing `_onSnapshot` (firestore_cached_repo.dart :241) —
  /// REUSED here, not reimplemented.
  ///
  /// A write failure (permission-denied / offline) is SWALLOWED by [guardWrite]
  /// and reported via [onResult]`(false)` — it NEVER throws into the UI (base rule
  /// #2). OFF ([_live] false — the master flag) or a missing [ownerUid] ⇒ a
  /// complete NO-OP: no write, no cache mutation (byte-identical).
  void saveDraft(
    StudioConfigPointer draft, {
    required String ownerUid,
    void Function(bool ok)? onResult,
  }) {
    // OFF (flag) or no owner ⇒ no write, no cache mutation — byte-identical.
    if (!_live || ownerUid.isEmpty) return;
    // Optimistic: show the draft NOW (cache + notify), with NO write to the
    // published `_source` (that path is callable-only). The persistent write is
    // the owner draft doc below; a late snapshot reconciles this (base :241).
    upsertLocalOnly(draft);
    // The ONLY remote write — the owner's draft doc, guarded (a failure is
    // swallowed → onResult(false), never thrown). Never `studioConfig/published`.
    guardWrite(
      () => _draftSource.set('draft-$ownerUid', toDoc(draft)),
      onResult: onResult,
    );
  }

  // ── Step 58 — SINGLE pointer listener + version-diff (the cache-bust signal) ──
  //
  // The base opens exactly ONE guarded `snapshots()` subscription over the
  // `studioConfig` collection (the single `published` pointer doc, ~200B) —
  // firestore_cached_repo.dart :204/:207 — and this step REUSES it (it does NOT
  // open a second listener). On top of that one subscription it layers a
  // VERSION-DIFF: the published pointer's `version` is monotonic (server-assigned
  // by the `publishConfig` callable, step 56), so a strictly-greater version is a
  // real publish → surfaced ONCE via [versionChanges] (the cache-bust signal step
  // 59 hooks its immutable-shard re-pull onto). An EQUAL/smaller snapshot — e.g. a
  // `publishedAt`-only field touch (§3.3) — is a NO-OP: the base still replaces
  // its one-element cache + notifies, but no redundant cache-bust is surfaced. A
  // pointer whose `schema` exceeds [maxKnownSchema] is from a NEWER app: we KEEP
  // the last-good version and raise [needsAppUpdate] WITHOUT advancing the signal
  // (R2-7 — never parse a newer tree; the tree parse itself lands in step 59).
  //
  // DORMANT/byte-identical when OFF: [attach] is called ONLY by the provider when
  // `kStudioLive && useFirebaseBackend` (`studio_config_local.dart`); OFF ⇒ the
  // const [LocalStudioConfigRepository] is returned and this is NEVER reached ⇒
  // no listener, no signal, no cost — the born bundled seed stands.

  /// The newest config schema this build can PARSE. A published pointer with a
  /// higher `schema` is from a newer app → keep the last-good + ask the user to
  /// update, and do NOT parse its tree or advance the re-pull signal (R2-7).
  /// Pinned to the app's [kSchemaVersion] (the single forward-compat gate).
  static const int maxKnownSchema = kSchemaVersion;

  /// The version-change signal, backed privately so consumers get a READ-ONLY
  /// [ValueListenable]. Born at the bundled seed's version (0) so cold-start is
  /// non-empty before snapshot 1; advances (and fires) ONCE per strictly-greater,
  /// known-schema published version — never on an equal/smaller snapshot, never
  /// on a schema-newer pointer.
  final ValueNotifier<int> _versionChanges =
      ValueNotifier<int>(StudioConfigPointer.bundled.version);

  /// R2-7 flag, backed privately (read-only to consumers via [needsAppUpdate]).
  final ValueNotifier<bool> _needsAppUpdate = ValueNotifier<bool>(false);

  /// Idempotency guard for the diff wiring — mirrors the base's `_sub ??=` so a
  /// second [attach] neither re-subscribes nor double-wires the diff.
  bool _diffWired = false;

  /// The cache-bust signal (read-only). Its value is the newest SURFACED
  /// published version; it fires ONCE per real advance. Step 59 watches this to
  /// trigger the immutable-shard re-pull — an equal/smaller snapshot is suppressed
  /// so there is no redundant rebuild.
  ValueListenable<int> get versionChanges => _versionChanges;

  /// The newest published version this repo has surfaced (0 = the bundled seed).
  int get lastSeenVersion => _versionChanges.value;

  /// R2-7 — raised (once) when a published pointer's `schema` exceeds
  /// [maxKnownSchema]: the tree is from a newer app, so we keep the last-good and
  /// surface "update the app" WITHOUT parsing. Read-only to consumers.
  ValueListenable<bool> get needsAppUpdate => _needsAppUpdate;

  /// Open the SINGLE pointer listener (the base's one guarded subscription,
  /// REUSED — not a second listen) and wire the version-diff onto it. Called ONLY
  /// by the provider when `kStudioLive && useFirebaseBackend` — OFF ⇒ the local
  /// impl is returned and this is never reached. Idempotent (mirrors the base's
  /// `_sub ??=`).
  @override
  void attach() {
    super.attach(); // the ONE guarded snapshots() listener (base :204/:207)
    if (_diffWired) return;
    _diffWired = true;
    // The diff rides the SAME subscription's notify (self-listen on the base
    // ChangeNotifier) — it does NOT open a second `snapshots()` listener.
    addListener(_diffVersion);
    // Step 59 — the immutable-shard re-pull hooks onto the version-change signal:
    // a strictly-greater, known-schema publish fires `versionChanges`, and ONLY
    // then do we pull + verify + swap. "Re-pull only on version-change" is free —
    // an equal/smaller/schema-newer snapshot never fires it.
    _versionChanges.addListener(_pullShards);
  }

  /// Version-diff — runs on each base cache-replacement (driven by the single
  /// subscription's `notifyListeners`). Advances [versionChanges] ONCE per
  /// strictly-greater, known-schema published version; an equal/smaller version
  /// (e.g. a `publishedAt`-only touch, §3.3) is a NO-OP — no redundant cache-bust.
  /// A schema newer than [maxKnownSchema] keeps the last-good version and raises
  /// [needsAppUpdate] WITHOUT surfacing it (R2-7 — the newer tree is never parsed;
  /// the raw pointer cache may move, but the re-pull SIGNAL holds at last-good).
  void _diffVersion() {
    final p = published();
    if (p.schema > maxKnownSchema) {
      // R2-7: a newer-schema pointer is from a newer app — keep last-good, ask to
      // update, and do NOT advance / re-pull (the tree parse is refused, step 59).
      _needsAppUpdate.value = true;
      return;
    }
    if (p.version > _versionChanges.value) {
      // A real publish — surface the cache-bust ONCE (step 59 re-pulls off this).
      _versionChanges.value = p.version;
    }
    // else: an equal/smaller version — NO-OP (no redundant rebuild).
  }

  // ── Step 59 — immutable-shard PULL · checksum-verify · ATOMIC swap ────────────
  //
  // On a real version-bump (surfaced by step 58's `versionChanges`) pull the
  // IMMUTABLE snapshot named by the pointer's `ref` (its `/shards` subcollection),
  // VERIFY the checksum over the raw shard bytes, ASSEMBLE the `ConfigLayer`, and
  // swap it in ATOMICALLY — one `notifyListeners`, the fully-built tree, so an
  // in-flight reader is never torn and the old immutable snapshot is never mutated.
  // R2-7 keep-last-good governs EVERY failure: a checksum mismatch retries ONCE
  // then holds the last-good tree; a parse/`fromJson` throw falls back to the
  // last-good/seed — NEVER a blank app; a schema-newer pointer never reaches here
  // (step 58 gated it: kept last-good + raised `needsAppUpdate`, no advance).
  //
  // The last-good tree is held SEPARATELY from the pointer cache: a new pointer
  // arrives tree-less (`fromDoc` maps only version/schema/ref/checksum), so a
  // FAILED pull for `vN` keeps rendering the previously-good `v(N-1)` tree instead
  // of blanking to the tree-less new pointer.

  /// The last VERIFIED, fully-assembled published tree (R2-7 keep-last-good). Born
  /// [ConfigLayer.empty] — the bundled seed, byte-identical cold-start — and only
  /// ever replaced by a checksum-verified assembled tree, so a failed pull can
  /// NEVER empty it. This is exactly what [publishedTree] serves.
  ConfigLayer _lastGoodTree = ConfigLayer.empty;

  /// The re-pull — triggered ONLY by a `versionChanges` advance (step 58), so it
  /// runs once per real publish, never on an equal/smaller/schema-newer snapshot
  /// ("re-pull only on version-change" falls out for free). Fully guarded (base
  /// rule #2): any failure keeps the last-good tree and never throws.
  Future<void> _pullShards() async {
    try {
      final target = published();
      // No snapshot to pull (bundled/legacy pointer, empty ref) — keep last-good.
      if (target.ref.isEmpty) return;
      final assembled = await _fetchVerifyAssemble(target);
      // Checksum/parse/missing failure → keep last-good, NEVER blank (R2-7).
      if (assembled == null) return;
      // A newer publish landed while we fetched → discard this stale tree; the
      // newer pull owns the swap (monotonic — an in-flight reader is never torn).
      final now = published();
      if (now.version != target.version || now.ref != target.ref) return;
      // ATOMIC swap — one assignment + one notify, the fully-built tree.
      _lastGoodTree = assembled;
      notifyListeners();
    } on Object catch (e) {
      // Defence in depth — a pull must never surface an error (base rule #2).
      debugPrint(
          'FirebaseStudioConfigRepository: shard pull failed (ignored): $e');
    }
  }

  /// Fetch → checksum-verify → assemble. Returns the assembled tree on success or
  /// `null` on any failure (caller keeps last-good). A checksum MISMATCH gets
  /// exactly ONE retry (R2-7); a parse/`fromJson` throw falls back IMMEDIATELY
  /// (re-fetching verified-but-unparseable bytes cannot help).
  Future<ConfigLayer?> _fetchVerifyAssemble(StudioConfigPointer p) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final List<RemoteDoc> ordered;
      try {
        ordered = _ordered(await _snapshotSource.fetchShards(p.ref));
      } on Object catch (e) {
        debugPrint('FirebaseStudioConfigRepository: shard fetch failed '
            '(attempt ${attempt + 1}) — keep last-good: $e');
        continue; // transient fetch error → retry once
      }
      // A missing/empty snapshot is an incomplete pull — never swap to empty.
      if (ordered.isEmpty) continue;
      // Verify the checksum over the RAW bytes BEFORE parsing (cheap corruption
      // guard). An empty pointer checksum (legacy) skips the check.
      if (p.checksum.isNotEmpty && checksumOf(ordered) != p.checksum) {
        debugPrint('FirebaseStudioConfigRepository: checksum mismatch '
            '(attempt ${attempt + 1}) — keep last-good (R2-7)');
        continue; // retry once, never swap to corrupt
      }
      // Parse/assemble GUARDED: a malformed shard (`jsonDecode` throw) or a
      // hostile `fromJson` falls back to last-good/seed — never bricks the app.
      try {
        return _assemble(ordered);
      } on Object catch (e) {
        debugPrint('FirebaseStudioConfigRepository: assemble threw — keep '
            'last-good/seed, never blank (R2-7): $e');
        return null; // do NOT retry an unparseable-but-verified blob
      }
    }
    return null; // both attempts failed the fetch/checksum — keep last-good
  }

  /// Assemble the ordered shards into a [ConfigLayer]. Each shard's `data` is a
  /// JSON string of a layer FRAGMENT (a subset of the `global`/`persona`/
  /// `structure` maps — the tree is split by size across shards, §1.1B); fragments
  /// are merged in shard order, then decoded through the tolerant
  /// [ConfigLayer.fromJson]. `jsonDecode` MAY throw on a malformed shard — that is
  /// the R2-7 parse-throw the caller catches.
  static ConfigLayer _assemble(List<RemoteDoc> ordered) {
    final merged = <String, dynamic>{};
    for (final shard in ordered) {
      final Object? raw = shard.data['data'];
      if (raw is! String) continue; // tolerate an absent/non-string payload
      final Object? decoded = jsonDecode(raw); // MAY throw → caught by the caller
      if (decoded is Map) _mergeLayerJson(merged, decoded);
    }
    return ConfigLayer.fromJson(merged);
  }

  /// Merge one shard's layer-fragment JSON into the accumulator. Top-level layer
  /// keys (`global`/`persona`/`structure`) are shallow map-merged, so nodes split
  /// across shards reunite (sharding partitions ids, so keys don't collide).
  static void _mergeLayerJson(
      Map<String, dynamic> into, Map<dynamic, dynamic> fragment) {
    fragment.forEach((k, v) {
      final key = k.toString();
      final existing = into[key];
      if (existing is Map && v is Map) {
        final m = <String, dynamic>{};
        existing.forEach((ek, ev) => m[ek.toString()] = ev);
        v.forEach((vk, vv) => m[vk.toString()] = vv);
        into[key] = m;
      } else {
        into[key] = v;
      }
    });
  }

  /// The canonical shard order — by the `n` index (the order the publish callable
  /// wrote + checksummed), id-tiebroken — so the client's checksum + assembly read
  /// the shards in the SAME order the server used.
  static List<RemoteDoc> _ordered(List<RemoteDoc> shards) =>
      List<RemoteDoc>.of(shards)
        ..sort((a, b) {
          final an = (a.data['n'] as num?)?.toInt();
          final bn = (b.data['n'] as num?)?.toInt();
          if (an != null && bn != null) return an.compareTo(bn);
          return a.id.compareTo(b.id);
        });

  /// The content digest over the shard payloads — the value the publish callable
  /// (step 56) stamps on the pointer as `checksum`, RE-DERIVED here to verify a
  /// pull before the atomic swap (R2-7). Canonical = each shard's `data` string in
  /// `n` order, space-joined, hashed with a dependency-free FNV-1a-64 (gate 60 —
  /// no new pub dep; [BigInt] keeps it exact on web's 53-bit numbers). Exposed so
  /// the define-less test derives the SAME digest it asserts, and step 56's server
  /// contract is pinned to "produce `checksumOf`'s value" (swap this one body to
  /// sha256 if/when that canonical hash is committed server-side).
  static String checksumOf(List<RemoteDoc> shards) {
    final buf = StringBuffer();
    for (final s in _ordered(shards)) {
      final Object? raw = s.data['data'];
      buf
        ..write(raw is String ? raw : '')
        ..write(' '); // shard separator — guards concatenation ambiguity
    }
    return _fnv1a64Hex(buf.toString());
  }

  /// 64-bit FNV-1a over the UTF-8 bytes, hex. [BigInt] (not `int`) so it is exact
  /// on web too (JS numbers are 53-bit) — a checksum, not a hot path.
  static String _fnv1a64Hex(String s) {
    final mask = (BigInt.one << 64) - BigInt.one;
    final prime = BigInt.from(1099511628211);
    var hash = BigInt.parse('14695981039346656037'); // FNV-1a 64-bit offset basis
    for (final b in utf8.encode(s)) {
      hash = ((hash ^ BigInt.from(b)) * prime) & mask;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  @override
  void dispose() {
    if (_diffWired) {
      removeListener(_diffVersion);
      _versionChanges.removeListener(_pullShards);
    }
    _versionChanges.dispose();
    _needsAppUpdate.dispose();
    super.dispose(); // base: cancels the single subscription + ChangeNotifier
  }
}
