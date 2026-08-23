// 🃏 card_keyboard — the LIVE prediction-row bridge for the card keyboard.
//
// This file now holds ONLY the pure [cardKeyboardPredictions] helper. The old
// modal launcher (`openCardKeyboardSheet`) + sheet widget (`_CardKeyboardSheet`)
// were REMOVED when the surface became a PERSISTENT floating overlay opened by a
// keyboard FAB (see lib/screens/floating_card_keyboard.dart +
// lib/screens/home_shell.dart). The floating widget imports ONLY this helper.
//
// LAYERING — this is a `screens`-layer file, so unlike the PURE
// `keyboard_predictions.dart` bridge it MAY import the screens/catalog code:
//   • the finder ENGINE ([NewbieStep] / [offerQuestion] / [WordLexicon]) — to
//     mirror the finder's typed-query narrowing exactly, and
//   • [catalogProductMatchesQuery] (catalog_screen.dart) — the SAME forgiving
//     predicate `_submitQuery` records on its `NewbieStep`.
// [predictionChips] itself stays pure and untouched: we hand it the engine's
// [NewbieQuestion] and it returns the chip labels.
//
// HOW THE LIVE ROW MIRRORS THE FINDER (word_finder_screen.dart):
//   _submitQuery(q): clears the stack, and for a non-empty `q` pushes ONE
//     NewbieStep(axisLabel:'חיפוש', chipLabel:q, crumbWord:q,
//                predicate:(p)=>catalogProductMatchesQuery(p,q)).
//   _pool: filters `_basePool` through every step's predicate.
//   Then `offerQuestion(pool, stack, lexicon, null)` decides the next question,
//   and `offerQuestion` SKIPS its empty-stack AskWords branch precisely because
//   the stack is non-empty → it narrows instead. [cardKeyboardPredictions]
//   reproduces this: empty query → opening words (empty stack); else → filter
//   the pool + build the identical one-step stack, then `offerQuestion` →
//   `predictionChips`.

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/features/word_finder/keyboard_predictions.dart'
    show predictionChips;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep, offerQuestion;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordLexicon;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery;

/// LIVE prediction-row chips for the card keyboard, mirroring the finder's
/// typed-query path (`_submitQuery` + `_pool` in word_finder_screen.dart) and
/// passing the engine's verdict through the PURE [predictionChips].
///
/// PUBLIC + TESTABLE (no widgets, no providers): given a typed [query], the
/// [pool] (normally `kDivePool`) and a [lexicon] (normally
/// `buildWordLexicon(kDivePool)`), returns up to [max] short chip labels.
///
///   • `query.trim()` empty → OPENING WORDS: `offerQuestion(pool, [], lexicon,
///     null)` returns `AskWords` (the empty-stack branch) → top lexicon words.
///   • else → NARROW: filter the pool by `catalogProductMatchesQuery(p, query)`
///     and build a one-element stack carrying the EXACT same step
///     `_submitQuery` records — `NewbieStep(axisLabel:'חיפוש', chipLabel:q,
///     crumbWord:q, predicate:(p)=>catalogProductMatchesQuery(p,q))` — so
///     `offerQuestion` skips AskWords and narrows the filtered pool.
///
/// DETERMINISTIC: same (query, pool, lexicon) in ⇒ identical list out (both the
/// pool filter and `offerQuestion`/`predictionChips` are pure).
List<String> cardKeyboardPredictions(
  String query,
  List<LipskeyCatalogProduct> pool,
  WordLexicon lexicon, {
  int max = 4,
}) {
  final q = query.trim();
  if (q.isEmpty) {
    // Empty stack → offerQuestion returns the opening AskWords.
    return predictionChips(
      offerQuestion(pool, const <NewbieStep>[], lexicon, null),
      max: max,
    );
  }
  // Mirror _submitQuery: one step whose predicate IS catalogProductMatchesQuery,
  // over a pool pre-filtered by the same predicate (matches `_pool` applying
  // every step's predicate to the base pool).
  final filtered =
      pool.where((p) => catalogProductMatchesQuery(p, q)).toList();
  final stack = <NewbieStep>[
    NewbieStep(
      axisLabel: 'חיפוש',
      chipLabel: q,
      crumbWord: q,
      predicate: (p) => catalogProductMatchesQuery(p, q),
    ),
  ];
  return predictionChips(
    offerQuestion(filtered, stack, lexicon, null),
    max: max,
  );
}
