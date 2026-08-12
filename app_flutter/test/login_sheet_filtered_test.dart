// ratchet — מצב-מסונן · שלב E-ui: מסך-הכניסה במצב-מסונן.
//
// כשהדגל דלוק ⇒ המסך מציג רק מייל+סיסמה (מסתיר גוגל/SMS), והמתג מסומן פעיל.
// כבוי ⇒ מסך-הטלפון הרגיל + מתג-כבוי. פאמפ ישיר של LoginSheet (בלי מודאל/הקשה)
// כדי לא להפעיל אנימציית-ריצוד (ה-shader הבעייתי בסביבת-ה-CI המקומית).
import 'package:buildsmart/data/edge/filtered_mode.dart';
import 'package:buildsmart/data/edge/filtered_session.dart';
import 'package:buildsmart/screens/login_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemStore implements EdgeKvStore {
  _MemStore([Map<String, String>? seed]) {
    if (seed != null) m.addAll(seed);
  }
  final Map<String, String> m = {};
  @override
  String? read(String key) => m[key];
  @override
  void write(String key, String value) => m[key] = value;
  @override
  void remove(String key) => m.remove(key);
}

Future<void> _pump(WidgetTester t, EdgeKvStore store) async {
  await t.binding.setSurfaceSize(const Size(440, 950));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(
    ProviderScope(
      overrides: [edgeKvStoreProvider.overrideWithValue(store)],
      child: const MaterialApp(
        locale: Locale('he'),
        home: Scaffold(body: SingleChildScrollView(child: LoginSheet())),
      ),
    ),
  );
  await t.pump();
}

void main() {
  testWidgets('מצב-מסונן דלוק ⇒ רק מייל+סיסמה · גוגל/טלפון מוסתרים · מתג פעיל',
      (t) async {
    await _pump(t, _MemStore({kFilteredModeKey: '1'}));

    // פאנל-המייל מוצג (שדות אימייל+סיסמה):
    expect(find.text('אימייל'), findsOneWidget);
    expect(find.text('כניסה עם אימייל'), findsOneWidget);
    // גוגל וטלפון לא-מוצגים (נוגעים בכמה דומייני-גוגל):
    expect(find.text('המשך עם Google'), findsNothing);
    expect(find.text('מספר טלפון נייד'), findsNothing);
    // המתג מסומן פעיל:
    expect(
      find.text('✓ מצב אינטרנט מסונן פעיל — כניסה במייל וסיסמה'),
      findsOneWidget,
    );
  });

  testWidgets('מצב-מסונן כבוי (ברירת-מחדל) ⇒ מסך-טלפון + מתג-כבוי, ביט-זהה',
      (t) async {
    await _pump(t, _MemStore());

    // מסך-הטלפון הרגיל:
    expect(find.text('מספר טלפון נייד'), findsOneWidget);
    // אין פאנל-מייל (LOCK — email off + filtered off):
    expect(find.text('כניסה עם אימייל'), findsNothing);
    // המתג מוצג במצב-כבוי (הזמנה להדליק):
    expect(find.text('אני על אינטרנט מסונן (נטפרי/רימון)'), findsOneWidget);
  });
}
