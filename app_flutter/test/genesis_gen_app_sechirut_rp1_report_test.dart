// 🧪 בדיקת-ייצוא מחוללת · sechirut — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_sechirut_rp1.dart';

void main() {
  test('reportTextGenAppSechirutRp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_sechirut_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'עיר': 'עיר-3', 'שכירות': 'שכירות-4', 'חודשים': 'חודשים-5', 'מועד חתימה': '2026-01-01', 'מתווך': 'כן', 'אופציה': 'כן', 'החלטה': 'לחתום כמו שזה', 'שכירות לשנה': 'שכירות לשנה-10', 'תקרה לפי חודשים': 'תקרה לפי חודשים-11', 'תקרה לפי שליש': 'תקרה לפי שליש-12'});
  appStore.add('app_sechirut_ent3', {'תיק': id0, 'סעיף': 'סעיף-2', 'צבע': 'אדום', 'מה כתוב': 'מה כתוב-4', 'מה לבקש': 'מה לבקש-5', 'נשלח': 'כן'});
  appStore.add('app_sechirut_ent2', {'תיק': id0, 'פיקדון': 'פיקדון-2', 'ערבות בנקאית': 'ערבות בנקאית-3', 'שטר חוב': 'אין', 'ערב': 'אין', 'סך בטוחות': 'סך בטוחות-6', 'תקרה לפי חודשים': 'תקרה לפי חודשים-7', 'תקרה לפי שליש': 'תקרה לפי שליש-8', 'חורג מול חודשים': 'חורג מול חודשים-9', 'חורג מול שליש': 'חורג מול שליש-10'});
  final r0 = appStore.byId('app_sechirut_ent1', id0)!;
  final t = reportTextGenAppSechirutRp1Screen(r0, id0);
  expect(t, contains('*המספר שלך*'));
  expect(t, contains('*אדום צהוב ירוק*'));
  expect(t, contains('*התשובה*'));
  expect(t, contains('*לוח*'));
  expect(t, contains('*כרטיס עסקה*'));
  expect(t, contains('*חישוב בטוחות*'));
  expect(t, contains('*בקשות לשינוי*'));
  expect(t, contains('*מה לא בדקנו*'));
  expect(t, contains('*הסתייגות*'));
  expect(t, contains('לקוח: '));
  expect(t, contains('שכירות: '));
  expect(t, contains('חודשים: '));
  expect(t, contains('שכירות לשנה: '));
  });
}
