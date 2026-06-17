/// PURE property-based coverage of the minimal-distinction labeller
/// (`distinct_label.dart` → [distinctSelectionLabels]) — the fix for the
/// IDENTICAL-KEY bug where every converged product key showed the same plain
/// `quickLabel`.
///
/// Property-based over the REAL union pool (`kDivePool`) and the REAL lexicon
/// (`buildWordLexicon`) — NO invented skus. The core invariants are asserted
/// against the ACTUAL converged lists a dive would render:
///   • the distinct products of a resolved word ([distinctProducts] of
///     [resolveWord]) — the [ShowProducts] case, AND
///   • the compatible parts of a valid anchor ([connectionsFor]) — the
///     connections case (NOT collapse-deduped, so size/angle/colour also vary).
///
/// `flutter_test` is used only for `test`/`expect`/`group` — the project's
/// standard pure-logic harness (same as `word_finder_engine_test.dart` and
/// `connections_engine_test.dart`). No widgets are pumped.
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/distinct_label.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart'
    show quickLabel;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show connectionsFor, distinctProducts, isConnectionAnchor, resolveWord;
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The REAL lexicon over the REAL union pool — the same build the screen uses.
  final lex = buildWordLexicon(kDivePool);

  // sku → product over the real pool, for the connections fixture lookup.
  final bySku = {for (final p in kDivePool) p.sku: p};

  /// Assert the CORE distinction invariants on a converged [products] list:
  ///   1. one label per product (map size == distinct sku count),
  ///   2. every label is UNIQUE within the list (the bug's whole point),
  ///   3. every label STARTS WITH that product's bare `quickLabel` (the base
  ///      word is always the prefix — a distinction only ever APPENDS).
  void expectDistinctLabelInvariants(
    List<LipskeyCatalogProduct> products,
    String reasonTag,
  ) {
    final labels = distinctSelectionLabels(products);

    final distinctSkus = {for (final p in products) p.sku};
    expect(labels.length, distinctSkus.length,
        reason: '$reasonTag: exactly one label per distinct sku');

    // (2) all labels unique — the identical-key bug is gone.
    final values = labels.values.toList();
    expect(values.toSet().length, values.length,
        reason: '$reasonTag: every key label must be UNIQUE in the list '
            '(the identical-quickLabel bug)');

    // (3) each label starts with its product's plain base word.
    for (final p in products) {
      final label = labels[p.sku];
      expect(label, isNotNull,
          reason: '$reasonTag: every product sku is in the map');
      expect(label!.startsWith(quickLabel(p)), isTrue,
          reason: '$reasonTag: label "$label" must start with the base '
              'quickLabel "${quickLabel(p)}" (sku ${p.sku})');
    }
  }

  group('distinctSelectionLabels — edge cases', () {
    test('an empty list yields an empty map', () {
      expect(distinctSelectionLabels(const []), isEmpty,
          reason: 'no products → no labels');
    });

    test('a single product maps its sku to the bare quickLabel', () {
      final one = kDivePool.first;
      final labels = distinctSelectionLabels([one]);
      expect(labels, {one.sku: quickLabel(one)},
          reason: 'a lone product has no collision → the bare base word, no '
              'distinguishing suffix');
    });
  });

  group('distinctSelectionLabels — property over resolved-word lists', () {
    // SEED words: 'ברז' (the task's named anchor — a large, varied faucet pool)
    // plus the TWO next-highest-frequency lexicon words whose distinctProducts
    // list has >1 card (so the cascade is actually exercised, not a trivial
    // singleton). Discovered from the REAL lexicon so the seeds can never go
    // stale — the same discovery idiom word_finder_engine_test.dart uses.
    List<LipskeyCatalogProduct> distinctFor(String word) =>
        distinctProducts(resolveWord(word, lex));

    test("the named seed 'ברז' resolves to a multi-card list", () {
      final list = distinctFor('ברז');
      expect(list.length, greaterThan(1),
          reason: "'ברז' must be a real lexicon word resolving to several "
              'distinct cards — otherwise the distinction cascade is untested');
    });

    test("'ברז' converged list — all labels unique, prefixed by quickLabel", () {
      expectDistinctLabelInvariants(distinctFor('ברז'), "word 'ברז'");
    });

    test('two more common words — same invariants hold', () {
      // Highest-frequency words first; take the two most common (after 'ברז')
      // whose distinct-card list has >1 member. Plain Dart, no randomness.
      final byFreq = [...lex.entries]
        ..sort((a, b) => b.freq.compareTo(a.freq));
      final picks = <String>[];
      for (final e in byFreq) {
        if (e.word == 'ברז') continue; // 'ברז' is covered by its own test
        if (distinctFor(e.word).length > 1) {
          picks.add(e.word);
          if (picks.length == 2) break;
        }
      }
      expect(picks.length, 2,
          reason: 'the union pool must have at least two more common '
              'multi-card words to exercise the labeller');

      for (final word in picks) {
        final list = distinctFor(word);
        expect(list.length, greaterThan(1),
            reason: "discovered word '$word' must be multi-card");
        expectDistinctLabelInvariants(list, "word '$word'");
      }
    });
  });

  group('distinctSelectionLabels — property over a connections list', () {
    // The connections list is NOT collapse-deduped, so size/angle/colour ALSO
    // distinguish parts — the SECOND shape the labeller must handle. Anchor
    // 217861 is the verified DN32×DN32 PVC bottle trap used across the finder
    // tests (a valid anchor with a non-empty compatible set).
    final anchor = bySku['217861'];

    test('the fixture anchor exists and is a valid connection anchor', () {
      expect(anchor, isNotNull,
          reason: 'fixture sku 217861 must exist in kDivePool');
      expect(isConnectionAnchor(anchor!), isTrue,
          reason: '217861 is inCompat AND has a verified spec');
    });

    test('connections list — every key label is unique', () {
      final parts = connectionsFor(anchor!);
      expect(parts, isNotEmpty,
          reason: 'a DN32 PVC trap mates the DN32 drainage family — a '
              'non-empty list to label');
      // The connections case may legitimately surface parts whose quickLabel
      // differs, but the CONTRACT is the same: the rendered keys must be
      // mutually distinct so no two connection keys look identical.
      expectDistinctLabelInvariants(parts, 'connections(217861)');
    });
  });

  group(
      'distinctSelectionLabels — synthetic adversarial cases (regression guards '
      'for the subtle uniqueness paths the real-pool tests do not construct)',
      () {
    // Minimal product factory — only the fields the labeller reads (sku, nameHe,
    // color, brand) vary; the rest are inert constants. categoryHe is a non-real
    // 'בדיקה' so the quickLabel category-fallback never fires — every nameHe here
    // begins with a real plain word, so quickLabel is its first token.
    LipskeyCatalogProduct mk(String sku, String nameHe, {String? color}) =>
        LipskeyCatalogProduct(
          sku: sku,
          nameHe: nameHe,
          nameEn: '',
          color: color,
          categoryHe: 'בדיקה',
          categoryEn: 'test',
          categoryEmoji: '',
          page: 0,
        );

    test('same-spec different-sku variants → stable numeric (2)/(3) fallback',
        () {
      // Three identical rows: nothing distinguishes them, so the GLOBAL numeric
      // pass keeps the first bare and numbers the rest in input order.
      final out = distinctSelectionLabels([
        mk('A', 'ברז'),
        mk('B', 'ברז'),
        mk('C', 'ברז'),
      ]);
      expect(out, {'A': 'ברז', 'B': 'ברז (2)', 'C': 'ברז (3)'},
          reason: 'identical rows fall back to a stable numeric suffix by input '
              'order; the first stays bare');
    });

    test('an absent axis value is itself a distinction (colour present vs none)',
        () {
      // "" counts as its own value, so the colour axis splits them: the coloured
      // one grows a suffix, the bare one stays bare — and the two are distinct.
      final out = distinctSelectionLabels([
        mk('A', 'ברז', color: 'שחור'),
        mk('B', 'ברז'),
      ]);
      expect(out, {'A': 'ברז שחור', 'B': 'ברז'},
          reason: 'has-a-colour vs no-colour is a valid distinction; the empty '
              'one keeps the bare label');
    });

    test(
        'cascade: a name word splits one, colour splits the next, numeric closes '
        'the last tie', () {
      // p1 differs by a name word ('כפול'); p2 has a colour; p3 and p4 are
      // identical → word peels p1 off, colour peels p2 off, and the global
      // numeric pass separates the last two. Each axis touches ONLY the rows
      // still colliding after the previous one (the re-grouping contract).
      final out = distinctSelectionLabels([
        mk('1', 'ברז כפול'),
        mk('2', 'ברז יחיד', color: 'שחור'),
        mk('3', 'ברז יחיד'),
        mk('4', 'ברז יחיד'),
      ]);
      expect(out, {
        '1': 'ברז כפול',
        '2': 'ברז יחיד שחור',
        '3': 'ברז יחיד',
        '4': 'ברז יחיד (2)',
      },
          reason: 'word → colour → numeric cascade, each axis applied only to '
              'the rows still colliding after the previous one');
    });

    test('a mixed multi-group list is globally collision-free, every label '
        'prefixed by its quickLabel', () {
      // Several base-word groups concatenated into ONE list (the real call
      // shape). The whole-list contract: no two labels coincide ACROSS groups
      // (the global numeric pass guards the rare cross-group clash), and every
      // label still starts with its product's plain word.
      final products = [
        mk('a1', 'ברז'),
        mk('a2', 'ברז', color: 'שחור'),
        mk('b1', 'מסעף'),
        mk('b2', 'מסעף'),
        mk('b3', 'מסעף', color: 'לבן'),
        mk('c1', 'מחבר כפול'),
      ];
      final out = distinctSelectionLabels(products);
      expect(out.length, products.length, reason: 'one label per product');
      final values = out.values.toList();
      expect(values.toSet().length, values.length,
          reason: 'every label is unique across the whole multi-group list');
      for (final p in products) {
        expect(out[p.sku]!.startsWith(quickLabel(p)), isTrue,
            reason: 'label "${out[p.sku]}" must start with quickLabel '
                '"${quickLabel(p)}"');
      }
    });
  });
}
