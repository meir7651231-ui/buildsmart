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
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show productHasChip;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:buildsmart/features/word_finder/word_finder_flag.dart';
import 'package:buildsmart/features/word_finder/word_finder_screen.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart';
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
      // Each distinct product renders as a tappable key bearing its trimmed
      // name — the icon-free BsKey idiom (NO icons added).
      final firstProductLabel = reached.products.first.nameHe.trim();
      expect(find.widgetWithText(BsKey, firstProductLabel), findsWidgets,
          reason: 'each ShowProducts product renders as a plain word-key');
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
    // The compatible parts render as plain word-keys (icon-free BsKey idiom).
    final firstPartLabel = parts.first.nameHe.trim();
    expect(find.widgetWithText(BsKey, firstPartLabel), findsWidgets,
        reason: 'each compatible part renders as a plain product key');
    // A WordKeyboard carries the part keys (reusing the existing key idiom).
    expect(find.byType(WordKeyboard), findsOneWidget,
        reason: 'the parts are rendered via the WordKeyboard key idiom');
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
}
