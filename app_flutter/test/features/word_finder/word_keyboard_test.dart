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

    testWidgets(
        'showUtilityRow:false omits the הכל/הקלדה row but keeps word keys',
        (tester) async {
      WordKey? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              words: const [
                WordKey('ברז', payload: '111'),
                WordKey('צינור', payload: '222'),
              ],
              onWordTap: (w) => tapped = w,
              showUtilityRow: false,
            ),
          ),
        ),
      );

      // The word keys still render (the connections view shows its parts)...
      expect(find.text('ברז'), findsOneWidget);
      expect(find.text('צינור'), findsOneWidget);
      // ...but neither utility key is present — they would be dead no-ops on a
      // surface (the connections view) with no skip/type affordance.
      expect(find.text('הכל'), findsNothing,
          reason: 'showUtilityRow:false must not render the הכל key');
      expect(find.text('הקלדה'), findsNothing,
          reason: 'showUtilityRow:false must not render the הקלדה key');
      // Still icon-free, and word taps still route by identity (payload intact).
      expect(find.byType(Icon), findsNothing);
      await tester.tap(find.text('צינור'));
      await tester.pump();
      expect(tapped, isNotNull);
      expect(tapped!.payload, '222',
          reason: 'a tapped word key still routes with its payload');
    });

    testWidgets('showUtilityRow defaults true → utility row present',
        (tester) async {
      // Explicit default-preservation guard: omitting showUtilityRow keeps the
      // existing behavior for every current call site.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordKeyboard(
              words: const [WordKey('ברז')],
              onWordTap: (_) {},
              onAll: () {},
              onType: () {},
            ),
          ),
        ),
      );
      expect(find.text('הכל'), findsOneWidget);
      expect(find.text('הקלדה'), findsOneWidget);
    });
  });
}
