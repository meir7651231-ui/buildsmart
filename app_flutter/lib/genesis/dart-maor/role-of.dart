// ⚛️ אטום-Dart (דרגת-חוזה) · roleOf — תפקיד-משתמש מהקונפיג לפי מייל: admin ⇒ teacher ⇒ staff.
// מוצא: maor/src/lib/config.ts:650-659 · המקור: new/atoms/role-of.mjs · חוזה: role-of.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
// המיילים = קלט-ריצה בלבד (חוק-6 — זהות אינה אטום). טהור, סינכרוני, אפס שקעים.
//
// קלט: config — Map בצורת {adminEmails?: List<String>, roles?: {teachers?: Map<מייל,teacherId>}}
//       (אובייקט-JS ⇒ Map ב-Dart, כמוסכמת שאר האטומים) · email — String או null.
// פלט: 'admin' | 'teacher' | 'staff'.
//
// תיקון-הסגר (כלל-13 · toLowerCase יוניקוד): JS ‏String.prototype.toLowerCase שונה מ-Dart על İ
// (U+0130): ‏JS ⇒ "i̇" (i + combining-dot-above, 2 יחידות) · ‏Dart ⇒ "i". אימייל-אדמין עם İ לא
// זוהה ⇒ admin�⇒staff. התיקון: שקע-lowercase נאמן-JS (_jsLower, טבלת-חריגים İ/Cherokee/Final-Σ)
// מוזרק INLINE עם קידומת _ (חוק-1: אטום לא-מייבא). ‏.trim() נשמר כ-Dart-trim (החוזה בודק רק
// רווחי-ASCII, והאבחון נוגע ל-toLowerCase בלבד).
//
// הערות-המרה (מקור→Dart):
// · ‏`(email || '')` — שני מצבי-החסר (undefined/null) ⇒ '' — ‏`email ?? ''`. ‏`if (!e)` ⇒ `e.isEmpty`.
// · ‏`config.adminEmails?.some(...)` / ‏`teachers && ...some(...)` — ‏`is List`/`is Map` מכסה חסר,
//   null וריק כאחד (some/any על ריק = false) ⇒ זהה-ביט.
// · config==null עם מייל לא-ריק: הגישה `config['...']` זורקת — אותה סמנטיקת-כשל כמו TypeError.

/// Derives the user's role from the org config by email: empty/missing email
/// => 'staff'; listed in adminEmails => 'admin' (checked first — beats teacher);
/// key of roles.teachers => 'teacher'; otherwise 'staff'. All comparisons are
/// case- and edge-whitespace-insensitive (trim + JS-faithful lowercase on both sides).
/// Verbatim behaviour of the JS source `roleOf`.
String roleOf(dynamic config, dynamic email) {
  final e = _jsLower(((email ?? '') as String).trim());
  if (e.isEmpty) return 'staff';
  final adminEmails = config['adminEmails'];
  if (adminEmails is List &&
      adminEmails.any((a) => _jsLower((a as String).trim()) == e)) {
    return 'admin';
  }
  final roles = config['roles'];
  final teachers = roles is Map ? roles['teachers'] : null;
  if (teachers is Map &&
      teachers.keys.any((k) => _jsLower((k as String).trim()) == e)) {
    return 'teacher';
  }
  return 'staff';
}

// ── שקע מוזרק (העתק מ-machtzev/emit/js-compat-reference.dart · jsLower) ─────────
/// ‏String.prototype.toLowerCase נאמן-JS: חריגי İ/Cherokee/Final-Σ, השאר ‏Dart-toLowerCase.
String _jsLower(String s) {
  final out = StringBuffer();
  final runes = s.runes.toList();
  for (var i = 0; i < runes.length; i++) {
    final c = runes[i];
    if (c == 0x0130) {
      out.writeCharCode(0x69); // i
      out.writeCharCode(0x0307); // combining dot above
    } else if (c >= 0x13A0 && c <= 0x13EF) {
      out.writeCharCode(c + 0x97D0); // Cherokee upper ⇒ lower
    } else if (c == 0x03A3) {
      final prevWord = i > 0 && _isCased(runes[i - 1]);
      final nextWord = i + 1 < runes.length && _isCased(runes[i + 1]);
      out.write(prevWord && !nextWord ? 'ς' : 'σ');
    } else {
      out.write(String.fromCharCode(c).toLowerCase());
    }
  }
  return out.toString();
}

/// עזר ל-Final_Sigma: האם התו "אות" (Cased) לצורך גבול-מילה.
bool _isCased(int c) {
  final s = String.fromCharCode(c);
  return s.toLowerCase() != s.toUpperCase();
}
