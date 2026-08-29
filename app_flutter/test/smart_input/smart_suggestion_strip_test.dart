// SmartSuggestionStrip — the LIVE, self-gating strip's behaviour gates.
//
// Four states mirror the scaffold guard, but now data-driven via a controller +
// ChatSuggestionSource:
//   1. flag OFF (default mock prefs) → NO SmartChipStrip (renders nothing).
//   2. flag ON (prefs seed the flag) → SmartChipStrip mounts and at least one
//      chip renders for a blank-query controller (full pool is eligible).
//   3. tapping a chip inserts its text into the controller (text changes).
//   4. flag ON but screen reader active (accessibleNavigation:true) → NO strip.
//
// The strip reads `featureFlagsProvider`, so every pump is inside a
// ProviderScope; the RTL Directionality mirrors the real (Hebrew) call site. We
// pumpAndSettle so the FeatureFlagsNotifier's async `_load()` resolves first.

import 'package:buildsmart/widgets/smart_input/chat_suggestion_source.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:buildsmart/widgets/smart_input/smart_chip_strip.dart';
import 'package:buildsmart/widgets/smart_input/smart_suggestion_strip.dart';
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

  /// Pump the strip over a fresh ProviderScope, bound to [controller].
  /// [a11y] toggles the `accessibleNavigation` MediaQuery flag.
  Future<void> pumpStrip(
    WidgetTester tester,
    TextEditingController controller, {
    bool a11y = false,
  }) async {
    Widget tree = Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SmartSuggestionStrip(
          controller: controller,
          fieldContext: const SmartInputContext(kind: InputFieldKind.freeTextHe),
          source: const ChatSuggestionSource(),
        ),
      ),
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
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpStrip(tester, controller);

    expect(find.byType(SmartChipStrip), findsNothing);
  });

  testWidgets('flag ON → SmartChipStrip mounts and renders at least one chip',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    final controller = TextEditingController(); // blank → whole pool eligible
    addTearDown(controller.dispose);

    await pumpStrip(tester, controller);

    expect(find.byType(SmartChipStrip), findsOneWidget);
    // At least one chip renders — a quick-reply that is always in the pool.
    expect(find.text('קיבלתי, תודה'), findsOneWidget);
  });

  testWidgets('tapping a chip inserts its text into the controller',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpStrip(tester, controller);
    expect(controller.text, isEmpty);

    final chip = find.text('קיבלתי, תודה');
    expect(chip, findsOneWidget);
    await tester.tap(chip);
    await tester.pump();

    // The pick was inserted at the caret — controller text changed.
    expect(controller.text, isNotEmpty);
    expect(controller.text, contains('קיבלתי, תודה'));
  });

  testWidgets('flag ON but screen-reader active → NO strip', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpStrip(tester, controller, a11y: true);

    // a11y fallback: even with the flag ON, an accessible-navigation session
    // gets no strip of tappable chips.
    expect(find.byType(SmartChipStrip), findsNothing);
  });
}
