// 🧪 בדיקת-ייצוא מחוללת · peruk22 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk22_rp1.dart';

void main() {
  test('reportTextGenAppPeruk22Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk22_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'גיל': 'גיל-3', 'מה יש לילד': 'מה יש לילד-4', 'מה כתוב במעון': 'מה כתוב במעון-5', 'סוג עבודה': 'סוג עבודה-6', 'יש מישהו שני': 'יש מישהו שני-7'});

  final r0 = appStore.byId('app_peruk22_ent1', id0)!;
  final t = reportTextGenAppPeruk22Rp1Screen(r0, id0);
  expect(t, contains('*מי נשאר החלטה ברורה*'));
  expect(t, contains('*נוסח קצר למנהל ללקוח*'));
  expect(t, contains('*מה לבדוק מול המעון*'));
  expect(t, contains('*דגלים לרופא מיון לפי*'));
  expect(t, contains('*מה לא*'));
  expect(t, contains('*הסתייגות*'));

  });
}
