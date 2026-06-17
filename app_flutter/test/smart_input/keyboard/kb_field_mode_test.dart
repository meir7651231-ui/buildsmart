// useCustomKeyboard — the single shared gate predicate.
//
// Three truth-table states, mirroring the strip's gating but for the in-app
// keyboard's own visibility / the field's readOnly source of truth:
//   1. flag ABSENT (default mock prefs)              → false (OS keyboard).
//   2. flag PRESENT but screen reader active (a11y)  → false (OS keyboard).
//   3. flag PRESENT and a11y off                     → true  (custom keyboard).
//
// The predicate reads `featureFlagsProvider`, so every pump is inside a
// ProviderScope; we pumpAndSettle so the FeatureFlagsNotifier's async `_load()`
// resolves before we read the bool out of the probe widget.

import 'package:buildsmart/widgets/smart_input/keyboard/kb_field_mode.dart';
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

  /// Pumps a tiny [Consumer] probe that evaluates [useCustomKeyboard] and
  /// records the result into [out]. [a11y] toggles the `accessibleNavigation`
  /// MediaQuery flag. Returns after `pumpAndSettle` so the async flag load
  /// resolves.
  Future<void> pumpProbe(
    WidgetTester tester,
    List<bool> out, {
    bool a11y = false,
  }) async {
    Widget probe = Consumer(
      builder: (context, ref, _) {
        out
          ..clear()
          ..add(useCustomKeyboard(ref, context));
        return const SizedBox.shrink();
      },
    );
    if (a11y) {
      probe = MediaQuery(
        data: const MediaQueryData(accessibleNavigation: true),
        child: probe,
      );
    }
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: probe)),
    );
    await tester.pumpAndSettle(); // let the notifier's async _load() resolve
  }

  testWidgets('flag ABSENT → false', (tester) async {
    SharedPreferences.setMockInitialValues({}); // no flags
    final out = <bool>[];

    await pumpProbe(tester, out);

    expect(out.single, isFalse);
  });

  testWidgets('flag PRESENT but screen reader active → false', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    final out = <bool>[];

    await pumpProbe(tester, out, a11y: true);

    // a11y fallback: even with the flag ON, an accessible-navigation session
    // keeps the OS keyboard.
    expect(out.single, isFalse);
  });

  testWidgets('flag PRESENT and a11y off → true', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bs.feature-flags.v1': ['kSmartInput'],
    });
    final out = <bool>[];

    await pumpProbe(tester, out);

    expect(out.single, isTrue);
  });
}
