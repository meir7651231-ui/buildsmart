// ─────────────────────────────────────────────────────────────────────────────
// LocalStudioConfigRepository — the const/in-memory implementation of
// [StudioConfigRepository]. Pillar 5 · Step 54. It is the OFF default: it wraps
// the BUNDLED config pointer ([StudioConfigPointer.bundled]) — version 0, an
// EMPTY published tree — so every read returns exactly today's state (nothing
// server-published ⇒ the config merge yields identity ⇒ every wrapper renders
// its verbatim fallback, byte-for-byte identical). When Studio config moves to
// the live backend, only the provider's branch swaps (the class + eventual UI
// stay unchanged).
//
// PURE + const — no [Ref], no Firebase, no `cloud_firestore`: the whole answer
// is the const bundled pointer, so this file (and the app path that returns it)
// need no backend to compile or run.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart'
    show kStudioLive, useFirebaseBackend;
import 'package:buildsmart/data/repositories/studio_config_firebase.dart';
import 'package:buildsmart/data/repositories/studio_config_repository.dart';
import 'package:buildsmart/state/studio/config_doc.dart' show ConfigLayer;
import 'package:flutter/foundation.dart' show Listenable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The local (const-backed) implementation of [StudioConfigRepository]. Every
/// read forwards to the const [StudioConfigPointer.bundled], returning the SAME
/// bundled default the app ships with today — no value is recomputed, no [Ref]
/// is needed. A future remote impl swaps in behind the same provider.
class LocalStudioConfigRepository implements StudioConfigRepository {
  const LocalStudioConfigRepository();

  @override
  StudioConfigPointer published() => StudioConfigPointer.bundled;

  /// The bundled published tree — [ConfigLayer.empty] ⇒ the merge yields
  /// identity ⇒ byte-identical to today. (Re-declared, not inherited: this class
  /// `implements` the interface, so the default body isn't inherited.)
  @override
  ConfigLayer publishedTree() => StudioConfigPointer.bundled.tree;

  /// No live push on the local path — the bundled default is static.
  @override
  Listenable? get changes => null;
}

/// The Studio-config repository provider — the server-ready seam the Studio
/// eventually reads through, and the Firestore impl (steps 55-59) swaps in
/// behind. DORMANT (step 54): the `_firebase` branch activates ONLY when the
/// Studio-live flag AND the live backend are BOTH on `(kStudioLive &&
/// useFirebaseBackend)`; with either OFF (the default) it returns the const
/// local impl — the bundled config tree — so the build is BYTE-IDENTICAL to
/// today. Mirrors `stockRepositoryProvider` (the attach/onDispose shape) +
/// `catalogRepositoryProvider` (`catalog_local.dart`) with the extra flag gate.
final studioConfigRepositoryProvider = Provider<StudioConfigRepository>((ref) {
  if (kStudioLive && useFirebaseBackend) {
    final repo = FirebaseStudioConfigRepository()..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return const LocalStudioConfigRepository();
});
