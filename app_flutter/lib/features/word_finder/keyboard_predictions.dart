/// PURE prediction-row adapter for the keyboard tool-strip (STEP 3 of the
/// "keyboard-becomes-the-card" fusion).
///
/// The keyboard's tool-strip MIDDLE is a no-scroll prediction row that takes a
/// plain `List<String>`. The dive engine, however, speaks in [NewbieQuestion]s
/// ([AskWords] / [AskAxis] / [ShowProducts] / [Resolve]). This file is the thin,
/// pure bridge between the two: it maps whatever the engine asks at this turn
/// into the short chip labels the strip renders, so every keystroke can surface
/// the engine's next-best chips.
///
/// STEP of the word-finder swarm, kept PURE in the spirit of `dive_pool.dart`,
/// `word_lexicon.dart`, `narrow_axis.dart` and `quick_pad_engine.dart`: NO
/// Flutter widgets, NO Riverpod providers, NOTHING from `lib/widgets` or
/// `lib/screens`. It imports ONLY the engine ([NewbieQuestion] + subtypes),
/// `word_lexicon.dart` ([WordEntry]) and `quick_pad_engine.dart` ([quickLabel]).
/// Importing it pulls in zero UI.
///
/// WHAT IT PRODUCES:
///   A short, de-duplicated, non-empty-only list of chip labels capped at `max`,
///   preserving the engine's own ordering:
///     - [AskWords]     → the top words ([WordEntry.word]).
///     - [AskAxis]      → the axis chips.
///     - [ShowProducts] → each product mapped through [quickLabel].
///     - [Resolve]      → the single resolved product's [quickLabel].
///     - any other kind → `const <String>[]`.
///
/// DETERMINISM: same question in ⇒ identical list out. Blank/empty strings and
/// duplicates (keep first occurrence) are dropped BEFORE the cap is applied, so
/// the cap counts only the chips the user actually sees.
library;

import 'package:buildsmart/features/word_finder/quick_pad_engine.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';

/// Maps the engine's current [NewbieQuestion] to the prediction-row chip labels.
///
/// Exhaustive switch over the sealed [NewbieQuestion] type (the compiler enforces
/// every subtype is handled). The raw label sequence for each kind is cleaned by
/// [_clean] — empties/blanks removed, duplicates collapsed keeping the first —
/// and THEN capped at [max], in the engine's own order. PURE.
List<String> predictionChips(NewbieQuestion q, {int max = 4}) {
  switch (q) {
    case AskWords(:final words):
      return _clean(words.map((w) => w.word), max);
    case AskAxis(:final chips):
      return _clean(chips, max);
    case ShowProducts(:final products):
      return _clean(products.map(quickLabel), max);
    case Resolve(:final product):
      return _clean(<String>[quickLabel(product)], max);
  }
}

/// Trims, drops blank/empty strings, collapses duplicates (keeping the FIRST
/// occurrence), then caps the result at [max] — all order-preserving.
List<String> _clean(Iterable<String> raw, int max) {
  final seen = <String>{};
  final out = <String>[];
  for (final s in raw) {
    final t = s.trim();
    if (t.isEmpty) continue;
    if (!seen.add(t)) continue; // duplicate → keep the first occurrence only
    out.add(t);
    if (out.length >= max) break; // cap AFTER de-dup/blank-drop
  }
  return out;
}
