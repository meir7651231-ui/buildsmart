import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/ai_result_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Pins the three shared AI render-states extracted from the 8 narrate screens
// (אודיט-נחיל גל-4). The result rung stays per-screen and is not covered here.

Widget _wrap(Widget child) => MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('AiOffState', () {
    testWidgets('shows the given text, muted (mutedLight/13)', (tester) async {
      await tester.pumpWidget(_wrap(const AiOffState('💡 דורש חיבור לשרת.')));
      expect(find.text('💡 דורש חיבור לשרת.'), findsOneWidget);
      final t = tester.widget<Text>(find.text('💡 דורש חיבור לשרת.'));
      expect(t.style?.color, BsTokens.mutedLight);
      expect(t.style?.fontSize, 13);
    });
  });

  group('AiLoadingState', () {
    testWidgets('shows a centered progress indicator', (tester) async {
      await tester.pumpWidget(_wrap(const AiLoadingState()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AiFailedState', () {
    testWidgets('honest line in dangerDark (WCAG) + retry affordance',
        (tester) async {
      await tester.pumpWidget(_wrap(AiFailedState(onRetry: () {})));
      expect(find.text('משהו השתבש — נסה שוב.'), findsOneWidget);
      final t = tester.widget<Text>(find.text('משהו השתבש — נסה שוב.'));
      // Darker red so it clears WCAG AA on the light card — NOT the lighter danger.
      expect(t.style?.color, BsTokens.dangerDark);
      expect(t.style?.color, isNot(BsTokens.danger));
      expect(find.text('נסה שוב'), findsOneWidget);
      expect(find.text('🔄'), findsOneWidget);
    });

    testWidgets('tapping retry fires onRetry exactly once', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(AiFailedState(onRetry: () => taps++)));
      await tester.tap(find.text('נסה שוב'));
      await tester.pump();
      expect(taps, 1);
    });
  });
}
