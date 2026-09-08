// 🧪 בדיקת-ייצוא מחוללת · peruk01 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk01_rp1.dart';

void main() {
  test('reportTextGenAppPeruk01Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk01_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'קובץ החוזה': 'קובץ החוזה-3', 'שכר דירה חודשי': 'שכר דירה חודשי-4', 'תקופת החוזה': 'תקופת החוזה-5', 'עיר': 'עיר-6', 'האם יש אופציה': 'כן', 'פיקדון': 'פיקדון-8', 'ערבות': 'ערבות-9', 'ערב': 'ערב-10', 'שטר חוב': 'שטר חוב-11', 'מתווך': 'מתווך-12', 'חוזה קודם': 'חוזה קודם-13', 'הודעות וואטסאפ עם המשכיר': 'הודעות וואטסאפ עם המשכיר-14', 'מועד חתימה': '2026-01-01', 'בלי החוזה המלא אין': 'בלי החוזה המלא אין-16', 'החלטה': 'לחתום כמו שזה'});
  appStore.add('app_peruk01_ent2', {'תיק': id0, 'סעיף': 'סעיף-2', 'מה כתוב': 'מה כתוב-3', 'מה לבקש': 'מה לבקש-4', 'צבע': 'אדום'});
  final r0 = appStore.byId('app_peruk01_ent1', id0)!;
  final t = reportTextGenAppPeruk01Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס עסקה ב־ שורות*'));
  expect(t, contains('*אדום צהוב ירוק*'));
  expect(t, contains('*חישוב בטוחות*'));
  expect(t, contains('*בקשות לשינוי*'));
  expect(t, contains('*החלטה*'));
  expect(t, contains('*מה לא בדקנו*'));
  expect(t, contains('*לוח*'));
  expect(t, contains('*הסתייגות*'));
  expect(t, contains('מתווך: '));
  expect(t, contains('החלטה: '));
  });
}
