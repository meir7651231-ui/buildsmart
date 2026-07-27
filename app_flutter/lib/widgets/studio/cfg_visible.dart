// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 11 — CfgVisible (show/hide wrapper).
//
// Hides an element by the owner's `hidden` override. No override (or a [critical]
// element) ⇒ [child] VERBATIM — the zero-regression path. Hidden + not-editing ⇒
// gone (SizedBox). Hidden + edit-mode ⇒ a 35%-opacity GHOST + "מוסתר" badge so the
// owner can still find and restore it (never a bare SizedBox in edit-mode — the
// owner could never bring it back otherwise). Generalises hidden_catalog_sections.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/org_gates.dart' show elementVisible;
import 'package:buildsmart/state/studio/config_store.dart'
    show resolvedNodeProvider;
import 'package:buildsmart/state/studio/edit_mode.dart' show editModeProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Show/hide [child] by the owner's `hidden` override. [critical] elements can
/// never be hidden (defence-in-depth; the merge + publish-validator enforce it too).
class CfgVisible extends StatelessWidget {
  const CfgVisible(
    this.id, {
    required this.child,
    this.critical = false,
    super.key,
  });

  final String id;
  final Widget child;
  final bool critical;

  @override
  Widget build(BuildContext context) {
    if (critical) return child; // core — never hideable (scope-independent, first)
    // Degrade to [child] verbatim when there is no Riverpod scope (a scope-less
    // test host) — never throw. Mirrors CfgText's scope guard; the real app
    // always has a scope, so this only affects bare-MaterialApp test pumps.
    try {
      ProviderScope.containerOf(context, listen: false);
    } on Object {
      return child;
    }
    return Consumer(
      builder: (context, ref, _) {
        // giant · setup-wizard org-visibility axis: an org that hides this
        // element removes the WHOLE composite (button/card chrome, not just the
        // label a CfgText would blank) — in BOTH end-user and edit modes (a
        // wizard setting, not a Studio inline hide, so no restorable ghost).
        // Absent config ⇒ elementVisible true ⇒ [child] verbatim ⇒ byte-identical.
        if (!elementVisible(ref, id)) return const SizedBox.shrink();
        final hidden = ref
                .watch(resolvedNodeProvider(id).select((n) => n.hidden)) ??
            false;
        if (!hidden) return child; // visible — the zero-regression path

        final editing = ref.watch(editModeProvider.select((s) => s.isEditing));
        if (!editing) return const SizedBox.shrink(); // hidden for end-users

        // Owner-only: a dimmed ghost + badge so a hidden element stays restorable.
        return Opacity(
          opacity: 0.35,
          child: Stack(
            children: [
              child,
              const PositionedDirectional(
                top: 0,
                start: 0,
                child: ColoredBox(
                  color: BsTokens.brand,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'מוסתר',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: BsTokens.typeCaption,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
