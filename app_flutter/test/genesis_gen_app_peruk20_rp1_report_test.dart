// 🧪 בדיקת-ייצוא מחוללת · peruk20 — הטקסט של הדוח (G25) מכיל כל *חלק* וכל "שדה: ערך" של השורש; הרשומות נזרעות מהסכמה (ערכי-צורה).
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_peruk20_rp1.dart';

void main() {
  test('reportTextGenAppPeruk20Rp1Screen: *חלקים* + עובדות-השורש', () {
  final id0 = appStore.add('app_peruk20_ent1', {'לקוח': 'לקוח-1', 'טלפון': 'טלפון-2', 'צילום סטטוס': 'כן', 'מה צריך': 'מה צריך-4', 'תאריך טיסה אם יש': '2026-01-01', 'סיווג': 'חסר מסמך'});

  final r0 = appStore.byId('app_peruk20_ent1', id0)!;
  final t = reportTextGenAppPeruk20Rp1Screen(r0, id0);
  expect(t, contains('*כרטיס*'));
  expect(t, contains('*רשימת השלמה*'));
  expect(t, contains('*נוסח פנייה ללשכה פנייה*'));
  expect(t, contains('*האם בכלל שייך דחוף*'));
  expect(t, contains('*מה לא*'));
  expect(t, contains('*הסתייגות*'));

  });
}
