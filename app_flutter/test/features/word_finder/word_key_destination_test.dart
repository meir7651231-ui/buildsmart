// P9.86: a WordKey can carry an isDestination accent (#41). When true, WordKeyboard draws
// a small trailing north-east arrow; false (the default, every live key) draws a plain key
// with no icon — byte-identical to before.

import 'package:buildsmart/features/word_finder/word_keyboard.dart';
import 'package:buildsmart/features/word_finder/word_keys_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a destination WordKey shows exactly one north_east accent',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WordKeyboard(
            words: const [
              WordKey('ברז'),
              WordKey('מחבר', isDestination: true),
            ],
            onWordTap: (_) {},
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.north_east), findsOneWidget);
  });

  testWidgets('with no destination key the keyboard renders no icon (byte-identical)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WordKeyboard(
            words: const [WordKey('ברז'), WordKey('צינור')],
            onWordTap: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(Icon), findsNothing);
  });
}
