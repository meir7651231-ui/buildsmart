// 🧪 בדיקת-ייצוא מחוללת · peruk09 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk09_rp1.dart';

void main() {
  test('reportTextGenAppPeruk09Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk09_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'הצעה': 'הצעה-3', 'חשבונית': 'חשבונית-4', 'הוכחת מסירה': 'הוכחת מסירה-5', 'מה נשאר': 'מה נשאר-6', 'מה הוא אמר': 'מה הוא אמר-7'});

  final r0 = appStore.byId('app_peruk09_ent1', id0)!;
  final t = reportTextGenAppPeruk09Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*סולם הודעות*'));
  expect(t, contains('*אם יש טענת ליקוי*'));
  expect(t, contains('*מה לא*'));
  expect(t, contains('*מתי תביעה קטנה הגיונית*'));
  expect(t, contains('*הסתייגות*'));

  });
}
