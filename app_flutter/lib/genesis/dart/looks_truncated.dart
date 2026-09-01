// ⚛️ אטום-Dart (דרגת-חוזה) · looksTruncated
// תפקיד: בודק אם מחרוזת JSON-ית נראית-חתוכה — סורק runes ומחזיר true אם נותרנו בתוך-מחרוזת
//        או עומק-סוגריים {}/[]‏ > 0 בסוף (מודע-escaping בתוך מחרוזות).
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:334-357 (‏_looksTruncated; חוק-4).
// אחים: אין. private-במקור (`_looksTruncated`) קודם לפונקציה top-level ציבורית `looksTruncated`.
//       אפס-שקע: [candidate] פרמטר-נתון. (השקעים-המועמדים בטיוטה — elementIds/actionIdsFor —
//       שייכים ל-`expandScope` שאחריה, לא לאטום זה.)
// טוהר: dart:core בלבד; אפס import, אפס state, אפס טיפוס-שכן.

/// true אם [candidate] נראה-חתוך: בסוף-הסריקה נותרנו בתוך-מחרוזת פתוחה או עומק-סוגריים>0.
/// escaping (`\`) ו-מרכאות (`"`) נספרים רק מחוץ-למחרוזת; בתוך-מחרוזת `{`/`[`/`}`/`]` אינם משנים עומק.
/// verbatim edit_intent.dart:334-357.
bool looksTruncated(String candidate) {
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (final rune in candidate.runes) {
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (rune == 0x5C /* \ */) {
        escaped = true;
      } else if (rune == 0x22 /* " */) {
        inString = false;
      }
      continue;
    }
    if (rune == 0x22 /* " */) {
      inString = true;
    } else if (rune == 0x7B /* { */ || rune == 0x5B /* [ */) {
      depth++;
    } else if (rune == 0x7D /* } */ || rune == 0x5D /* ] */) {
      depth--;
    }
  }
  return inString || depth > 0;
}
