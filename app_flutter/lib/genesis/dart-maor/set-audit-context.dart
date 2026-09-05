// ⚛️ אטום-Dart (דרגת-חוזה) · setAuditContext — בניית הקשר-הלוג-המסונכרן
// מוצא: maor/src/lib/cloud.ts:138-143 (setAuditContext; חוק-4 — התנהגות זהה למקור-ה-JS).
//        המקור: new/atoms/set-audit-context.mjs —
//        `return { auditUid: uid, auditEmail: email.trim().toLowerCase(), auditReadable: canRead };`
// טוהר: פונקציות top-level עצמאיות, אפס import (רק שפה/סטנדרט); עוזרים מקומיים בקידומת _.
//
// תפקיד: הקשר auditlog/{uid} של המחובר — uid כמות-שהוא · מייל מנורמל (trim+lowercase,
//        כהשוואת-המיילים ב-Rules) · canRead (מנהל/מייל-על ⇒ true; עובד/ת ⇒ false).
//        במקור הושם לשלושה משתני-מודול — ההשמה היא חיווט-קופסה; האטום רק מחשב.
// קלט:  uid (String) · email (String) · canRead (bool) — dynamic כמו ה-JS.
// פלט:  Map חדש {auditUid, auditEmail, auditReadable} — הפניה טרייה בכל קריאה.
//
// תיקון-הסגר (אצווה #22, FIXES set-audit-context): ה-_jsLower הישן הכיר רק İ/Σ
// והחמיץ את מיפוי-הצ'רוקי של JS toLowerCase — "ᏣᎳᎩ" (U+13A0–U+13F5) ⇒ JS מקטין
// (+0x97D0 / +0x08) בעוד Dart משאיר כמות-שהוא. התיקון מיישר ל-js-compat jsLower
// המאומת: טווח-צ'רוקי-רבתי U+13A0–U+13EF ⇒ +0x97D0, ותוספת U+13F0–U+13F5 ⇒ +0x08.
//
// הערות-המרה (מקור→Dart), אומתו בהרצה-דיפרנציאלית Node מול Dart-VM:
// • trim: Dart trim() מקרצף גם U+0085 (NEL); JS TrimString לא. ⇒ _jsTrim עם
//   קבוצת-התווים המדויקת של ES (WhiteSpace + LineTerminator).
// • toLowerCase (מיפוי-מלא של JS מול הפשוט של Dart): İ ⇒ "i"+U+0307 · צ'רוקי ⇒
//   קטנות · Σ סופית (Final_Sigma) ⇒ ς; כל השאר ⇒ מיפוי-Dart הפשוט (זהה).
// • קלט לא-מחרוזת: JS זורק TypeError על email.trim ⇒ Dart זורק TypeError בהורדת-
//   הטיפוס — שקילות-זריקה.

/// JS-faithful trim: exactly the ES TrimString character set (WhiteSpace +
/// LineTerminator). Notably does NOT strip U+0085 (NEL), unlike Dart's trim().
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

String _jsTrim(String s) {
  var start = 0, end = s.length;
  while (start < end && _esWs.contains(s.codeUnitAt(start))) start++;
  while (end > start && _esWs.contains(s.codeUnitAt(end - 1))) end--;
  return s.substring(start, end);
}

/// עזר ל-Final_Sigma: האם התו הוא "אות" (Cased) לצורך גבול-מילה.
bool _isCased(int c) {
  final s = String.fromCharCode(c);
  return s.toLowerCase() != s.toUpperCase();
}

/// JS-faithful toLowerCase (full Unicode default case conversion):
/// U+0130 "İ" -> "i"+U+0307, Cherokee upper -> lower, and Final_Sigma Σ -> ς;
/// everything else delegates to Dart's simple mapping (identical to JS outside).
String _jsLower(String s) {
  final out = StringBuffer();
  final runes = s.runes.toList();
  for (var i = 0; i < runes.length; i++) {
    final c = runes[i];
    if (c == 0x0130) {
      out.writeCharCode(0x69); // i
      out.writeCharCode(0x0307); // combining dot above
    } else if (c >= 0x13A0 && c <= 0x13EF) {
      out.writeCharCode(c + 0x97D0); // Cherokee upper ⇒ lower (U+AB70–U+ABBF)
    } else if (c >= 0x13F0 && c <= 0x13F5) {
      out.writeCharCode(c + 0x08); // Cherokee supplement upper ⇒ lower (U+13F8–U+13FD)
    } else if (c == 0x03A3) {
      // Σ · Final_Sigma: קטנה-סופית ς אם אחריה אין תו-מילה (ותו-מילה לפניה)
      final prevWord = i > 0 && _isCased(runes[i - 1]);
      final nextWord = i + 1 < runes.length && _isCased(runes[i + 1]);
      out.write(prevWord && !nextWord ? 'ς' : 'σ');
    } else {
      out.write(String.fromCharCode(c).toLowerCase());
    }
  }
  return out.toString();
}

/// Builds the synced-audit-log context of the signed-in user. Verbatim
/// behaviour of the JS source new/atoms/set-audit-context.mjs:
/// uid passes through untouched, email is normalised (JS trim + JS
/// toLowerCase), canRead passes through. Returns a fresh Map every call —
/// no shared state (the module-variable assignment stayed in the box).
dynamic setAuditContext(dynamic uid, dynamic email, dynamic canRead) {
  return {
    'auditUid': uid,
    'auditEmail': _jsLower(_jsTrim(email as String)),
    'auditReadable': canRead,
  };
}
