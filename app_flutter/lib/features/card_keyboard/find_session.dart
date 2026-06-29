/// PURE engine-driving session for the keyboard's product-FIND mode.
///
/// Owner pivot (30/6): the KEYBOARD is the product-finder — the merged engine's
/// chips render AS KEYS (the grid), the answered path RISES to the prediction
/// row, and the screen/card underneath stays untouched. This wraps the pure
/// [mergedKeys] engine with the dive `stack` + the `pool` it narrows, so the
/// floating keyboard owns ONE [FindSession] in find-mode and re-reads `verdict`
/// after each tap. It does NOT add content to the product card (the sections
/// already carry it); it only drives WHICH keys the keyboard shows next.
///
/// PURITY/DETERMINISM: no Flutter / Riverpod / clock / IO — same contract as
/// `card_engine` + `word_finder_engine`. The `pool` is derived locally (never a
/// global/provider), so the session is unit-testable and
/// employer-isolation-safe (build plan §3).
library;

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show CardVerdict, SignalChip, mergedKeys;
import 'package:buildsmart/features/card_keyboard/card_signals.dart'
    show WordSignal, sourcesFor;
import 'package:buildsmart/features/card_keyboard/pool_seed.dart'
    show seedFromText, seedStep;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordLexicon, buildWordLexicon;

/// The find-mode lexicon — built ONCE from the dive pool (pure + deterministic).
/// Mirrors `cardKeyboardLexicon` WITHOUT importing the screen widget, keeping
/// this controller Flutter-free.
final WordLexicon kFindLexicon = buildWordLexicon(kDivePool);

/// Rebuild a merged chip's narrowing predicate from its `(axisId, value)` DATA
/// (replay-stable — the step is data, not a captured closure; mirrors the
/// screen's `_predicateFor`). Falls back to the word source for an unknown axis
/// (impossible for an engine-emitted chip). Top-level + pure so a test can pin
/// it directly.
bool Function(LipskeyCatalogProduct) findPredicateFor(
  String axisId,
  String value,
  String? subtype,
) {
  final src = sourcesFor(subtype)
      .firstWhere((s) => s.axisId == axisId, orElse: () => const WordSignal());
  final chip = SignalChip(axisId: axisId, value: value, displayLabel: value);
  return (p) => src.matches(p, chip);
}

/// A mutable dive session: the answered [stack], the [pool] it narrows, and the
/// engine [verdict] for the current turn. Re-read [verdict] after every
/// [pushChip] / [pushWord] / [pop] / [reset].
class FindSession {
  FindSession({this.subtype, WordLexicon? lexicon})
      : _lexicon = lexicon ?? kFindLexicon;

  /// Optional curated sub-type, passed straight through to [mergedKeys].
  final String? subtype;
  final WordLexicon _lexicon;

  /// The answered steps, oldest-first — the breadcrumb that RISES to the
  /// prediction row (one chip per step, [NewbieStep.crumbWord]).
  final List<NewbieStep> stack = <NewbieStep>[];

  /// kDivePool narrowed by every answered step's predicate. Pure recompute —
  /// cheap next to the merge, and the engine memoises the heavy work downstream.
  List<LipskeyCatalogProduct> get pool {
    var p = kDivePool;
    for (final s in stack) {
      p = p.where(s.predicate).toList();
    }
    return p;
  }

  /// The engine's verdict for the current state — what the keyboard renders:
  /// `MergedKeys` → chips-as-keys · `CardShowProducts` → product keys ·
  /// `CardResolve` → open the sheet · `CardAskWords` → opening words.
  CardVerdict get verdict => mergedKeys(pool, stack, _lexicon, subtype);

  /// The answered path, in order — the chips shown in the prediction row.
  List<String> get selection => [for (final s in stack) s.crumbWord];

  /// Narrow by a tapped merged chip — the predicate is rebuilt from the chip's
  /// `(axisId, value)` DATA (replay-stable), the crumb shows its displayLabel
  /// (swarm R2: never the predicate `value`).
  void pushChip(SignalChip chip) {
    final src = sourcesFor(subtype).firstWhere(
      (s) => s.axisId == chip.axisId,
      orElse: () => const WordSignal(),
    );
    stack.add(NewbieStep(
      axisLabel: src.axisName,
      chipLabel: chip.displayLabel,
      crumbWord: chip.displayLabel,
      predicate: findPredicateFor(chip.axisId, chip.value, subtype),
    ));
  }

  /// Open the dive from a plain word (the opening mouth) — routes through the
  /// SAME unified [seedStep] funnel the screen + every other mouth use. Returns
  /// false (no-op) when the word matches nothing, so the caller keeps the
  /// surface rather than dead-ending.
  bool pushWord(String word) {
    final seed = seedFromText(word, _lexicon);
    if (seed == null) return false;
    stack.add(seedStep(seed));
    return true;
  }

  /// Undo the last answered step (the BACK key). No-op on an empty stack.
  void pop() {
    if (stack.isNotEmpty) stack.removeLast();
  }

  /// Restart the dive (back to the opening words).
  void reset() => stack.clear();
}
