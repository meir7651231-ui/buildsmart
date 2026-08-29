// The opt-in wrapper a real text field is wrapped in to gain the smart-input
// suggestion strip (Phase-1). It is a STRICT no-op unless the feature is on:
//
//   • flag OFF  → returns [child] verbatim (byte-identical — zero regression);
//   • a11y on   → returns [child] verbatim too. A screen-reader user navigates
//                 the keyboard/field directly; an extra strip of tappable chips
//                 would just be noise, so we fall back to the plain field.
//
// Only when the `kSmartInput` flag is enabled AND `accessibleNavigation` is off
// do we render the field with a [SmartChipStrip] beneath it. The suggestions
// are already ranked by the caller (Phase-1 passes them in); picking one fires
// [onPick]. The column is `min`-sized so the wrapper adds no extra height
// beyond the field + (optional) strip.

import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:buildsmart/widgets/smart_input/smart_chip_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps a [child] text field, adding a suggestion [SmartChipStrip] beneath it
/// when the `kSmartInput` flag is on and the screen reader is off. Otherwise it
/// is a transparent passthrough of [child].
class SmartInputScaffold extends ConsumerWidget {
  const SmartInputScaffold({
    required this.fieldContext,
    required this.child,
    required this.onPick,
    super.key,
    this.suggestions = const [],
  });

  /// Describes the field being edited (kind/screen/payload) for the engine.
  final SmartInputContext fieldContext;

  /// The real text field this wrapper decorates.
  final Widget child;

  /// Already-ranked suggestions to offer; Phase-1 passes them in.
  final List<Suggestion> suggestions;

  /// Called with the picked suggestion when a chip is tapped.
  final ValueChanged<Suggestion> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(featureFlagsProvider).contains(kSmartInputFlag);
    final a11y = MediaQuery.of(context).accessibleNavigation;
    // PASSTHROUGH — byte-identical, zero regression — when off or a11y-active.
    if (!on || a11y) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        if (suggestions.isNotEmpty)
          SmartChipStrip(suggestions: suggestions, onPick: onPick),
      ],
    );
  }
}
