// 🧪 גל 11 · אימות-רנדר (THE-WAY §6) למצב-המסך השמור "טעינה" של מסך-המלאי (SchoolOS).
//   סוגר את חוב-הדרך: מוכיח דטרמיניסטית שמצב-הטעינה מרונדר (CircularProgressIndicator +
//   "טוען מלאי…") אחרי רענון, ומתנקה אחרי החלון — חזק מצילום-headless שביר.
//   משטח רחב-וגבוה (800×2400): בלי גלישת-Row, וכל התוכן על-המסך ⇒ קליקים נוחתים.
//   האטומים המונפשים אינסופית ⇒ pump מפורש (לא pumpAndSettle שנתקע).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos.dart';

void main() {
  testWidgets('גל 11 · מצב-טעינה שמור מרונדר אחרי רענון ומתנקה', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SchoolOsApp());
    await tester.pump(const Duration(milliseconds: 300)); // מסך-הבית

    // ניווט למסך-המלאי דרך אריח-הניווט 'מלאי'
    await tester.tap(find.text('מלאי').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // סיום-מעבר-המסלול
    expect(find.text('פריטים דורשי-הזמנה'), findsOneWidget, reason: 'הניווט למסך-המלאי הצליח');

    // מצב-התחלתי: אין טעינה
    expect(find.text('🔄'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // רענון ⇒ מצב-הטעינה השמור מאיר
    await tester.tap(find.text('🔄'));
    await tester.pump(); // setState(_loading=true)
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('טוען מלאי…'), findsOneWidget,
        reason: 'מצב-טעינה: "טוען מלאי…" חייב לרנדר אחרי רענון');
    expect(find.byType(CircularProgressIndicator), findsOneWidget,
        reason: 'מצב-טעינה: CircularProgressIndicator חייב לרנדר אחרי רענון');

    // אחרי חלון-הטעינה (700ms) — מתנקה חזרה לתוכן
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(CircularProgressIndicator), findsNothing,
        reason: 'מצב-טעינה: מתנקה אחרי החלון (Future.delayed)');
    expect(find.text('טוען מלאי…'), findsNothing);
  });
}
