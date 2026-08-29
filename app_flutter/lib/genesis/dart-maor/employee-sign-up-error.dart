// ⚛️ אטום-Dart (דרגת-חוזה) · employeeSignUpError — ולידציית הרשמת-עובד/ת ("קוד מהבוס")
// מוצא: maor/src/lib/config.ts:762-768 כלשונו (ORGADMIN); חוק-4 — התנהגות זהה למקור-ה-JS,
//        לא-משופרת. המקור: new/atoms/employee-sign-up-error.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: מאמת שדות-הרשמה בסדר קבוע ומחזיר את הודעת-השגיאה העברית הראשונה, או '' כשהכול תקין:
//        מייל תקין ← טלפון ← סיסמה ≥6 ← קוד-הזמנה לא-ריק.
// קלט:  email/phone/password/code — כולם String.
// פלט:  הודעת-שגיאה בעברית (String), או '' כשתקין.
//
// הערות-המרה (מקור→Dart, סטיות שהמנוע פספס):
//  • JS `RegExp(...).test(s)` ⇒ Dart `RegExp(...).hasMatch(s)` (אין `.test` ב-Dart).
//  • JS truthiness `if (!code.trim())` (מחרוזת-ריקה = falsy) ⇒ Dart `code.trim().isEmpty`.
//  • `password.length < 6` שקול (אורך-String בשתי השפות). אין locale/פורמט/getMonth/תאריך.
//  • הביטויים-הרגולריים זהים ביט-אחר-ביט (raw-strings), כולל `{6,}` ו-`\S`/`\d`/`\s`.

/// Employee sign-up validation. Returns the first Hebrew error message in fixed
/// order (email → phone → password → invite code), or '' when all valid.
/// Verbatim behaviour of the JS source new/atoms/employee-sign-up-error.mjs.
String employeeSignUpError(String email, String phone, String password, String code, {required String Function(String) term}) {
  if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email.trim())) {
    return term('ktvbt-haymyyl-aynh-tkynh');
  }
  if (!RegExp(r'^[\d+][\d\s-]{6,}$').hasMatch(phone.trim())) {
    return term('mspr-tlpvn-tkyn-hva-shdh-chvbh');
  }
  if (password.length < 6) return term('hsysmh-chyybt-lhyvt-lpchvt-tvvym');
  if (code.trim().isEmpty) return term('kvdhhzmnh-mhmnhl-hva-shdh-chvbh');
  return '';
}
