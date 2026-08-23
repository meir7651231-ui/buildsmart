// ─────────────────────────────────────────────────────────────────────────────
// StudioConfigRepository — the read/listen surface for the PUBLISHED Studio
// config (the No-Code config tree that flows to every user). Pillar 5 · Step 54.
//
// SERVER-READY SEAM (the proven repo-pair shape — mirrors [CatalogRepository] /
// [OrdersRepository]). This is the ABSTRACT interface + its pointer value-object
// only; the const local impl ([LocalStudioConfigRepository]) and the Firestore
// impl ([FirebaseStudioConfigRepository]) live beside it. When Studio config
// moves to a real backend (draft→publish on Firestore, steps 55-59) the only
// thing that swaps is the implementation behind `studioConfigRepositoryProvider`
// (`studio_config_local.dart`) — the eventual consumers stay unchanged.
//
// WHAT THE DOMAIN IS: the live config is the `studioConfig/published` POINTER —
// a tiny doc carrying `{version, schema, ref, checksum}` that NAMES the current
// published snapshot (the immutable shards step 59 pulls the tree from). The
// tree itself is the published [ConfigLayer] (global ⊕ persona ⊕ structure
// overrides). TODAY nothing is server-published, so the pointer is the BUNDLED
// default ([StudioConfigPointer.bundled]) — version 0, an EMPTY tree — and the
// config merge yields the identity, i.e. every wrapper renders its verbatim
// fallback (byte-identical to today; the zero-regression root the whole Studio
// rests on, `config_store.dart` / `config_doc.dart`).
//
// FIREBASE-FREE by construction: this file imports NO `cloud_firestore` (nor
// Riverpod). It speaks only the pure config value-objects (`config_doc.dart`),
// so it — and the tests that drive the seam — need no Firebase to compile.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_doc.dart'
    show ConfigLayer, kSchemaVersion;
import 'package:flutter/foundation.dart' show Listenable, immutable;

/// The canonical single-doc channel under the `studioConfig` collection — the
/// live pointer is `studioConfig/published` (mirrors the plan's
/// `studioConfig/{channel}`; the trigger in step 57 keys on this channel).
const String kStudioConfigChannel = 'published';

/// One PUBLISHED config pointer — the neutral value-object the seam speaks in
/// (the `studioConfig/published` doc mapped down). It carries ONLY the pointer
/// metadata + the published [tree]; draft/history are the owner-local concern of
/// the [ConfigStore], never this published seam.
///
/// [version] is the monotonic published version (`0` = the BUNDLED default, i.e.
/// never server-published — today's state). [schema] pins forward-compat (step
/// 54 addition-a); [ref] names the immutable snapshot shards (step 59 pulls the
/// tree by it); [checksum] validates a swap after the pull (step 54 addition-b /
/// step 59). In THIS dormant step [tree] stays the bundled default — the pointer
/// maps, but the tree pull lands in step 59, so a freshly-published pointer
/// changes nothing that renders.
@immutable
class StudioConfigPointer {
  const StudioConfigPointer({
    this.channel = kStudioConfigChannel,
    this.version = 0,
    this.schema = kSchemaVersion,
    this.ref = '',
    this.checksum = '',
    this.tree = ConfigLayer.empty,
  });

  /// The doc channel — the natural key (`idOf`), `studioConfig/{channel}`.
  final String channel;

  /// Monotonic published version; `0` = the bundled default (never published).
  final int version;

  /// Config schema of the published tree (forward-compat gate, step 54/59).
  final int schema;

  /// The immutable-snapshot ref the tree is pulled from (step 59). '' = bundled.
  final String ref;

  /// Content checksum for post-swap validation (step 54 addition-b / step 59).
  final String checksum;

  /// The published config layer flowed to all users. Bundled default = the EMPTY
  /// layer ⇒ the merge yields identity ⇒ byte-identical to today. Step 59 will
  /// populate this from the immutable shards named by [ref].
  final ConfigLayer tree;

  /// The bundled default — today's config: nothing server-published (version 0),
  /// an empty tree. The born-seed of the cache + the local impl's whole answer.
  static const StudioConfigPointer bundled = StudioConfigPointer();

  /// True when this is the bundled default (never server-published).
  bool get isBundled => version == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudioConfigPointer &&
          other.channel == channel &&
          other.version == version &&
          other.schema == schema &&
          other.ref == ref &&
          other.checksum == checksum &&
          other.tree == tree;

  @override
  int get hashCode =>
      Object.hash(channel, version, schema, ref, checksum, tree);
}

/// Server-ready contract over the PUBLISHED Studio config. The current backing
/// is the bundled default ([StudioConfigPointer.bundled]); the Firestore impl
/// (steps 55-59) swaps in behind `studioConfigRepositoryProvider`.
///
/// Reads are SYNCHRONOUS (served from a born-seeded cache — never a Future), so
/// the interface is a drop-in over an async backend, exactly like the other
/// repo-pairs. `implements`-ing classes must re-declare the default members
/// ([publishedTree] / [changes]) — a Dart `implements` does not inherit bodies
/// (see the same note on `catalog_local.dart`).
abstract class StudioConfigRepository {
  /// GET — the current published pointer, synchronously. Off the server this is
  /// [StudioConfigPointer.bundled] (version 0, empty tree).
  StudioConfigPointer published();

  /// GET — the published config layer (convenience over [published]). Bundled
  /// default ⇒ [ConfigLayer.empty] ⇒ the merge yields identity (byte-identical).
  ConfigLayer publishedTree() => published().tree;

  /// LISTEN — an optional [Listenable] that fires when the published pointer
  /// changes (Pillar-5 server push). `null` for the const local impl: the
  /// bundled default is static, so nothing ever pushes.
  Listenable? get changes => null;
}
