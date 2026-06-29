// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 8 — the edit-mode governance gate (#84).
//
// [EditModeController] is the ONE place that can turn live editing on. It flips
// `isEditing` to true ONLY when ALL THREE hold:
//   1. the Studio is ACTIVE   — `studioActiveProvider` (compile `kStudioFlag` OR
//                               the owner-staged runtime `kStudio` flag);
//   2. the identity is the OWNER — `isOwnerEmail(studioOwnerEmailProvider)` (the
//                               real Google email — un-spoofable, the #84 anchor);
//   3. a MANAGER context      — `studioInManagerContextProvider`.
// For anyone else the controller is inert FOREVER (enter() is a no-op) ⇒ with the
// flag OFF (default) the whole Studio is answer-equivalent / zero-regression.
//
// SPEC CORRECTION (read-don't-guess, vs detail/001-015.md:154):
//   • the spec wrote `isOwnerEmail(session.email)`, but `BoardSession`
//     (board_auth.dart:28) has NO `email` field — the real owner email is
//     `authStateProvider.user?.email` (AuthUser.email, auth_state.dart:77), which
//     is exactly what the live manager gate already uses (welcome_screen.dart:362).
//   • the spec checked ONLY `roleKeyOf(roleProvider)=='manager'`, but the REAL
//     owner manager mode is the authenticated board session
//     `boardAuthProvider.role == BoardRole.manager` (set by `loginManagerViaGoogle`,
//     board_auth.dart:291) — a `roleProvider`-only check would NEVER open in the
//     real owner flow. We accept EITHER the board manager session OR the manager
//     persona (both ARE "the management screen"), AND-ed behind the un-spoofable
//     owner-email guard, so the superset stays safe.
//
// The three gate inputs are exposed as thin derived providers so (a) step 20's
// manager row can read them and (b) tests can override them without standing up a
// fake AuthGateway / BoardAuthNotifier.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/board_accounts_local.dart' show isOwnerEmail;
import 'package:buildsmart/state/auth_state.dart'
    show authStateProvider, roleProvider;
import 'package:buildsmart/state/board_auth.dart'
    show BoardRole, boardAuthProvider;
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:buildsmart/state/studio/config_merge.dart' show roleKeyOf;
import 'package:buildsmart/state/studio/studio_flags.dart'
    show kStudioFlag, kStudioFlagName;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Studio active = the compile gate `kStudioFlag` OR the owner-staged runtime
/// `kStudio` flag. The single source of truth read by the gate AND by the manager
/// UI (step 20). Watches [featureFlagsProvider] so toggling the runtime flag off
/// mid-session rebuilds it (→ the gate revalidates).
final studioActiveProvider = Provider<bool>(
  (ref) =>
      kStudioFlag || ref.watch(featureFlagsProvider).contains(kStudioFlagName),
);

/// The spec's `studioActive(ref)` — a convenience for non-widget callers; reads
/// [studioActiveProvider].
bool studioActive(Ref ref) => ref.read(studioActiveProvider);

/// The current signed-in email (the real Google identity), or null. The #84
/// owner-gate reads this; derived from [authStateProvider] so it tracks
/// login/logout live, and thin enough to override in a test.
final studioOwnerEmailProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).user?.email,
);

/// True when the viewer is in a MANAGER context — EITHER the real authenticated
/// owner board (`boardAuthProvider.role == BoardRole.manager`) OR the manager
/// persona (`roleProvider == 'manager'`, via the canonical [roleKeyOf]). Both are
/// "the management screen"; the owner-email guard keeps the superset safe.
final studioInManagerContextProvider = Provider<bool>((ref) {
  final boardRole = ref.watch(boardAuthProvider)?.role;
  final persona = roleKeyOf(ref.watch(roleProvider));
  return boardRole == BoardRole.manager || persona == 'manager';
});

/// Auto-exit guard (footgun defence, spec 8.10): the owner must not be left in
/// edit-mode in front of a customer. Wired to an inactivity timer in a later step.
const int kEditModeAutoExitMinutes = 10;

/// One enter/exit edit-mode audit entry (#84 audit trail, spec 8.9). In-memory in
/// v1; a later publish/audit step persists it.
@immutable
class EditAudit {
  const EditAudit(this.action, this.email, this.atMs);

  /// `'enter'` | `'exit'`.
  final String action;
  final String? email;
  final int atMs;
}

/// Immutable edit-mode state. Default = [inert] (everything off) ⇒ zero-regression.
@immutable
class EditModeState {
  const EditModeState({
    this.isEditing = false,
    this.previewDraft = false,
    this.selectedId,
  });

  /// `true` while the owner is editing live.
  final bool isEditing;

  /// `true` ⇒ resolved nodes include the unpublished draft (owner sees WIP live).
  /// Tracks [isEditing]. This is the seam step 7's `resolvedNodeProvider` reads.
  final bool previewDraft;

  /// The element id currently selected for inline editing, or null.
  final String? selectedId;

  /// The permanent off-state — what every non-owner session is pinned to.
  static const EditModeState inert = EditModeState();

  EditModeState copyWith({
    bool? isEditing,
    bool? previewDraft,
    String? selectedId,
    bool clearSelected = false,
  }) =>
      EditModeState(
        isEditing: isEditing ?? this.isEditing,
        previewDraft: previewDraft ?? this.previewDraft,
        selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
      );

  @override
  bool operator ==(Object other) =>
      other is EditModeState &&
      other.isEditing == isEditing &&
      other.previewDraft == previewDraft &&
      other.selectedId == selectedId;

  @override
  int get hashCode => Object.hash(isEditing, previewDraft, selectedId);
}

/// The #84 gate. Flips edit-mode on ONLY for owner + manager-context + active;
/// inert for everyone else. Resets itself the instant any gate input stops
/// qualifying (see [editModeProvider]'s listeners).
class EditModeController extends StateNotifier<EditModeState> {
  EditModeController(this._ref) : super(EditModeState.inert);

  final Ref _ref;
  final List<EditAudit> _audit = <EditAudit>[];

  /// Read-only #84 audit trail of enter/exit events (in-memory, v1).
  List<EditAudit> get auditLog => List.unmodifiable(_audit);

  /// All three gate conditions, evaluated fresh (point-in-time) on every flip.
  bool get _gateOpen =>
      _ref.read(studioActiveProvider) &&
      isOwnerEmail(_ref.read(studioOwnerEmailProvider)) &&
      _ref.read(studioInManagerContextProvider);

  /// True iff the current identity MAY edit — exposed for the manager UI (step 20)
  /// so the "🎨 סטודיו" toggle renders for the owner only.
  bool get canEdit => _gateOpen;

  /// Turn editing on. No-op for anyone who fails the gate (#84) and idempotent.
  void enterEdit() {
    if (!_gateOpen) return; // inert for non-owner / non-manager / flag-off
    if (state.isEditing) return; // idempotent
    state = state.copyWith(isEditing: true, previewDraft: true);
    _log('enter');
  }

  /// Turn editing off and clear selection + preview.
  void exitEdit() {
    if (state == EditModeState.inert) return; // already off
    final wasEditing = state.isEditing;
    state = EditModeState.inert;
    if (wasEditing) _log('exit');
  }

  /// Toggle — the manager "🎨 סטודיו" row (step 20). Still gated: enterEdit() is a
  /// no-op for non-owners, so a stray toggle can never leak edit-mode.
  void toggleEdit() => state.isEditing ? exitEdit() : enterEdit();

  /// Select an element for inline editing (no-op outside edit-mode). `null` clears.
  void select(String? id) {
    if (!state.isEditing) return;
    state = id == null
        ? state.copyWith(clearSelected: true)
        : state.copyWith(selectedId: id);
  }

  /// Re-check the gate after an identity / context / flag change and drop
  /// edit-mode the instant the caller no longer qualifies (logout, persona/board
  /// switch, flag off). Wired to the gate inputs in [editModeProvider]. #84:
  /// edit-mode must NEVER survive into a non-owner / non-manager session.
  void revalidate() {
    if (state.isEditing && !_gateOpen) exitEdit();
  }

  void _log(String action) {
    _audit.add(
      EditAudit(
        action,
        _ref.read(studioOwnerEmailProvider),
        DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

/// The edit-mode controller. Listens to the THREE gate inputs and revalidates on
/// any change, so edit-mode dies immediately on logout / persona-or-board switch /
/// flag-off (#84).
final editModeProvider =
    StateNotifierProvider<EditModeController, EditModeState>((ref) {
  final controller = EditModeController(ref);
  ref
    ..listen<bool>(studioActiveProvider, (_, __) => controller.revalidate())
    ..listen<String?>(
      studioOwnerEmailProvider,
      (_, __) => controller.revalidate(),
    )
    ..listen<bool>(
      studioInManagerContextProvider,
      (_, __) => controller.revalidate(),
    );
  return controller;
});
