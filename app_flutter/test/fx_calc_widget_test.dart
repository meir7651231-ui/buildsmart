// FX converter sheet (finance_hub_sheets `_FxCalc`, opened via
// openFinanceLeaf('fin-fx')). Typing extreme amounts used to THROW inside
// build (RangeError on "0.0000001", UnsupportedError on "1e999"). Now the
// result line degrades to "—" and the field shows its own error.
import 'package:buildsmart/screens/finance_hub_sheets.dart'
    show openFinanceLeaf;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openFx(WidgetTester t) async {
  t.view.physicalSize = const Size(800, 2000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder:
              (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => openFinanceLeaf(ctx, 'fin-fx'),
                    child: const Text('open'),
                  ),
                ),
              ),
        ),
      ),
    ),
  );
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('default 1000 USD converts with the demo rate', (t) async {
    await _openFx(t);
    expect(find.text('1,000 USD = ₪3,720'), findsOneWidget);
  });

  for (final input in ['0.0000001', '1e999', '1e300', 'abc']) {
    testWidgets('"$input" never throws', (t) async {
      await _openFx(t);
      await t.enterText(find.byType(TextField), input);
      await t.pump();
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('overflowing amount shows a dash, not a number', (t) async {
    await _openFx(t);
    await t.enterText(find.byType(TextField), '1e999');
    await t.pump();
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('empty field prompts for an amount (RTL message)', (t) async {
    await _openFx(t);
    await t.enterText(find.byType(TextField), '');
    await t.pump();
    final msg = t.widget<Text>(find.text('הזינו סכום להמרה'));
    expect(msg.textDirection, TextDirection.rtl);
  });
}
