import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// T6 — safety/budget notification actions show real inline content (R9 sheet),
// replacing the prior "בבנייה" toast. Consumes T0 seeds (kSafetyTips +
// kBudgetThresholds from data/contractor_seeds.dart).
void main() {
  testWidgets('T6 · safety action → SAFETY_TIPS×5 + ack button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () =>
                    showNotifActionSheet(context, NotifSection.safety, ''),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(kSafetyTips.length, 5);
    for (final tip in kSafetyTips) {
      expect(find.text(tip), findsOneWidget);
    }
    expect(find.text('אשר תדריך'), findsOneWidget);
  });

  testWidgets('T6 · budget action → kBudgetThresholds + status', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showNotifActionSheet(
                  context,
                  NotifSection.budget,
                  'פרויקט A חרג ב-12% מהתקציב',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    for (final t in kBudgetThresholds) {
      expect(find.text(t.label), findsOneWidget);
    }
    expect(find.textContaining('חרג ב-12%'), findsOneWidget);
  });
}
