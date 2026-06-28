import 'package:buildsmart/features/word_finder/word_keyboard.dart'
    show WordKeyboard;
import 'package:buildsmart/features/word_finder/word_keys_model.dart'
    show WordKey;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The SINGLE opening surface of the unified finder (P3 step 52). ONE flow with
/// input methods — type in the [TextField], tap a seed in the [WordKeyboard], or
/// speak via the mic — and EQUAL click-mouth tabs ([mouthTabs]) that only swap WHICH
/// seeds the grid shows (word/material/job/category): all the SAME finder, never a
/// tool chooser (kOpeningSurfaceIsSingleMouth). The mic renders only when [showMic].
/// Pure presentation — every callback is supplied by the screen.
class OpeningSurface extends StatelessWidget {
  const OpeningSurface({
    required this.wordKeys,
    required this.onWordTap,
    required this.onQuery,
    super.key,
    this.onMic,
    this.showMic = false,
    this.onVoiceUnavailable,
    this.onSubmit,
    this.mouthTabs = const [],
    this.activeMouth,
    this.onMouthTap,
    this.onToggleMore,
    this.moreExpanded = false,
  });

  /// The opening word suggestions (the grid input method).
  final List<WordKey> wordKeys;

  /// Tapped a word in the grid.
  final void Function(WordKey) onWordTap;

  /// Typed free text (live, per keystroke) — the screen debounces + resolves it
  /// as keywords (the literal path).
  final void Function(String) onQuery;

  /// Submitted free text (enter / "find me") — routed through the AI interpreter
  /// when provided, else the literal [onQuery]. ONE surface, no mode chooser: live
  /// typing is the literal keyword path, SUBMIT is the semantic (AI) path.
  final void Function(String)? onSubmit;

  /// Tapped the mic (voice input). Null falls back to [onVoiceUnavailable].
  final VoidCallback? onMic;

  /// Whether voice is live; the mic is rendered only when true.
  final bool showMic;

  /// Tapped the mic while voice is unavailable (an honest message).
  final VoidCallback? onVoiceUnavailable;

  /// The click-mouth tabs (word/material/job/category) shown ABOVE the grid at the
  /// opening — EQUAL seed VIEWS of the one finder, NOT a tool chooser. Empty hides
  /// the row (byte-identical default).
  final List<({String id, String label})> mouthTabs;

  /// The selected mouth id (one of [mouthTabs]'s ids); null when no tabs.
  final String? activeMouth;

  /// Tapped a mouth tab — the screen swaps the grid's seeds, no step pushed.
  final void Function(String)? onMouthTap;

  /// Toggle the word mouth's grid between the top-kFirstWordCount and the full long
  /// tail ('עוד…'/'פחות'). Null hides the toggle (non-word mouths). Never seeds.
  final VoidCallback? onToggleMore;

  /// Whether the word grid is currently expanded (drives the toggle's label).
  final bool moreExpanded;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 800;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: wide ? 720 : double.infinity),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(BsTokens.space2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            textDirection: TextDirection.rtl,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: 'הקלד או דבר…',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: onQuery,
                            onSubmitted: onSubmit ?? onQuery,
                          ),
                        ),
                        if (showMic) ...[
                          const SizedBox(width: BsTokens.space1),
                          IconButton(
                            icon: const Icon(Icons.mic),
                            tooltip: 'חיפוש קולי',
                            onPressed: onMic ?? onVoiceUnavailable,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: BsTokens.space2),
                    if (mouthTabs.isNotEmpty) ...[
                      Wrap(
                        spacing: BsTokens.space1,
                        children: [
                          for (final tab in mouthTabs)
                            ChoiceChip(
                              label: Text(tab.label),
                              selected: tab.id == activeMouth,
                              onSelected: (_) => onMouthTap?.call(tab.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: BsTokens.space2),
                    ],
                    WordKeyboard(
                      words: wordKeys,
                      onWordTap: onWordTap,
                      showUtilityRow: false,
                    ),
                    if (onToggleMore != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onToggleMore,
                          child: Text(moreExpanded ? 'פחות' : 'עוד…'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
