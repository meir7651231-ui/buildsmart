// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 13 — the always-mounted Studio overlay.
//
// One line in main.dart's builder Stack, beside ConnectionIndicator. OFF-gate
// (Studio inactive OR not editing) it builds `SizedBox.shrink()`: inert, zero
// pointer-area, answer-equivalent — the proven ConnectionIndicator always-mounted-
// inert pattern (and with `kStudioFlag` const-OFF it tree-shakes away entirely).
// ON-gate it shows the owner's "מצב עריכה" banner with the live draft count, a
// "פרסם" button (publish the in-place edits to ALL users, behind a confirm), and
// an exit button. The per-element tap→inline-editor is wired in [EditHandle].
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_store.dart'
    show configStoreProvider;
import 'package:buildsmart/state/studio/edit_mode.dart'
    show editModeProvider, studioActiveProvider, studioOwnerEmailProvider;
import 'package:buildsmart/state/studio/element_registry.dart'
    show criticalIdsProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:buildsmart/widgets/toast.dart' show showGlobalToast;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Floats above every screen; inert until the owner enters edit-mode.
class StudioOverlay extends ConsumerWidget {
  const StudioOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(studioActiveProvider);
    final editing = ref.watch(editModeProvider.select((s) => s.isEditing));
    if (!active || !editing) return const SizedBox.shrink();
    final draftCount =
        ref.watch(configStoreProvider.select((d) => d.draftNodeCount));

    return Positioned(
      top: MediaQuery.of(context).padding.top + 4,
      left: 8,
      right: 8,
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: BsTokens.brand,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 14, end: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  draftCount > 0 ? '✏️ עריכה · $draftCount' : '✏️ מצב עריכה',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: BsTokens.typeCaption,
                  ),
                ),
                if (draftCount > 0)
                  TextButton(
                    onPressed: () => _publish(ref),
                    child: const Text(
                      'פרסם',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () =>
                      ref.read(editModeProvider.notifier).exitEdit(),
                  child: const Text(
                    'צא',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Publish the in-place draft to ALL users. The overlay lives in
  /// `MaterialApp.builder` (ABOVE the Navigator), so it must NOT use
  /// `showDialog` / `ScaffoldMessenger.of(context)` — there is no Navigator in
  /// this context and the call fails silently ("פרסם does nothing"). We publish
  /// directly (the button is deliberate + a publish is reversible via history)
  /// and confirm with the CONTEXT-FREE [showGlobalToast] (served through the root
  /// `bsMessengerKey`, which is always mounted).
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
