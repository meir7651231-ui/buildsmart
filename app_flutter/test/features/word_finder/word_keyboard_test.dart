import 'package:buildsmart/features/word_finder/word_keyboard.dart';
import 'package:buildsmart/features/word_finder/word_keys_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WordKeyboard', () {
    testWidgets('renders each word as a plain, icon-free key', (tester) async {
      WordKey? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              words: const [
                WordKey('ברז'),
                WordKey('צינור'),
                WordKey('אטם'),
              ],
              onWordTap: (w) => tapped = w,
            ),
          ),
        ),
      );

      // The Hebrew word renders as text on its key.
      expect(find.text('ברז'), findsOneWidget);
      expect(find.text('צינור'), findsOneWidget);
      expect(find.text('אטם'), findsOneWidget);

      // No key — word keys nor the utility row — renders an Icon.
      expect(find.byType(Icon), findsNothing);

      // Tapping a word routes that exact WordKey to onWordTap.
      await tester.tap(find.text('ברז'));
      await tester.pump();

      expect(tapped, isNotNull);
      expect(tapped!.label, 'ברז');
    });

    testWidgets('utility row exposes הכל and הקלדה without icons', (tester) async {
      var allTapped = false;
      var typeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              words: const [WordKey('ברז')],
              onWordTap: (_) {},
              onAll: () => allTapped = true,
              onType: () => typeTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('הכל'), findsOneWidget);
      expect(find.text('הקלדה'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);

      await tester.tap(find.text('הכל'));
      await tester.pump();
      expect(allTapped, isTrue);

      await tester.tap(find.text('הקלדה'));
      await tester.pump();
      expect(typeTapped, isTrue);
    });
  });
}
