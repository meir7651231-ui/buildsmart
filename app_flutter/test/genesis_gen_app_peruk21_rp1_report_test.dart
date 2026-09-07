// 🧪 בדיקת-ייצוא מחוללת · peruk21 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk21_rp1.dart';

void main() {
  test('reportTextGenAppPeruk21Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk21_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'המכתב': 'המכתב-3', 'מה כבר יש': 'מה כבר יש-4', 'עד מתי': '2026-01-01', 'סיווג': 'בקשת מסמך'});

  final r0 = appStore.byId('app_peruk21_ent1', id0)!;
  final t = reportTextGenAppPeruk21Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס בעברית פשוטה*'));
  expect(t, contains('*רשימת הגשה*'));
  expect(t, contains('*טיוטת תשובה קצרה למחנכת*'));
  expect(t, contains('*שאלות לפגישה*'));
  expect(t, contains('*מה לא לכתוב בקבוצת*'));
  expect(t, contains('*הסתייגות*'));

  });
}
