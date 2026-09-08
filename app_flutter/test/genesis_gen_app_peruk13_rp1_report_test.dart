// 🧪 בדיקת-ייצוא מחוללת · peruk13 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk13_rp1.dart';

void main() {
  test('reportTextGenAppPeruk13Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk13_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'המסמך המלא': 'המסמך המלא-3', 'סיווג': 'לקרוא עם רופא'});

  final r0 = appStore.byId('app_peruk13_ent1', id0)!;
  final t = reportTextGenAppPeruk13Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*מה במסמך מסומן חריג*'));
  expect(t, contains('*מה לא כתוב לא*'));
  expect(t, contains('*שאלות לרופא*'));
  expect(t, contains('*דחוף לא דחוף לפי*'));
  expect(t, contains('*הנחיה קשיחה*'));
  expect(t, contains('*הסתייגות*'));

  });
}
