// ─────────────────────────────────────────────────────────────────────────────
// co_editor_gate — Studio Pillar 4 · step 80. The SINGLE gate for the
// manager-only Studio CO-EDITOR. It separates three INDEPENDENT axes so each
// concern is decided in exactly one place (step 81's cockpit hero/route read all
// three from here). DORMANT: no `lib/` file watches this provider yet, so with
// [kStudioCoEditor] OFF the whole gate tree-shakes out → the shipped build is
// byte-identical to today (the same zero-regression invariant as `claudeGateway
// Provider`). Pure/provider-only — zero widget, zero I/O.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart'
    show kStudioCoEditor, useFirebaseBackend;
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/state/board_auth.dart'
    show BoardRole, boardAuthProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The three-axis gate for the manager-only Studio co-editor. Each axis answers
/// one INDEPENDENT question, deliberately NOT conflated (step 80 §4/§8/§9):
///   • `enabled` — is the co-editor pillar itself live? The [kStudioCoEditor]
///     build-flag ANDed with the live backend ([useFirebaseBackend]). Default
///     OFF → false (mirrors [useCatalogServerSearch]); the demo/test build never
///     activates it, and with no consumer the whole gate tree-shakes away
///     (byte-identical).
///   • `ai` — is the Claude gateway bound? (`claudeGatewayProvider != null`.) A
///     DISTINCT axis from `enabled`: pillar-on / gateway-off is a LEGAL state —
///     the manual builder still works and the co-editor shows an honest
///     "requires connection" off-state — so the two are never merged.
///   • `manager` — is the current board session a manager?
///     (`boardAuthProvider?.role == BoardRole.manager`.) The manager-only guard
///     centralised here so step 81's hero/route read it from one source.
///
/// A record (not a class) so the reader destructures the axis it needs
/// (`final (:enabled, :ai, :manager) = ref.watch(studioCoEditorProvider);`).
final studioCoEditorProvider =
    Provider<({bool enabled, bool ai, bool manager})>((ref) {
  final enabled = kStudioCoEditor && useFirebaseBackend;
  final ai = ref.watch(claudeGatewayProvider) != null;
  final manager = ref.watch(boardAuthProvider)?.role == BoardRole.manager;
  return (enabled: enabled, ai: ai, manager: manager);
});
