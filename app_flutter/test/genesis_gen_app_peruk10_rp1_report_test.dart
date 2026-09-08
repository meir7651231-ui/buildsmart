// 🧪 בדיקת-ייצוא מחוללת · peruk10 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk10_rp1.dart';

void main() {
  test('reportTextGenAppPeruk10Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk10_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'צילום כל המכתב': 'צילום כל המכתב-3', 'כולל תאריכים וסכומים': 'כולל תאריכים וסכומים-4', 'אם יש מכתב ישן': 'אם יש מכתב ישן-5', 'תשלום חלקי': 'תשלום חלקי-6', 'צילום בעלות': '7', 'סיווג': 'עוד חלון'});

  final r0 = appStore.byId('app_peruk10_ent1', id0)!;
  final t = reportTextGenAppPeruk10Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*פירוק הסכום לשורות*'));
  expect(t, contains('*צעד אחד השבוע לא*'));
  expect(t, contains('*טיוטת פנייה אם יש*'));
  expect(t, contains('*מה יקרה אם מתעלמים*'));
  expect(t, contains('*מתי לעצור וללכת לעו״ד*'));
  expect(t, contains('*הסתייגות*'));

  });
}
