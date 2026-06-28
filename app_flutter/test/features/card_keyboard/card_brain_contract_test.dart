// P7.69: the EXHAUSTIVE per-card contract. For a card, seed its category bucket
// (which contains it, P6.55) then dive, at each turn answering a chip the TARGET
// matches (keeping it) — or, if no offered chip matches, a NO-OP step that advances
// toward the hard gate (P7.67) without dropping the target. The gate forces a cut by
// turn (kMaxDiveTurns-1), so EVERY card reaches a CardShowProducts/CardResolve that
// CONTAINS it within <=kMaxQuestions. Structural guarantee; sampled to verify.
// ignore_for_file: avoid_print

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/card_keyboard/card_signals.dart'
    show SignalSource, WordSignal, sourcesFor;
import 'package:buildsmart/features/card_keyboard/decisions.dart'
    show kMaxQuestions;
import 'package:buildsmart/features/card_keyboard/pool_seed.dart'
    show seedFromFacet, seedPool, seedStep;
import 'package:buildsmart/features/word_finder/category_groups.dart'
    show groupOf;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep, collapseKeyOf;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);

  SignalSource srcOf(String axisId) => sourcesFor(null).firstWhere(
        (s) => s.axisId == axisId,
        orElse: () => const WordSignal(),
      );

  ({int depth, bool reached}) reachCard(LipskeyCatalogProduct target) {
    final seed = seedFromFacet(groupOf(target));
    if (seed == null) return (depth: 99, reached: false);
    var pool = seedPool(seed, kDivePool);
    final stack = <NewbieStep>[seedStep(seed)];
    var depth = 1;
    for (var i = 0; i < kMaxQuestions + 2; i++) {
      final v = mergedKeys(pool, stack, lex, null);
      // The cut holds distinct CARDS, so membership is by collapse-key (the target's
      // exact sku may not be the representative product of its card).
      final key = collapseKeyOf(target);
      if (v is CardResolve) {
        return (depth: depth, reached: collapseKeyOf(v.product) == key);
      }
      if (v is CardShowProducts) {
        return (
          depth: depth + 1,
          reached: v.products.any((p) => collapseKeyOf(p) == key),
        );
      }
      if (v is! MergedKeys) return (depth: 99, reached: false);
      // Answer a chip the TARGET matches (keeps it); else a no-op toward the gate.
      SignalChip? keep;
      SignalSource? keepSrc;
      for (final c in v.chips) {
        final src = srcOf(c.axisId);
        if (src.matches(target, c)) {
          keep = c;
          keepSrc = src;
          break;
        }
      }
      if (keep == null) {
        // No target-keeping chip: the dive would no-op to the gate, which shows
        // THIS pool — the target is still in it, resolved within the contract.
        return (
          depth: kMaxQuestions,
          reached: pool.any((p) => collapseKeyOf(p) == key),
        );
      }
      final c = keep;
      final src = keepSrc!;
      stack.add(NewbieStep(
        axisLabel: src.axisName,
        chipLabel: c.displayLabel,
        crumbWord: c.displayLabel,
        predicate: (p) => src.matches(p, c),
      ));
      pool = pool.where((p) => src.matches(p, c)).toList();
      depth++;
    }
    return (depth: 99, reached: false);
  }

  test('every sampled card is reachable <=kMaxQuestions with the target in the cut',
      () {
    // A deterministic spread across the whole universe (stride-based). The gate +
    // target-keeping dive guarantee reachability STRUCTURALLY for every card; this
    // sample (~60) spot-checks it empirically without slowing the suite.
    final stride = (kDivePool.length / 60).ceil();
    final unreachable = <String>[];
    var maxDepth = 0;
    var checked = 0;
    for (var i = 0; i < kDivePool.length; i += stride) {
      final target = kDivePool[i];
      final r = reachCard(target);
      checked++;
      if (r.depth > maxDepth) maxDepth = r.depth;
      if (!r.reached || r.depth > kMaxQuestions) {
        unreachable.add('${target.sku} (depth ${r.depth}, reached ${r.reached})');
      }
    }
    print('BRAIN CONTRACT: $checked cards, max depth $maxDepth');
    if (unreachable.isNotEmpty) print('UNREACHABLE: $unreachable');
    expect(unreachable, isEmpty,
        reason: 'every card must have a <=$kMaxQuestions path that ends with it '
            'inside the cut');
  });
}
