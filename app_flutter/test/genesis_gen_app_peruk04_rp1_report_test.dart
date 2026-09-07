// 🧪 בדיקת-ייצוא מחוללת · peruk04 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk04_rp1.dart';

void main() {
  test('reportTextGenAppPeruk04Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk04_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'חוזה ישן': 'חוזה ישן-3', 'טיוטה חדשה': 'טיוטה חדשה-4', 'שכ״ד נוכחי': 'שכ״ד נוכחי-5', 'תאריך סיום': '2026-01-01', 'מתי ביקשו תשובה': '2026-01-01', 'ליקויים פתוחים': 'ליקויים פתוחים-8', 'וואטסאפ': 'וואטסאפ-9', 'מה משלמים באזור': 'מה משלמים באזור-10', 'הודעת תשובה אחת': 'כן עם תנאים'});

  final r0 = appStore.byId('app_peruk04_ent1', id0)!;
  final t = reportTextGenAppPeruk04Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*דיף סעיפים*'));
  expect(t, contains('*מספר מיקוח אחד*'));
  expect(t, contains('*הודעת תשובה אחת*'));
  expect(t, contains('*לוח*'));
  expect(t, contains('*הסתייגות*'));
  expect(t, contains('הודעת תשובה אחת: '));
  });
}
