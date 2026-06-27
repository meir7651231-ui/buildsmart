// P4.58: the <=6 census — proves the LOCKED contract (kMaxQuestions) holds from
// every sampled mouth. PURE: drives the engine (mergedKeys) directly, greedily
// following its top-ranked chip each turn, with no widget. The answer step mirrors
// the screen's _ChipTap EXACTLY (axisLabel: src.axisName + predicate: src.matches
// == the screen's _predicateFor), so the simulated dive == the real dive.
// ignore_for_file: avoid_print

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/card_keyboard/card_signals.dart'
    show WordSignal, sourcesFor;
import 'package:buildsmart/features/card_keyboard/decisions.dart'
    show kMaxQuestions;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show kMaterials;
import 'package:buildsmart/features/word_finder/synonym_bridge.dart'
    show resolveQuery;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep, divePoolBySku, wordsByFrequency;
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);

  /// Greedy dive from a seeded pool: follow the engine's top-ranked chip each
  /// turn until a terminal. Returns the QUESTION count (the opening = 1).
  ({int depth, String terminal}) dive(
    List<LipskeyCatalogProduct> seed, {
    int cap = 12,
  }) {
    var pool = seed;
    final stack = <NewbieStep>[
      NewbieStep(
        axisLabel: '_censusOpening', // a non-signal label: keeps every axis open
        chipLabel: 'seed',
        crumbWord: 'seed',
        predicate: (_) => true, // mergedKeys reads the pre-narrowed pool, not this
      ),
    ];
    var depth = 1; // the opening choice is question 1
    for (var i = 0; i < cap; i++) {
      final v = mergedKeys(pool, stack, lex, null);
      if (v is CardResolve) return (depth: depth, terminal: 'resolve');
      if (v is CardShowProducts) {
        // picking from the scan-by-eye list is one more question
        return (depth: depth + 1, terminal: 'show(${v.products.length})');
      }
      if (v is! MergedKeys) {
        return (depth: cap + 1, terminal: 'askWords?!'); // unreachable post-seed
      }
      final c = v.chips.first;
      final src = sourcesFor(null).firstWhere(
        (s) => s.axisId == c.axisId,
        orElse: () => const WordSignal(),
      );
      stack.add(NewbieStep(
        axisLabel: src.axisName, // marks THIS axis answered (mergedKeys §263)
        chipLabel: c.displayLabel,
        crumbWord: c.displayLabel,
        predicate: (p) => src.matches(p, c),
      ));
      pool = pool.where((p) => src.matches(p, c)).toList();
      depth++;
    }
    return (depth: cap + 1, terminal: 'cap-exceeded');
  }

  // The mouths: the 7 material queries (text/voice funnel) + the broadest opening
  // words (the word-tap funnel). Voice == text (same resolveQuery), so it is
  // covered by the material/word seeds.
  final mouths = <String, List<LipskeyCatalogProduct>>{};
  for (final m in kMaterials.keys) {
    mouths['material:$m'] = [
      for (final s in resolveQuery(m, lex))
        if (divePoolBySku[s] != null) divePoolBySku[s]!,
    ];
  }
  for (final e in wordsByFrequency(lex).take(40)) {
    final pool = [
      for (final s in e.skus)
        if (divePoolBySku[s] != null) divePoolBySku[s]!,
    ];
    if (pool.isNotEmpty) mouths['word:${e.word}'] = pool;
  }

  test('every sampled mouth resolves within <=$kMaxQuestions questions', () {
    final overBudget = <String, int>{};
    final hist = <int, int>{};
    mouths.forEach((label, pool) {
      final r = dive(pool);
      hist[r.depth] = (hist[r.depth] ?? 0) + 1;
      if (r.depth > kMaxQuestions) overBudget[label] = r.depth;
    });
    final sortedHist = (hist.keys.toList()..sort())
        .map((k) => '$k:${hist[k]}')
        .join(' ');
    print('CENSUS: ${mouths.length} mouths · depth(questions) $sortedHist');
    if (overBudget.isNotEmpty) print('OVER BUDGET (>$kMaxQuestions): $overBudget');
    expect(mouths.length, greaterThan(20),
        reason: 'the census must sample real mouths, not vacuously pass');
    expect(overBudget, isEmpty,
        reason: 'mouths exceeding the <=$kMaxQuestions contract: $overBudget');
  });
}
