// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 13 — the always-mounted Studio chrome.
//
// One line in main.dart's builder Stack, beside ConnectionIndicator. OFF-gate
// (Studio INACTIVE) it builds `SizedBox.shrink()`: inert, zero pointer-area,
// answer-equivalent — the proven ConnectionIndicator always-mounted-inert pattern
// (and with `kStudioFlag` const-OFF it tree-shakes away entirely).
//
// ON-gate (Studio ACTIVE) it shows a PERSISTENT chrome pill giving the owner the
// TWO navigation levels needed to work freely and never be trapped by edit-mode
// (directive "wizard = the studio", slice-0):
//   1. a clear נווט⇄ערוך toggle — DEFAULT "נווט" (edit OFF) ⇒ every tap is normal
//      navigation (open sheets, enter workflows, reach every sub-screen). "ערוך"
//      arms the per-element tap→inline-editor ([EditHandle]). Gated on
//      [studioCanEditProvider] (#84 owner gate) so a non-owner can never flip it.
//   2. a board selector — reuses the app's own [showRolePicker] (👷 קבלן · 👔 מנהל ·
//      🏪 חנות · 🛵 שליח · 🦺 עובד), pushed through the root navigator, so it lives
//      OUTSIDE the edit-trap (above the Navigator) and the owner is never stranded
//      on one screen. Only in the STUDIO/preview build (`kStudioFlag`), where the
//      root `navigatorKey` is wired (main.dart) — else hidden.
// In edit-mode it also shows the live draft count + "פרסם" (publish to all users).
// The per-element tap→inline-editor itself is wired in [EditHandle].
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/screens/role_picker_sheet.dart' show showRolePicker;
import 'package:buildsmart/state/studio/config_store.dart'
    show configStoreProvider;
import 'package:buildsmart/state/studio/edit_mode.dart'
    show
        editModeProvider,
        studioActiveProvider,
        studioCanEditProvider,
        studioOwnerEmailProvider;
import 'package:buildsmart/state/studio/element_registry.dart'
    show criticalIdsProvider;
import 'package:buildsmart/state/studio/studio_flags.dart' show kStudioFlag;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:buildsmart/widgets/toast.dart'
    show bsNavigatorKey, showGlobalToast;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Floats above every screen; a slim persistent chrome once the Studio is active.
class StudioOverlay extends ConsumerWidget {
  const StudioOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(studioActiveProvider);
    if (!active) return const SizedBox.shrink(); // off-gate ⇒ answer-equivalent

    final editing = ref.watch(editModeProvider.select((s) => s.isEditing));
    final canEdit = ref.watch(studioCanEditProvider);
    final draftCount = editing
        ? ref.watch(configStoreProvider.select((d) => d.draftNodeCount))
        : 0;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 4,
      left: 8,
      right: 8,
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          elevation: 6,
          shadowColor: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Board selector — reuses the app's role picker, pushed through
                // the root navigator (wired only when kStudioFlag), so it works
                // from above the Navigator and OUTSIDE the edit-trap.
                if (kStudioFlag) ...[
                  _ChromeButton(
                    icon: '🔀',
                    label: 'בורד',
                    onTap: _openBoardPicker,
                  ),
                  const _ChromeDivider(),
                ],
                // נווט ⇄ ערוך — default "נווט"; disabled for a non-owner (#84).
                _NavEditToggle(editing: editing, enabled: canEdit),
                if (editing && draftCount > 0) ...[
                  const _ChromeDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '✏️ $draftCount',
                      style: const TextStyle(
                        color: BsTokens.brandDark,
                        fontWeight: FontWeight.w800,
                        fontSize: BsTokens.typeCaption,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _publish(ref),
                    style: TextButton.styleFrom(
                      foregroundColor: BsTokens.brand,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'פרסם',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Open the app's own persona/board picker through the ROOT navigator (the
  /// overlay is above the Navigator, so it has no Navigator in its own context).
  /// `bsNavigatorKey` is wired in main.dart under `kStudioFlag`; a null context
  /// (never, in the preview build) is a safe no-op.
  void _openBoardPicker() {
    final ctx = bsNavigatorKey.currentContext;
    if (ctx != null) showRolePicker(ctx);
  }

  /// Publish the in-place draft to ALL users. The overlay lives in
  /// `MaterialApp.builder` (ABOVE the Navigator), so it must NOT use `showDialog`
  /// / `ScaffoldMessenger.of(context)` — there is no Navigator in this context.
  /// We publish directly (a publish is reversible via history) and confirm with
  /// the CONTEXT-FREE [showGlobalToast] (root `bsMessengerKey`, always mounted).
  void _publish(WidgetRef ref) {
    if (ref.read(configStoreProvider).draftNodeCount == 0) return;
    final published = ref.read(configStoreProvider.notifier).publish(
          note: 'עריכה בחי',
          byEmail: ref.read(studioOwnerEmailProvider) ?? '',
          nowMs: DateTime.now().millisecondsSinceEpoch,
          criticalIds: ref.read(criticalIdsProvider),
        );
    showGlobalToast(
      published ? 'פורסם לכל המשתמשים ✓' : 'אין שינויים לפרסום',
    );
  }
}

/// The load-bearing נווט⇄ערוך toggle. Default "נווט" (edit OFF) ⇒ the app is fully
/// usable; "ערוך" arms the per-element inline editor. Disabled (null callback) for
/// a non-owner so a stray tap can never leak edit-mode (#84 defence-in-depth —
/// enterEdit is itself gated, this only greys the control).
class _NavEditToggle extends ConsumerWidget {
  const _NavEditToggle({required this.editing, required this.enabled});

  final bool editing;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      segments: const [
        ButtonSegment<bool>(
          value: false,
          label: Text('נווט'),
          icon: Icon(Icons.touch_app_outlined, size: 15),
        ),
        ButtonSegment<bool>(
          value: true,
          label: Text('ערוך'),
          icon: Icon(Icons.edit_outlined, size: 15),
        ),
      ],
      selected: {editing},
      onSelectionChanged: !enabled
          ? null
          : (sel) {
              final n = ref.read(editModeProvider.notifier);
              if (sel.first) {
                n.enterEdit();
              } else {
                n.exitEdit();
              }
            },
    );
  }
}

/// A compact icon+label button for the chrome pill (board selector).
class _ChromeButton extends StatelessWidget {
  const _ChromeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Text(icon, style: const TextStyle(fontSize: 15)),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: BsTokens.typeCaption,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: BsTokens.inkLight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// A thin vertical separator between chrome controls.
class _ChromeDivider extends StatelessWidget {
  const _ChromeDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: BsTokens.surfaceMid,
      );
}
