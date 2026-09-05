// ⚛️ אטום-Dart (דרגת-חוזה) · signUpError — ולידציית טופס-הרשמה עצמית (CLOUD2).
// מוצא: maor/src/lib/config.ts:739-761 (signUpError — מסך-ההרשמה SIGNUP) ·
//        המקור: new/atoms/sign-up-error.mjs · חוזה: new/atoms/sign-up-error.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core RegExp).
// חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: בודק בסדר קבוע — שם-ארגון · שם-איש-קשר · טלפון · אימייל · סיסמה ≥6 ·
//        זהות-סיסמאות — ומחזיר את הודעת-השגיאה **הראשונה** בעברית, או '' כשהכול תקין.
//        "הזרימה מבוססת שיחה חוזרת (עדכון פקודה 30.7) — איש קשר וטלפון חובה".
// קלט:  orgName · contactName · phone · email · password · password2 (מחרוזות).
// פלט:  מחרוזת — הודעת-שגיאה בעברית או '' (תקין).
//
// הערות-המרה (מקור→Dart):
//  • truthiness (כלל-7): `!orgName.trim()` ב-JS = "המחרוזת-המקוצצת ריקה"; ב-Dart
//    מפורש — `orgName.trim().isEmpty`. זהה-ביט לקלט-מחרוזת (חוזה הקלט).
//  • `/re/.test(s)` → `RegExp(r're').hasMatch(s)` — מנוע-ה-RegExp של Dart תואם-ECMAScript:
//    `\d`=[0-9], `\s`=מחלקת-הרווחים של JS, `{6,}` ו-`^`/`$` (בלי multiline) זהים.
//  • `trim()`: קבוצת-הרווחים של JS (WhiteSpace+LineTerminator כולל NBSP/U+FEFF) ≡ של Dart
//    (White_Space+BOM) — אותו ניקוי-קצוות.
//  • `password.length` — יחידות-UTF-16 בשתי השפות (זהה-ביט גם לאמוג'י/סורוגטים).
//  • `!==` על מחרוזות → `!=` של Dart (השוואת-ערך) — שקול בדיוק.
//  אין locale/פורמט/תאריך/מוטציה — אטום טהור, אפס שקעים.

/// Self-service sign-up form validation (CLOUD2). Verbatim port of the JS source
/// new/atoms/sign-up-error.mjs (`signUpError`): checks in fixed order —
/// org name, contact name, phone (`^[\d+][\d\s-]{6,}$` on trim), email
/// (`^\S+@\S+\.\S+$` on trim), password >= 6, passwords match — and returns the
/// FIRST Hebrew error message, or '' when everything is valid.
String signUpError(String orgName, String contactName, String phone,
    String email, String password, String password2, {required String Function(String) term}) {
  if (orgName.trim().isEmpty) return term('shm-hargvn-hva-shdh-chvbh');
  // הזרימה מבוססת שיחה חוזרת (עדכון פקודה 30.7) — איש קשר וטלפון חובה
  if (contactName.trim().isEmpty) return term('shm-aysh-hkshr-hva-shdh-chvbh');
  if (!RegExp(r'^[\d+][\d\s-]{6,}$').hasMatch(phone.trim())) {
    return term('mspr-tlpvn-tkyn-hva-shdh-chvbh-nchzvr-alykm-layshvr');
  }
  if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email.trim())) {
    return term('ktvbt-haymyyl-aynh-tkynh');
  }
  if (password.length < 6) return term('hsysmh-chyybt-lhyvt-lpchvt-tvvym');
  if (password != password2) return term('hsysmavt-aynn-zhvt');
  return '';
}
