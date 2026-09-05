// ⚛️ אטום-Dart (דרגת-חוזה) · taskIdentity — זהות-עובד/ת קנונית למשימות.
// מוצא: maor/src/lib/worktasks.ts:9-14 · המקור: new/atoms/task-identity.mjs —
//        `const e = (email ?? '').trim().toLowerCase(); return e || 'מקומי';`
// טוהר: פונקציות top-level עצמאיות, אפס import (רק dart-core). חוק-4 — זהה-ביט למקור-ה-JS.
//
// תפקיד: מנרמל כתובת-אימייל לזהות אחידה (גזום+אותיות-קטנות); ריק/חסר ⇒ 'מקומי'.
// קלט: email — מחרוזת או null. פלט: String תמיד.
//
// תיקון-ההסגר (חוק-13, FIXES.md): הטיוטה חסרה את מיפוי ה-Final_Sigma. אומת מול V8:
//   'ΟΔΟΣ'.toLowerCase() ⇒ 'οδος' (ς סופית U+03C2), 'Σ' מבודדת ⇒ σ. ‏_toLowerJs
//   הורחב ל-Σ הקשרי (prevWord && !nextWord ⇒ ς) לצד İ + שני טווחי-צ'רוקי.
// • חוק-16 (trim): ‏_trimJs גוזם את קבוצת-ES בלבד (U+0085/U+180E לא נגזמים).
// • חוק-13 (toLowerCase): İ U+0130 ⇒ 'i'+U+0307 · צ'רוקי U+13A0–U+13EF ⇒ +0x97D0 ·
//   צ'רוקי U+13F0–U+13F5 ⇒ +8 · Σ U+03A3 ⇒ ς/σ הקשרי. שאר התווים = Dart.toLowerCase.
// אין locale/תאריכים/מספרים/מוטביליות.

/// Canonical worker identity for tasks: trimmed, lower-cased email; empty/null
/// falls back to 'מקומי'. Bit-identical to the JS source `taskIdentity`.
String taskIdentity(dynamic email, Map<String, String> T) {
  final String e = _toLowerJs(_trimJs((email ?? '') as String));
  return e.isEmpty ? T['k1']! : e; // '' כוזב ב-JS ⇒ ברירת-המחדל
}

/// קבוצת-הרווחים של ES (WhiteSpace ∪ LineTerminator) — בלי U+0085 ובלי U+180E.
bool _isEsWhitespace(int c) =>
    c == 0x09 ||
    c == 0x0A ||
    c == 0x0B ||
    c == 0x0C ||
    c == 0x0D ||
    c == 0x20 ||
    c == 0xA0 ||
    c == 0x1680 ||
    (c >= 0x2000 && c <= 0x200A) ||
    c == 0x2028 ||
    c == 0x2029 ||
    c == 0x202F ||
    c == 0x205F ||
    c == 0x3000 ||
    c == 0xFEFF;

/// trim נאמן-ל-ES (חוק-16): גוזם רק את קבוצת-ES, לא את התוספות של Dart.
String _trimJs(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _isEsWhitespace(s.codeUnitAt(start))) {
    start++;
  }
  while (end > start && _isEsWhitespace(s.codeUnitAt(end - 1))) {
    end--;
  }
  return (start == 0 && end == s.length) ? s : s.substring(start, end);
}

/// עזר ל-Final_Sigma: האם התו הוא "אות" (Cased) לצורך גבול-מילה.
bool _isCased(int c) {
  final s = String.fromCharCode(c);
  return s.toLowerCase() != s.toUpperCase();
}

/// toLowerCase נאמן-ל-JS (חוק-13): Dart.toLowerCase + חריגים שנמדדו מול V8.
String _toLowerJs(String s) {
  final out = StringBuffer();
  final runes = s.runes.toList();
  for (var i = 0; i < runes.length; i++) {
    final c = runes[i];
    if (c == 0x0130) {
      out.writeCharCode(0x69); // İ ⇒ i
      out.writeCharCode(0x0307); // + combining dot above (מיפוי-מלא)
    } else if (c >= 0x13A0 && c <= 0x13EF) {
      out.writeCharCode(c + 0x97D0); // צ'רוקי גדולות ⇒ U+AB70–U+ABBF
    } else if (c >= 0x13F0 && c <= 0x13F5) {
      out.writeCharCode(c + 8); // צ'רוקי U+13F0–U+13F5 ⇒ U+13F8–U+13FD
    } else if (c == 0x03A3) {
      // Σ · Final_Sigma: ς אם אחריה אין תו-מילה (ותו-מילה לפניה); אחרת σ.
      final prevWord = i > 0 && _isCased(runes[i - 1]);
      final nextWord = i + 1 < runes.length && _isCased(runes[i + 1]);
      out.write(prevWord && !nextWord ? 'ς' : 'σ');
    } else {
      out.write(String.fromCharCode(c).toLowerCase());
    }
  }
  return out.toString();
}
