// 🧪 בדיקת-ייצוא מחוללת · peruk06 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk06_rp1.dart';

void main() {
  test('reportTextGenAppPeruk06Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk06_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'כמה שולם ואיך': 'כמה שולם ואיך-3', 'הצעה': 'הצעה-4', 'מה המצב עכשיו': 'כן', 'מה הוא אמר לאחרונה': 'מה הוא אמר לאחרונה-6', 'הצעת השלמה ממישהו אחר': 'הצעת השלמה ממישהו אחר-7', 'קבלות חומרים': 'קבלות חומרים-8', 'שם מלא': 'שם מלא-9'});

  final r0 = appStore.byId('app_peruk06_ent1', id0)!;
  final t = reportTextGenAppPeruk06Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*ציר*'));
  expect(t, contains('*טבלת כסף*'));
  expect(t, contains('*הודעה*'));
  expect(t, contains('*הודעה*'));
  expect(t, contains('*מה לא לעשות השבוע*'));
  expect(t, contains('*הסתייגות*'));

  });
}
