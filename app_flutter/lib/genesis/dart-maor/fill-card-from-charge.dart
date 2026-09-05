// ⚛️ אטום-Dart (דרגת-חוזה) · fillCardFromCharge — מילוי-אם-ריק של פרטי-קשר מהעסקה לכרטיס.
// מוצא: maor/src/lib/nedarimSync.ts:303-321 · המקור: new/atoms/fill-card-from-charge.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכנים normPhone/normId הוזרקו כשקעים.
//
// תפקיד: פרטי-הקשר של עסקת-הסליקה נכנסים לשדות-הכרטיס ה**ריקים** בלבד; לעולם לא דורסים
//        ערך קיים. phone=הגלם-הגזום (לא המנורמל) · email/name גזומים · idNum=zeout מנורמל.
//        🐛 C12: טלפון שלא שורד נורמליזציה (<7 ספרות / מספר-דמה) לא ממלא גם שדה-ריק.
//        אין-מה-למלא ⇒ מוחזר **אותו** אובייקט (identical); יש ⇒ עותק חדש עם המילויים.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • `charge.phone || ''` / `sp.phone || ''`: ב-JS `||` נופל על undefined/null/''; כאן
//    כל הערכים מחרוזות, ו-`?? ''` של Dart (null בלבד) שקול — כי '' של המקור גם-כך trim⇒''.
//    ממומש ב-`_s` (null/לא-String ⇒ '', אחרת המחרוזת) — משקף `x || ''` לתחום המחרוזתי.
//  • truthiness: `if (phone && ...)` — phone הוא תוצאת-הטרנרי (מחרוזת), truthy=לא-ריקה
//    ⇒ `phone.isNotEmpty`. `!(sp.phone||'').trim()` ⇒ `.trim().isEmpty`.
//  • זהות-רפרנס: fill ריק ⇒ מחזירים את sp עצמו (identical), לא עותק (דוגמה 6).
//  • מוטביליות: fill הוא final (מוטבל דרך []=); העותק דרך `{...sp, ...fill}`.
//  • אין locale/פורמט/getMonth — הנרמול (phone/id) חי כולו בשקעים המוזרקים.

/// משקף `v || ''` לתחום-המחרוזתי: null/לא-String ⇒ '', אחרת המחרוזת עצמה.
String _s(dynamic v) => v is String ? v : '';

Map<String, dynamic> fillCardFromCharge(
  Map<String, dynamic> sp,
  Map<String, dynamic> charge,
  String Function(String) normPhone,
  String Function(String) normId,
) {
  final fill = <String, dynamic>{};
  // 🐛 C12: טלפון שלא שורד נורמליזציה (קצר/דמה) לא ממלא שדה ריק —
  // אחרת הוא חוסם השלמה אמיתית עתידית (מילוי-אם-ריק לא דורס).
  final rawPhone = _s(charge['phone']).trim();
  final phone = normPhone(rawPhone).length >= 7 ? rawPhone : '';
  final email = _s(charge['email']).trim();
  final zeout = normId(_s(charge['zeout']));
  final name = _s(charge['name']).trim();
  if (phone.isNotEmpty && _s(sp['phone']).trim().isEmpty) fill['phone'] = phone;
  if (email.isNotEmpty && _s(sp['email']).trim().isEmpty) fill['email'] = email;
  if (zeout.isNotEmpty && _s(sp['idNum']).trim().isEmpty) fill['idNum'] = zeout;
  if (name.isNotEmpty && _s(sp['name']).trim().isEmpty) fill['name'] = name;
  return fill.isNotEmpty ? {...sp, ...fill} : sp;
}
