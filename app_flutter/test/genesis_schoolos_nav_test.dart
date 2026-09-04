// 🧪 SchoolOS · חיווט קצה-לקצה (THE-WAY §6 — אימות-ברנדר, לא "מתקמפל").
//   מוכיח דטרמיניסטית שמסך-הבית מנווט ל-9 המסכים (8 מודולי-הסשנים + מלאי) וכל אחד מרנדר
//   את כותרתו — כלומר האפליקציה מחוברת מקצה-לקצה, לא 9 קבצים נפרדים.
//   משטח גבוה (800×2400) ⇒ כל האריחים על-המסך; pump מפורש (אטומים מונפשים אינסופית).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos.dart';

const _tiles = <String, String>{
  // אריח-בית ⇒ טקסט שחייב להופיע במסך-היעד (כותרת-המסך / KPI ייחודי)
  'לוח-הנהלה': 'לוח-הנהלה',
  'תלמידים': 'תלמידים',
  'נוכחות': 'נוכחות',
  'חוגים ומערכת': 'חוגים',
  'מורים': 'מורים',
  'חדרים': 'חדרים',
  'גבייה': 'גבייה',
  'הורים': 'הורים',
  'מלאי': 'פריטים דורשי-הזמנה',
};

void main() {
  for (final e in _tiles.entries) {
    testWidgets('בית ⇒ ${e.key} מרונדר וחוזר', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SchoolOsApp());
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(e.key), findsWidgets, reason: 'אריח "${e.key}" חייב להיות במסך-הבית');

      await tester.tap(find.text(e.key).last); // .last = אריח-הניווט (ה-KPI 'תלמידים' קודם בעץ — טעות-בודק V5 שנתפסה)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600)); // מעבר-מסלול
      expect(find.textContaining(e.value), findsWidgets,
          reason: 'המסך "${e.key}" חייב לרנדר "${e.value}" אחרי הניווט');
      expect(tester.takeException(), isNull, reason: 'אפס חריגות-רנדר במסך "${e.key}"');
      expect(find.text('ימים-עד-ריקון מול אספקה — שלא ייגמר'), findsNothing,
          reason: 'הבית באמת עזב — הניווט ל-"${e.key}" קרה (לא נשארנו בבית)');

      // חזרה לבית — הניווט דו-כיווני
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('מלאי'), findsWidgets, reason: 'חזרה לבית אחרי "${e.key}"');
    });
  }
}
