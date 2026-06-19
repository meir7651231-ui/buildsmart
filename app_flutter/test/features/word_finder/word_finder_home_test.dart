// WordFinderHome — BEHAVIORAL widget test for the unified "one keyboard, two
// modes" entry (manual toggle between the newbie cascade and the quick pad).
//
// NOT a pixel/golden test (fonts are brittle): every assertion is on widget
// presence, the active IndexedStack index, or a known toggle label.
//
// STATE-PRESERVATION NOTE: the host body is an [IndexedStack], so BOTH child
// screens stay MOUNTED whenever the flag is on — only the selected one is shown
// (the index), the other is retained offstage so its in-progress State survives
// a toggle. Tests therefore assert on which child is SELECTED (the IndexedStack
// index, and the visible/offstage split via `skipOffstage`), NOT on which is
// merely mounted — the mount set no longer distinguishes the modes.
//
//   Test 1 (flag ON, default mode): the host defaults to the NEWBIE cascade →
//     IndexedStack.index == 0 and the cascade's WordKeyboard is the VISIBLE
//     (non-offstage) keyboard. (newbie-first, per 'מתחילים פשוט-לכולם'.)
//
//   Test 2 (flag ON, tap the 'המהיר שלי' toggle): tapping the quick-pad
//     segment selects the pad → IndexedStack.index == 1 and the QuickPadKeyboard
//     is the VISIBLE keyboard. We seed productFavoritesProvider with a REAL
//     kDivePool sku (data-driven, drift-proof) so the pad renders its KEYBOARD
//     rather than its empty-state — mirroring quick_pad_screen_test.dart.
//
//   Test 3 (gated OFF): with kWordFinderFlag NOT seeded, the host is a
//     zero-height shrink → neither keyboard mounts and there is no IndexedStack.
//
//   Test 4 (state preservation across a toggle): drive the cascade into a
//     mid-dive state (answered step), flip to the pad and back, and assert the
//     cascade kept its in-progress breadcrumb — the IndexedStack's reason to
//     exist (a plain switch-on-_mode body would rebuild it fresh each flip).
//
// Flag wiring mirrors word_finder_screen_test.dart / quick_pad_screen_test.dart:
// seed the flag via SharedPreferences.setMockInitialValues({'bs.feature-flags
// .v1': [...]}) and pumpAndSettle() so the FeatureFlagsNotifier's async
// _load() resolves before we read the gate. Where we also need seeded
// favorites we layer a ProviderContainer override (as quick_pad_screen_test
// does) on top of the SharedPreferences-seeded flag.

import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/quick_pad_keyboard.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show AskWords, resolveWord;
import 'package:buildsmart/features/word_finder/word_finder_flag.dart';
import 'package:buildsmart/features/word_finder/word_finder_home.dart';
import 'package:buildsmart/features/word_finder/word_finder_screen.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A favorites notifier pre-seeded with `skus` — used to override
/// `productFavoritesProvider` so the quick pad has deterministic picks (and
/// thus renders its KEYBOARD, not the empty state) without depending on
/// SharedPreferences ordering. Mirrors `quick_pad_screen_test.dart`.
class _SeededFavorites extends ProductFavoritesNotifier {
  _SeededFavorites(Set<String> skus) {
    state = skus;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The quick-pad segment label on the host toggle row (OWNER-REVIEW copy).
  const quickPadToggleLabel = 'המהיר שלי';

  /// The active child index of the host's [IndexedStack] (0 = cascade,
  /// 1 = quick pad). Reads the single IndexedStack the host body builds.
  int activeIndex(WidgetTester tester) =>
      // IndexedStack.index is int? (null = show nothing); the host always sets
      // 0 (cascade) or 1 (quick pad), so default a null to 0 for the int return.
      tester.widget<IndexedStack>(find.byType(IndexedStack)).index ?? 0;

  testWidgets(
      'flag ON: defaults to the newbie cascade (index 0, WordKeyboard visible)',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': [kWordFinderFlag], // flag ON
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: WordFinderHome())),
      ),
    );
    await tester.pumpAndSettle();

    // The default mode is the cascade → the IndexedStack selects index 0 and the
    // VISIBLE (non-offstage) keyboard is the cascade's WordKeyboard. With no
    // favorites seeded the pad child renders its empty-state (not a
    // QuickPadKeyboard), so no QuickPadKeyboard mounts at all here.
    expect(activeIndex(tester), 0,
        reason: 'the host defaults to the newbie cascade (index 0)');
    expect(find.byType(WordKeyboard, skipOffstage: false), findsOneWidget,
        reason: 'the cascade WordKeyboard is mounted as the default surface');
    expect(find.byType(QuickPadKeyboard), findsNothing,
        reason: 'unseeded favorites → the pad shows its empty-state, no keyboard');
  });

  testWidgets(
      "flag ON: tapping 'המהיר שלי' selects the quick pad "
      '(index 1, QuickPadKeyboard visible)', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': [kWordFinderFlag], // flag ON
    });

    // Seed favorites with a REAL kDivePool sku (data-driven, drift-proof) so
    // the quick pad renders its KEYBOARD rather than its empty-state text.
    final favSet = kDivePool.take(3).map((p) => p.sku).toSet();
    expect(favSet, isNotEmpty,
        reason: 'need >=1 real sku so the pad shows its keyboard, not empty');

    final container = ProviderContainer(
      overrides: [
        productFavoritesProvider
            .overrideWith((ref) => _SeededFavorites(favSet)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: WordFinderHome())),
      ),
    );
    await tester.pumpAndSettle();

    // Sanity: we start on the cascade (index 0). With favorites seeded the pad
    // child IS mounted (the IndexedStack keeps both alive) but it is OFFSTAGE —
    // the cascade's WordKeyboard is the visible keyboard.
    expect(activeIndex(tester), 0, reason: 'host starts on the cascade');
    expect(find.byType(WordKeyboard), findsOneWidget,
        reason: 'the cascade keyboard is visible at the start');

    // Tap the 'המהיר שלי' toggle segment → select the quick pad.
    final toggle = find.text(quickPadToggleLabel);
    expect(toggle, findsOneWidget,
        reason: 'the quick-pad toggle segment must render as plain text');
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    // Now the IndexedStack selects index 1 and the quick pad's keyboard is the
    // VISIBLE one; the cascade's keyboard is offstage (mounted, not shown).
    expect(activeIndex(tester), 1,
        reason: 'tapping the toggle selects the quick pad (index 1)');
    expect(find.byType(QuickPadKeyboard), findsOneWidget,
        reason: 'the quick pad keyboard is now the visible surface');
    expect(find.byType(WordKeyboard), findsNothing,
        reason: 'the cascade keyboard is offstage after selecting the pad');
  });

  testWidgets(
      'a11y: the active toggle segment carries Semantics selected:true, the '
      'inactive one selected:false (and it flips on tap)', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': [kWordFinderFlag], // flag ON
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: WordFinderHome())),
      ),
    );
    await tester.pumpAndSettle();

    // The active state is colour-only on the key face, so each segment wraps its
    // BsKey in a Semantics(selected:) node. Inspect that widget's own
    // SemanticsProperties directly (robust to how the flag merges into the
    // semantics tree): the Semantics whose subtree contains the label's Text.
    bool selectedFor(String label) {
      final node = find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.selected != null,
        ),
      );
      expect(node, findsOneWidget,
          reason: 'segment "$label" wraps its key in a selected: Semantics');
      return tester.widget<Semantics>(node).properties.selected!;
    }

    // Default mode is the cascade → 'מצא לי' is selected, 'המהיר שלי' is not.
    expect(selectedFor('מצא לי'), isTrue,
        reason: 'the active cascade segment announces selected');
    expect(selectedFor('המהיר שלי'), isFalse,
        reason: 'the inactive quick-pad segment announces not-selected');

    // Tap the quick-pad segment → the selected flag flips to it.
    await tester.tap(find.text('המהיר שלי'));
    await tester.pumpAndSettle();
    expect(selectedFor('המהיר שלי'), isTrue,
        reason: 'after tapping, the quick-pad segment is the selected one');
    expect(selectedFor('מצא לי'), isFalse,
        reason: 'the cascade segment is no longer selected after the switch');
  });

  testWidgets('gated OFF: host renders neither keyboard (no IndexedStack)',
      (tester) async {
    SharedPreferences.setMockInitialValues({}); // flag NOT set

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: WordFinderHome())),
      ),
    );
    await tester.pumpAndSettle();

    // The whole host is a zero-height shrink → no toggle, no child surface, no
    // IndexedStack at all.
    expect(find.byType(IndexedStack), findsNothing,
        reason: 'with kWordFinderFlag off the host short-circuits to a shrink');
    expect(find.byType(WordKeyboard, skipOffstage: false), findsNothing,
        reason: 'with kWordFinderFlag off the host must render nothing');
    expect(find.byType(QuickPadKeyboard, skipOffstage: false), findsNothing,
        reason: 'with kWordFinderFlag off the host must render nothing');
  });

  testWidgets(
      'state preserved across a toggle: the cascade keeps its mid-dive '
      'breadcrumb after switching to the pad and back', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': [kWordFinderFlag], // flag ON
    });

    // Seed favorites so the pad has a real keyboard to switch to (so the toggle
    // genuinely swaps a live surface, not an empty-state).
    final favSet = kDivePool.take(3).map((p) => p.sku).toSet();
    final container = ProviderContainer(
      overrides: [
        productFavoritesProvider
            .overrideWith((ref) => _SeededFavorites(favSet)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: WordFinderHome())),
      ),
    );
    await tester.pumpAndSettle();

    // Reach into the (mounted) cascade screen's State and drive it into a
    // mid-dive state by answering one offered word — the SAME @visibleForTesting
    // path word_finder_screen_test uses. The State subclass is library-private,
    // so capture the public State base and reach the hooks via a dynamic view.
    // ignore: avoid_dynamic_calls
    final dynamic cascade = tester.state(find.byType(WordFinderScreen));
    // Don't auto-open the heavy product sheet if the word happens to resolve to
    // one card.
    cascade.openSheetOnResolve = false; // ignore: avoid_dynamic_calls

    // Pick an offered first-question word that seeds a MULTI-card pool (so the
    // dive does not immediately resolve and a breadcrumb step persists).
    // Data-driven from the live AskWords list (no hard-coded word).
    final firstQ = cascade.currentQuestion as AskWords; // ignore: avoid_dynamic_calls
    String? seedWord;
    for (final e in firstQ.words) {
      if (resolveWord(e.word, wordFinderLexicon).length > 1) {
        seedWord = e.word;
        break;
      }
    }
    expect(seedWord, isNotNull,
        reason: 'an offered word must seed a multi-card pool to leave a step');
    await tester.tap(find.text(seedWord!).first);
    await tester.pumpAndSettle();

    // The cascade now has exactly one answered breadcrumb step.
    final crumbsBefore =
        List<String>.from(cascade.crumbs as Iterable); // ignore: avoid_dynamic_calls
    expect(crumbsBefore, isNotEmpty,
        reason: 'answering a word pushes a breadcrumb step on the cascade');

    // Flip to the quick pad, then back to the cascade.
    await tester.tap(find.text(quickPadToggleLabel));
    await tester.pumpAndSettle();
    expect(activeIndex(tester), 1, reason: 'switched to the quick pad');
    await tester.tap(find.text('מצא לי')); // the cascade segment label
    await tester.pumpAndSettle();
    expect(activeIndex(tester), 0, reason: 'switched back to the cascade');

    // The cascade State was PRESERVED across the toggle (IndexedStack kept it
    // mounted) — same State object, same breadcrumb. A switch-on-_mode body
    // would have rebuilt the screen fresh and lost the step.
    // ignore: avoid_dynamic_calls
    final dynamic cascadeAfter = tester.state(find.byType(WordFinderScreen));
    final crumbsAfter =
        List<String>.from(cascadeAfter.crumbs as Iterable); // ignore: avoid_dynamic_calls
    expect(crumbsAfter, crumbsBefore,
        reason: 'the cascade kept its mid-dive breadcrumb across the toggle — '
            'the IndexedStack preserves each side\'s state');
  });
}
