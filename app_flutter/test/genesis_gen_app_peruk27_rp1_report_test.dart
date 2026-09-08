// 🧪 בדיקת-ייצוא מחוללת · peruk27 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk27_rp1.dart';

void main() {
  test('reportTextGenAppPeruk27Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk27_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'יש ילדים': 'יש ילדים-3', 'סיווג': 'ילדים בבית'});

  final r0 = appStore.byId('app_peruk27_ent1', id0)!;
  final t = reportTextGenAppPeruk27Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס ימים לפי סדר*'));
  expect(t, contains('*מה לא לחתום לא*'));
  expect(t, contains('*רשימת ניירת לאסוף חוזה*'));
  expect(t, contains('*טיוטת הודעה עניינית לצד*'));
  expect(t, contains('*מתי חובה עו״ד מחר*'));
  expect(t, contains('*הסתייגות*'));

  });
}
