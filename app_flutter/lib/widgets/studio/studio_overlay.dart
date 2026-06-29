// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 13 — the always-mounted Studio overlay.
//
// One line in main.dart's builder Stack, beside ConnectionIndicator. OFF-gate
// (Studio inactive OR not editing) it builds `SizedBox.shrink()`: inert, zero
// pointer-area, answer-equivalent — the proven ConnectionIndicator always-mounted-
// inert pattern (and with `kStudioFlag` const-OFF it tree-shakes away entirely).
// ON-gate it shows the owner's "מצב עריכה" banner + an exit button. (The single
// edit-mode hit-test — tap an element → select it — is wired in a focused step.)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/edit_mode.dart'
    show editModeProvider, studioActiveProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
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
                const Text(
                  '✏️ מצב עריכה',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: BsTokens.typeCaption,
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
}
