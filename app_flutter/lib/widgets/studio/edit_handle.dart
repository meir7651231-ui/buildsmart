// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 9 — the in-place edit affordance.
//
// [EditHandle.maybe] returns its [child] UNTOUCHED unless the owner is in
// edit-mode — the load-bearing zero-regression contract: with kStudioFlag OFF,
// `isEditing` can never be true, so every call site short-circuits to `return
// child` (zero added widgets, no rebuild cost). Only `isEditing` is watched (via
// `.select`), so selecting a different element never rebuilds these wrappers.
//
// In edit-mode it overlays a NON-SIZING brand outline (Positioned.fill ⇒ never
// changes the child's layout) and tags the subtree with [StudioEditTarget] via
// `MetaData`, so the StudioOverlay (step 13) maps ONE tap to an element id with a
// single hit-test — NOT a per-wrapper GestureDetector (R2-#3: no gesture-arena
// storm on dense screens). The tap/popover is wired in step 13.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/edit_mode.dart' show editModeProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hit-test tag attached (edit-mode only) to an editable element's subtree, so the
/// StudioOverlay (step 13) can resolve a tap-point to [id] via a single hit-test.
@immutable
class StudioEditTarget {
  const StudioEditTarget(this.id);
  final String id;
}

/// In-place edit affordance for one element — applied ONLY in edit-mode.
class EditHandle {
  const EditHandle._();

  /// [child] verbatim outside edit-mode (zero added widgets); in edit-mode, a
  /// non-sizing brand outline + a [StudioEditTarget] tag for the overlay.
  static Widget maybe(
    WidgetRef ref,
    String id, {
    required Widget child,
  }) {
    final editing = ref.watch(editModeProvider.select((s) => s.isEditing));
    if (!editing) return child; // ← the critical OFF path (zero-regression)
    return _EditAffordance(id: id, child: child);
  }
}

class _EditAffordance extends StatelessWidget {
  const _EditAffordance({required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          MetaData(
            metaData: StudioEditTarget(id),
            behavior: HitTestBehavior.translucent,
            child: child,
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: BsTokens.brand, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
