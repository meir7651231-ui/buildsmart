// 🧪 בדיקת-ייצוא מחוללת · peruk26 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk26_rp1.dart';

void main() {
  test('reportTextGenAppPeruk26Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk26_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'צילום עו״ש': 'צילום עו״ש-3', 'רשימת מנויים אם יש': 'רשימת מנויים אם יש-4', 'ביטוחים': 'ביטוחים-5', 'סיווג': 'קבוע גדול'});

  final r0 = appStore.byId('app_peruk26_ent1', id0)!;
  final t = reportTextGenAppPeruk26Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*חורים ממוספרים ב־*'));
  expect(t, contains('*פעולה לכל חור לבטל*'));
  expect(t, contains('*נוסח ביטול מנוי שיחת*'));
  expect(t, contains('*מה לא לגעת החודש*'));
  expect(t, contains('*הסתייגות*'));

  });
}
