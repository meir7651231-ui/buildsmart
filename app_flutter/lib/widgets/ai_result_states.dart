import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';

/// Shared render-states for the AI "narrate" screens (alt/paired/adapter/credit
/// explain · business-summary · quote-polish · daily-report · reject-reason).
///
/// Each of those screens fetches a Claude phrasing and shows a 4-rung ladder:
/// **off** (backend unavailable) · **loading** · **failed**+retry · **result**.
/// The first three rungs were duplicated verbatim across the screens; they live
/// here once. The **result** rung stays per-screen (its content/layout differs —
/// some screens spread several widgets), so it is intentionally NOT folded in.
///
/// Folded fix (אודיט-נחיל גל-4): the failed-line color moved `danger`→`dangerDark`
/// so it clears WCAG AA on the light card background, in one place for all screens.
/// (Historical: `danger` was #EF4444 = 3.2:1, failing; §W0 slice-3 deepened it to
/// #CE3A32 = 4.9:1, now passing — but `dangerDark` is kept here for max legibility.)

/// Backend-off rung: a muted hint that the smart phrasing needs a server.
class AiOffState extends StatelessWidget {
  const AiOffState(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
      );
}

/// Loading rung: centered spinner while Claude is phrasing.
class AiLoadingState extends StatelessWidget {
  const AiLoadingState({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Failed rung: an honest line + a retry button that re-runs the fetch.
class AiFailedState extends StatelessWidget {
  const AiFailedState({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // dangerDark (not the lighter `danger`) — clears WCAG AA on light card.
          const CfgText(
            'ai_result_states.t01',
            'משהו השתבש — נסה שוב.',
            style: TextStyle(color: BsTokens.dangerDark, fontSize: 14),
          ),
          const SizedBox(height: BsTokens.space3),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Text('🔄'),
            label: const CfgText('ai_result_states.t02', 'נסה שוב'),
          ),
        ],
      );
}
