// BsKeyboard — the custom Hebrew on-screen keyboard's tap routing.
//
// BsKeyboard is pure presentation + dispatch: each key forwards its tap to a
// typed callback based on its KeyKind. We pump it inside the RTL app shell
// (mirroring the real call site; the keyboard pins ITSELF to LTR so key order
// holds) with spy callbacks and assert that:
//   • a letter key ('א') inserts its character via onKey, exactly once;
//   • the appended backspace key fires onBackspace;
//   • enter (↵ → keyboard_return icon) fires onEnter;
//   • the send key (→ send icon) fires onSend;
//   • the '?123' layer key fires onToggleSymbols;
//   • in the symbols layer a digit key ('5') inserts '5' via onKey.
//
// Tool keys (backspace/enter/send) render a Material ICON, not their label, so
// they are located with find.byIcon; text/punct keys use find.text.

import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Spy buffers — one per callback, recording every invocation.
  late List<String> keys;
  late int backspaces;
  late int enters;
  late int sends;
  late int toggles;
  late int languages;

  setUp(() {
    keys = <String>[];
    backspaces = 0;
    enters = 0;
    sends = 0;
    toggles = 0;
    languages = 0;
  });

  // Pump BsKeyboard inside MaterialApp + RTL Directionality (the real call
  // site), wiring every callback to its spy buffer.
  Future<void> pumpKeyboard(
    WidgetTester tester, {
    bool showSymbols = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: BsKeyboard(
              showSymbols: showSymbols,
              onKey: keys.add,
              onBackspace: () => backspaces++,
              onEnter: () => enters++,
              onSend: () => sends++,
              onToggleSymbols: () => toggles++,
              onLanguage: () => languages++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapping the letter "א" inserts it via onKey exactly once',
      (tester) async {
    await pumpKeyboard(tester);

    expect(find.text('א'), findsOneWidget);
    await tester.tap(find.text('א'));
    await tester.pumpAndSettle();

    expect(keys, <String>['א']);
    // No other callback fired off the back of a single letter tap.
    expect(backspaces + enters + sends + toggles + languages, 0);
  });

  testWidgets('the appended backspace key fires onBackspace', (tester) async {
    await pumpKeyboard(tester);

    // Backspace renders as an icon (BsKey maps the kind → backspace_outlined).
    final backspace = find.byIcon(Icons.backspace_outlined);
    expect(backspace, findsOneWidget);
    await tester.tap(backspace);
    await tester.pumpAndSettle();

    expect(backspaces, 1);
    expect(keys, isEmpty);
  });

  testWidgets('tapping enter (↵) fires onEnter', (tester) async {
    await pumpKeyboard(tester);

    final enter = find.byIcon(Icons.keyboard_return);
    expect(enter, findsOneWidget);
    await tester.tap(enter);
    await tester.pumpAndSettle();

    expect(enters, 1);
  });

  testWidgets('tapping the Send key fires onSend', (tester) async {
    await pumpKeyboard(tester);

    final send = find.byIcon(Icons.send);
    expect(send, findsOneWidget);
    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(sends, 1);
  });

  testWidgets('tapping "?123" fires onToggleSymbols', (tester) async {
    await pumpKeyboard(tester);

    expect(find.text('?123'), findsOneWidget);
    await tester.tap(find.text('?123'));
    await tester.pumpAndSettle();

    expect(toggles, 1);
  });

  testWidgets('with showSymbols:true a digit "5" inserts "5" via onKey',
      (tester) async {
    await pumpKeyboard(tester, showSymbols: true);

    // The symbols layer carries the digit row; '5' renders as text (punct).
    expect(find.text('5'), findsOneWidget);
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();

    expect(keys, <String>['5']);
  });
}
