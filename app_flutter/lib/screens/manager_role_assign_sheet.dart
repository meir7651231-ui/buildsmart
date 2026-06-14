// ─────────────────────────────────────────────────────────────────────────────
// manager_role_assign_sheet — A12 (launch Phase A): the MANAGER UI that assigns
// a role to a user, the in-app call-site of the `setRole` callable seam.
//
// WHY THIS EXISTS (SPEC launch Phase A, row A12):
//   S1.9 landed the seam — `AuthStateNotifier.assignRole({uid, role})` forwards
//   `{uid, role}` to the `setRole` Cloud Function (auth_state.dart), and A7
//   landed the directory — `UsersLookup.uidByPhone` translates a counterparty's
//   PHONE into their `auth.uid` (users_lookup.dart). Until now both were only
//   reachable programmatically. This sheet is the missing surface: a manager
//   looks a user up by phone (→ uid via [UsersLookup]) — or pastes a uid — picks
//   a role, and the assignment forwards through the existing `assignRole` seam.
//   The TARGET user sees the new role on their next token refresh / sign-in.
//
// HARD RULES (mirroring every other launch seam):
//   1. NO faked success. The real effect needs the live callable backend
//      (`setRole`, deployed to the owner's Functions project — see
//      functions/src/index.ts). Without it ([authGatewayProvider] is null —
//      the SAME `useFirebaseBackend` gate the repos use), the sheet does NOT
//      pretend: the action is DISABLED and a clear Hebrew banner explains the
//      assignment is owner/backend-gated. If the seam is somehow reached
//      anyway, its `unavailable` throw is caught and surfaced — never a
//      "success" toast.
//   2. SELF-CONTAINED. All logic lives here; the manager ניהול tab mounts it
//      with a single button (manager_dashboard_screen.dart), so the parallel
//      edit to that screen has the smallest possible conflict surface.
//   3. ADDITIVE. Nothing here changes an existing flow; it only EXPOSES the
//      already-shipped assignRole + UsersLookup seams behind a manager gesture.
//
// The verification is server-side: `setRole` checks the CALLER's admin claim
// before writing the target's claim. This UI does not (cannot) grant itself
// permission — a non-admin caller's call is rejected by the Function and the
// rejection is surfaced as a failure toast, exactly like any other failure.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:buildsmart/data/repositories/users_lookup.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/telemetry.dart';
import 'package:buildsmart/theme/app_theme.dart' show bsOnAccent;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One assignable role — the claim id the `setRole` callable + `rolesFromClaims`
/// (auth_state.dart) key on, paired with its verbatim Hebrew label (the persona
/// titles from `data/personas.dart` / `kBoardDemoNames`). `contractor` is the
/// default/no-role identity and is NOT assignable here (a manager assigns a
/// SPECIAL role; clearing back to contractor is not part of A12).
@immutable
class RoleOption {
  const RoleOption(this.id, this.emoji, this.label);

  final String id;
  final String emoji;
  final String label;
}

/// The roles a manager can assign — store / courier / worker / manager (the
/// task's known set), verbatim emoji + Hebrew labels.
const List<RoleOption> kAssignableRoles = [
  RoleOption('store', '🏪', 'חנות ספק'),
  RoleOption('courier', '🛵', 'שליח'),
  RoleOption('worker', '🦺', 'עובד'),
  RoleOption('manager', '👔', 'מנהל המערכת'),
];

/// Open the role-assignment sheet (the manager ניהול tab's hook calls this).
/// A modal bottom sheet, RTL, LIGHT — matching the manager dashboard's other
/// sheets (`showModalBottomSheet` + `Directionality` + `cardLight`).
Future<void> showManagerRoleAssignSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: BsTokens.cardLight,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
    ),
    builder: (sheetCtx) => const Directionality(
      textDirection: TextDirection.rtl,
      child: ManagerRoleAssignSheet(),
    ),
  );
}

/// The A12 role-assignment sheet body. A manager types a user's PHONE (looked
/// up to a uid via [usersLookupProvider]) — or pastes a uid directly — picks a
/// [RoleOption], and taps שייך תפקיד, which forwards `{uid, role}` through the
/// existing `assignRole` seam ([authStateProvider]'s notifier). Success/failure
/// surface as Hebrew toasts. With no live backend the action is disabled and a
/// banner explains the feature is owner/backend-gated (HARD RULE #1).
class ManagerRoleAssignSheet extends ConsumerStatefulWidget {
  const ManagerRoleAssignSheet({super.key});

  @override
  ConsumerState<ManagerRoleAssignSheet> createState() =>
      _ManagerRoleAssignSheetState();
}

class _ManagerRoleAssignSheetState
    extends ConsumerState<ManagerRoleAssignSheet> {
  final _phoneCtrl = TextEditingController();
  final _uidCtrl = TextEditingController();

  /// The picked role id (null = none picked yet → the action stays disabled).
  String? _roleId;

  /// In-flight guard — disables the action + shows a spinner while the lookup /
  /// callable round-trips, so a double-tap can't fire two assignments.
  bool _busy = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _uidCtrl.dispose();
    super.dispose();
  }

  /// The assignment gesture. Resolves the target uid (an explicitly pasted uid
  /// wins; otherwise the phone is translated via [UsersLookup.uidByPhone]),
  /// then forwards `{uid, role}` through the `assignRole` seam. Every branch
  /// gives the manager a clear Hebrew toast; only a seam call that COMPLETES
  /// without throwing is reported as success (HARD RULE #1 — no faked success).
  Future<void> _assign() async {
    final roleId = _roleId;
    if (roleId == null || _busy) return;

    // Resolve the uid: a pasted uid is authoritative; else look up by phone.
    final typedUid = _uidCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (typedUid.isEmpty && phone.isEmpty) {
      showToast(context, 'הזן מספר טלפון או מזהה משתמש (uid).');
      return;
    }

    setState(() => _busy = true);
    try {
      var uid = typedUid;
      if (uid.isEmpty) {
        // Phone → uid through the A7 directory. Null when no live backend
        // (the provider is null) OR no users doc carries that phone.
        final lookup = ref.read(usersLookupProvider);
        if (lookup == null) {
          if (mounted) {
            showToast(context, _kNoBackendMessage);
          }
          return;
        }
        final resolved = await lookup.uidByPhone(phone);
        if (resolved == null) {
          if (mounted) {
            showToast(context, 'לא נמצא משתמש עם הטלפון $phone.');
          }
          return;
        }
        uid = resolved;
      }

      // Forward {uid, role} through the EXISTING seam (S1.9). On a
      // Firebase-free run the notifier throws `unavailable` — caught below and
      // surfaced as the owner/backend-gated message, NOT as success.
      await ref
          .read(authStateProvider.notifier)
          .assignRole(uid: uid, role: roleId);

      // G4 — key funnel event: a manager assigned a server role. Reached only
      // on a real (non-throwing) assignment, so it always has a live backend;
      // the sink forwards to FirebaseAnalytics when Firebase is up, else no-op.
      // The uid is NOT logged (PII) — only the assigned role.
      ref.read(telemetryProvider).logEvent(
        TelemetryEvents.roleAssigned,
        params: {'role': roleId},
      );

      if (!mounted) return;
      final label = _labelFor(roleId);
      showToast(context, '✅ התפקיד "$label" שויך למשתמש $uid.');
      unawaited(Navigator.of(context).maybePop());
    } on AuthGatewayException catch (e) {
      if (!mounted) return;
      // `unavailable` = no live backend (the gateway is null); anything else is
      // a real server-side rejection (e.g. the caller is not an admin, or the
      // Function errored). Both are HONEST failures — never a success toast.
      showToast(
        context,
        e.code == 'unavailable'
            ? _kNoBackendMessage
            : 'שיוך התפקיד נכשל (${e.code}). נסה שוב מאוחר יותר.',
      );
    } on Object catch (e, st) {
      // G4 — generic handled-error breadcrumb (Crashlytics + an `app_error`
      // analytics event), tagged with a stable context label (never raw user
      // data). No-op when Firebase is absent → demo path unchanged.
      ref.read(telemetryProvider).logError(e, st, where: 'role_assign');
      if (!mounted) return;
      showToast(context, 'שיוך התפקיד נכשל. נסה שוב מאוחר יותר. ($e)');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _labelFor(String roleId) {
    for (final r in kAssignableRoles) {
      if (r.id == roleId) return r.label;
    }
    return roleId;
  }

  @override
  Widget build(BuildContext context) {
    // The seam that does the work is the auth gateway; it is null exactly when
    // there is no live backend (the `useFirebaseBackend` gate). That is the
    // single source of truth for the no-backend gate — when null, the action is
    // disabled and the banner explains why (HARD RULE #1).
    final hasBackend = ref.watch(authGatewayProvider) != null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('🔑', style: TextStyle(fontSize: 34), textAlign: TextAlign.center),
            const SizedBox(height: BsTokens.space2),
            const Text(
              'שיוך תפקיד למשתמש',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'אתר משתמש לפי טלפון (או הדבק מזהה uid) ובחר תפקיד להקצאה.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
            const SizedBox(height: BsTokens.space4),

            if (!hasBackend) ...[
              const _NoBackendBanner(),
              const SizedBox(height: BsTokens.space4),
            ],

            // The user lookup: phone (primary) + an optional explicit uid.
            TextField(
              key: const ValueKey('role-assign-phone'),
              controller: _phoneCtrl,
              enabled: hasBackend && !_busy,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: _fieldDecoration('טלפון המשתמש', '050-1234567'),
            ),
            const SizedBox(height: BsTokens.space3),
            TextField(
              key: const ValueKey('role-assign-uid'),
              controller: _uidCtrl,
              enabled: hasBackend && !_busy,
              textDirection: TextDirection.ltr,
              decoration: _fieldDecoration('מזהה משתמש (uid) — אופציונלי', 'uid'),
            ),
            const SizedBox(height: BsTokens.space4),

            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'תפקיד',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space2),
            Wrap(
              spacing: BsTokens.space2,
              runSpacing: BsTokens.space2,
              children: [
                for (final r in kAssignableRoles)
                  _RoleChip(
                    option: r,
                    selected: _roleId == r.id,
                    enabled: hasBackend && !_busy,
                    onTap: () => setState(() => _roleId = r.id),
                  ),
              ],
            ),
            const SizedBox(height: BsTokens.space5),

            _AssignButton(
              // Enabled only with a live backend, a picked role, and not busy.
              enabled: hasBackend && _roleId != null && !_busy,
              busy: _busy,
              onPressed: _assign,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        hintTextDirection: TextDirection.ltr,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
}

/// The verbatim no-backend message — shared by the banner and every toast so
/// the wording is identical wherever the gate is hit.
const String _kNoBackendMessage =
    'שיוך תפקידים זמין רק עם חיבור לשרת (מופעל ע״י בעל המערכת). '
    'לא בוצע שיוך.';

/// The disabled-state banner (no live backend) — a soft amber panel making it
/// unambiguous that NO assignment happens here without the owner's backend.
class _NoBackendBanner extends StatelessWidget {
  const _NoBackendBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFF2A516)),
      ),
      child: const Text(
        '⚠️ $_kNoBackendMessage',
        style: TextStyle(
          color: Color(0xFF8A5A00),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }
}

/// One selectable role chip — a `brand` fill when selected, a light outline
/// otherwise; disabled (muted, no tap) when there is no backend / a call is in
/// flight. Keyed `role-chip-<id>` so a test can tap a specific role.
class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final RoleOption option;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${option.emoji} ${option.label}',
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Material(
          color: selected ? BsTokens.brand : BsTokens.cardLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          child: InkWell(
            key: ValueKey('role-chip-${option.id}'),
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            onTap: enabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                border:
                    selected ? null : Border.all(color: const Color(0xFFE2E2E2)),
              ),
              child: Text(
                '${option.emoji} ${option.label}',
                style: TextStyle(
                  color: selected ? bsOnAccent(context) : BsTokens.inkLight,
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The full-width שייך תפקיד action — a `brand` pill (disabled grey when the
/// form is incomplete / there is no backend), a spinner while busy. Keyed
/// `role-assign-submit` for tests.
class _AssignButton extends StatelessWidget {
  const _AssignButton({
    required this.enabled,
    required this.busy,
    required this.onPressed,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? BsTokens.brand : const Color(0xFFE2E2E2),
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        key: const ValueKey('role-assign-submit'),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: enabled ? onPressed : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: busy
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Text(
                  'שייך תפקיד',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: enabled ? bsOnAccent(context) : BsTokens.mutedLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
