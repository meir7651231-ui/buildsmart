// CategorySuggestionStrip — the smart-nav PROOF-OF-CONCEPT strip's gates +
// navigation execution.
//
// Mirrors smart_suggestion_strip_test.dart: every pump is inside a ProviderScope
// (the strip reads `featureFlagsProvider`), the RTL Directionality matches the
// real Hebrew call site, and we pumpAndSettle so the FeatureFlagsNotifier's
// async `_load()` resolves before asserting.
//   1. flag OFF (default mock prefs) → NO SmartChipStrip (renders nothing).
//   2. flag ON (prefs seed the flag) → SmartChipStrip mounts + a category chip.
//   3. flag ON but screen reader active (accessibleNavigation:true) → NO strip.
//   4. flag ON, tap a category chip → the execution ran: the tree-path provider
//      is non-empty AND the tab provider switched to 0 (the catalog tab).

import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogTreePathProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/widgets/smart_input/nav/category_suggestion_strip.dart';
import 'package:buildsmart/widgets/smart_input/smart_chip_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Default: no flags enabled. Individual tests override before pumping.
    SharedPreferences.setMockInitialValues({});
  });

  /// Pump the strip over a fresh ProviderScope.
  /// [a11y] toggles the `accessibleNavigation` MediaQuery flag.
  Future<void> pumpStrip(
    WidgetTester tester, {
    bool a11y = false,
  }) async {
    Widget tree = const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(body: CategorySuggestionStrip()),
    );
    if (a11y) {
      tree = MediaQuery(
        data: const MediaQueryData(accessibleNavigation: true),
        child: tree,
      );
    }
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: tree)),
    );
    await tester.pumpAndSettle(); // let the notifier's async _load() resolve
  }

  testWidgets('flag OFF → NO strip', (tester) async {
    SharedPreferences.setMockInitialValues({}); // default: no flags enabled

    await pumpStrip(tester);

    expect(find.byType(SmartChipStrip), findsNothing);
  });

  testWidgets('flag ON → SmartChipStrip mounts with a category chip',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });

    await pumpStrip(tester);

    expect(find.byType(SmartChipStrip), findsOneWidget);
    expect(find.text('מקלחות ואמבטיות'), findsOneWidget);
  });

  testWidgets('flag ON but screen-reader active → NO strip', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });

    await pumpStrip(tester, a11y: true);

    // a11y fallback: even with the flag ON, an accessible-navigation session
    // gets no strip of tappable chips.
    expect(find.byType(SmartChipStrip), findsNothing);
  });

  testWidgets('flag ON, tapping a category chip runs the navigation execution',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });

    await pumpStrip(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CategorySuggestionStrip)),
    );

    // Pre-conditions: not drilling, and parked on a NON-catalog tab so the
    // switch-to-0 is an observable change (not the default).
    expect(container.read(catalogTreePathProvider), isEmpty);
    container.read(mainTabProvider.notifier).state = 3; // e.g. the store tab
    expect(container.read(mainTabProvider), 3);

    final chip = find.text('מקלחות ואמבטיות');
    expect(chip, findsOneWidget);
    await tester.tap(chip);
    await tester.pump();

    // The execution ran: drilled into the category AND switched to the catalog
    // tab (index 0).
    expect(container.read(catalogTreePathProvider), isNotEmpty);
    expect(container.read(mainTabProvider), 0);
  });
}
