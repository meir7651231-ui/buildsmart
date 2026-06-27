import 'package:buildsmart/features/word_finder/word_keyboard.dart'
    show WordKeyboard;
import 'package:buildsmart/features/word_finder/word_keys_model.dart'
    show WordKey;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The SINGLE opening surface of the unified finder (P3 step 52). ONE flow with
/// THREE input methods — type in the [TextField], tap a word in the
/// [WordKeyboard], or speak via the mic — and ZERO mode buttons: the user never
/// picks a tool first (kOpeningSurfaceIsSingleMouth). The mic renders only when
/// [showMic]. Pure presentation — every callback is supplied by the screen.
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
                    WordKeyboard(
                      words: wordKeys,
                      onWordTap: onWordTap,
                      showUtilityRow: false,
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
