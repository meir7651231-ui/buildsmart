// SmartChipStrip — the horizontal suggestion strip (Phase-1 of smart input).
//
// We pump the strip with three suggestions (one primary) inside the RTL app
// shell and assert:
//   • all three `display` strings render (label falls back to text);
//   • tapping a chip fires `onPick` with THAT suggestion (identity preserved).
//
// The strip pins itself to LTR internally so chip ORDER is stable in the RTL
// app — we wrap in Directionality(rtl) to mirror the real call site and prove
// the lock holds.

import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:buildsmart/widgets/smart_input/smart_chip_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // One primary (branded, rendered first) + two neutral chips. The middle one
  // carries a `label`, so its chip must show the label, not the raw text.
  const suggestions = [
    Suggestion('צינור 3/4 אינץ׳', isPrimary: true),
    Suggestion('pex-16', label: 'PEX 16 מ״מ'),
    Suggestion('ברז כדורי'),
  ];

  Future<void> pumpStrip(
    WidgetTester tester, {
    required ValueChanged<Suggestion> onPick,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SmartChipStrip(suggestions: suggestions, onPick: onPick),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders every suggestion display (label falls back to text)',
      (tester) async {
    await pumpStrip(tester, onPick: (_) {});

    expect(find.text('צינור 3/4 אינץ׳'), findsOneWidget); // primary, text
    expect(find.text('PEX 16 מ״מ'), findsOneWidget); // label wins over text
    expect(find.text('ברז כדורי'), findsOneWidget); // neutral, text
    // The raw text of the labelled chip is NOT shown (display == label).
    expect(find.text('pex-16'), findsNothing);
  });

  testWidgets('tapping a chip fires onPick with that exact suggestion',
      (tester) async {
    final picked = <Suggestion>[];
    await pumpStrip(tester, onPick: picked.add);

    await tester.tap(find.text('PEX 16 מ״מ'));
    await tester.pumpAndSettle();

    expect(picked, hasLength(1));
    // Identity is preserved — the callback gets the very suggestion tapped.
    expect(identical(picked.single, suggestions[1]), isTrue);
    expect(picked.single.text, 'pex-16');

    // A second, different chip routes its own suggestion through.
    await tester.tap(find.text('ברז כדורי'));
    await tester.pumpAndSettle();
    expect(picked, hasLength(2));
    expect(identical(picked.last, suggestions[2]), isTrue);
  });
}
