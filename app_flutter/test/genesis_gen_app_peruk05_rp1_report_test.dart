// 🧪 בדיקת-ייצוא מחוללת · peruk05 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk05_rp1.dart';

void main() {
  test('reportTextGenAppPeruk05Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk05_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'חוזה': 'חוזה-3', 'השטר': 'השטר-4', 'מה כבר שולם כפיקדון': 'מה כבר שולם כפיקדון-5', 'מי חותם ערב הורה': 'מי חותם ערב הורה-6', 'בקשות לתיקון לפני חתימה': 'לכתוב סכום מקסימום בשטר'});

  final r0 = appStore.byId('app_peruk05_ent1', id0)!;
  final t = reportTextGenAppPeruk05Rp1Screen(r0, id0);
  expect(t, contains('*מפת בטוחות*'));
  expect(t, contains('*חשיפת ההורה במשפט אחד*'));
  expect(t, contains('*בקשות לתיקון לפני חתימה*'));
  expect(t, contains('*הודעה למשכיר מתווך*'));
  expect(t, contains('*החלטה*'));
  expect(t, contains('*הסתייגות*'));
  expect(t, contains('בקשות לתיקון לפני חתימה: '));
  expect(t, contains('השטר: '));
  });
}
