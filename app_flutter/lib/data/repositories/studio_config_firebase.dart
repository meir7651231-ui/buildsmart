// ─────────────────────────────────────────────────────────────────────────────
// FirebaseStudioConfigRepository — the Firestore-backed implementation of
// [StudioConfigRepository], built on the offline-first cache base
// ([FirestoreCachedRepo]). Pillar 5 · Step 54 — DORMANT until the flags flip.
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
// No direct `cloud_firestore` import — the live handle is resolved lazily inside
// [FirestoreCollectionSource] (from `firestore_cached_repo.dart`), exactly as
// `orders_firebase.dart` does; a fake source drives the whole bridge in tests.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/studio_config_repository.dart';
import 'package:buildsmart/state/studio/config_doc.dart'
    show ConfigLayer, kSchemaVersion;
import 'package:flutter/foundation.dart' show Listenable;

/// The Firestore document-map mapper lives inline here (not in the model) so the
/// pure [StudioConfigPointer] value-object stays Firebase-free — drop-in is
/// preserved, exactly as `orders_firebase.dart` keeps `Order` untouched.
class FirebaseStudioConfigRepository
    extends FirestoreCachedRepo<StudioConfigPointer>
    implements StudioConfigRepository {
  /// Constructs the repo over the `studioConfig` collection (the single
  /// `published` pointer doc). The real Firestore instance is resolved LAZILY by
  /// [FirestoreCollectionSource] (never here), so construction does not require
  /// Firebase to be initialised. Pass [source] in tests to drive the cache with
  /// a fake.
  FirebaseStudioConfigRepository({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('studioConfig'));

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

  @override
  ConfigLayer publishedTree() => published().tree;

  /// LISTEN — the base is a [ChangeNotifier] (a [Listenable]); it notifies on
  /// every snapshot-driven cache replacement, so a consumer can watch pointer
  /// changes through it. (Step 58 formalises the single-listener kill-switch.)
  @override
  Listenable? get changes => this;
}
