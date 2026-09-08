// 🧪 בדיקת-ייצוא מחוללת · peruk25 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk25_rp1.dart';

void main() {
  test('reportTextGenAppPeruk25Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk25_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'מכתב פיטורים': 'מכתב פיטורים-3', 'ותק': 'ותק-4', 'האם חתמו על משהו': 'כן', 'סיווג': 'סיום רגיל מכתב'});

  final r0 = appStore.byId('app_peruk25_ent1', id0)!;
  final t = reportTextGenAppPeruk25Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס ימים*'));
  expect(t, contains('*רשימת מסמכים מכתב תלושים*'));
  expect(t, contains('*מה לא לחתום הלילה*'));
  expect(t, contains('*נוסח שאלה למעסיק על*'));
  expect(t, contains('*רק אחר כך*'));
  expect(t, contains('*הסתייגות*'));

  });
}
