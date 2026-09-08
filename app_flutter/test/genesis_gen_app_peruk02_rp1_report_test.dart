// 🧪 בדיקת-ייצוא מחוללת · peruk02 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk02_rp1.dart';

void main() {
  test('reportTextGenAppPeruk02Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk02_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'סכום הפיקדון': '3', 'מה המשכיר אמר הודעה': 'מה המשכיר אמר הודעה-4', 'תאריך מסירת מפתח': '2026-01-01', 'חוזה לפחות סעיפי בטוחה': 'חוזה לפחות סעיפי בטוחה-6', 'תיקונים': 'תיקונים-7', 'יציאה': 'יציאה-8', 'חזק מאוד אם יש': 'חזק מאוד אם יש-9', 'פרוטוקול כניסה יציאה': 'פרוטוקול כניסה יציאה-10', 'תמונות כניסה ויציאה': 'תמונות כניסה ויציאה-11', 'וואטסאפ מלא עם המשכיר': 'וואטסאפ מלא עם המשכיר-12', 'קבלות על תיקונים שהוא': 'קבלות על תיקונים שהוא-13'});

  final r0 = appStore.byId('app_peruk02_ent1', id0)!;
  final t = reportTextGenAppPeruk02Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*טבלת שורות*'));
  expect(t, contains('*סכום יעד לדרישה*'));
  expect(t, contains('*הודעת וואטסאפ אחת*'));
  expect(t, contains('*אם מתעלמים מדרגה הבאה*'));
  expect(t, contains('*מה חסר*'));
  expect(t, contains('*לוח*'));
  expect(t, contains('*הסתייגות*'));
  expect(t, contains('יציאה: '));
  });
}
