/// PURE coverage of `keyboard_predictions.dart` — the bridge that turns the
/// dive engine's [NewbieQuestion] into the keyboard prediction-row chips
/// (STEP 3 of the "keyboard-becomes-the-card" fusion).
///
/// Hermetic over the REAL union pool (`kDivePool`) and the REAL lexicon
/// (`buildWordLexicon`) for the AskWords / ShowProducts cases — the same pure
/// primitives `word_finder_engine_test.dart` walks. No Flutter widgets are
/// built; only the engine construction needs the real data. `flutter_test`
/// supplies the standard `test`/`expect`/`group` harness.
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/keyboard_predictions.dart';
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:flutter_test/flutter_test.dart';

/// A const-friendly always-true predicate for the sentinel [NewbieStep]s that
/// push the engine past its AskWords branch (a top-level tear-off is const).
bool _alwaysTrue(LipskeyCatalogProduct _) => true;

/// Asserts the universal contract every [predictionChips] result must satisfy:
/// within the cap, no blanks, no duplicates.
void _assertChipContract(List<String> chips, int max) {
  expect(chips.length, lessThanOrEqualTo(max), reason: 'capped at max=$max');
  for (final c in chips) {
    expect(c.trim(), isNotEmpty, reason: 'no blank/empty chip: "$c"');
  }
  expect(chips.toSet().length, chips.length, reason: 'no duplicate chips');
}

void main() {
  group('keyboard_predictions — engine → prediction-row chips', () {
    final lexicon = buildWordLexicon(kDivePool);

    test('empty stack → AskWords → real lexicon words, capped, clean', () {
      final q = offerQuestion(const [], const [], lexicon, null);
      expect(q, isA<AskWords>(),
          reason: 'an empty stack must open with the word question');

      final chips = predictionChips(q);
      expect(chips, isNotEmpty,
          reason: 'the lexicon built from kDivePool yields words to offer');
      _assertChipContract(chips, 4); // default max

      // Every chip is a REAL lexicon word (the engine offers WordEntry.word
      // values; the bridge must surface them verbatim).
      final lexiconWords = {for (final e in lexicon.entries) e.word};
      for (final c in chips) {
        expect(lexiconWords.contains(c), isTrue,
            reason: '"$c" must be a genuine lexicon word');
      }

      // Order is preserved: the chips are the de-duped prefix of the offered
      // words (which are non-blank and already distinct by construction).
      final offered = (q as AskWords).words.map((w) => w.word).toList();
      expect(chips, offered.take(chips.length).toList(),
          reason: 'chips preserve the engine word order');
    });

    test('a small narrowed pool → ShowProducts → quickLabel chips', () {
      // A multi-card pool already at/under kShowProductsThreshold short-circuits
      // straight to ShowProducts (mirrors the engine test's small-pool case).
      // Three DISTINCT non-size words keep them as three separate cards.
      final pool = <LipskeyCatalogProduct>[
        for (var i = 0; i < 3; i++)
          LipskeyCatalogProduct(
            sku: 'KP-SMALL-$i',
            nameHe: 'מחבר סוג$i ½" ¾"',
            nameEn: 'connector type$i 1/2" 3/4"',
            categoryHe: 'מחברים',
            categoryEn: 'connectors',
            categoryEmoji: '🔩',
            page: 1,
          ),
      ];
      expect(distinctCardCount(pool), lessThanOrEqualTo(kShowProductsThreshold));

      // A sentinel word-step puts the engine past the AskWords branch.
      final stack = <NewbieStep>[
        const NewbieStep(
          axisLabel: 'מילה',
          chipLabel: 'מחבר',
          predicate: _alwaysTrue,
          crumbWord: 'מחבר',
        ),
      ];
      final q = offerQuestion(pool, stack, lexicon, null);
      expect(q, isA<ShowProducts>(),
          reason: 'a pool already <= threshold offers the products to pick');

      final chips = predictionChips(q);
      expect(chips, isNotEmpty, reason: 'ShowProducts yields product chips');
      _assertChipContract(chips, 4);

      // The chips ARE the quickLabel of the offered products, in engine order,
      // with blanks dropped and duplicates collapsed (first-wins) before the
      // cap — computed here from the SAME quickLabel the bridge calls, so the
      // assertion is exact regardless of how the token derivation labels them.
      final show = q as ShowProducts;
      final expected = <String>[];
      final seen = <String>{};
      for (final p in show.products) {
        final l = quickLabel(p).trim();
        if (l.isNotEmpty && seen.add(l)) expected.add(l);
        if (expected.length >= 4) break;
      }
      expect(chips, expected,
          reason: 'ShowProducts chips are the deduped quickLabel prefix');
    });

    test('AskAxis → its chips, in order, capped', () {
      // Build an AskAxis VALUE directly with sample chips and assert the mapping
      // (chips.take(max)) — the deterministic path the task blesses. The chips
      // here are non-blank and distinct, so all four survive the cleaner.
      const axis = AskAxis(
        'איזה גודל?',
        <String>['½"', '¾"', '1"', '2"'],
        'גודל',
      );
      final chips = predictionChips(axis);
      expect(chips, <String>['½"', '¾"', '1"', '2"'],
          reason: 'AskAxis surfaces its chip labels verbatim, in order');
      _assertChipContract(chips, 4);
    });

    test('AskAxis cleaner drops blanks + duplicates BEFORE the cap', () {
      // Raw chips with a blank, a whitespace-only entry and a duplicate. The
      // cleaner must remove all three (keeping first occurrence) BEFORE capping,
      // so the cap counts only the chips the user actually sees.
      const axis = AskAxis(
        'איזה צבע?',
        <String>['כרום', '', 'שחור', '   ', 'כרום', 'לבן'],
        'צבע',
      );
      final chips = predictionChips(axis);
      expect(chips, <String>['כרום', 'שחור', 'לבן'],
          reason: 'blanks + the duplicate "כרום" are dropped, order kept');
      _assertChipContract(chips, 4);
    });

    test('Resolve → the single product quickLabel', () {
      const product = LipskeyCatalogProduct(
        sku: 'KP-RES',
        nameHe: 'מחסום סיפון',
        nameEn: 'trap',
        categoryHe: 'מחסומים',
        categoryEn: 'traps',
        categoryEmoji: '🚰',
        page: 1,
      );
      const q = Resolve(product, <LipskeyCatalogProduct>[product]);
      final chips = predictionChips(q);
      expect(chips.length, 1, reason: 'Resolve yields exactly one chip');
      expect(chips.single, quickLabel(product),
          reason: 'the chip is the resolved product quickLabel');
      _assertChipContract(chips, 4);
    });

    test('a custom max caps the list (max: 2)', () {
      // Five distinct, non-blank chips → the cap must trim to exactly 2, keeping
      // the first two in order.
      const axis = AskAxis(
        'איזה גודל?',
        <String>['½"', '¾"', '1"', '1¼"', '2"'],
        'גודל',
      );
      final chips = predictionChips(axis, max: 2);
      expect(chips, <String>['½"', '¾"'],
          reason: 'max:2 keeps the first two chips, in order');
      _assertChipContract(chips, 2);

      // The same cap applies to the live AskWords path.
      final ask = offerQuestion(const [], const [], lexicon, null);
      final words = predictionChips(ask, max: 2);
      expect(words.length, lessThanOrEqualTo(2), reason: 'AskWords honours max');
    });
  });
}
