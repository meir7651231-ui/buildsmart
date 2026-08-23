// SmartInputScaffold — THE zero-regression guard for the smart-input wrapper.
//
// Three states, one invariant: the wrapper must be a transparent passthrough of
// the real field UNLESS the flag is on AND no screen reader is active.
//
//   1. flag OFF (default mock prefs) → NO SmartChipStrip; the child TextField
//      is present untouched (passthrough — byte-identical, zero regression).
//   2. flag ON  (prefs seed the `kSmartInput` flag under the persistence key) →
//      the SmartChipStrip appears beneath the field. We pumpAndSettle so the
//      FeatureFlagsNotifier's async `_load()` resolves before asserting.
//   3. flag ON but screen reader active (MediaQuery accessibleNavigation:true)
//      → passthrough again: NO strip (a11y fallback to the plain field).
//
// The scaffold reads `featureFlagsProvider`, so every pump is inside a
// ProviderScope; the RTL Directionality mirrors the real (Hebrew) call site.

import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:buildsmart/widgets/smart_input/smart_chip_strip.dart';
import 'package:buildsmart/widgets/smart_input/smart_input_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Non-empty suggestions in every case — so when the strip is ABSENT we know
  // it is the flag/a11y gate hiding it, not an empty list.
  const suggestions = [
    Suggestion('צינור 3/4 אינץ׳', isPrimary: true),
    Suggestion('ברז כדורי'),
  ];

  const childField = TextField(key: Key('child'));

  /// Pump the scaffold over a fresh ProviderScope. [a11y] toggles the
  /// `accessibleNavigation` MediaQuery flag for the screen-reader case.
  Future<void> pumpScaffold(WidgetTester tester, {bool a11y = false}) async {
    Widget tree = Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SmartInputScaffold(
          fieldContext: const SmartInputContext(kind: InputFieldKind.search),
          suggestions: suggestions,
          onPick: (_) {},
          child: childField,
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

  testWidgets('flag OFF → passthrough: NO strip, child field present',
      (tester) async {
    SharedPreferences.setMockInitialValues({}); // default: no flags enabled
    await pumpScaffold(tester);

    // The zero-regression assertion: the smart strip never mounts when off.
    expect(find.byType(SmartChipStrip), findsNothing);
    // …and the real field is rendered verbatim.
    expect(find.byKey(const Key('child')), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('flag ON → SmartChipStrip renders beneath the field',
      (tester) async {
    // Seed the flag under the SAME persistence key the notifier loads from.
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    await pumpScaffold(tester);

    expect(find.byType(SmartChipStrip), findsOneWidget);
    // Field is still there — the strip is ADDED, not a replacement.
    expect(find.byKey(const Key('child')), findsOneWidget);
  });

  testWidgets('flag ON but screen-reader active → passthrough: NO strip',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    await pumpScaffold(tester, a11y: true);

    // a11y fallback: even with the flag ON, an accessible-navigation session
    // gets the plain field — no extra strip of tappable chips.
    expect(find.byType(SmartChipStrip), findsNothing);
    expect(find.byKey(const Key('child')), findsOneWidget);
  });
}
