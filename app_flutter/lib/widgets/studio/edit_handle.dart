// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 9 — the in-place edit affordance.
//
// [EditHandle.maybe] returns its [child] UNTOUCHED unless the owner is in
// edit-mode — the load-bearing zero-regression contract: with kStudioFlag OFF,
// `isEditing` can never be true, so every call site short-circuits to `return
// child` (zero added widgets, no rebuild cost). Only `isEditing` is watched (via
// `.select`), so selecting a different element never rebuilds these wrappers.
//
// In edit-mode it (a) overlays a NON-SIZING brand outline (Positioned.fill ⇒
// never changes the child's layout), (b) tags the subtree with [StudioEditTarget]
// via `MetaData` (kept for the overlay hit-test / tests), and (c) — the WYSIWYG
// "עריכה בחי" — wraps the element in an OPAQUE [GestureDetector] so a tap opens an
// inline text editor for [id] INSTEAD of the underlying control's action (a tap on
// an editable label no longer navigates). The edit detector is the DEEPEST tap
// recognizer, so it wins the gesture arena over any ancestor button. `editText`
// pre-fills the editor (the current effective text); a null value (a non-text
// container wrapper) still outlines but its editor opens empty.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_store.dart'
    show SetText, cfgOpError, configStoreProvider, kCfgMaxTextLen;
import 'package:buildsmart/state/studio/edit_mode.dart' show editModeProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hit-test tag attached (edit-mode only) to an editable element's subtree, so the
/// StudioOverlay can resolve a tap-point to [id] via a single hit-test.
@immutable
class StudioEditTarget {
  const StudioEditTarget(this.id);
  final String id;
}

/// In-place edit affordance for one element — applied ONLY in edit-mode.
class EditHandle {
  const EditHandle._();

  /// [child] verbatim outside edit-mode (zero added widgets); in edit-mode, a
  /// tappable brand outline that opens the inline text editor for [id].
  /// [editText] is the current text used to pre-fill that editor.
  static Widget maybe(
    WidgetRef ref,
    String id, {
    required Widget child,
    String? editText,
  }) {
    final editing = ref.watch(editModeProvider.select((s) => s.isEditing));
    if (!editing) return child; // ← the critical OFF path (zero-regression)
    return _EditAffordance(id: id, editText: editText, child: child);
  }
}

class _EditAffordance extends ConsumerWidget {
  const _EditAffordance({
    required this.id,
    required this.child,
    this.editText,
  });

  final String id;
  final Widget child;
  final String? editText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      // Opaque + the DEEPEST tap recognizer ⇒ a tap on an editable label opens
      // the editor and never falls through to the ancestor button's onTap.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openInlineEditor(context, ref, id, editText ?? ''),
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
      ),
    );
  }
}

/// The WYSIWYG inline editor: a small RTL dialog pre-filled with [current]; on save
/// it validates (length / bidi via [cfgOpError]) and applies a [SetText] to the
/// draft, so the tapped text updates LIVE (the owner sees the change immediately,
/// then broadcasts it with "פרסם לכולם"). Cancel / no-change ⇒ a no-op.
Future<void> _openInlineEditor(
  BuildContext context,
  WidgetRef ref,
  String id,
  String current,
) async {
  final controller = TextEditingController(text: current);
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('עריכת טקסט', textAlign: TextAlign.right),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          maxLength: kCfgMaxTextLen,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'הקלד טקסט חדש',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ביטול'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: const Text('שמור'),
        ),
      ],
    ),
  );
  if (result == null || result == current) return; // cancelled / unchanged
  final op = SetText(id, result);
  final err = cfgOpError(op);
  if (err != null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
    return;
  }
  ref.read(configStoreProvider.notifier).applyOps([op]);
}
