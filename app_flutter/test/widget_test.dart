import 'package:buildsmart/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap() => const ProviderScope(child: BuildSmartApp());

void main() {
  testWidgets('BuildSmart shell boots and renders the brand wordmark',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('BuildSmart'), findsOneWidget);
    expect(find.text('הקש על כפתור צף כדי להתחיל'), findsOneWidget);
  });

  testWidgets('Tapping the BS FAB opens the 5-persona dial', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    final bsFab = find.byTooltip('BS').first;
    await tester.tap(bsFab);
    await tester.pumpAndSettle();

    expect(find.text('קבלן'), findsOneWidget);
    expect(find.text('מנהל המערכת'), findsOneWidget);
    expect(find.text('חנות ספק'), findsOneWidget);
    expect(find.text('שליח'), findsOneWidget);
    expect(find.text('עובד'), findsOneWidget);
  });

  testWidgets('Tapping the Menu FAB opens the 4-tab dial', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('תפריט'));
    await tester.pumpAndSettle();

    expect(find.text('בית'), findsOneWidget);
    expect(find.text('הפרויקטים'), findsOneWidget);
    expect(find.text('רכש'), findsOneWidget);
    expect(find.text('הגדרות'), findsOneWidget);
  });
}
