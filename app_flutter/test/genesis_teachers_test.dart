// 🧪 מורים (SchoolOS) · אימות-רנדר דטרמיניסטי (THE-WAY §6) — שלושת המבטים מרונדרים ללא חריגה.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_teachers.dart';

Widget _wrap(Widget child) => MaterialApp(home: Directionality(textDirection: TextDirection.rtl, child: child));

void main() {
  for (final mode in [0, 1, 2]) {
    testWidgets('מבט $mode מרונדר', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_wrap(TeachersScreen(initialMode: mode)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('שיעורים ללא מורה היום'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
