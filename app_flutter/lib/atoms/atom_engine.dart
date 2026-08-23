import 'package:buildsmart/atoms/atom_schema.dart';
import 'package:flutter/material.dart';

/// The result of resolving one [AtomSpec] against live screen state: whether
/// the slot is [visible] and, if so, the atom [child] to render.
class AtomSlot {
  const AtomSlot({required this.visible, required this.child});

  /// A hidden slot — the engine skips it. `child` is never read.
  const AtomSlot.hidden()
      : visible = false,
        child = const SizedBox.shrink();

  final bool visible;
  final Widget child;
}

/// Supplied by a screen controller. Given a spec, evaluate its `when` predicate
/// against current state and build the atom with real props.
typedef AtomResolver = AtomSlot Function(AtomSpec spec);

/// The assembly engine. Domain-agnostic: it walks a [schema] in order, asks the
/// [resolve]r for each slot, drops invisible slots, wraps `expanded` slots in
/// [Expanded], and returns a [Column] — the same structure a hand-wired screen
/// would build, but driven by the manifest. All data lives in the resolver.
class AtomEngine {
  const AtomEngine._();

  static Widget render(AtomSchema schema, AtomResolver resolve) {
    final children = <Widget>[];
    for (final spec in schema.atoms) {
      final slot = resolve(spec);
      if (!slot.visible) continue;
      children.add(spec.expanded ? Expanded(child: slot.child) : slot.child);
    }
    return Column(children: children);
  }
}
