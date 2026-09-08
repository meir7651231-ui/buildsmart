// 🧪 בדיקת-ייצוא מחוללת · peruk24 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk24_rp1.dart';

void main() {
  test('reportTextGenAppPeruk24Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk24_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'מה קרה': 'מה קרה-3', 'גר לבד': 'גר לבד-4', 'כמה אחים': 'כמה אחים-5', 'מכתב אם יש': 'מכתב אם יש-6', 'סיווג': 'אחרי נפילה'});

  final r0 = appStore.byId('app_peruk24_ent1', id0)!;
  final t = reportTextGenAppPeruk24Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*רשימת שעות*'));
  expect(t, contains('*חלוקה לאחים אפילו אם*'));
  expect(t, contains('*טיוטת הודעה להורה בלי*'));
  expect(t, contains('*מתי סיעוד רופא גריאטר*'));
  expect(t, contains('*הסתייגות*'));

  });
}
