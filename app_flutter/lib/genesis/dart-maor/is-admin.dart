// ⚛️ אטום-Dart (דרגת-חוזה) · isAdmin — הכרעת-מנהל.
// מוצא: המקור new/atoms/is-admin.mjs —
//        `export function isAdmin(adminEmails, email){ ... }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: רשימת-מיילי-מנהל ריקה/חסרה ⇒ כולם מנהלים (true). אחרת — התאמת-מייל
//        חסינת-רווחים-ורישיות מול הרשימה.
// קלט:  adminEmails = List<String>? (רשימת-מיילי-מנהל) · email = String? (המייל לבדיקה).
// פלט:  bool.
//
// הערות-המרה (מקור→Dart), תיקוני-המנוע:
//  · truthiness: ב-JS `!adminEmails || adminEmails.length===0` תופס גם null וגם ריק ⇒
//    ב-Dart `adminEmails == null || adminEmails.isEmpty`.
//  · truthiness: ב-JS `!email` תופס null *וגם* מחרוזת-ריקה '' ⇒
//    ב-Dart `email == null || email.isEmpty` (לא רק null!).
//  · מוטביליות: `const e` שלא-מוקצה-מחדש ⇒ `final e` ב-Dart.
//  · אין locale/פורמט/getMonth מעורבים — trim()/toLowerCase() מקבילים ישירים.

/// Returns true when [email] is an admin. An empty or null [adminEmails] list means
/// everyone is an admin. Otherwise matches [email] case- and whitespace-insensitively.
/// Behaviourally bit-identical to the JS source new/atoms/is-admin.mjs.
bool isAdmin(List<String>? adminEmails, String? email) {
  if (adminEmails == null || adminEmails.isEmpty) return true;
  if (email == null || email.isEmpty) return false;
  final e = email.trim().toLowerCase();
  return adminEmails.any((a) => a.trim().toLowerCase() == e);
}
