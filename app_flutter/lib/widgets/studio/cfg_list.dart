// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 11 — CfgList (order wrapper).
//
// Renders [items] in the owner's published `order` (STABLE sort; a missing order ⇒
// the declaration index, so NO override ⇒ declaration order = zero-regression). The
// caller supplies the container via [builder] (Column / ListView / Wrap / …) so the
// surrounding layout is unchanged. Edit-mode drag-reorder is wired together with the
// inspector write-path (it needs to emit SetOrder ops); v1 is the read/sort half.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_store.dart'
    show resolvedNodeProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One ordered child in a [CfgList], identified by [id] (whose `order` override
/// decides its position).
@immutable
class CfgListItem {
  const CfgListItem(this.id, this.child);
  final String id;
  final Widget child;
}

/// Orders [items] by their published `order` then hands the sorted widgets to
/// [builder] (which owns the actual container, so layout is the caller's).
class CfgList extends ConsumerWidget {
  const CfgList({required this.items, required this.builder, super.key});

  final List<CfgListItem> items;
  final Widget Function(BuildContext context, List<Widget> ordered) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranked = <({int index, int order, Widget child})>[
      for (var i = 0; i < items.length; i++)
        (
          index: i,
          order: ref.watch(
                resolvedNodeProvider(items[i].id).select((n) => n.order),
              ) ??
              i,
          child: items[i].child,
        ),
    ]..sort((a, b) {
        final c = a.order.compareTo(b.order);
        return c != 0 ? c : a.index.compareTo(b.index); // stable tiebreaker
      });
    return builder(context, [for (final e in ranked) e.child]);
  }
}
