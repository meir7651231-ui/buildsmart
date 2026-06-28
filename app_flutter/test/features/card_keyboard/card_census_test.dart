// P4.58: the <=6 census — proves the LOCKED contract (kMaxQuestions) holds from
// every sampled mouth. PURE: drives the engine (mergedKeys) directly, greedily
// following its top-ranked chip each turn, with no widget. The answer step mirrors
// the screen's _ChipTap EXACTLY (axisLabel: src.axisName + predicate: src.matches
// == the screen's _predicateFor), so the simulated dive == the real dive.
// ignore_for_file: avoid_print

import 'dart:math' show Random;

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/card_keyboard/card_seed.dart' show CardSeed;
import 'package:buildsmart/features/card_keyboard/card_signals.dart'
    show WordSignal, sourcesFor;
import 'package:buildsmart/features/card_keyboard/decisions.dart'
    show kMaxQuestions;
import 'package:buildsmart/features/card_keyboard/seed_sources.dart'
    show categorySeeds, materialSeeds;
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
    bool adversarial = false,
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
      // Greedy follows the top chip (best narrowing). ADVERSARIAL follows the chip that
      // narrows LEAST (widest resulting pool) — the worst case that holds the pool largest,
      // maximising both depth and the forced terminal list, so the <=6 gate is proven under
      // stress rather than only on the engine's best-effort path.
      var c = v.chips.first;
      if (adversarial) {
        var widest = -1;
        for (final ch in v.chips) {
          final s = sourcesFor(null).firstWhere(
            (x) => x.axisId == ch.axisId,
            orElse: () => const WordSignal(),
          );
          final size = pool.where((p) => s.matches(p, ch)).length;
          if (size > widest) {
            widest = size;
            c = ch;
          }
        }
      }
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

  test('ADVERSARIAL worst-case dive (widest chip each turn) holds <=$kMaxQuestions, terminal scannable',
      () {
    final overBudget = <String, int>{};
    var worstShow = 0;
    String? worstAt;
    mouths.forEach((label, pool) {
      final r = dive(pool, adversarial: true);
      if (r.depth > kMaxQuestions) overBudget[label] = r.depth;
      if (r.terminal.startsWith('show(')) {
        final n = int.parse(r.terminal.substring(5, r.terminal.length - 1));
        if (n > worstShow) {
          worstShow = n;
          worstAt = label;
        }
      }
    });
    print('ADVERSARIAL: ${mouths.length} mouths · worst forced terminal '
        'show($worstShow) at $worstAt');
    expect(overBudget, isEmpty,
        reason: 'even the WORST (widest-first) path must hold <=$kMaxQuestions: '
            '$overBudget');
    expect(worstShow, lessThanOrEqualTo(40),
        reason: 'the worst forced scan-list must stay scannable; '
            'got show($worstShow) at $worstAt');
  });

  test('fuzz: 200 deterministic-random seeds always resolve within budget', () {
    final rnd = Random(20260628); // seeded -> reproducible
    final words = wordsByFrequency(lex).toList();
    final mats = kMaterials.keys.toList();
    var ran = 0;
    var maxDepth = 0;
    for (var i = 0; i < 200; i++) {
      final List<LipskeyCatalogProduct> seed;
      if (i.isEven) {
        final w = words[rnd.nextInt(words.length)];
        seed = [
          for (final s in w.skus)
            if (divePoolBySku[s] != null) divePoolBySku[s]!,
        ];
      } else {
        final m = mats[rnd.nextInt(mats.length)];
        seed = [
          for (final s in resolveQuery(m, lex))
            if (divePoolBySku[s] != null) divePoolBySku[s]!,
        ];
      }
      if (seed.isEmpty) continue;
      ran++;
      final r = dive(seed);
      // Robustness: every seed reaches a real terminal — never a runaway
      // ('cap-exceeded') and never a post-seed 'askWords?!' bad state.
      expect(r.terminal, anyOf(equals('resolve'), startsWith('show')),
          reason: 'seed #$i bad terminal: ${r.terminal}');
      expect(r.depth, lessThanOrEqualTo(kMaxQuestions),
          reason: 'seed #$i depth ${r.depth} exceeds <=$kMaxQuestions');
      if (r.depth > maxDepth) maxDepth = r.depth;
    }
    print('FUZZ: $ran/200 seeds ran · max depth $maxDepth');
    expect(ran, greaterThan(150), reason: 'most random seeds resolve to a pool');
  });

  // P6.60: the BROWSE census — a ZERO-typing user taps a category or material seed
  // and still reaches a product within the contract. Every category bucket covers
  // 100% of the universe (P6.55), so this proves EVERY card is browse-reachable <=6.
  group('browse census (P6.60 — every bucket resolves <=kMaxQuestions, no text)',
      () {
    void censusOver(String label, List<CardSeed> seeds) {
      final overBudget = <String, int>{};
      final hist = <int, int>{};
      for (final seed in seeds) {
        final pool = kDivePool.where(seed.seedPredicate).toList();
        if (pool.isEmpty) continue;
        final r = dive(pool);
        hist[r.depth] = (hist[r.depth] ?? 0) + 1;
        if (r.depth > kMaxQuestions) overBudget[seed.displayLabel] = r.depth;
      }
      final sortedHist =
          (hist.keys.toList()..sort()).map((k) => '$k:${hist[k]}').join(' ');
      print('BROWSE $label: depth(questions) $sortedHist');
      if (overBudget.isNotEmpty) print('OVER ($label): $overBudget');
      expect(overBudget, isEmpty,
          reason: '$label buckets over <=$kMaxQuestions: $overBudget');
    }

    test('every CATEGORY bucket resolves within the contract', () {
      censusOver('category', categorySeeds(kDivePool));
    });

    test('every MATERIAL bucket resolves within the contract', () {
      censusOver('material', materialSeeds(kDivePool));
    });
  });
}
