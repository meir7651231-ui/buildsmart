// BsKeyboard — the custom Hebrew on-screen keyboard (Phase-3a).
//
// Pure presentation + routing: it lays out the approved layout
// ([hebrew_layout.dart]) as a grid of [BsKey]s and forwards every tap to a
// typed callback based on the key's [KeyKind]. No text controller / Riverpod /
// feature-flag awareness lives here — what to do with an inserted character,
// a backspace, an enter, a send, or a layer toggle is entirely the caller's
// job. This keeps the widget trivially testable and reusable.
//
// The whole keyboard is pinned to [TextDirection.ltr] so the key ORDER stays
// stable inside the otherwise-RTL app (the framework would mirror the rows
// under RTL otherwise — see [hebrew_layout.dart]). The letters themselves are
// authored LTR for the same reason.

import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_key.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/english_layout.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/hebrew_layout.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter/material.dart';

/// The custom keyboard. Renders one of three layers — the Hebrew letters
/// ([kHebrewRows]), the English QWERTY letters ([kEnglishRows]) when [english]
/// is true, or the `?123` symbols layer ([kSymbolsRows]) when [showSymbols] is
/// true (which takes precedence) — always followed by [kBottomRow]. A backspace
/// key is appended to the right end of the last letter/symbol row.
class BsKeyboard extends StatelessWidget {
  /// Insert this text into the field (letters, digits, punctuation, or the
  /// space bar's `' '` output).
  final ValueChanged<String> onKey;

  /// Delete one character (backspace key).
  final VoidCallback onBackspace;

  /// Insert a newline / submit a line (enter key).
  final VoidCallback onEnter;

  /// Fire the send action (the brand-orange send key).
  final VoidCallback onSend;

  /// Toggle between the letter and `?123` symbols layers. The single
  /// layer-switch key — labelled `?123` on letters, `אבג` on symbols — routes
  /// here (there is no second toggle key).
  final VoidCallback? onToggleSymbols;

  /// Switch input language (the globe key).
  final VoidCallback? onLanguage;

  /// When true, render the `?123` symbols layer instead of the letter layer.
  final bool showSymbols;

  /// When true (and not showing symbols), render the English QWERTY layer
  /// instead of Hebrew.
  final bool english;

  const BsKeyboard({
    super.key,
    required this.onKey,
    required this.onBackspace,
    required this.onEnter,
    required this.onSend,
    this.onToggleSymbols,
    this.onLanguage,
    this.showSymbols = false,
    this.english = false,
  });

  /// Dispatches a tapped [key] to the matching callback based on its [kind].
  /// Text-bearing kinds (letter / period / punct / space) insert their
  /// [KbKey.effectiveOutput]; the rest drive keyboard behaviour.
  void _route(KbKey key) {
    switch (key.kind) {
      case KeyKind.letter:
      case KeyKind.period:
      case KeyKind.punct:
      case KeyKind.space:
        onKey(key.effectiveOutput);
      case KeyKind.backspace:
        onBackspace();
      case KeyKind.enter:
        onEnter();
      case KeyKind.send:
        onSend();
      case KeyKind.symbols:
        onToggleSymbols?.call();
      case KeyKind.language:
        onLanguage?.call();
    }
  }

  /// Builds one keyboard row: each key gets an [Expanded] sized by its
  /// [KbKey.flex], with small gaps between keys.
  Widget _buildRow(List<KbKey> keys) {
    final children = <Widget>[];
    for (var i = 0; i < keys.length; i++) {
      if (i > 0) children.add(const SizedBox(width: BsTokens.space1));
      final key = keys[i];
      // Two keys relabel at runtime by layer/language; tap routing still uses
      // the original key. (Runtime values → `final`, not const.)
      //   • The layer-switch key: `?123` on the letter layer, and the
      //     back-to-letters label matches the active language on the symbols
      //     layer (`ABC` in English, `אבג` in Hebrew) — ONE toggle key (like
      //     real keyboards), never two.
      //   • The space bar: labelled for the active language (`English` /
      //     `עברית`), keeping its `' '` output and wide flex.
      final KbKey model;
      if (key.kind == KeyKind.symbols) {
        model = KbKey(
          showSymbols ? (english ? 'ABC' : 'אבג') : '?123',
          kind: KeyKind.symbols,
        );
      } else if (key.kind == KeyKind.space) {
        model = KbKey(
          english ? 'English' : 'עברית',
          kind: KeyKind.space,
          output: key.effectiveOutput,
          flex: key.flex,
        );
      } else {
        model = key;
      }
      children.add(
        Expanded(
          flex: key.flex,
          child: BsKey(
            model: model,
            isAccent: key.kind == KeyKind.send,
            onTap: () => _route(key),
          ),
        ),
      );
    }
    return Row(children: children);
  }

  @override
  Widget build(BuildContext context) {
    // The active letter/symbol layer.
    final layer =
        showSymbols ? kSymbolsRows : (english ? kEnglishRows : kHebrewRows);

    // Append a backspace to the END of the LAST layer row so it sits at the
    // right end of the bottom letter/symbol row. We copy that row rather than
    // mutate the const layout.
    const backspace = KbKey('⌫', kind: KeyKind.backspace);
    final rows = <List<KbKey>>[
      for (var i = 0; i < layer.length; i++)
        i == layer.length - 1 ? <KbKey>[...layer[i], backspace] : layer[i],
    ];

    final rowWidgets = <Widget>[];
    for (final row in rows) {
      rowWidgets.add(_buildRow(row));
      rowWidgets.add(const SizedBox(height: BsTokens.space1));
    }
    // The bottom action row (send · ?123 · globe · space · period · enter).
    rowWidgets.add(_buildRow(kBottomRow));

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
