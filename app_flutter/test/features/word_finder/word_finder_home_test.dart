// WordFinderHome — BEHAVIORAL widget test for the unified "one keyboard, two
// modes" entry (manual toggle between the newbie cascade and the quick pad).
//
// NOT a pixel/golden test (fonts are brittle): every assertion is on widget
// presence (which keyboard mounted) or a known toggle label. Three cases:
//
//   Test 1 (flag ON, default mode): the host defaults to the NEWBIE cascade,
//     so the cascade's WordKeyboard mounts and the pad's QuickPadKeyboard does
//     NOT. (newbie-first, per 'מתחילים פשוט-לכולם'.)
//
//   Test 2 (flag ON, tap the 'המהיר שלי' toggle): tapping the quick-pad
//     segment swaps the body → the QuickPadKeyboard mounts and the cascade's
//     WordKeyboard is gone. We seed productFavoritesProvider with a REAL
//     kDivePool sku (data-driven, drift-proof) so the pad renders its KEYBOARD
//     rather than its empty-state — mirroring quick_pad_screen_test.dart.
//
//   Test 3 (gated OFF): with kWordFinderFlag NOT seeded, the host is a
//     zero-height shrink → neither keyboard mounts.
//
// Flag wiring mirrors word_finder_screen_test.dart / quick_pad_screen_test.dart:
// seed the flag via SharedPreferences.setMockInitialValues({'bs.feature-flags
// .v1': [...]}) and pumpAndSettle() so the FeatureFlagsNotifier's async
// _load() resolves before we read the gate. Where we also need seeded
// favorites we layer a ProviderContainer override (as quick_pad_screen_test
// does) on top of the SharedPreferences-seeded flag.

import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/quick_pad_keyboard.dart';
import 'package:buildsmart/features/word_finder/word_finder_flag.dart';
import 'package:buildsmart/features/word_finder/word_finder_home.dart';
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

  testWidgets(
      'flag ON: defaults to the newbie cascade (WordKeyboard, no QuickPad)',
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

    // The default mode is the cascade → its WordKeyboard mounts and the quick
    // pad's QuickPadKeyboard does NOT.
    expect(find.byType(WordKeyboard), findsOneWidget,
        reason: 'the host defaults to the newbie cascade → WordKeyboard mounts');
    expect(find.byType(QuickPadKeyboard), findsNothing,
        reason: 'the quick pad is not shown until the toggle is tapped');
  });

  testWidgets(
      "flag ON: tapping 'המהיר שלי' swaps to the quick pad "
      '(QuickPadKeyboard, no WordKeyboard)', (tester) async {
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

    // Sanity: we start on the cascade.
    expect(find.byType(WordKeyboard), findsOneWidget,
        reason: 'host starts on the cascade');
    expect(find.byType(QuickPadKeyboard), findsNothing);

    // Tap the 'המהיר שלי' toggle segment → switch to the quick pad.
    final toggle = find.text(quickPadToggleLabel);
    expect(toggle, findsOneWidget,
        reason: 'the quick-pad toggle segment must render as plain text');
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    // Now the quick pad's keyboard is mounted and the cascade's is gone.
    expect(find.byType(QuickPadKeyboard), findsOneWidget,
        reason: 'tapping the toggle swaps the body to the quick pad');
    expect(find.byType(WordKeyboard), findsNothing,
        reason: 'the cascade is no longer shown after switching to the pad');
  });

  testWidgets('gated OFF: host renders neither keyboard', (tester) async {
    SharedPreferences.setMockInitialValues({}); // flag NOT set

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: WordFinderHome())),
      ),
    );
    await tester.pumpAndSettle();

    // The whole host is a zero-height shrink → no toggle, no child surface.
    expect(find.byType(WordKeyboard), findsNothing,
        reason: 'with kWordFinderFlag off the host must render nothing');
    expect(find.byType(QuickPadKeyboard), findsNothing,
        reason: 'with kWordFinderFlag off the host must render nothing');
  });
}
