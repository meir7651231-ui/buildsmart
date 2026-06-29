// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 11 — CfgAction (behavior wrapper / seam).
//
// `cfgAction(ref, id, fallback)` resolves the effective tap for an element. v1: the
// action-override REGISTRY is Pillar-4 (the behavior builder), so an override may be
// recorded but the original [fallback] ALWAYS wins (a safe, documented fallthrough —
// an unknown kind must never swallow the real action). The seam exists so call sites
// adopt `onTap: cfgAction(ref, id, original)` NOW and gain owner-rerouting later
// without another migration.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_store.dart'
    show resolvedNodeProvider;
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The effective tap for [id]: today always [fallback]. Watches the action override
/// so the consuming widget rebuilds when Pillar-4 begins interpreting it.
VoidCallback? cfgAction(WidgetRef ref, String id, VoidCallback? fallback) {
  final action = ref.watch(resolvedNodeProvider(id).select((n) => n.action));
  if (action == null) return fallback;
  // Pillar-4 interprets `action.kind` via the action registry; until then an
  // override is inert and the original behavior wins (the documented fallthrough).
  return fallback;
}
