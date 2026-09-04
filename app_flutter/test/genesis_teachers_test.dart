// 🧪 מורים (SchoolOS) · אימות-רנדר דטרמיניסטי (THE-WAY §6) — מבטים + כרטיס-מורה על כל 9 הטאבים, ללא חריגה.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_teachers.dart';

Widget _wrap(Widget child) => MaterialApp(home: Directionality(textDirection: TextDirection.rtl, child: child));

void _surface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final mode in [0, 1, 2]) {
    testWidgets('מבט $mode מרונדר', (tester) async {
      _surface(tester);
      await tester.pumpWidget(_wrap(TeachersScreen(initialMode: mode)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('שיעורים ללא מורה היום'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (var tab = 0; tab < 9; tab++) {
    testWidgets('כרטיס-מורה טאב $tab מרונדר', (tester) async {
      _surface(tester);
      await tester.pumpWidget(_wrap(TeachersScreen(initialPanel: 't2', initialTab: tab)));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 600)); // אנימציית-הגיליון
      expect(find.text('פעולות'), findsOneWidget, reason: 'הכרטיס נפתח');
      expect(tester.takeException(), isNull);
    });
  }
}
