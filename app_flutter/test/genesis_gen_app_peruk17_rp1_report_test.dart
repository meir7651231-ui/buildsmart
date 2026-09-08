// 🧪 בדיקת-ייצוא מחוללת · peruk17 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk17_rp1.dart';

void main() {
  test('reportTextGenAppPeruk17Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk17_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'המכתב המלא': 'המכתב המלא-3', 'איזו בקשה': 'איזו בקשה-4', 'מה כבר הוגש': 'מה כבר הוגש-5', 'סיווג': 'השלמת מסמכים'});

  final r0 = appStore.byId('app_peruk17_ent1', id0)!;
  final t = reportTextGenAppPeruk17Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*רשימת מסמכים ממוספרת*'));
  expect(t, contains('*טיוטת נלווה קצרה*'));
  expect(t, contains('*מה לא לשלוח ערמה*'));
  expect(t, contains('*מתי לעו״ד לחבר מגיש*'));
  expect(t, contains('*הסתייגות*'));

  });
}
