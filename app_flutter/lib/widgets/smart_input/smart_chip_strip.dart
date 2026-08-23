// The horizontal suggestion strip shown above the keyboard (Phase-1 of the
// "smart input" feature). A single scrollable row of tappable chips — one per
// [Suggestion] — rendering `s.display`. The composed/primary chip
// (`isPrimary == true`) is FILLED with the brand orange; the rest are neutral
// outlined chips. Tapping a chip fires [onPick] with that suggestion.
//
// LTR LOCK: the strip pins its own subtree to `TextDirection.ltr` so the chip
// ORDER is stable even though the app runs RTL — the ranking decides order
// (primary first), and we don't want RTL flipping it. Colours/spacing come from
// `BsTokens` (no hard-coded hex).

import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:flutter/material.dart';

/// A horizontal, scrollable strip of suggestion chips. Renders nothing of its
/// own when [suggestions] is empty (a zero-height strip); callers typically
/// guard on `isNotEmpty` before mounting it.
class SmartChipStrip extends StatelessWidget {
  const SmartChipStrip({
    required this.suggestions,
    required this.onPick,
    super.key,
  });

  /// The already-ranked suggestions to render (primary-first); each becomes one
  /// tappable chip showing its [Suggestion.display].
  final List<Suggestion> suggestions;

  /// Called with the picked suggestion when its chip is tapped.
  final ValueChanged<Suggestion> onPick;

  @override
  Widget build(BuildContext context) {
    // LTR-lock: keep chip order stable in this RTL app (ranking owns order).
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space4,
            vertical: BsTokens.space2,
          ),
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(width: BsTokens.space2),
          itemBuilder: (context, i) {
            final s = suggestions[i];
            return _Chip(suggestion: s, onPick: onPick);
          },
        ),
      ),
    );
  }
}

/// A single chip — brand-filled when [Suggestion.isPrimary], outlined/neutral
/// otherwise. Extracted so the primary/neutral styling lives in one place.
class _Chip extends StatelessWidget {
  const _Chip({required this.suggestion, required this.onPick});

  final Suggestion suggestion;
  final ValueChanged<Suggestion> onPick;

  @override
  Widget build(BuildContext context) {
    final primary = suggestion.isPrimary;
    final fg = primary ? Colors.white : BsTokens.inkLight;

    return Material(
      color: primary ? BsTokens.brand : Theme.of(context).colorScheme.surface,
      shape: StadiumBorder(
        side: primary
            ? BorderSide.none
            : const BorderSide(color: BsTokens.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onPick(suggestion),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space3,
            vertical: BsTokens.space2,
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              suggestion.display,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: BsTokens.typeLabel,
                fontWeight: primary ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
