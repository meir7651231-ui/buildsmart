// The LIVE, self-gating suggestion strip (Phase-2 live wiring).
//
// Wraps `SmartChipStrip` with the runtime gates and data plumbing so a call
// site only has to hand it a controller + context + source:
//   * self-gates on the `kSmartInputFlag` feature flag AND on screen-reader
//     state — renders NOTHING (a zero-height `SizedBox.shrink`) when off or
//     when `accessibleNavigation` is active (a11y fallback to the plain field);
//   * listens to the controller so candidates re-rank as the user types;
//   * feeds usage signal (recent + frequencies) into `rankSuggestions`;
//   * on pick, inserts the phrase at the caret via `insertAtCaret` and records
//     the pick so it floats up next time.

import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/state/smart_input_usage.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:buildsmart/widgets/smart_input/ranking.dart';
import 'package:buildsmart/widgets/smart_input/smart_chip_strip.dart';
import 'package:buildsmart/widgets/smart_input/suggestion_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A live suggestion strip bound to a [controller]: watches the feature flag +
/// a11y state to self-gate, re-ranks [source] candidates as the text changes,
/// and inserts the picked phrase at the caret while recording the pick.
class SmartSuggestionStrip extends ConsumerWidget {
  const SmartSuggestionStrip({
    super.key,
    required this.controller,
    required this.fieldContext,
    required this.source,
  });

  /// The field this strip suggests into; also the listenable that drives
  /// re-ranking and the target of [insertAtCaret] on pick.
  final TextEditingController controller;

  /// Describes the field (kind/screen/payload) for the [source].
  final SmartInputContext fieldContext;

  /// Supplies the raw candidate phrases for the current text.
  final SuggestionSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(featureFlagsProvider).contains(kSmartInputFlag);
    final a11y = MediaQuery.of(context).accessibleNavigation;
    if (!on || a11y) return const SizedBox.shrink(); // OFF / screen-reader → nothing

    final usage = ref.watch(smartInputUsageProvider);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (ctx, value, _) {
        final cands = source.candidates(fieldContext, value.text);
        final ranked = rankSuggestions(
          cands,
          query: value.text,
          recent: usage.recent,
          frequencies: usage.frequencies,
        );
        if (ranked.isEmpty) return const SizedBox.shrink();
        return SmartChipStrip(
          suggestions: ranked,
          onPick: (s) {
            insertAtCaret(controller, s.text);
            ref.read(smartInputUsageProvider.notifier).record(s.text);
          },
        );
      },
    );
  }
}
