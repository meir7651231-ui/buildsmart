// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 11 — CfgBox (container restyle wrapper).
//
// Restyles a container by the owner's `bgToken` / `pad` style override. No override
// ⇒ [child] VERBATIM (zero-regression). With an override it wraps the child in
// Padding / ColoredBox and (in edit-mode) an EditHandle.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_node.dart' show EdgeKey;
import 'package:buildsmart/state/studio/config_store.dart'
    show resolvedNodeProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:buildsmart/widgets/studio/cfg_text.dart' show cfgColorFromToken;
import 'package:buildsmart/widgets/studio/edit_handle.dart' show EditHandle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owner-facing spacing tokens → padding (BsTokens scale). null ⇒ null (no padding).
EdgeInsets? cfgEdgeFromKey(EdgeKey? k) {
  switch (k) {
    case EdgeKey.sm:
      return const EdgeInsets.all(BsTokens.space2); // 8
    case EdgeKey.md:
      return const EdgeInsets.all(BsTokens.space4); // 16
    case EdgeKey.lg:
      return const EdgeInsets.all(BsTokens.space5); // 24
    case EdgeKey.none:
      return EdgeInsets.zero;
    case null:
      return null;
  }
}

/// Restyle a container by the owner's `bgToken` / `pad` override.
class CfgBox extends ConsumerWidget {
  const CfgBox(this.id, {required this.child, super.key});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(resolvedNodeProvider(id).select((n) => n.style));
    final bg = cfgColorFromToken(style?.bgToken);
    final pad = cfgEdgeFromKey(style?.pad);
    if (bg == null && pad == null) return child; // no override — zero-regression

    var w = child;
    if (pad != null) w = Padding(padding: pad, child: w);
    if (bg != null) w = ColoredBox(color: bg, child: w);
    return EditHandle.maybe(ref, id, child: w);
  }
}
