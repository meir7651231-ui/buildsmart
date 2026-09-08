// 🧪 בדיקת-ייצוא מחוללת · peruk07 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk07_rp1.dart';

void main() {
  test('reportTextGenAppPeruk07Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk07_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'מכתב הדחייה': 'מכתב הדחייה-3', 'סוג הביטוח מה קרה': 'סוג הביטוח מה קרה-4', 'פוליסה או תנאים כלליים': 'פוליסה', 'מה כבר הוגש': 'מה כבר הוגש-6', 'קבלות': 'קבלות-7', 'סיווג': 'א חסר מסמך'});

  final r0 = appStore.byId('app_peruk07_ent1', id0)!;
  final t = reportTextGenAppPeruk07Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*עילת הדחייה מול הסעיף*'));
  expect(t, contains('*רשימת השלמה*'));
  expect(t, contains('*מכתב מייל תשובה אחד*'));
  expect(t, contains('*מדרגה אם שוב לא*'));
  expect(t, contains('*האם בכלל שווה*'));
  expect(t, contains('*הסתייגות*'));

  });
}
