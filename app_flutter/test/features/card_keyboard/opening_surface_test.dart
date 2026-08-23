import 'package:buildsmart/features/card_keyboard/opening_surface.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart'
    show WordKeyboard;
import 'package:buildsmart/features/word_finder/word_keys_model.dart'
    show WordKey;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _words = [WordKey('ברז'), WordKey('צינור'), WordKey('מחבר')];

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('one TextField + one WordKeyboard + ZERO mode controls',
      (t) async {
    await t.pumpWidget(_wrap(
      OpeningSurface(wordKeys: _words, onWordTap: (_) {}, onQuery: (_) {}),
    ));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(WordKeyboard), findsOneWidget);
    expect(find.byType(ToggleButtons), findsNothing);
    expect(find.byType(TabBar), findsNothing);
  });

  testWidgets('mic renders iff showMic', (t) async {
    await t.pumpWidget(_wrap(
      OpeningSurface(wordKeys: _words, onWordTap: (_) {}, onQuery: (_) {}),
    ));
    expect(find.byIcon(Icons.mic), findsNothing);

    await t.pumpWidget(_wrap(
      OpeningSurface(
        wordKeys: _words,
        onWordTap: (_) {},
        onQuery: (_) {},
        showMic: true,
        onMic: () {},
      ),
    ));
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });

  testWidgets('typing routes to onQuery', (t) async {
    String? q;
    await t.pumpWidget(_wrap(
      OpeningSurface(wordKeys: _words, onWordTap: (_) {}, onQuery: (v) => q = v),
    ));
    await t.enterText(find.byType(TextField), 'נחושת');
    expect(q, 'נחושת');
  });

  testWidgets('no overflow at 360px width', (t) async {
    t.view.physicalSize = const Size(360, 800);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(_wrap(
      OpeningSurface(
        wordKeys: _words,
        onWordTap: (_) {},
        onQuery: (_) {},
        showMic: true,
        onMic: () {},
      ),
    ));
    expect(t.takeException(), isNull);
  });
}
