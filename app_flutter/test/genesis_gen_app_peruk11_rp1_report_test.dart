// 🧪 בדיקת-ייצוא מחוללת · peruk11 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk11_rp1.dart';

void main() {
  test('reportTextGenAppPeruk11Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk11_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'הצעה': 'הצעה-3', 'סיווג': 'עכשיו בטיחות הרכב'});

  final r0 = appStore.byId('app_peruk11_ent1', id0)!;
  final t = reportTextGenAppPeruk11Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*טבלה*'));
  expect(t, contains('*שאלות למוסך*'));
  expect(t, contains('*נוסח*'));
  expect(t, contains('*מתי כן לקחת הצעה*'));
  expect(t, contains('*הסתייגות*'));
  expect(t, contains('הצעה: '));
  });
}
