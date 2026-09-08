// 🧪 בדיקת-ייצוא מחוללת · peruk28 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk28_rp1.dart';

void main() {
  test('reportTextGenAppPeruk28Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk28_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'ותק': 'ותק-3', 'תפקיד': 'תפקיד-4', 'העלאה אחרונה': 'העלאה אחרונה-5', 'מה נוסף בתפקיד': 'מה נוסף בתפקיד-6', 'מספר אם יש': '7', 'סיווג': 'סבב העלאות קרוב'});

  final r0 = appStore.byId('app_peruk28_ent1', id0)!;
  final t = reportTextGenAppPeruk28Rp1Screen(r0, id0);
  expect(t, contains('*האם עכשיו בכלל זמן*'));
  expect(t, contains('*מספר אחד לבקש טווח*'));
  expect(t, contains('*משפטים לפגישה*'));
  expect(t, contains('*אסור*'));
  expect(t, contains('*מה לבקש בכתב אחרי*'));
  expect(t, contains('*הסתייגות*'));

  });
}
