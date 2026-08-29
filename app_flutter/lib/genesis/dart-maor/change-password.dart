// ⚛️ אטום-Dart (דרגת-חוזה) · changePassword — שינוי-סיסמה: אימות-מחדש ואז החלפה.
// מוצא: maor/src/lib/cloud.ts:362-383 → new/atoms/change-password.mjs
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת). קריאות Firebase-Auth
//        (getUser/reauth/update) ומיפוי-השגיאות hebrewAuthError הוזרקו כשקעים (חוק-1/6).
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: מאמת-מחדש עם הסיסמה הנוכחית ואז מחליף; שגיאות בעברית. הסדר + מיפוי-השגיאות בלבד.
// קלט:  currentPass · nextPass · 4 שקעים (getUser · reauth · update · hebrewAuthError).
// פלט:  Future<void>; כישלון ⇒ זריקת שגיאה בעברית (StateError בעל message).
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • truthiness (כלל 7): JS `!u || !u.email` — email ריק/null/חסר נחשב falsy;
//    ב-Dart בודקים במפורש `u == null || email == null || email.isEmpty`.
//  • `(e?.code ?? '').toString()`: e הוא ערך-דחייה שרירותי מהשקע; קריאת-code בטוחה
//    דרך dynamic עם נפילה ל-'' כשאין code (מקביל ל-undefined→'' של JS).
//  • Error של JS ⇒ StateError של Dart (נושא `message` לצורך רתמת-הזהב).

typedef GetUser = dynamic Function();
typedef Reauth = Future<void> Function(dynamic u, String currentPass);
typedef UpdatePass = Future<void> Function(dynamic u, String nextPass);
typedef HebrewAuthError = Object Function(Object? e);

String _codeOf(Object? e) {
  try {
    final dynamic c = (e as dynamic)?.code;
    return (c ?? '').toString();
  } catch (_) {
    return '';
  }
}

String? _emailOf(dynamic u) {
  try {
    final dynamic em = u?.email;
    return em == null ? null : em.toString();
  } catch (_) {
    return null;
  }
}

/// Change the signed-in user's password: re-authenticate with the current
/// password, then update. Hebrew errors; verbatim behaviour of the JS source
/// new/atoms/change-password.mjs.
Future<void> changePassword(
  String currentPass,
  String nextPass,
  GetUser getUser,
  Reauth reauth,
  UpdatePass update,
  HebrewAuthError hebrewAuthError,
) async {
  final u = getUser();
  final email = _emailOf(u);
  if (u == null || email == null || email.isEmpty) {
    throw StateError('אין משתמש מחובר — התחברו ונסו שוב');
  }
  try {
    await reauth(u, currentPass);
  } catch (e) {
    final code = _codeOf(e);
    if (code == 'auth/wrong-password' ||
        code == 'auth/invalid-credential' ||
        code == 'auth/invalid-login-credentials') {
      throw StateError('הסיסמה הנוכחית שגויה');
    }
    throw hebrewAuthError(e);
  }
  try {
    await update(u, nextPass);
  } catch (e) {
    final code = _codeOf(e);
    if (code == 'auth/weak-password') {
      throw StateError('הסיסמה החדשה חלשה מדי — לפחות 6 תווים');
    }
    throw hebrewAuthError(e);
  }
}
