// 🧪 בדיקת-ייצוא מחוללת · peruk18 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk18_rp1.dart';

void main() {
  test('reportTextGenAppPeruk18Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk18_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'המכתב': 'המכתב-3', 'עוסק פטור': 'עוסק פטור-4', 'יש רו״ח כן': 'יש רו״ח כן-5', 'האם הוגש דוח': 'כן', 'סיווג': 'אי־הגשה'});

  final r0 = appStore.byId('app_peruk18_ent1', id0)!;
  final t = reportTextGenAppPeruk18Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*דברים להוציא מהמגרה*'));
  expect(t, contains('*שאלות לרו״ח או תפתח*'));
  expect(t, contains('*טיוטה קצרה רק אם*'));
  expect(t, contains('*מה לא לשלם עיוור*'));
  expect(t, contains('*הסתייגות*'));

  });
}
