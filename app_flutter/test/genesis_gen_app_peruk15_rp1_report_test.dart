// 🧪 בדיקת-ייצוא מחוללת · peruk15 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk15_rp1.dart';

void main() {
  test('reportTextGenAppPeruk15Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk15_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'החשבון כולו': 'החשבון כולו-3', 'קופה': 'קופה-4', 'האם תאונה': 'כן', 'האם הייתה הפניה': 'כן', 'סיווג': 'טעות מנהלית'});

  final r0 = appStore.byId('app_peruk15_ent1', id0)!;
  final t = reportTextGenAppPeruk15Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*שאלות לבית החולים לקופה*'));
  expect(t, contains('*טיוטת בקשת פירוט העברת*'));
  expect(t, contains('*מה לא לדחות סתם*'));
  expect(t, contains('*אם כבר הוצל״פ עצירה*'));
  expect(t, contains('*הסתייגות*'));

  });
}
