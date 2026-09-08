// 🧪 בדיקת-ייצוא מחוללת · peruk16 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk16_rp1.dart';

void main() {
  test('reportTextGenAppPeruk16Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk16_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'צילום הביטול': 'צילום הביטול-3', 'לאיזה רופא': 'לאיזה רופא-4', 'למה נקבע': 'למה נקבע-5', 'מה כואב עכשיו': 'מה כואב עכשיו-6', 'סיווג': 'מעקב שגרתי'});

  final r0 = appStore.byId('app_peruk16_ent1', id0)!;
  final t = reportTextGenAppPeruk16Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*סדר פעולות היום אפליקציה*'));
  expect(t, contains('*נוסח הודעה למרפאה לרופא*'));
  expect(t, contains('*מתי פרטי הגיוני*'));
  expect(t, contains('*סימנים שבהם לא מחכים*'));
  expect(t, contains('*הסתייגות*'));

  });
}
