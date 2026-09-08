// 🧪 בדיקת-ייצוא מחוללת · peruk12 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk12_rp1.dart';

void main() {
  test('reportTextGenAppPeruk12Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk12_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'קישור מודעה': 'קישור מודעה-3', 'מחיר': '4', 'מה המוכר אמר': 'מה המוכר אמר-5', 'האם נסעת': 'כן'});

  final r0 = appStore.byId('app_peruk12_ent1', id0)!;
  final t = reportTextGenAppPeruk12Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*רשימת שאלות למוכר מקסימום*'));
  expect(t, contains('*מה לבדוק בנסיעה*'));
  expect(t, contains('*מה חייב לפני העברה*'));
  expect(t, contains('*נוסח*'));
  expect(t, contains('*החלטה*'));
  expect(t, contains('*הסתייגות*'));
  expect(t, contains('מחיר: '));
  });
}
