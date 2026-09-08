// 🧪 בדיקת-ייצוא מחוללת · peruk03 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk03_rp1.dart';

void main() {
  test('reportTextGenAppPeruk03Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk03_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'תיאור תמונות': 'תיאור תמונות-3', 'תאריך כניסה': '2026-01-01', 'מתי הודיעו': '2026-01-01', 'סעיף תיקונים בחוזה': 'סעיף תיקונים בחוזה-6', 'פרוטוקול כניסה': 'פרוטוקול כניסה-7', 'תשובת המשכיר': 'תשובת המשכיר-8', 'הצעת טכנאי': 'הצעת טכנאי-9', 'אופציות אחרי השעון רק': 'תיקון עצמי אחרי הודעה', 'סיווג': 'דחוף שעון ימים'});

  final r0 = appStore.byId('app_peruk03_ent1', id0)!;
  final t = reportTextGenAppPeruk03Rp1Screen(r0, id0);
  expect(t, contains('*סיווג*'));
  expect(t, contains('*שעון*'));
  expect(t, contains('*הודעה למשכיר וואטסאפ תיאור*'));
  expect(t, contains('*הודעה אם אין תשובה*'));
  expect(t, contains('*אסור*'));
  expect(t, contains('*אופציות אחרי השעון רק*'));
  expect(t, contains('*מה לצלם היום כדי*'));
  expect(t, contains('*לוח*'));
  expect(t, contains('*הסתייגות*'));
  expect(t, contains('אופציות אחרי השעון רק: '));
  });
}
