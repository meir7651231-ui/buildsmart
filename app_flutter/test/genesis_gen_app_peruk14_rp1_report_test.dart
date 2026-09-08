// 🧪 בדיקת-ייצוא מחוללת · peruk14 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk14_rp1.dart';

void main() {
  test('reportTextGenAppPeruk14Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk14_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'מכתב דחייה': 'מכתב דחייה-3', 'מרשם': 'מרשם-4', 'מה הרופא אמר': 'מה הרופא אמר-5', 'האם יש שב״ן': 'כן', 'סיווג': 'חסר מסמך'});

  final r0 = appStore.byId('app_peruk14_ent1', id0)!;
  final t = reportTextGenAppPeruk14Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*רשימת השלמה לרופא לקופה*'));
  expect(t, contains('*טיוטת פנייה קצרה*'));
  expect(t, contains('*האם לגעת בשב״ן*'));
  expect(t, contains('*מה לא*'));
  expect(t, contains('*הסתייגות*'));

  });
}
