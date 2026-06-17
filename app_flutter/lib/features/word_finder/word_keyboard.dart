// WordKeyboard — a word-key keyboard in the approved BsKeyboard aesthetic.
//
// Pure presentation + routing: it lays out a list of [WordKey] suggestions as
// rows of [BsKey]s and forwards every tap to a typed callback. No controller /
// Riverpod / feature-flag awareness lives here — what to do with a tapped word
// is entirely the caller's job.
//
// Every word renders via KbKey(kind: KeyKind.letter), which BsKey draws as
// plain text with NO icon (see BsKey._iconFor → null for KeyKind.letter). The
// optional [primary] word renders with isAccent:true (brand-orange fill), the
// same accent BsKeyboard reserves for its send key.
//
// The whole keyboard is pinned to [TextDirection.ltr] + Material(surfaceMid),
// mirroring BsKeyboard, so the key ORDER stays stable inside the otherwise-RTL
// app while the Hebrew words themselves still render RTL within each key.

import 'package:buildsmart/features/word_finder/word_keys_model.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_key.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter/material.dart';

/// A keyboard of tappable Hebrew word suggestions, styled like `BsKeyboard`.
///
/// [words] are chunked into rows of [_wordsPerRow]; each renders as a plain
/// (icon-free) [BsKey]. The [primary] word — matched by identity — is drawn in
/// brand orange. A final utility row carries exactly two icon-free keys:
/// `הכל` → [onAll] and `הקלדה` → [onType].
class WordKeyboard extends StatelessWidget {
  const WordKeyboard({
    required this.words,
    required this.onWordTap,
    super.key,
    this.onAll,
    this.onType,
    this.primary,
  });

  /// The word suggestions to render, in order.
  final List<WordKey> words;

  /// Invoked with the tapped [WordKey].
  final void Function(WordKey) onWordTap;

  /// Fired by the `הכל` ("all") utility key.
  final VoidCallback? onAll;

  /// Fired by the `הקלדה` ("type") utility key.
  final VoidCallback? onType;

  /// When non-null and present in [words], this word renders with the brand
  /// accent fill instead of the plain white key.
  final WordKey? primary;

  /// Words per word-row before wrapping to the next row.
  static const int _wordsPerRow = 3;

  /// Builds one row of word keys: each gets an [Expanded] (uniform flex), with
  /// [BsTokens.space1] gaps between keys — the BsKeyboard row idiom.
  Widget _buildWordRow(List<WordKey> rowWords) {
    final children = <Widget>[];
    for (var i = 0; i < rowWords.length; i++) {
      if (i > 0) children.add(const SizedBox(width: BsTokens.space1));
      final word = rowWords[i];
      children.add(
        Expanded(
          child: BsKey(
            // KeyKind.letter → BsKey renders the label as plain text, no icon.
            model: KbKey(word.label),
            isAccent: identical(word, primary),
            onTap: () => onWordTap(word),
          ),
        ),
      );
    }
    return Row(children: children);
  }

  /// Builds the trailing utility row: `הכל` and `הקלדה`, both icon-free
  /// (KeyKind.letter) keys routed to [onAll] / [onType].
  Widget _buildUtilityRow() {
    return Row(
      children: [
        Expanded(
          child: BsKey(
            model: const KbKey('הכל'),
            onTap: () => onAll?.call(),
          ),
        ),
        const SizedBox(width: BsTokens.space1),
        Expanded(
          child: BsKey(
            model: const KbKey('הקלדה'),
            onTap: () => onType?.call(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Chunk the words into rows of [_wordsPerRow].
    final rowWidgets = <Widget>[];
    for (var i = 0; i < words.length; i += _wordsPerRow) {
      final end = (i + _wordsPerRow < words.length) ? i + _wordsPerRow : words.length;
      rowWidgets
        ..add(_buildWordRow(words.sublist(i, end)))
        ..add(const SizedBox(height: BsTokens.space1));
    }
    // The trailing utility row (הכל · הקלדה).
    rowWidgets.add(_buildUtilityRow());

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: BsTokens.surfaceMid,
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rowWidgets,
          ),
        ),
      ),
    );
  }
}
