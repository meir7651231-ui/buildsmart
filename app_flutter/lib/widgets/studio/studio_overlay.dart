// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 13 — the always-mounted Studio chrome.
//
// UN-FROZEN (edit-trigger directive · owner-approved 2026-07-28). The slice-0
// freeze removed the on-screen edit chrome because the נווט⇄ערוך toggle / board
// selector had no good UNIVERSAL trigger location (screens like site-management
// have no fixed logo). The trigger now lives on the app-global KEYBOARD FAB
// (long-press → toggleEdit, in main.dart's `_GlobalKeyboardOverlay`) — which
// floats on EVERY screen — so this overlay no longer hosts a trigger at all.
// Its ONLY job now: while the owner is in live edit-mode, light a single ✎
// (pencil) button just above the cart-FAB — the "editing is live" indicator +
// a one-tap exit. NO banner, NO top toolbar (that was the confusing part the
// directive removes).
//
// 🛡️ SAFETY — byte-identical, three nested gates (outermost first):
//   1. `kStudioFlag` (compile const) — FALSE on production ⇒ the whole build body
//      tree-shakes away and this widget IS `const SizedBox.shrink()`, BYTE-
//      IDENTICAL to the slice-0 freeze. The ✎ exists ONLY on the STUDIO build.
//   2. `studioCanEditProvider` (#84 owner gate, un-spoofable) — non-owner ⇒ shrink.
//   3. `isEditing` — the ✎ shows ONLY while edit-mode is actually on.
// Still ALWAYS-MOUNTED (main.dart's builder Stack is untouched) — the proven
// ConnectionIndicator always-mounted-inert pattern; re-freezing is a localized
// revert. It is a bare Stack child ABOVE the Navigator, so the ✎ is a self-
// contained Material+InkWell (no Tooltip/Hero/Overlay.of that would need an
// Overlay ancestor), and its Align leaves the rest of the screen click-through.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/keyboard_screen_tools.dart'
    show keyboardScreenToolsProvider;
import 'package:buildsmart/state/studio/edit_mode.dart'
    show editModeProvider, studioCanEditProvider;
import 'package:buildsmart/state/studio/studio_flags.dart' show kStudioFlag;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:buildsmart/widgets/toast.dart' show bsNavigatorKey;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// HomeShell bottom-nav height — the ✎ lifts by this (only when no route is
/// pushed) to clear the nav, exactly like the keyboard FAB's navOffset (main.dart).
const double _kHomeNavHeight = 58;

/// Always mounted; inert unless the owner is in live edit-mode on the STUDIO build.
/// Shows a single ✎ above the cart-FAB — the active-edit indicator + one-tap exit.
/// (The edit TRIGGER is the keyboard-FAB long-press; see `_GlobalKeyboardOverlay`.)
class StudioOverlay extends ConsumerWidget {
  const StudioOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gate 1 — compile const. Production (STUDIO unset) tree-shakes everything
    // below ⇒ this IS `const SizedBox.shrink()`, byte-identical to slice-0.
    if (!kStudioFlag) return const SizedBox.shrink();
    // Gate 2 — #84 owner gate (un-spoofable). Non-owner ⇒ nothing at all.
    if (!ref.watch(studioCanEditProvider)) return const SizedBox.shrink();
    // Gate 3 — only while editing. The ✎ IS the "edit is live" light.
    if (!ref.watch(editModeProvider.select((s) => s.isEditing))) {
      return const SizedBox.shrink();
    }

    // Lift above the HomeShell bottom-nav ONLY when no full-screen route is pushed
    // (a pushed route has no nav) — mirrors `_GlobalKeyboardOverlay`'s navOffset so
    // the ✎ tracks the cart-FAB's corner on every route. Watch the tool stack so
    // this rebuilds on push/pop.
    ref.watch(keyboardScreenToolsProvider);
    final routePushed = bsNavigatorKey.currentState?.canPop() ?? false;
    final navOffset = routePushed ? 0.0 : _kHomeNavHeight;

    // Same bottom-END corner as the cart-FAB (Scaffold endFloat → bottom-LEFT under
    // RTL), lifted clear ABOVE it: 16 (cart-FAB bottom margin) + 56 (cart-FAB) + 28
    // gap. The 28 (not 12) budgets for the cart's count-badge, which overhangs ~10px
    // above the FAB (Positioned top:-10) — a 12px gap left only ~2px above the badge.
    // Only the ✎ is hit-testable; the Align's empty area is click-through below.
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            end: 16,
            bottom: navOffset + 16 + 56 + 28,
          ),
          child: Material(
            color: BsTokens.brand,
            elevation: 4,
            shape: const CircleBorder(
              side: BorderSide(color: Colors.white, width: 2),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              // Tap the active ✎ to exit edit-mode (the second exit, alongside a
              // second long-press on the keyboard FAB). Gated already by reaching
              // here (owner + editing), and toggleEdit is itself a #84 no-op for
              // anyone who slips past.
              onTap: () => ref.read(editModeProvider.notifier).toggleEdit(),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.edit, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
