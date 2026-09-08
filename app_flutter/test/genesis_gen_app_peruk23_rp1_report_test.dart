// 🧪 בדיקת-ייצוא מחוללת · peruk23 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk23_rp1.dart';

void main() {
  test('reportTextGenAppPeruk23Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk23_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'נושא': 'נושא-3'});

  final r0 = appStore.byId('app_peruk23_ent1', id0)!;
  final t = reportTextGenAppPeruk23Rp1Screen(r0, id0);
  expect(t, contains('*מה באמת חשוב למבחן*'));
  expect(t, contains('*הסבר אחד פשוט לנקודת*'));
  expect(t, contains('*תרגילים דומים פתרון נפרד*'));
  expect(t, contains('*סדר דקות*'));
  expect(t, contains('*מה לא לכסות הלילה*'));
  expect(t, contains('*הסתייגות*'));

  });
}
