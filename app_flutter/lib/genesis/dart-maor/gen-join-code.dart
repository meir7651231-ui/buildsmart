// ⚛️ אטום-Dart (דרגת-חוזה) · genJoinCode — קוד-הזמנה דטרמיניסטי (FNV-1a → base36)
// מוצא: maor/src/components/platform/lib.ts:83-98 · המקור: new/atoms/gen-join-code.mjs
//        (חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת). חוזה: new/atoms/gen-join-code.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: hash דטרמיניסטי (FNV-1a 32-ביט) של seed ⇒ 8 תווי base36 — קוד-הצטרפות לעובד/ת.
// קלט:  seed — String (נזרע דרך charCodeAt/codeUnitAt = יחידת-UTF-16).
// פלט:  String בן 8 תווים מ-'0-9a-z'.
//
// הערות-המרה (מקור→Dart · לפי machtzev/emit/DART-PORTING-RULES.md):
//  • Math.imul — כפל 32-ביט. JS מריץ את כל פעולות-הביט על int32; רק 32 הביטים הנמוכים
//    זורמים דרך XOR ו-imul, לכן שומרים את h כ-uint32 ממוסך (& 0xFFFFFFFF) — זהה-ביט
//    לחלוטין ל-int32-החתום של JS (אותם 32 ביטים, פרשנות-סימן בלבד משתנה). ‏codeUnitAt
//    ≤ 65535 < 2^32, ‏16777619 < 2^24 ⇒ המכפלה < 2^56, אין גלישת-int64 של Dart-VM.
//  • x = h >>> 0 — המרה ל-uint32; ב-h הממוסך x שווה ל-h עצמו.
//  • Math.floor(x/36) || fallback — truthiness של JS: 0 בלבד falsy ⇒ תנאי-מפורש `!= 0`.
//    x איננו ממוסך-חזרה ל-32-ביט (זהה למקור); ה-fallback (h + i + 1) עלול לחרוג מ-2^32
//    — נשמר כ-int רגיל בדיוק כמו double של JS.
//  • toString(36) — Dart toRadixString(36) פולט '0-9a-z' באותיות-קטנות, זהה ל-JS.

/// Deterministic FNV-1a → base36 join code (8 chars). Verbatim behaviour of the
/// JS source new/atoms/gen-join-code.mjs.
String genJoinCode(String seed) {
  int h = 2166136261;
  for (int i = 0; i < seed.length; i++) {
    h = (h ^ seed.codeUnitAt(i)) & 0xFFFFFFFF;
    h = (h * 16777619) & 0xFFFFFFFF;
  }
  final out = StringBuffer();
  int x = h; // x = h >>> 0 — h is already an unsigned 32-bit value.
  for (int i = 0; i < 8; i++) {
    out.write((x % 36).toRadixString(36));
    final t = x ~/ 36;
    x = t != 0 ? t : (h + i + 1);
  }
  return out.toString();
}
