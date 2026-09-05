// ⚛️ אטום-Dart (דרגת-חוזה) · setEmployeeOverride — קביעת כרטיס-עובד: דריסות המייל המנורמל במפת memberConfigs.
// מוצא: maor/src/components/platform/lib.ts:256-265 · המקור: new/atoms/set-employee-override.mjs —
//   export function setEmployeeOverride(org, email, override, normEmail) {
//     const e = normEmail(email);
//     return { memberConfigs: { ...org.memberConfigs, [e]: override } };
//   }
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקע (חוק-1): normEmail — נירמול-מייל של השכן, מוזרק כפרמטר (כתקדים approve-member).
// קלט: org (מפה עם memberConfigs?) · email · override (כרטיס-עובד; {} ריק = "רואה כמו הארגון") · normEmail.
// פלט: {'memberConfigs': Map} — מפה חדשה בהפניה; הכרטיס החדש מחליף את הקודם במלואו (לא מיזוג).
//
// 🔧 תיקון-הסגר (FIXES §set-employee-override · כלל-14 + עידונו): סדר-מפתחות-JS.
//   ב-JS מפתחות דמויי-אינדקס-מערך ("0".."4294967294") ממוינים מספרית-קודם, ואז שאר-המפתחות
//   בסדר-הכנסה. Dart משמר סדר-הכנסה בלבד ⇒ JSON שונה כשיש מפתחות-שלמים. בדומיין-האמיתי
//   (מיילים עם @) לא מתממש — אך חוק-4 (זהות-ביט) מחייב. הפורט-השבור פרס בסדר-הכנסה גולמי.
//   התיקון: _jsOrder ממיין מפתחות-אינדקס-קנוניים קודם (עולה), אחריהם שאר-המפתחות בסדר-הכנסה.
//   _isJsArrayIndex: מחרוזת-שלם קנונית (בלי אפס-מוביל, בלי סימן) בטווח [0, 2^32−2=4294967294].

/// Sets an employee override card: writes [override] under the normalized
/// email in a fresh `memberConfigs` map, in JS object-property order.
/// Verbatim behaviour of the JS source — full replacement, no merge; org
/// is not mutated.
Map<String, dynamic> setEmployeeOverride(
  Map org,
  String email,
  dynamic override,
  String Function(String) normEmail,
) {
  final e = normEmail(email);
  final existing = (org['memberConfigs'] as Map?) ?? const {};
  final combined = <dynamic, dynamic>{...existing, e: override};
  return {'memberConfigs': _jsOrder(combined)};
}

// ── שקע-INLINE (חוק-1): סדר-מפתחות-אובייקט של JS ──────────────────────────────
// integer-index keys עולה, אחריהם שאר-המפתחות בסדר-הכנסה.
Map<dynamic, dynamic> _jsOrder(Map m) {
  final intKeys = <String>[];
  final rest = <dynamic>[];
  for (final k in m.keys) {
    if (k is String && _isJsArrayIndex(k)) {
      intKeys.add(k);
    } else {
      rest.add(k);
    }
  }
  intKeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  final out = <dynamic, dynamic>{};
  for (final k in intKeys) {
    out[k] = m[k];
  }
  for (final k in rest) {
    out[k] = m[k];
  }
  return out;
}

/// True אם [k] הוא מפתח דמוי-אינדקס-מערך של JS: מחרוזת-שלם קנונית
/// (בלי אפס-מוביל, בלי סימן, בלי שבר) בטווח [0, 4294967294].
bool _isJsArrayIndex(String k) {
  if (k.isEmpty) return false;
  if (k == '0') return true;
  final first = k.codeUnitAt(0);
  if (first < 0x31 || first > 0x39) return false; // חייב להתחיל 1–9 (אין אפס-מוביל)
  for (var i = 1; i < k.length; i++) {
    final c = k.codeUnitAt(i);
    if (c < 0x30 || c > 0x39) return false;
  }
  final n = int.tryParse(k);
  return n != null && n <= 4294967294; // 2^32 − 2
}
