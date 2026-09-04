// 🧪 SchoolOS · חדרים — אימות-רנדר (THE-WAY §6) של RoomsScreen מול המטרה, לא מול "מתקמפל".
//   משטח 800×2400 (בלי גלישת-Row, כל התוכן על-המסך) · pump מפורש (אטומים מונפשים ⇒ לא pumpAndSettle).
//   הערכים המצופים חושבו ביד מהדאטה-הדטרמיניסטית (today=2026-09-03 · now=10:15) — הבודק מפעיל את המנגנון (V6).
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_rooms.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_pure.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      builder: (c, ch) => PureScope(
        theme: DsPure.themes[DsPure.defaultTheme]!,
        fonts: const DsPureFonts(serif: 'Heebo', serifHe: 'FrankRuhlLibre', grotesk: 'JetBrains Mono', he: 'Heebo'),
        child: Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink()),
      ),
      home: const RoomsScreen(),
    );

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_app());
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('גל 1 · KPI-10 מרונדרים מדאטה-אמת (7 חדרים · 2 התנגשויות · 1 תפוס-עכשיו)', (tester) async {
    await _pump(tester);
    expect(find.text('התנגשויות-תפיסה השבוע'), findsOneWidget, reason: 'hero=המטרה (אפס כפל-תפיסה)');
    // 2 התנגשויות-אמת: r1 חמישי 09:00 (מתמטיקה⊕מבחן-מתכונת) · r2 חמישי 10:00 (כימיה⊕ביולוגיה)
    expect(find.text('2'), findsWidgets, reason: 'hero + BareStat התנגשויות = 2');
    expect(find.text('🏫 חדרים'), findsOneWidget);
    expect(find.text('7'), findsOneWidget, reason: '7 חדרים בדאטה');
    // roomsNow ב-10:15 יום-חמישי: רק מעבדת-מדעים (כימיה יא׳ 10:00) תפוסה מתוך 6 פעילים
    expect(find.text('🔴 תפוסים-עכשיו'), findsOneWidget);
    expect(find.text('🟢 פנויים-עכשיו'), findsOneWidget);
    expect(find.text('5'), findsWidgets, reason: 'פנויים-עכשיו = 6 פעילים − 1 תפוס');
    expect(find.text('🔧 תקלות-פתוחות'), findsOneWidget);
    expect(find.text('3'), findsWidgets, reason: 'f1·f2·f3 פתוחות (f4 done)');
    expect(find.text('⏳ ממתינות-אישור'), findsOneWidget);
    expect(find.text('🧰 ציוד-חסר/תקול'), findsOneWidget);
    expect(find.text('🪑 לא-מנוצלים'), findsOneWidget);
    expect(find.text('📊 ניצולת-שבוע'), findsOneWidget);
  });
}
