// 🧪 בדיקת-ייצוא מחוללת · peruk08 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk08_rp1.dart';

void main() {
  test('reportTextGenAppPeruk08Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk08_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'צילום החיוב': 'צילום החיוב-3', 'הזמנה': 'הזמנה-4', 'מה קרה': 'מה קרה-5', 'האם כבר פנו למוכר': 'כן', 'סיווג': 'א לא הגיע'});

  final r0 = appStore.byId('app_peruk08_ent1', id0)!;
  final t = reportTextGenAppPeruk08Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*סדר פעולות ממוספר קודם*'));
  expect(t, contains('*הודעה למוכר*'));
  expect(t, contains('*טיוטה למנפיק ביט רק*'));
  expect(t, contains('*מה לצרף*'));
  expect(t, contains('*אם לא שווה סכום*'));
  expect(t, contains('*הסתייגות*'));

  });
}
