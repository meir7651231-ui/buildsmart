// ⚛️ אטום-Dart (דרגת-חוזה) · resetPassword — שליחת מייל איפוס-סיסמה, שגיאות בעברית.
// מוצא: maor/src/lib/cloud.ts:347-356 → new/atoms/reset-password.mjs
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת). קריאות Firebase-Auth
//        (requireAuth/sendReset) ומיפוי-השגיאות hebrewAuthError הוזרקו כשקעים (חוק-1/6).
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: עוטף את קריאת-הענן במיפוי-שגיאות לעברית. הסדר + מיפוי-השגיאות בלבד.
// קלט:  email · 3 שקעים (requireAuth · sendReset · hebrewAuthError).
// פלט:  Future<void>; כישלון ⇒ זריקת שגיאה בעברית (StateError בעל message).
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • `(e?.code ?? '').toString()`: e הוא ערך-דחייה שרירותי מהשקע; קריאת-code בטוחה
//    דרך dynamic עם נפילה ל-'' כשאין code (מקביל ל-undefined→'' של JS). כלל 2/7.
//  • Error של JS ⇒ StateError של Dart (נושא `message` לצורך רתמת-הזהב).
//  • example 6: requireAuth זורק — נקרא כארגומנט בתוך ה-try, לכן נתפס וממופה (כמו JS).

typedef RequireAuth = dynamic Function();
typedef SendReset = Future<void> Function(dynamic auth, String email);
typedef HebrewAuthError = Object Function(Object? e);

String _codeOf(Object? e) {
  try {
    final dynamic c = (e as dynamic)?.code;
    return (c ?? '').toString();
  } catch (_) {
    return '';
  }
}

/// Send a password-reset email, mapping Firebase-Auth failures to Hebrew.
/// Verbatim behaviour of the JS source new/atoms/reset-password.mjs.
Future<void> resetPassword(
  String email,
  RequireAuth requireAuth,
  SendReset sendReset,
  HebrewAuthError hebrewAuthError,
) async {
  try {
    await sendReset(requireAuth(), email);
  } catch (e) {
    final code = _codeOf(e);
    if (code == 'auth/user-not-found') {
      throw StateError('לא נמצא משתמש עם האימייל הזה');
    }
    if (code == 'auth/invalid-email') {
      throw StateError('כתובת האימייל אינה תקינה');
    }
    throw hebrewAuthError(e);
  }
}
