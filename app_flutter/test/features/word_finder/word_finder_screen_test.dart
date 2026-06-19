// The screen's State subclass is library-private, so its @visibleForTesting
// getters/setters are reached through a `dynamic` view (the accepted
// visibleForTesting-via-dynamic pattern). That makes every access a dynamic
// call, and the `state.openSheetOnResolve = false` setter lines trip
// cascade_invocations — but a cascade would bind to the static `State` return
// of `tester.state(...)` (not the dynamic view) and fail to resolve, so they
// must stay separate statements. Both lints are suppressed file-wide rather
// than littering inline ignores.
// ignore_for_file: avoid_dynamic_calls, cascade_invocations
//
// WordFinderScreen — BEHAVIORAL widget test for the flag-gated newbie path.
//
// NOT a pixel/golden test (fonts are brittle): every assertion is on widget
// presence, tappable keys, or the engine's reached state. Two cases:
//
//   Test 1 (gated OFF): with `kWordFinderFlag` NOT seeded, the screen is a
//     zero-height shrink → no WordKeyboard mounts.
//
//   Test 2 (newbie path, flag ON): the first question + word keys render; we
//     pick a word KNOWN (computed live from `wordFinderLexicon`) to resolve to
//     a MULTI-card pool, tap it, then drive a bounded number (<=6) of "tap the
//     first offered key" steps until the engine RESOLVEs to a single distinct
//     card.
//
// WHY assert on the engine's reached state, not the opened sheet: opening the
// real `showLipskeyProductSheet` requires the sheet's heavy Riverpod deps
// (smartCartProvider, catalogSettingsProvider, image assets, …) which are not
// trivially supplyable in an isolated widget test. So per the STEP-5 contract
// we assert on the screen state's `@visibleForTesting` hooks
// (`currentQuestion` / `distinctCardsLeft`), which are the SAME values
// `build` switches on to decide whether to open the sheet — so reaching a
// `Resolve` here is exactly "the flow would open the product sheet now".
//
// Flag wiring mirrors `smart_suggestion_strip_test.dart`: seed the flag via
// `SharedPreferences.setMockInitialValues({'bs.feature-flags.v1': [...]})` and
// `pumpAndSettle()` so the FeatureFlagsNotifier's async `_load()` resolves
// before we read the gate. (This is equivalent to the `_app_demo.dart`
// `featureFlagsProvider.overrideWith(... .enable(...))` pattern, without the
// async-persist churn.)

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart'
    show SmartProduct, kSmartProducts, smartProductForSku;
import 'package:buildsmart/features/word_finder/distinct_label.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/material_lexicon.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show productHasChip;
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart'
    show quickLabel;
import 'package:buildsmart/features/word_finder/recipe_kit.dart'
    show KitLine, KitMatch, assembleKit;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:buildsmart/features/word_finder/word_finder_flag.dart';
import 'package:buildsmart/features/word_finder/word_finder_screen.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart';
import 'package:buildsmart/features/word_finder/word_keys_model.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery, searchRelevance;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_key.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Pump the screen inside a ProviderScope + MaterialApp, then settle so the
  /// feature-flag notifier's async `_load()` resolves before assertions.
  Future<void> pumpScreen(WidgetTester tester) async {
    // A tall phone-sized surface: the screen is a full keyboard UI (content +
    // word/emergency keyboard) that needs realistic height; the default
    // 800x600 test surface is too short and triggers RenderFlex overflow.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WordFinderScreen())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('gated OFF → no WordKeyboard (screen is shrink)', (tester) async {
    SharedPreferences.setMockInitialValues({}); // flag NOT set
    await pumpScreen(tester);

    expect(find.byType(WordKeyboard), findsNothing,
        reason: 'with kWordFinderFlag off the screen must render nothing');
  });

  testWidgets('SHORT screen: the key grid scrolls, never RenderFlex-overflows '
      '(canonical-audit crash guard)', (tester) async {
    // A deliberately short viewport: the opening 24-word grid is far taller than
    // the screen. Before the SingleChildScrollView wrap this threw a RenderFlex
    // overflow (the crash the canonical audit caught — the other tests masked it
    // by forcing a 1080x2400 surface). With the scroll wrap, the grid scrolls
    // and no exception is thrown.
    tester.view.physicalSize = const Size(360, 300);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': [kWordFinderFlag],
    });
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WordFinderScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WordKeyboard), findsOneWidget,
        reason: 'the word keyboard mounts on the short screen');
    expect(tester.takeException(), isNull,
        reason: 'a tall key grid must SCROLL within the bounded short screen, '
            'never throw a RenderFlex overflow');
  });

  testWidgets('newbie path: word → narrow → reach a product pick',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': [kWordFinderFlag], // flag ON
    });
    await pumpScreen(tester);

    // The first question + word keyboard are present.
    expect(find.byType(WordKeyboard), findsOneWidget,
        reason: 'flag on → the word keyboard mounts');
    expect(find.text(kFirstQuestion), findsOneWidget,
        reason: 'the opening prompt is the first question');

    // Grab the screen state to read the OFFERED first-question words and to
    // drive + assert on the engine's reached verdict. The State subclass is
    // library-private, so capture the public `State` base and reach the
    // @visibleForTesting getters via a `dynamic` view.
    final dynamic state = tester.state(find.byType(WordFinderScreen));

    // Do NOT auto-open the real product sheet on resolve: that needs the
    // sheet's heavy Riverpod deps (smartCart / catalogSettings / image assets)
    // we don't supply here. We assert on the engine's REACHED state instead —
    // the SAME value `build` switches on to decide whether to open the sheet,
    // so reaching a Resolve is exactly "the flow would open the sheet now".
    state.openSheetOnResolve = false;

    // The opening question is an AskWords showing only the top words; the seed
    // MUST be one of those (only offered words are tappable). Among the offered
    // words that resolve to a MULTI-card pool, take the one with the FEWEST
    // distinct cards (>1): data-driven (no hard-coded word that could drift),
    // small enough to reliably collapse within the bounded tap budget below,
    // yet still exercising the word→narrow→resolve path.
    final firstQ = state.currentQuestion;
    expect(firstQ, isA<AskWords>(),
        reason: 'the opening question must be a word ask');
    final offered = (firstQ as AskWords).words;
    final multiCardSeeds = <({String word, int cards})>[];
    for (final e in offered) {
      final products = resolveWord(e.word, wordFinderLexicon);
      final cards = distinctCardCount(products);
      if (products.length > 1 && cards > 1) {
        multiCardSeeds.add((word: e.word, cards: cards));
      }
    }
    expect(multiCardSeeds, isNotEmpty,
        reason: 'no OFFERED first-question word resolves to a multi-card pool '
            '— cannot exercise the narrow path');
    multiCardSeeds.sort((a, b) => a.cards.compareTo(b.cards));
    final seedWord = multiCardSeeds.first.word;

    // Tap the seed word on the keyboard (its key text is the word itself).
    final seedKey = find.widgetWithText(BsKey, seedWord);
    expect(seedKey, findsWidgets,
        reason: 'the chosen seed word must be offered as a key');
    await tester.tap(seedKey.first);
    await tester.pumpAndSettle();

    // After seeding, the engine is mid-dive: either already converged (Resolve
    // or ShowProducts) or asking an axis. Drive up to 6 "tap first key" steps
    // until it CONVERGES on a product pick. Convergence = Resolve (one distinct
    // card) OR ShowProducts (the cascade stopped narrowing and offers the
    // remaining products to pick) — both are terminal "now pick a product"
    // states; an endless re-asked axis is the bug this guards against.
    // Annotate as NewbieQuestion so `is AskAxis` promotes (state is dynamic).
    bool isConverged(NewbieQuestion q) => q is Resolve || q is ShowProducts;
    var converged = isConverged(state.currentQuestion as NewbieQuestion);
    var taps = 0;
    while (!converged && taps < 6) {
      // The current question must be an axis ask exposing chips to tap.
      final q = state.currentQuestion as NewbieQuestion;
      if (q is! AskAxis) break; // not converged and not an axis → can't proceed
      expect(q.chips, isNotEmpty,
          reason: 'an AskAxis must offer at least one narrowing chip');

      // Tap the first offered chip key.
      final firstChip = find.widgetWithText(BsKey, q.chips.first);
      expect(firstChip, findsWidgets,
          reason: 'the first axis chip must render as a key');
      await tester.tap(firstChip.first);
      await tester.pumpAndSettle();

      taps++;
      converged = isConverged(state.currentQuestion as NewbieQuestion);
    }

    // The bounded dive converged on a product pick — i.e. the flow would now
    // either open the product sheet (Resolve) or render product keys to tap
    // (ShowProducts). (We assert on the engine verdict, not the sheet, because
    // the real sheet needs providers we don't supply here.)
    expect(converged, isTrue,
        reason:
            'within $taps narrow taps (<=6) the cascade must converge on a '
            'product pick (Resolve or ShowProducts), never re-ask an axis');
  });

  // ── Shared flag-ON seeding + helpers ───────────────────────────────────────

  /// Seed the feature flag ON for the behavioral cases below.
  void seedFlagOn() => SharedPreferences.setMockInitialValues({
        'bs.feature-flags.v1': [kWordFinderFlag],
      });

  /// The live matched pool for [query] over the REAL union pool — the same
  /// `catalogProductMatchesQuery` predicate the screen's typed-query step uses.
  List<LipskeyCatalogProduct> matchedPool(String query) =>
      kDivePool.where((p) => catalogProductMatchesQuery(p, query)).toList();

  // ── Test 3: emergency typing re-seeds the dive AND ranks by relevance ──────

  testWidgets(
      'emergency typing: re-seeds the pool to the query and ranks by relevance',
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    // Don't auto-open the heavy product sheet on a single-card collapse.
    state.openSheetOnResolve = false;

    // Pick a DATA-DRIVEN query (no hard-coded word that could drift): the most
    // common product-name word whose match set has >1 product AND a non-flat
    // relevance spread (so ranking is observable, not a tie of equals). We draw
    // candidate words straight from kDivePool product names.
    final wordFreq = <String, int>{};
    for (final p in kDivePool) {
      for (final w in p.nameHe.split(RegExp(r'\s+'))) {
        if (w.length >= 2) wordFreq[w] = (wordFreq[w] ?? 0) + 1;
      }
    }
    final candidates = wordFreq.keys.toList()
      ..sort((a, b) => wordFreq[b]!.compareTo(wordFreq[a]!));
    String? query;
    for (final w in candidates) {
      final pool = matchedPool(w);
      if (pool.length < 2) continue;
      final scores = pool.map((p) => searchRelevance(p, w)).toSet();
      if (scores.length > 1) {
        // A spread of scores → ranking changes the order.
        query = w;
        break;
      }
    }
    expect(query, isNotNull,
        reason: 'kDivePool must offer a word query with a multi-product, '
            'non-flat-relevance match set to exercise ranking');
    final q = query!;

    final baselineCards = distinctCardCount(kDivePool);

    // Reveal the emergency typing surface via the keyboard's `הקלדה` key.
    final typeKey = find.widgetWithText(BsKey, 'הקלדה');
    expect(typeKey, findsOneWidget,
        reason: 'the word keyboard exposes a הקלדה (type) utility key');
    await tester.tap(typeKey);
    await tester.pumpAndSettle();

    // The typing surface is the real BsKeyboard over a TextField.
    expect(find.byType(TextField), findsOneWidget,
        reason: 'tapping הקלדה reveals a TextField to type into');
    expect(find.byType(BsKeyboard), findsOneWidget,
        reason: 'tapping הקלדה reveals the real BsKeyboard');

    // Type the query and submit it (the emergency path's onSubmitted).
    await tester.enterText(find.byType(TextField), q);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // The stack re-seeded to exactly the typed query.
    expect(state.crumbs, [q],
        reason: 'submitting a typed query clears the stack and re-seeds it to '
            'a single search step whose crumb IS the query');

    // The pool narrowed away from the full union pool.
    expect(state.distinctCardsLeft, lessThan(baselineCards),
        reason: 'a matching typed query narrows the pool below the full pool');

    // RANKING (Fix 2): the first product of the live pool is a top-relevance
    // match for the query. Assert membership in the max-score set so a
    // relevance TIE still passes (deterministic base order breaks the tie).
    final pool = matchedPool(q);
    final maxScore =
        pool.map((p) => searchRelevance(p, q)).reduce((a, b) => a > b ? a : b);
    final topSkus = {
      for (final p in pool)
        if (searchRelevance(p, q) == maxScore) p.sku,
    };
    final first = state.firstPoolProduct as LipskeyCatalogProduct?;
    expect(first, isNotNull, reason: 'a matching query has a non-empty pool');
    expect(topSkus.contains(first!.sku), isTrue,
        reason: 'the relevance-ranked pool puts a highest-searchRelevance '
            'product first (got sku ${first.sku}, score '
            '${searchRelevance(first, q)} vs max $maxScore)');
  });

  // ── Test 4: empty-pool → neutral empty-state, not a zero-chip AskAxis ──────

  testWidgets('empty-pool: a no-match typed query renders the empty-state',
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // A query no product can match — long, all-Latin gibberish (kDivePool names
    // are Hebrew; SKU match needs >=5 chars AND digits). Assert it truly
    // matches nothing so the test pins the empty-pool behavior, not a typo.
    const noMatch = 'zzzqqqxxxnomatch';
    expect(matchedPool(noMatch), isEmpty,
        reason: 'the chosen query must match no real product');

    final typeKey = find.widgetWithText(BsKey, 'הקלדה');
    await tester.tap(typeKey);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), noMatch);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // The neutral empty-state text renders...
    expect(find.text('לא נמצא מוצר מתאים — נסה שוב'), findsOneWidget,
        reason: 'an empty pool must show the neutral empty-state, never a '
            'silent zero-chip keyboard');
    // ...and a restart affordance is offered, while the dead-end word keyboard
    // is NOT shown (it would be a zero-key AskAxis).
    expect(find.text('התחל מחדש'), findsOneWidget,
        reason: 'the empty-state offers a restart way-back');
    expect(find.byType(WordKeyboard), findsNothing,
        reason: 'the empty-state replaces the (would-be empty) word keyboard');

    // The engine WOULD have produced a zero-product ShowProducts (an empty pool
    // has no splitting axis, so the convergence guard returns ShowProducts with
    // the empty distinct-product set) — confirm the screen chose the empty-state
    // over surfacing that dead-end.
    final q = state.currentQuestion as NewbieQuestion;
    expect(q, isA<ShowProducts>(),
        reason: 'the underlying engine verdict on an empty pool is a '
            'ShowProducts (no axis splits an empty pool)');
    expect((q as ShowProducts).products, isEmpty,
        reason: 'that ShowProducts carries zero products — the dead-end the '
            'screen replaces with the empty-state');

    // Restart clears the dive back to the first word question.
    await tester.tap(find.text('התחל מחדש'));
    await tester.pumpAndSettle();
    expect(state.crumbs, isEmpty,
        reason: 'התחל מחדש clears the answered stack');
    expect(state.currentQuestion, isA<AskWords>(),
        reason: 'a cleared dive is back at the opening word question');
    expect(find.byType(WordKeyboard), findsOneWidget,
        reason: 'the word keyboard is back after a restart');
  });

  // ── Test 5: back-nav pops a step; pop on empty stack is a safe no-op ───────

  testWidgets('back-nav: tap a word, then the חזרה control clears one step',
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // Choose an offered first-question word that does NOT immediately resolve
    // to one card (so the back button + crumb appear and there's a step to
    // pop). Data-driven from the live AskWords list.
    final firstQ = state.currentQuestion as AskWords;
    String? seedWord;
    for (final e in firstQ.words) {
      final products = resolveWord(e.word, wordFinderLexicon);
      if (products.length > 1 && distinctCardCount(products) > 1) {
        seedWord = e.word;
        break;
      }
    }
    expect(seedWord, isNotNull,
        reason: 'an offered word must seed a multi-card pool to exercise back');
    final w = seedWord!;

    await tester.tap(find.widgetWithText(BsKey, w).first);
    await tester.pumpAndSettle();
    expect(state.crumbs.length, 1,
        reason: 'tapping a word pushes exactly one answered step');

    // The back control is the Semantics-labeled 'חזרה' button (tooltip too).
    final backBtn = find.byTooltip('חזרה');
    expect(backBtn, findsOneWidget,
        reason: 'a non-empty stack shows the חזרה back control');
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(state.crumbs, isEmpty,
        reason: 'חזרה pops the only step → empty breadcrumb');
    expect(state.currentQuestion, isA<AskWords>(),
        reason: 'an empty stack returns to the opening word question');

    // Popping again at an EMPTY stack must be a safe no-op (no throw, still
    // AskWords). The back control is now gone, so call the popper directly.
    state.openSheetOnResolve = false;
    expect(state.popStepForTest, returnsNormally,
        reason: 'popping at an empty stack is a guarded no-op');
    expect(state.crumbs, isEmpty);
    expect(state.currentQuestion, isA<AskWords>());
  });

  // ── Test 6: first AskWords renders word keys and NO icons ──────────────────

  testWidgets('first-words: top offered words render as keys with no icons',
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    final firstQ = state.currentQuestion as AskWords;
    expect(firstQ.words, isNotEmpty,
        reason: 'the first question must offer words');

    // The top few offered words each render as a BsKey with that text.
    final topWords = firstQ.words.take(3).map((e) => e.word);
    for (final w in topWords) {
      expect(find.widgetWithText(BsKey, w), findsWidgets,
          reason: 'offered first-question word "$w" must render as a key');
    }

    // The first screen is icon-free: word/chip keys are KeyKind.letter (no
    // icon) and the back arrow only appears once a step is answered.
    expect(find.byType(Icon), findsNothing,
        reason: 'the opening word screen shows no icons (no back arrow yet, '
            'and word keys are plain text)');
  });

  // ── Test 8: multi-size CONVERGENCE — reaches a ShowProducts pick, no loop ──

  testWidgets(
      'multi-size pool: tapping a size reaches a product pick (ShowProducts), '
      'never an endless איזה גודל', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // Helper: a question has converged on a product pick (either ShowProducts
    // — render product keys — or Resolve — open the sheet).
    bool isConverged(NewbieQuestion q) => q is ShowProducts || q is Resolve;

    // DATA-DRIVEN seed: among the OFFERED first-question words, take the one
    // whose dive — driven by "tap the first chip each turn" — reaches a
    // ShowProducts pick within the tap bound (the multi-size convergence path,
    // exactly what the engine now guards). We simulate the dive PURELY first
    // (no taps) to choose a seed, then replay it through the real UI. This
    // avoids hard-coding a faucet word that could drift in the catalog.
    final firstQ = state.currentQuestion as AskWords;
    const tapBound = 6;
    String? seedWord;
    for (final e in firstQ.words) {
      var pool = resolveWord(e.word, wordFinderLexicon);
      if (pool.length < 2 || distinctCardCount(pool) < 2) continue;
      final stack = <NewbieStep>[
        NewbieStep(
          axisLabel: 'דגם',
          chipLabel: e.word,
          predicate: (_) => true,
          crumbWord: e.word,
        ),
      ];
      var reachedShow = false;
      for (var i = 0; i < tapBound; i++) {
        final q = offerQuestion(pool, stack, wordFinderLexicon, null);
        if (q is ShowProducts) {
          reachedShow = true;
          break;
        }
        if (q is! AskAxis || q.chips.isEmpty) break;
        final chip = q.chips.first;
        pool = pool.where((p) => productHasChip(p, chip)).toList();
        stack.add(NewbieStep(
          axisLabel: q.axisLabel,
          chipLabel: chip,
          predicate: (p) => productHasChip(p, chip),
          crumbWord: chip,
        ));
      }
      if (reachedShow) {
        seedWord = e.word;
        break;
      }
    }
    expect(seedWord, isNotNull,
        reason: 'kDivePool must offer a word whose dive reaches a ShowProducts '
            'pick (the multi-size convergence path) within $tapBound taps');
    final w = seedWord!;

    // Replay through the REAL UI: tap the seed word, then "tap the first chip"
    // until the screen renders the ShowProducts product-pick. The same axis
    // must NEVER appear twice in a row (the loop the fix removes).
    await tester.tap(find.widgetWithText(BsKey, w).first);
    await tester.pumpAndSettle();

    String? lastAxis;
    var converged = isConverged(state.currentQuestion as NewbieQuestion);
    var taps = 0;
    while (!converged && taps < tapBound) {
      final q = state.currentQuestion as NewbieQuestion;
      if (q is! AskAxis) break;
      expect(q.axisLabel == lastAxis, isFalse,
          reason: 'the SAME axis ("${q.axisLabel}") must not be asked twice in '
              'a row — that is the multi-size loop this fix removes');
      lastAxis = q.axisLabel;
      await tester.tap(find.widgetWithText(BsKey, q.chips.first).first);
      await tester.pumpAndSettle();
      taps++;
      converged = isConverged(state.currentQuestion as NewbieQuestion);
    }

    expect(converged, isTrue,
        reason: 'within $taps taps (<=$tapBound) the cascade converged on a '
            'product pick, never an endless איזה גודל');

    // When the convergence is a ShowProducts, the screen renders the distinct
    // products as plain word-keys (BsKey) — assert the product pick is on
    // screen and tappable. (A Resolve would instead open the sheet, which we
    // suppressed; both are valid termini, but the seed was chosen to reach
    // ShowProducts.)
    final reached = state.currentQuestion as NewbieQuestion;
    if (reached is ShowProducts) {
      expect(reached.products, isNotEmpty,
          reason: 'a ShowProducts pick offers the remaining products');
      expect(find.text(kPickProductQuestion), findsOneWidget,
          reason: 'the ShowProducts header prompts the user to pick a product');
      // Each distinct product renders as a tappable key bearing its DISTINCT
      // plain label — the short word (quickLabel) plus the MINIMAL distinguishing
      // suffix the labeller adds so two same-word cards never look identical —
      // via the icon-free BsKey idiom (NO icons). (Fix: distinct selection labels.)
      final labels = distinctSelectionLabels(reached.products);
      final firstProductLabel = labels[reached.products.first.sku]!;
      expect(find.widgetWithText(BsKey, firstProductLabel), findsWidgets,
          reason: 'each ShowProducts product renders as a distinct plain word-key');
      expect(find.byType(WordKeyboard), findsOneWidget,
          reason: 'the product pick reuses the WordKeyboard key idiom');
    }
  });

  // ── Test 7: 'הכל' characterization — current intended no-op ────────────────

  testWidgets("'הכל' on an AskAxis is a no-op (pinned; real skip is owner-gated)",
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // Seed a multi-card word so the next question is an AskAxis (so 'הכל' is
    // meaningful). Data-driven from the offered words.
    final firstQ = state.currentQuestion as AskWords;
    String? seedWord;
    for (final e in firstQ.words) {
      final products = resolveWord(e.word, wordFinderLexicon);
      if (products.length > 1 && distinctCardCount(products) > 1) {
        seedWord = e.word;
        break;
      }
    }
    expect(seedWord, isNotNull);
    await tester.tap(find.widgetWithText(BsKey, seedWord!).first);
    await tester.pumpAndSettle();

    // We need to be on an AskAxis for 'הכל' to be on screen / meaningful.
    final before = state.currentQuestion as NewbieQuestion;
    if (before is! AskAxis) {
      // The seed collapsed straight to Resolve — 'הכל' isn't shown; skip the
      // characterization rather than assert a false invariant.
      return;
    }

    final crumbsBefore = List<String>.from(state.crumbs as Iterable);
    final cardsBefore = state.distinctCardsLeft;

    // Tap the 'הכל' utility key.
    final allKey = find.widgetWithText(BsKey, 'הכל');
    expect(allKey, findsOneWidget,
        reason: 'an AskAxis screen shows the הכל utility key');
    await tester.tap(allKey);
    await tester.pumpAndSettle();

    // CHARACTERIZATION: 'הכל' is a pinned no-op for now — it re-renders but
    // neither narrows the pool nor advances the question. (Turning it into a
    // real skip-axis is owner-gated.)
    final after = state.currentQuestion as NewbieQuestion;
    expect(after, isA<AskAxis>(),
        reason: 'הכל does not advance the question (still the same axis ask)');
    expect((after as AskAxis).axisLabel, before.axisLabel,
        reason: 'הכל leaves the current axis unchanged');
    expect(state.distinctCardsLeft, cardsBefore,
        reason: 'הכל performs no narrowing — distinct card count is unchanged');
    expect(state.crumbs, crumbsBefore,
        reason: 'הכל adds no breadcrumb step');
  });

  // ── Test 9: 7th engine — "מה מתחבר לזה" connections view ───────────────────

  testWidgets(
      'connections: opening an anchor shows compatible parts as keys (no icons), '
      'back closes the view', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // A KNOWN valid anchor from the real pool: '217861' (PVC DN32 bottle trap),
    // confirmed inCompat + hasSpec by dive_pool_test. Pulled live from kDivePool
    // (no fabricated product). The connections view's entry key is only rendered
    // inside a ShowProducts state, so we drive the view through the screen's
    // @visibleForTesting hook (`showConnectionsForTest`) — the SAME method the
    // 'מה מתחבר לזה?' key calls — rather than navigating the dive onto an anchor.
    final anchor = kDivePool.firstWhere((p) => p.sku == '217861');
    expect(isConnectionAnchor(anchor), isTrue,
        reason: 'fixture must be a valid anchor');

    // The parts the engine says connect — the EXPECTED on-screen product keys.
    final parts = connectionsFor(anchor);
    expect(parts, isNotEmpty,
        reason: 'a valid anchor must yield at least one compatible part');

    // Open the connections view.
    state.showConnectionsForTest(anchor);
    await tester.pumpAndSettle();

    expect(state.connectionsViewOpen as bool, isTrue,
        reason: 'the hook opens the connections view');
    // The view's header renders (OWNER-REVIEW copy).
    expect(find.text(kConnectionsHeader), findsWidgets,
        reason: 'the connections view shows its header');
    // The compatible parts render as plain word-keys (icon-free BsKey idiom):
    // the DISTINCT plain label (quickLabel + minimal distinguishing suffix), NOT
    // the full nameHe. The connections list is NOT collapse-deduped, so the
    // labeller may use size/colour to tell same-word parts apart.
    final partLabels = distinctSelectionLabels(parts);
    final firstPartLabel = partLabels[parts.first.sku]!;
    expect(find.widgetWithText(BsKey, firstPartLabel), findsWidgets,
        reason: 'each compatible part renders as a distinct plain product key');
    // A WordKeyboard carries the part keys (reusing the existing key idiom).
    expect(find.byType(WordKeyboard), findsOneWidget,
        reason: 'the parts are rendered via the WordKeyboard key idiom');
    // Fix 3: the connections view has NO skip/type affordance, so the
    // הכל/הקלדה utility row is suppressed — those keys must NOT render here.
    expect(find.widgetWithText(BsKey, 'הכל'), findsNothing,
        reason: 'the connections view passes showUtilityRow:false → no הכל key');
    expect(find.widgetWithText(BsKey, 'הקלדה'), findsNothing,
        reason: 'the connections view passes showUtilityRow:false → no הקלדה key');
    // The shown set equals the engine's connectionsFor (the screen adds no
    // compat logic of its own).
    final shown = (state.connectionsShown as List).cast<LipskeyCatalogProduct>();
    expect(shown.map((p) => p.sku).toSet(),
        parts.map((p) => p.sku).toSet(),
        reason: 'the view shows exactly connectionsFor(anchor)');

    // The view's back control closes it (a single back arrow tooltip is present;
    // the breadcrumb back is absent because the dive stack is empty here).
    final backBtn = find.byTooltip('חזרה');
    expect(backBtn, findsOneWidget,
        reason: 'the connections view offers a חזרה back control');
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    expect(state.connectionsViewOpen as bool, isFalse,
        reason: 'tapping back closes the connections view');
  });

  // ── Test 9b (Fix 2): exactly ONE back control even with a non-empty dive ────
  //
  // The breadcrumb back appears whenever the dive stack is non-empty; a sub-view
  // (connections / kit) brings its OWN back. The bug guarded here is BOTH showing
  // at once (two 'חזרה' arrows). The screen suppresses the breadcrumb back while
  // any sub-view is open (the single `_subViewOpen` guard), so even with a
  // non-empty stack UNDER an open connections view there must be exactly one
  // back control.

  testWidgets(
      'back control: a sub-view over a non-empty dive shows exactly ONE חזרה '
      '(breadcrumb back is suppressed)', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // Drive the dive to a NON-EMPTY stack: tap an offered word that seeds a
    // multi-card pool (so a step persists and the breadcrumb back would show).
    final firstQ = state.currentQuestion as AskWords;
    String? seedWord;
    for (final e in firstQ.words) {
      if (resolveWord(e.word, wordFinderLexicon).length > 1) {
        seedWord = e.word;
        break;
      }
    }
    expect(seedWord, isNotNull,
        reason: 'need an offered word seeding a multi-card pool');
    await tester.tap(find.widgetWithText(BsKey, seedWord!).first);
    await tester.pumpAndSettle();
    expect(state.crumbs, isNotEmpty,
        reason: 'the dive now has a non-empty stack (breadcrumb would show)');

    // Sanity: with NO sub-view open and a non-empty stack, the breadcrumb back
    // is the single back control.
    expect(find.byTooltip('חזרה'), findsOneWidget,
        reason: 'a non-empty dive shows the breadcrumb back');

    // Open the connections view ON TOP of the non-empty dive (a known anchor).
    final anchor = kDivePool.firstWhere((p) => p.sku == '217861');
    expect(isConnectionAnchor(anchor), isTrue);
    state.showConnectionsForTest(anchor);
    await tester.pumpAndSettle();
    expect(state.connectionsViewOpen as bool, isTrue);

    // EXACTLY ONE back control — the connections view's own back; the breadcrumb
    // back is suppressed (no double 'חזרה').
    expect(find.byTooltip('חזרה'), findsOneWidget,
        reason: 'a sub-view over a non-empty dive must show EXACTLY ONE back '
            'control — the breadcrumb back is suppressed while a sub-view owns '
            'its own back');

    // Closing the sub-view restores the (single) breadcrumb back.
    await tester.tap(find.byTooltip('חזרה'));
    await tester.pumpAndSettle();
    expect(state.connectionsViewOpen as bool, isFalse);
    expect(find.byTooltip('חזרה'), findsOneWidget,
        reason: 'closing the sub-view returns to the single breadcrumb back');
  });

  // ── Test 10: 7th engine — a non-anchor opens NO connections view ───────────

  testWidgets('connections: a non-anchor product opens no view (guarded)',
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // '171026' — a toilet seat ('מושבי אסלה'), deliberately without a verified
    // spec → NOT an anchor. The screen's enter-guard must refuse to open the
    // view (so a non-anchor can never present an empty/confusing connections UI).
    final seat = kDivePool.firstWhere((p) => p.sku == '171026');
    expect(isConnectionAnchor(seat), isFalse,
        reason: 'fixture must be a non-anchor');

    state.showConnectionsForTest(seat);
    await tester.pumpAndSettle();

    expect(state.connectionsViewOpen as bool, isFalse,
        reason: 'opening connections for a non-anchor is a guarded no-op');
    expect(find.text(kConnectionsHeader), findsNothing,
        reason: 'no connections header for a non-anchor');
  });

  // ── Test 11 (Fix 1): a ShowProducts key shows the PLAIN word, not nameHe ────

  testWidgets(
      'plain-word labels: a ShowProducts product key renders quickLabel '
      '(the short plain word), NOT the full technical nameHe', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // DATA-DRIVEN seed (same approach as Test 8): pick an offered first-question
    // word whose "tap the first chip each turn" dive reaches a ShowProducts pick
    // within the tap bound — simulated PURELY first, then replayed via the UI.
    final firstQ = state.currentQuestion as AskWords;
    const tapBound = 6;
    String? seedWord;
    for (final e in firstQ.words) {
      var pool = resolveWord(e.word, wordFinderLexicon);
      if (pool.length < 2 || distinctCardCount(pool) < 2) continue;
      final stack = <NewbieStep>[
        NewbieStep(
          axisLabel: 'דגם',
          chipLabel: e.word,
          predicate: (_) => true,
          crumbWord: e.word,
        ),
      ];
      var reachedShow = false;
      for (var i = 0; i < tapBound; i++) {
        final q = offerQuestion(pool, stack, wordFinderLexicon, null);
        if (q is ShowProducts) {
          reachedShow = true;
          break;
        }
        if (q is! AskAxis || q.chips.isEmpty) break;
        final chip = q.chips.first;
        pool = pool.where((p) => productHasChip(p, chip)).toList();
        stack.add(NewbieStep(
          axisLabel: q.axisLabel,
          chipLabel: chip,
          predicate: (p) => productHasChip(p, chip),
          crumbWord: chip,
        ));
      }
      if (reachedShow) {
        seedWord = e.word;
        break;
      }
    }
    expect(seedWord, isNotNull,
        reason: 'kDivePool must offer a word whose dive reaches a ShowProducts '
            'pick within $tapBound taps to exercise plain-word labels');
    final w = seedWord!;

    // Replay through the real UI to the ShowProducts pick.
    await tester.tap(find.widgetWithText(BsKey, w).first);
    await tester.pumpAndSettle();
    var taps = 0;
    while (state.currentQuestion is! ShowProducts && taps < tapBound) {
      final q = state.currentQuestion as NewbieQuestion;
      if (q is! AskAxis || q.chips.isEmpty) break;
      await tester.tap(find.widgetWithText(BsKey, q.chips.first).first);
      await tester.pumpAndSettle();
      taps++;
    }
    final reached = state.currentQuestion as NewbieQuestion;
    expect(reached, isA<ShowProducts>(),
        reason: 'the chosen seed must converge on a ShowProducts pick');
    final products = (reached as ShowProducts).products;
    expect(products, isNotEmpty);

    // Pick a rendered product whose PLAIN word genuinely differs from its full
    // nameHe (catalog names are multi-word jargon; quickLabel folds to the first
    // meaningful token), so the assertion proves simplification, not a tautology.
    LipskeyCatalogProduct? simplified;
    for (final p in products) {
      if (quickLabel(p) != p.nameHe.trim()) {
        simplified = p;
        break;
      }
    }
    expect(simplified, isNotNull,
        reason: 'the converged ShowProducts list must contain at least one '
            'product whose quickLabel differs from its full nameHe');
    final p = simplified!;

    // The key bears the DISTINCT plain label — quickLabel(p) plus, if it
    // collided, a minimal distinguishing suffix; it always STARTS WITH the plain
    // word and never becomes the full jargon nameHe.
    final showLabels = distinctSelectionLabels(products);
    final pLabel = showLabels[p.sku]!;
    expect(pLabel.startsWith(quickLabel(p)), isTrue,
        reason: 'the distinct label still starts with the plain word quickLabel(p)');
    expect(find.widgetWithText(BsKey, pLabel), findsWidgets,
        reason: 'the product key renders the distinct plain label');
    // ...and the FULL technical nameHe is NOT rendered on any key (the
    // simplify-to-words vision — full jargon must not leak onto the key face).
    expect(find.widgetWithText(BsKey, p.nameHe.trim()), findsNothing,
        reason: 'the full technical nameHe must NOT appear as a key label');
  });

  // ── Test 12 (Fix 2): tapping the SECOND of a same-label pair → SECOND sku ───

  testWidgets(
      'sku resolution: two distinct cards sharing a plain word both resolve by '
      'sku — tapping the SECOND reaches the SECOND product, not the first',
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // Two REAL, DISTINCT skus from kDivePool that share an IDENTICAL nameHe
    // ('ונטיל לכיור אמריקאי') → identical quickLabel ('ונטיל'). This is exactly
    // the bug fixture from the wall-check: 117 identical-nameHe groups where a
    // label match always returned the FIRST, making the 2nd unreachable.
    final first = kDivePool.firstWhere((p) => p.sku == '178700');
    final second = kDivePool.firstWhere((p) => p.sku == '187700');
    expect(first.sku, isNot(second.sku),
        reason: 'fixture skus must be distinct');
    expect(first.nameHe, second.nameHe,
        reason: 'fixture skus must share an identical nameHe (the bug trigger)');
    expect(quickLabel(first), quickLabel(second),
        reason: 'identical nameHe → identical plain-word label, so a label '
            'match could never tell the two apart');

    // The products list the converged cascade / connections view would carry,
    // with BOTH same-label cards present (order: first, then second).
    final products = <LipskeyCatalogProduct>[first, second];

    // Build the product keys exactly as the screen does: label = plain word,
    // payload = the product's UNIQUE sku.
    final firstKey = WordKey(quickLabel(first), payload: first.sku);
    final secondKey = WordKey(quickLabel(second), payload: second.sku);
    expect(firstKey.label, secondKey.label,
        reason: 'both keys show the SAME plain word — only the sku payload '
            'distinguishes them');

    // Resolve each key against the list using the SAME sku-keyed lookup the live
    // tap handler uses. The SECOND key must resolve to the SECOND product — the
    // label-match bug (always returning products.first) is gone.
    final resolvedSecond = state.resolveTappedProductForTest(products, secondKey)
        as LipskeyCatalogProduct?;
    expect(resolvedSecond, isNotNull,
        reason: 'a key whose sku payload is in the list must resolve');
    expect(resolvedSecond!.sku, second.sku,
        reason: 'tapping the SECOND same-label card resolves to the SECOND sku '
            '(${second.sku}), NOT the first (${first.sku}) — the label-match '
            'bug this fix removes would have returned the first');

    // And the first key still resolves to the first product (sanity: resolution
    // is by the unique payload, not by list position).
    final resolvedFirst = state.resolveTappedProductForTest(products, firstKey)
        as LipskeyCatalogProduct?;
    expect(resolvedFirst!.sku, first.sku,
        reason: 'the first key resolves to the first sku by its payload');
  });

  // ── Test 13 (Fix 3): the NORMAL cascade keyboard KEEPS the utility row ──────

  testWidgets(
      'utility row: the normal word/chip cascade keyboard still shows '
      'הכל and הקלדה (showUtilityRow defaults true)', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    // On the opening AskWords cascade keyboard (no connections view), both
    // utility keys are present — the default showUtilityRow:true is preserved.
    expect(find.byType(WordKeyboard), findsOneWidget,
        reason: 'the opening cascade renders the word keyboard');
    expect(find.widgetWithText(BsKey, 'הכל'), findsOneWidget,
        reason: 'the normal cascade keeps the הכל utility key');
    expect(find.widgetWithText(BsKey, 'הקלדה'), findsOneWidget,
        reason: 'the normal cascade keeps the הקלדה utility key');
  });

  // ── Test 14: product thumbnails — ShowProducts keys carry a thumbnail Image,
  //    the opening AskWords word keys stay clean (image-free) ─────────────────

  testWidgets(
      'thumbnails: a ShowProducts product key contains an Image while an '
      'AskWords word key does not (word keys stay clean)', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // The opening AskWords screen is entirely image-free: word keys are plain
    // text (no thumbnail), and the only other widgets are text/util keys.
    expect(state.currentQuestion, isA<AskWords>(),
        reason: 'the opening question must be a word ask');
    expect(find.byType(Image), findsNothing,
        reason: 'the opening word screen shows NO thumbnails — word keys are '
            'plain text only (clean by default)');

    // Mirror the product/`imageFile` rule the screen uses (`_thumbAssetFor`): a
    // thumbnail is shown ONLY for a real per-product crop — imageFile non-null
    // and NOT a full `page_` catalog image. Used to compute the EXACT number of
    // thumbnail Images the converged product list should render.
    bool hasThumb(LipskeyCatalogProduct p) {
      final f = p.imageFile;
      return f != null && !f.startsWith('page_');
    }

    // DATA-DRIVEN seed (same pure-simulation approach as Test 8/11): pick an
    // offered first-question word whose "tap the first chip each turn" dive
    // reaches a ShowProducts pick that contains AT LEAST ONE thumbnail-bearing
    // product — so the assertion below actually observes a rendered Image.
    final firstQ = state.currentQuestion as AskWords;
    const tapBound = 6;
    String? seedWord;
    var reachedProducts = <LipskeyCatalogProduct>[];
    for (final e in firstQ.words) {
      var pool = resolveWord(e.word, wordFinderLexicon);
      if (pool.length < 2 || distinctCardCount(pool) < 2) continue;
      final stack = <NewbieStep>[
        NewbieStep(
          axisLabel: 'דגם',
          chipLabel: e.word,
          predicate: (_) => true,
          crumbWord: e.word,
        ),
      ];
      List<LipskeyCatalogProduct>? show;
      for (var i = 0; i < tapBound; i++) {
        final q = offerQuestion(pool, stack, wordFinderLexicon, null);
        if (q is ShowProducts) {
          show = q.products;
          break;
        }
        if (q is! AskAxis || q.chips.isEmpty) break;
        final chip = q.chips.first;
        pool = pool.where((p) => productHasChip(p, chip)).toList();
        stack.add(NewbieStep(
          axisLabel: q.axisLabel,
          chipLabel: chip,
          predicate: (p) => productHasChip(p, chip),
          crumbWord: chip,
        ));
      }
      if (show != null && show.any(hasThumb)) {
        seedWord = e.word;
        reachedProducts = show;
        break;
      }
    }
    expect(seedWord, isNotNull,
        reason: 'kDivePool must offer a word whose dive reaches a ShowProducts '
            'pick containing at least one real-crop product (a thumbnail)');
    final w = seedWord!;

    // Replay through the REAL UI to the ShowProducts pick.
    await tester.tap(find.widgetWithText(BsKey, w).first);
    await tester.pumpAndSettle();
    var taps = 0;
    while (state.currentQuestion is! ShowProducts && taps < tapBound) {
      final q = state.currentQuestion as NewbieQuestion;
      if (q is! AskAxis || q.chips.isEmpty) break;
      await tester.tap(find.widgetWithText(BsKey, q.chips.first).first);
      await tester.pumpAndSettle();
      taps++;
    }
    final reached = state.currentQuestion as NewbieQuestion;
    expect(reached, isA<ShowProducts>(),
        reason: 'the chosen seed must converge on a ShowProducts pick');
    final products = (reached as ShowProducts).products;
    // The live converged list matches the pure simulation that chose the seed.
    expect(products.map((p) => p.sku).toSet(),
        reachedProducts.map((p) => p.sku).toSet(),
        reason: 'the replayed dive reaches the same ShowProducts list');

    // The number of thumbnail Images on screen equals the number of converged
    // products that carry a real crop — proving product keys (and ONLY product
    // keys) render a thumbnail. In the test environment the asset bytes never
    // decode, so each Image paints its errorBuilder SizedBox.shrink, but the
    // Image WIDGET stays mounted → find.byType(Image) is a resilient presence
    // check (no pixels asserted), exactly the brittle-proof approach required.
    final expectedThumbs = products.where(hasThumb).length;
    expect(expectedThumbs, greaterThan(0),
        reason: 'the chosen ShowProducts list has at least one thumbnail');
    expect(find.byType(Image), findsNWidgets(expectedThumbs),
        reason: 'each real-crop product key renders exactly one thumbnail '
            'Image; non-crop / navigation / util keys render none');

    // Structural guard: a thumbnail Image is a DESCENDANT of a product BsKey.
    // Pick the first thumbnail-bearing product and assert its key contains an
    // Image (it still exposes its plain text label, so widgetWithText matches).
    final showLabels = distinctSelectionLabels(products);
    final withThumb = products.firstWhere(hasThumb);
    final thumbLabel = showLabels[withThumb.sku]!;
    final thumbKey = find.widgetWithText(BsKey, thumbLabel);
    expect(thumbKey, findsWidgets,
        reason: 'a real-crop product key still exposes its plain text label');
    expect(
      find.descendant(of: thumbKey.first, matching: find.byType(Image)),
      findsOneWidget,
      reason: 'the thumbnail Image is a descendant of the product key',
    );
  });

  // ── Test 15: 6th engine — the work-recipe KIT view ─────────────────────────
  //
  // The kit view (engine #6, "מתכון העבודה") shows, for a reached WORK-product,
  // the assembled kit: each accessory's recommended product + collapsible
  // alternatives, and un-catalogued accessories as honest plain text. Driven via
  // the screen's @visibleForTesting `showKitForTest` hook (the SAME method the
  // 'בנה לי את הערכה' key calls) — the entry key only renders inside a
  // ShowProducts state for a work-product, so a test reaches the view through
  // the hook rather than navigating the dive onto a specific product (the same
  // pattern Test 9 uses for connections).

  /// A DATA-DRIVEN kit fixture, derived from the real tree so it can never drift
  /// to a hard-coded recipe: the FIRST [SmartProduct] that simultaneously
  ///  (a) is a real WORK-product — one of its brand skus resolves back via
  ///      `smartProductForSku` to ITSELF (so `_kitEntryRecipe` would pick it),
  ///  (b) has a kit line carrying a RECOMMENDED product PLUS alternatives whose
  ///      product+alternatives include >=3 with an IDENTICAL nameHe (so
  ///      `distinctSelectionLabels` is genuinely exercised — three same-name,
  ///      different-size variants must render distinct), and
  ///  (c) has at least one un-catalogued ([KitMatch.none]) accessory (so the
  ///      plain-text branch is exercised).
  ({SmartProduct recipe, String selfSku, KitLine richLine})? findKitFixture() {
    for (final r in kSmartProducts) {
      // (a) a self-mapping brand sku.
      String? selfSku;
      for (final b in r.brands) {
        final s = b.sku;
        if (s != null && identical(smartProductForSku(s), r)) {
          selfSku = s;
          break;
        }
      }
      if (selfSku == null) continue;

      final kit = assembleKit(r);
      // (c) an un-catalogued accessory line.
      if (!kit.any((l) => l.match == KitMatch.none)) continue;

      // (b) a line whose product + alternatives contain >=3 identical names.
      KitLine? richLine;
      for (final l in kit) {
        final p = l.product;
        if (p == null || l.alternatives.length < 2) continue;
        final byName = <String, int>{};
        for (final q in <LipskeyCatalogProduct>[p, ...l.alternatives]) {
          byName[q.nameHe] = (byName[q.nameHe] ?? 0) + 1;
        }
        if (byName.values.any((c) => c >= 3)) {
          richLine = l;
          break;
        }
      }
      if (richLine == null) continue;

      return (recipe: r, selfSku: selfSku, richLine: richLine);
    }
    return null;
  }

  testWidgets(
      'kit view: opens for a work-product and shows its accessory keys + the '
      'work name header', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    final fx = findKitFixture();
    expect(fx, isNotNull,
        reason: 'kSmartProducts must offer a work-product whose kit has an '
            'identical-name alternatives line AND an un-catalogued accessory');
    final recipe = fx!.recipe;
    // Sanity: the fixture really is a work-product (the entry-seam predicate).
    expect(smartProductForSku(fx.selfSku), isNotNull,
        reason: 'the fixture brand sku must resolve to a work recipe (the '
            '_kitEntryRecipe seam test)');

    // Open the kit view through the hook (the same method the buildkit key calls).
    state.showKitForTest(recipe);
    await tester.pumpAndSettle();

    expect(state.kitViewOpen as bool, isTrue,
        reason: 'the hook opens the kit view');
    // The header is the work-recipe name.
    expect(find.text(recipe.name), findsWidgets,
        reason: 'the kit view header shows the work-recipe name');

    // At least one RESOLVED accessory (a product line) renders as a tappable
    // BsKey bearing its distinct plain label — proving accessory keys render.
    final kit = assembleKit(recipe);
    final firstProductLine =
        kit.firstWhere((l) => l.product != null);
    final lineProducts = <LipskeyCatalogProduct>[
      firstProductLine.product!,
      ...firstProductLine.alternatives,
    ];
    final recLabel =
        distinctSelectionLabels(lineProducts)[firstProductLine.product!.sku]!;
    expect(find.widgetWithText(BsKey, recLabel), findsWidgets,
        reason: 'a resolved accessory renders as a product key bearing its '
            'distinct plain label');
    // The kit view reuses the WordKeyboard key idiom.
    expect(find.byType(WordKeyboard), findsWidgets,
        reason: 'kit lines render product keys via the WordKeyboard idiom');
  });

  testWidgets(
      'kit view: three same-name products render with DISTINCT labels '
      '(distinctSelectionLabels applied to product + alternatives)',
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    final fx = findKitFixture();
    expect(fx, isNotNull);
    final richLine = fx!.richLine;

    // The labeller's output over the line's product + alternatives. Because the
    // line has >=3 IDENTICAL nameHe, a naive label (the bare quickLabel) would
    // collide; the labeller must add a minimal distinguishing suffix so EVERY
    // label in the line is unique.
    final lineProducts = <LipskeyCatalogProduct>[
      richLine.product!,
      ...richLine.alternatives,
    ];
    final labels = distinctSelectionLabels(lineProducts);
    final distinctLabels = labels.values.toSet();
    expect(distinctLabels.length, lineProducts.length,
        reason: 'distinctSelectionLabels must make EVERY product in a same-name '
            'line unique (no two identical key faces)');

    state.showKitForTest(fx.recipe);
    await tester.pumpAndSettle();

    // Expand the alternatives so all the same-name variants are on screen.
    expect(richLine.alternatives, isNotEmpty);
    final more = find.textContaining('עוד אפשרויות');
    expect(more, findsWidgets,
        reason: 'a line with alternatives offers a "עוד אפשרויות" expander');
    await tester.tap(more.first);
    await tester.pumpAndSettle();

    // The RECOMMENDED product and EACH alternative render under their DISTINCT
    // label (e.g. three "אטם דו צדדי" become size-distinguished), and crucially
    // the bare (undistinguished) shared name is NOT what the keys show.
    for (final p in lineProducts) {
      expect(find.widgetWithText(BsKey, labels[p.sku]!), findsWidgets,
          reason: 'each same-name product renders under its distinct label '
              '"${labels[p.sku]}"');
    }
  });

  testWidgets(
      'kit view: "עוד אפשרויות" is collapsed by default and reveals the '
      'alternatives when tapped', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    final fx = findKitFixture();
    expect(fx, isNotNull);
    final richLine = fx!.richLine;
    final lineProducts = <LipskeyCatalogProduct>[
      richLine.product!,
      ...richLine.alternatives,
    ];
    final labels = distinctSelectionLabels(lineProducts);
    // An alternative whose distinct label differs from the recommended one (so
    // its appearance is an observable change, not already-on-screen text).
    final altLabel = labels[richLine.alternatives.first.sku]!;
    final recLabel = labels[richLine.product!.sku]!;
    expect(altLabel, isNot(recLabel),
        reason: 'the alternative must carry a label distinct from the '
            'recommended product (the labeller guarantees this)');

    state.showKitForTest(fx.recipe);
    await tester.pumpAndSettle();

    // DEFAULT COLLAPSED: the recommended product is visible, the alternative is
    // NOT yet rendered.
    expect(find.widgetWithText(BsKey, recLabel), findsWidgets,
        reason: 'the recommended product is always visible');
    expect(find.widgetWithText(BsKey, altLabel), findsNothing,
        reason: 'alternatives are collapsed by default — not yet on screen');

    // Tap the "עוד אפשרויות (N)" expander → the alternative key appears.
    final more = find.textContaining('עוד אפשרויות');
    expect(more, findsWidgets);
    await tester.tap(more.first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(BsKey, altLabel), findsWidgets,
        reason: 'expanding "עוד אפשרויות" reveals the alternatives as keys');
  });

  testWidgets(
      'kit view: an un-catalogued accessory shows as plain text (אין בקטלוג), '
      'not a key', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    final fx = findKitFixture();
    expect(fx, isNotNull);
    final recipe = fx!.recipe;
    final noneLine =
        assembleKit(recipe).firstWhere((l) => l.match == KitMatch.none);

    state.showKitForTest(recipe);
    await tester.pumpAndSettle();

    // The un-catalogued accessory is listed honestly as plain text with the
    // "אין בקטלוג" note, and is NOT rendered as a tappable product key.
    expect(find.text('${noneLine.acc.name} (אין בקטלוג)'), findsOneWidget,
        reason: 'a KitMatch.none accessory is shown as plain text with the '
            'not-in-catalog note');
    expect(find.widgetWithText(BsKey, noneLine.acc.name), findsNothing,
        reason: 'an un-catalogued accessory is NOT a tappable key');
  });

  testWidgets(
      'kit view: a back control closes it back to the dive', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    final fx = findKitFixture();
    expect(fx, isNotNull);
    state.showKitForTest(fx!.recipe);
    await tester.pumpAndSettle();
    expect(state.kitViewOpen as bool, isTrue);

    final backBtn = find.byTooltip('חזרה');
    expect(backBtn, findsOneWidget,
        reason: 'the kit view offers a single חזרה back control');
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    expect(state.kitViewOpen as bool, isFalse,
        reason: 'tapping back closes the kit view');
  });

  testWidgets(
      'kit view SHORT screen: a long kit scrolls, never RenderFlex-overflows '
      '(audit crash guard)', (tester) async {
    // The same crash-guard the main dive carries (the canonical audit lesson): a
    // long kit (many accessories, each with an expandable alternatives block) is
    // far taller than a short phone viewport. The kit view MUST live inside the
    // build()'s Expanded + SingleChildScrollView, so the content scrolls and no
    // RenderFlex overflow is thrown at 360x300.
    tester.view.physicalSize = const Size(360, 300);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    seedFlagOn();
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WordFinderScreen())),
    );
    await tester.pumpAndSettle();

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    final fx = findKitFixture();
    expect(fx, isNotNull);
    state.showKitForTest(fx!.recipe);
    await tester.pumpAndSettle();

    expect(state.kitViewOpen as bool, isTrue,
        reason: 'the kit view is open on the short screen');
    expect(tester.takeException(), isNull,
        reason: 'a tall kit must SCROLL within the bounded short screen, never '
            'throw a RenderFlex overflow');
  });

  testWidgets('kit view: flag OFF → inert (no kit view, screen is a shrink)',
      (tester) async {
    SharedPreferences.setMockInitialValues({}); // flag NOT set
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));

    // Even if the kit state is forced open, a flag-OFF screen renders nothing —
    // the self-gate short-circuits build() before the kit view branch.
    final fx = findKitFixture();
    expect(fx, isNotNull);
    state.showKitForTest(fx!.recipe);
    await tester.pumpAndSettle();

    expect(find.byType(WordKeyboard), findsNothing,
        reason: 'with kWordFinderFlag off the gated screen renders nothing, so '
            'no kit keyboard mounts');
    expect(find.text(fx.recipe.name), findsNothing,
        reason: 'the kit view (its work-name header) must not render while the '
            'feature flag is off');
  });

  testWidgets('opening word list offers the "עוד…" expand key', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': [kWordFinderFlag],
    });
    await pumpScreen(tester);

    expect(find.widgetWithText(BsKey, kMoreWordsKey), findsOneWidget,
        reason: 'the opening list offers a show-more-words key');
    expect(find.widgetWithText(BsKey, kFewerWordsKey), findsNothing,
        reason: 'the collapse key only appears once expanded');
  });

  testWidgets('"עוד…" reveals a word hidden below the top-cut, "פחות" collapses '
      'it back', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': [kWordFinderFlag],
    });
    await pumpScreen(tester);
    final dynamic state = tester.state(find.byType(WordFinderScreen));

    // A word GUARANTEED below the opening cut: the (kFirstWordCount+1)-th by
    // frequency. Data-driven (no hard-coded 'ניפל' that could drift) — by
    // construction it is NOT in the opening list.
    final all = wordsByFrequency(wordFinderLexicon);
    expect(all.length, greaterThan(kFirstWordCount),
        reason: 'this test only means something when a hidden tail EXISTS');
    final hiddenWord = all[kFirstWordCount].word;

    expect(find.widgetWithText(BsKey, hiddenWord), findsNothing,
        reason: '$hiddenWord is below the cut → not shown while collapsed');
    expect(state.showAllWordsActive, isFalse);

    await tester.tap(find.widgetWithText(BsKey, kMoreWordsKey));
    await tester.pumpAndSettle();

    expect(state.showAllWordsActive, isTrue);
    expect(find.widgetWithText(BsKey, hiddenWord), findsOneWidget,
        reason: 'after "עוד…" every lexicon word (incl. the hidden tail) is '
            'reachable by tap — the whole point of the affordance');
    expect(find.widgetWithText(BsKey, kFewerWordsKey), findsOneWidget,
        reason: 'expanded → the collapse key shows');
    expect(find.widgetWithText(BsKey, kMoreWordsKey), findsNothing,
        reason: 'expanded → the expand key is replaced by collapse');

    await tester.tap(find.widgetWithText(BsKey, kFewerWordsKey));
    await tester.pumpAndSettle();

    expect(state.showAllWordsActive, isFalse);
    expect(find.widgetWithText(BsKey, hiddenWord), findsNothing,
        reason: 'collapsed again → the hidden word is hidden again');
    expect(find.widgetWithText(BsKey, kMoreWordsKey), findsOneWidget);
  });

  testWidgets('restart resets the expansion (no leak across dives)',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': [kWordFinderFlag],
    });
    await pumpScreen(tester);
    final dynamic state = tester.state(find.byType(WordFinderScreen));

    await tester.tap(find.widgetWithText(BsKey, kMoreWordsKey));
    await tester.pumpAndSettle();
    expect(state.showAllWordsActive, isTrue);

    state.restartForTest();
    await tester.pumpAndSettle();

    expect(state.showAllWordsActive, isFalse,
        reason: 'a fresh dive must open collapsed — no expansion leak');
    expect(find.widgetWithText(BsKey, kMoreWordsKey), findsOneWidget);
  });

  // ── Material axis ("ציר-חומר"): the opening material entry ──────────────────
  //
  // The finder gains a material-FIRST entry: at the opening the user picks a
  // material (נחושת / PPR / …) → the dive filters to that material and the noun
  // keys then show only that material's parts, after which the normal
  // word→size→colour cascade continues unchanged. These tests assert the entry
  // is offered, that picking a material scopes the words to that material, and —
  // the MONEY TEST — that the entry SURFACES a copper part unreachable from the
  // full opening's top-24. Driven via the @visibleForTesting hooks
  // (pickMaterialForTest / activeMaterial / restartForTest), mirroring Test 9's
  // connections pattern: the material chip-row only renders at the opening, so a
  // test reaches the entry through the hook AND (for the chip-presence case) by
  // finding the rendered key.

  testWidgets('material axis: the opening offers a נחושת material chip',
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    // נחושת is a material present in the full pool (SCOUT DATA ~111), so the
    // opening chip-row must render a נחושת key.
    expect(materialsInPool(kDivePool), contains('נחושת'),
        reason: 'נחושת must be a material present in the union pool');
    expect(find.widgetWithText(BsKey, 'נחושת'), findsOneWidget,
        reason: 'the opening material chip-row offers a נחושת key');
    // The leading caption is shown too.
    expect(find.text(kByMaterialLabel), findsOneWidget,
        reason: 'the material chip-row shows its "לפי חומר" caption');
  });

  testWidgets(
      'material axis: picking נחושת scopes the word keys to copper nouns AND '
      'surfaces a part unreachable from the full opening (MONEY TEST)',
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // The copper pool + its scoped lexicon, computed live (no hard-coded sku).
    final copperPool = productsOfMaterial(kDivePool, 'נחושת');
    expect(copperPool, isNotEmpty,
        reason: 'the copper pool must be non-empty to exercise the entry');
    final copperWords =
        buildWordLexicon(copperPool).entries.map((e) => e.word).toSet();

    // Pick the material through the hook (the SAME state change the chip tap
    // performs).
    state.pickMaterialForTest('נחושת');
    await tester.pumpAndSettle();

    // The material is recorded and the opening is back to a word ask.
    expect(state.activeMaterial as String?, 'נחושת',
        reason: 'pickMaterialForTest records the picked material');
    final scopedQ = state.currentQuestion;
    expect(scopedQ, isA<AskWords>(),
        reason: 'after picking a material the opening is still a word ask, now '
            'scoped to that material');

    // The offered words are a SUBSET of the copper nouns (the scoped lexicon
    // never offers a word that names no copper product).
    final offered = (scopedQ as AskWords).words.map((e) => e.word).toSet();
    expect(offered.difference(copperWords), isEmpty,
        reason: 'every offered word after picking נחושת must be a copper noun '
            '(the words are scoped to the copper pool)');

    // A noun that exists ONLY in copper (its word is in the copper lexicon but
    // NOT in the FULL union lexicon's word set) — proof the scoping is real.
    final fullWords =
        wordFinderLexicon.entries.map((e) => e.word).toSet();
    final copperOnly = copperWords.difference(fullWords);
    // (copperOnly may be empty if every copper word also appears globally; the
    // MONEY TEST below is the stronger, always-meaningful assertion.)

    // ── MONEY TEST ──────────────────────────────────────────────────────────
    // A word present in the copper pool but NOT in the full opening's top-24 is
    // OFFERED after picking נחושת — proving the material entry surfaces parts
    // unreachable before. Compute the full top-24 opening word set live, then a
    // copper word outside it that the scoped opening DOES offer.
    final fullTop24 = wordsByFrequency(wordFinderLexicon)
        .take(kFirstWordCount)
        .map((e) => e.word)
        .toSet();
    final surfaced =
        offered.firstWhere((w) => !fullTop24.contains(w), orElse: () => '');
    expect(surfaced, isNot(''),
        reason: 'picking נחושת must offer at least one word that the full '
            'opening top-$kFirstWordCount did NOT — the whole point of the '
            'material entry (copperOnly words: $copperOnly)');
    expect(find.widgetWithText(BsKey, surfaced), findsWidgets,
        reason: 'the surfaced copper word "$surfaced" renders as a tappable key '
            'after picking נחושת');
  });

  testWidgets(
      'material axis: clearing (restart) returns the full word list and drops '
      'the material', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);

    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    // The full opening word set, before any material is picked.
    final fullOffered = (state.currentQuestion as AskWords)
        .words
        .map((e) => e.word)
        .toSet();

    state.pickMaterialForTest('נחושת');
    await tester.pumpAndSettle();
    expect(state.activeMaterial as String?, 'נחושת');

    // Clear via restart (the SAME reset path _restart / the 'כל החומרים' clear
    // uses).
    state.restartForTest();
    await tester.pumpAndSettle();

    expect(state.activeMaterial as String?, isNull,
        reason: 'clearing the material returns to ALL materials');
    final clearedQ = state.currentQuestion;
    expect(clearedQ, isA<AskWords>(),
        reason: 'a cleared dive is back at the opening word question');
    expect((clearedQ as AskWords).words.map((e) => e.word).toSet(), fullOffered,
        reason: 'clearing the material restores the FULL (union) opening word '
            'list, identical to before any material was picked');
    // The material chip-row is offered again (back at the all-materials opening).
    expect(find.widgetWithText(BsKey, 'נחושת'), findsOneWidget,
        reason: 'the material chip-row returns after clearing');
  });

  testWidgets(
      'material axis: the breadcrumb keeps the material once the dive starts '
      '(MAJOR-fix lock)', (tester) async {
    seedFlagOn();
    await pumpScreen(tester);
    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    state.pickMaterialForTest('נחושת');
    await tester.pumpAndSettle();

    // Start the dive: tap the first scoped copper noun so the stack is non-empty
    // (the point at which the breadcrumb row renders).
    final noun = (state.currentQuestion as AskWords).words.first.word;
    final nounKey = find.widgetWithText(BsKey, noun).first;
    await tester.ensureVisible(nounKey);
    await tester.tap(nounKey);
    await tester.pumpAndSettle();

    // Mid-dive the material context must persist in the rendered breadcrumb —
    // otherwise the user loses the copper scope (the MAJOR finding this fixes).
    expect(find.textContaining('נחושת'), findsWidgets,
        reason: 'the breadcrumb must keep the material once diving in');
  });

  testWidgets(
      'material axis: back from the first noun keeps the material (stable scope)',
      (tester) async {
    seedFlagOn();
    await pumpScreen(tester);
    final dynamic state = tester.state(find.byType(WordFinderScreen));
    state.openSheetOnResolve = false;

    state.pickMaterialForTest('נחושת');
    await tester.pumpAndSettle();

    final noun = (state.currentQuestion as AskWords).words.first.word;
    final nounKey = find.widgetWithText(BsKey, noun).first;
    await tester.ensureVisible(nounKey);
    await tester.tap(nounKey);
    await tester.pumpAndSettle();

    // Back (pop the noun) → the material is KEPT (returns to the copper opening,
    // not all the way out to all-materials).
    state.popStepForTest();
    await tester.pumpAndSettle();

    expect(state.activeMaterial as String?, 'נחושת',
        reason: 'back from the first material-scoped noun keeps the material '
            '(stable scope); the user exits only via כל החומרים');
  });
}
