// 🧪 בדיקת-ייצוא מחוללת · peruk19 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk19_rp1.dart';

void main() {
  test('reportTextGenAppPeruk19Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk19_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'השובר': 'השובר-3', 'עיר': 'עיר-4', 'שוכר או בעלים': 'שוכר', 'תאריך כניסה': '2026-01-01', 'סיווג': 'הנחה שלא הוגשה'});

  final r0 = appStore.byId('app_peruk19_ent1', id0)!;
  final t = reportTextGenAppPeruk19Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*רשימת מסמכים להנחה השגה*'));
  expect(t, contains('*טיוטת פנייה קצרה*'));
  expect(t, contains('*מה לשלם בינתיים שלא*'));
  expect(t, contains('*מתי אין מה לערער*'));
  expect(t, contains('*הסתייגות*'));

  });
}
