// BsKeyboard — exhaustive "every key works" coverage.
//
// Unlike bs_keyboard_test.dart, which spot-checks one representative key per
// kind, this test enumerates EVERY rendered BsKey on each layer and taps it,
// asserting it fires exactly the callback its KeyKind implies (and nothing
// else). We locate keys by walking the actual BsKey widget list — NOT by
// find.text, which collides with the digit superscripts row-1 letters carry.
//
// It then asserts COVERAGE: that the taps we made collectively exercised all
// 27 Hebrew letters + maqaf + geresh + space + period (letters layer) and all
// ten digits + the back-to-letters key (symbols layer), with exactly one each
// of the tool keys.

import 'package:buildsmart/widgets/smart_input/keyboard/bs_key.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/english_layout.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/hebrew_layout.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  // Clear in place — the keyboard's onKey closure reads the `keys` variable at
  // call time, so clearing (not replacing) keeps it pointed at the live list.
  void resetCaptures() {
    keys.clear();
    backspaces = 0;
    enters = 0;
    sends = 0;
    toggles = 0;
    languages = 0;
  }

  // Total non-onKey callback fires — used to assert "no other callback fired".
  int otherFires() => backspaces + enters + sends + toggles + languages;

  // Pump BsKeyboard. The keyboard pins itself to Directionality.ltr, so a
  // MaterialApp wrap is enough; we mirror the real call site otherwise.
  Future<void> pumpKeyboard(
    WidgetTester tester, {
    bool showSymbols = false,
    bool english = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: BsKeyboard(
              showSymbols: showSymbols,
              english: english,
              onKey: (s) => keys.add(s),
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

  // The 27 Hebrew letters of kHebrewRows (kind == letter), in layout order.
  final Set<String> expectedLetters = <String>{
    for (final row in kHebrewRows)
      for (final k in row)
        if (k.kind == KeyKind.letter) k.effectiveOutput,
  };

  testWidgets(
    'letters layer: every rendered key fires the correct action',
    (tester) async {
      await pumpKeyboard(tester, showSymbols: false);

      final widgets = tester.widgetList<BsKey>(find.byType(BsKey)).toList();

      // Coverage accumulators across all taps.
      final Set<String> textOutputs = <String>{};
      var backspaceKeys = 0;
      var enterKeys = 0;
      var sendKeys = 0;
      var symbolsKeys = 0;
      var languageKeys = 0;

      for (final w in widgets) {
        resetCaptures();
        await tester.tap(find.byWidget(w));
        await tester.pump();

        switch (w.model.kind) {
          case KeyKind.letter:
          case KeyKind.period:
          case KeyKind.punct:
          case KeyKind.space:
            expect(
              keys.single,
              w.model.effectiveOutput,
              reason: 'text key "${w.model.label}" should insert its output',
            );
            expect(
              otherFires(),
              0,
              reason: 'text key "${w.model.label}" fired a non-onKey callback',
            );
            textOutputs.add(w.model.effectiveOutput);
          case KeyKind.backspace:
            expect(backspaces, 1, reason: 'backspace should fire once');
            expect(keys, isEmpty);
            expect(enters + sends + toggles + languages, 0);
            backspaceKeys++;
          case KeyKind.enter:
            expect(enters, 1, reason: 'enter should fire once');
            expect(keys, isEmpty);
            expect(backspaces + sends + toggles + languages, 0);
            enterKeys++;
          case KeyKind.send:
            expect(sends, 1, reason: 'send should fire once');
            expect(keys, isEmpty);
            expect(backspaces + enters + toggles + languages, 0);
            sendKeys++;
          case KeyKind.symbols:
            expect(toggles, 1, reason: 'symbols should toggle once');
            expect(keys, isEmpty);
            expect(backspaces + enters + sends + languages, 0);
            symbolsKeys++;
          case KeyKind.language:
            expect(languages, 1, reason: 'language should fire once');
            expect(keys, isEmpty);
            expect(backspaces + enters + sends + toggles, 0);
            languageKeys++;
        }
      }

      // COVERAGE — the union of text outputs we collected covers every letter
      // plus the maqaf/geresh/space bottom-row text keys. (The period key was
      // removed per owner request, so the LETTERS layer no longer emits '.'.)
      expect(
        textOutputs.containsAll(expectedLetters),
        isTrue,
        reason: 'missing letters: '
            '${expectedLetters.difference(textOutputs)}',
      );
      expect(expectedLetters.length, 27, reason: 'expected 27 Hebrew letters');
      expect(textOutputs.contains('־'), isTrue, reason: 'maqaf missing');
      expect(textOutputs.contains('׳'), isTrue, reason: 'geresh missing');
      expect(textOutputs.contains(' '), isTrue, reason: 'space missing');

      // Exactly one of each tool key on this layer.
      expect(backspaceKeys, 1, reason: 'exactly one backspace key');
      expect(enterKeys, 1, reason: 'exactly one enter key');
      expect(sendKeys, 1, reason: 'exactly one send key');
      expect(symbolsKeys, 1, reason: 'exactly one ?123 key');
      expect(languageKeys, 1, reason: 'exactly one globe/language key');
    },
  );

  testWidgets(
    'symbols layer: every rendered key fires the correct action',
    (tester) async {
      await pumpKeyboard(tester, showSymbols: true);

      final widgets = tester.widgetList<BsKey>(find.byType(BsKey)).toList();

      final Set<String> textOutputs = <String>{};
      var backspaceKeys = 0;
      var enterKeys = 0;
      var sendKeys = 0;
      var symbolsKeys = 0;
      var languageKeys = 0;

      for (final w in widgets) {
        resetCaptures();
        await tester.tap(find.byWidget(w));
        await tester.pump();

        switch (w.model.kind) {
          case KeyKind.letter:
          case KeyKind.period:
          case KeyKind.punct:
          case KeyKind.space:
            expect(
              keys.single,
              w.model.effectiveOutput,
              reason: 'text key "${w.model.label}" should insert its output',
            );
            expect(
              otherFires(),
              0,
              reason: 'text key "${w.model.label}" fired a non-onKey callback',
            );
            textOutputs.add(w.model.effectiveOutput);
          case KeyKind.backspace:
            expect(backspaces, 1, reason: 'backspace should fire once');
            expect(keys, isEmpty);
            expect(enters + sends + toggles + languages, 0);
            backspaceKeys++;
          case KeyKind.enter:
            expect(enters, 1, reason: 'enter should fire once');
            expect(keys, isEmpty);
            expect(backspaces + sends + toggles + languages, 0);
            enterKeys++;
          case KeyKind.send:
            expect(sends, 1, reason: 'send should fire once');
            expect(keys, isEmpty);
            expect(backspaces + enters + toggles + languages, 0);
            sendKeys++;
          case KeyKind.symbols:
            expect(toggles, 1, reason: 'symbols should toggle once');
            expect(keys, isEmpty);
            expect(backspaces + enters + sends + languages, 0);
            symbolsKeys++;
          case KeyKind.language:
            expect(languages, 1, reason: 'language should fire once');
            expect(keys, isEmpty);
            expect(backspaces + enters + sends + toggles, 0);
            languageKeys++;
        }
      }

      // COVERAGE — all ten digits inserted via onKey.
      const digits = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
      for (final d in digits) {
        expect(
          textOutputs.contains(d),
          isTrue,
          reason: 'digit "$d" missing from symbols layer',
        );
      }

      // The back-to-letters key (אבג) is a symbols-kind toggle on this layer,
      // and a backspace key is appended.
      expect(symbolsKeys, 1, reason: 'אבג back-to-letters key fires toggle');
      expect(backspaceKeys, 1, reason: 'a backspace key is present');

      // Bottom row still carries enter/send/language exactly once each.
      expect(enterKeys, 1);
      expect(sendKeys, 1);
      expect(languageKeys, 1);
    },
  );

  // The 26 English letters of kEnglishRows (all kind == letter), in order.
  final Set<String> expectedEnglishLetters = <String>{
    for (final row in kEnglishRows)
      for (final k in row)
        if (k.kind == KeyKind.letter) k.effectiveOutput,
  };

  testWidgets(
    'english layer: every rendered key fires the correct action',
    (tester) async {
      await pumpKeyboard(tester, english: true, showSymbols: false);

      final widgets = tester.widgetList<BsKey>(find.byType(BsKey)).toList();

      final Set<String> textOutputs = <String>{};
      var backspaceKeys = 0;
      var enterKeys = 0;
      var sendKeys = 0;
      var symbolsKeys = 0;
      var languageKeys = 0;

      for (final w in widgets) {
        resetCaptures();
        await tester.tap(find.byWidget(w));
        await tester.pump();

        switch (w.model.kind) {
          case KeyKind.letter:
          case KeyKind.period:
          case KeyKind.punct:
          case KeyKind.space:
            expect(
              keys.single,
              w.model.effectiveOutput,
              reason: 'text key "${w.model.label}" should insert its output',
            );
            expect(
              otherFires(),
              0,
              reason: 'text key "${w.model.label}" fired a non-onKey callback',
            );
            textOutputs.add(w.model.effectiveOutput);
          case KeyKind.backspace:
            expect(backspaces, 1, reason: 'backspace should fire once');
            expect(keys, isEmpty);
            expect(enters + sends + toggles + languages, 0);
            backspaceKeys++;
          case KeyKind.enter:
            expect(enters, 1, reason: 'enter should fire once');
            expect(keys, isEmpty);
            expect(backspaces + sends + toggles + languages, 0);
            enterKeys++;
          case KeyKind.send:
            expect(sends, 1, reason: 'send should fire once');
            expect(keys, isEmpty);
            expect(backspaces + enters + toggles + languages, 0);
            sendKeys++;
          case KeyKind.symbols:
            expect(toggles, 1, reason: 'symbols should toggle once');
            expect(keys, isEmpty);
            expect(backspaces + enters + sends + languages, 0);
            symbolsKeys++;
          case KeyKind.language:
            expect(languages, 1, reason: 'language should fire once');
            expect(keys, isEmpty);
            expect(backspaces + enters + sends + toggles, 0);
            languageKeys++;
        }
      }

      // COVERAGE — every one of the 26 English letters was inserted via onKey,
      // plus the space ' ' bottom-row text key. (The period key was removed per
      // owner request, so no layer's bottom row emits '.' anymore.)
      expect(
        textOutputs.containsAll(expectedEnglishLetters),
        isTrue,
        reason: 'missing letters: '
            '${expectedEnglishLetters.difference(textOutputs)}',
      );
      expect(
        expectedEnglishLetters.length,
        26,
        reason: 'expected 26 English letters',
      );
      expect(textOutputs.contains(' '), isTrue, reason: 'space missing');

      // Exactly one of each tool key on this layer. On the English letter layer
      // the layer-switch key is the '?123' symbols toggle.
      expect(backspaceKeys, 1, reason: 'exactly one backspace key');
      expect(enterKeys, 1, reason: 'exactly one enter key');
      expect(sendKeys, 1, reason: 'exactly one send key');
      expect(symbolsKeys, 1, reason: 'exactly one ?123 key');
      expect(languageKeys, 1, reason: 'exactly one globe/language key');
    },
  );

  testWidgets('key counts', (tester) async {
    // Letters layer: every layer key + 1 appended backspace + bottom row.
    await pumpKeyboard(tester, showSymbols: false);
    final lettersCount =
        tester.widgetList<BsKey>(find.byType(BsKey)).length;
    final expectedLetterKeys =
        kHebrewRows.fold<int>(0, (sum, r) => sum + r.length) +
            1 +
            kBottomRow.length;
    expect(lettersCount, expectedLetterKeys);

    // Symbols layer: every symbol key + 1 appended backspace + bottom row.
    await pumpKeyboard(tester, showSymbols: true);
    final symbolsCount =
        tester.widgetList<BsKey>(find.byType(BsKey)).length;
    final expectedSymbolKeys =
        kSymbolsRows.fold<int>(0, (sum, r) => sum + r.length) +
            1 +
            kBottomRow.length;
    expect(symbolsCount, expectedSymbolKeys);
  });
}
