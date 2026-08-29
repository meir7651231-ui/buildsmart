// ⚛️ אטום-Dart (דרגת-חוזה) · guideIntroLabel — קבוע: כותרת ראש-המדריך, נוסח-לגאסי.
// מוצא: המקור new/atoms/guide-intro-label.mjs (`GUIDE_INTRO_LABEL`) — חולץ כלשונו
//        מ-maor/src/lib/guide.ts:25 (legacy:2897). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
// טוהר: ערך top-level עצמאי, אפס import (רק dart:core). אין שכן, אין locale/פורמט.
//
// תפקיד: מחרוזת-כותרת "לפני הכל:" המוצגת בראש המדריך — נוסח-לגאסי מילה-במילה.
// קלט: אין (קבוע). פלט: String — 9 תווים, מסתיים בנקודתיים, פותח ב"לפני".
//
// הערות-המרה (מקור→Dart):
//  • `export const GUIDE_INTRO_LABEL = '…'` → `const String guideIntroLabel`.
//  • המחרוזת עברית ראשונית (codepoints U+05D0..; המילים ב-BMP) — מועתקת verbatim.
//    ‏String.length ב-Dart = code-units של UTF-16; העברית ב-BMP ⇒ 9, זהה ל-JS `.length`.
//  • מוטביליות: `const` (immutable) — אין var מוקצה-מחדש.

/// Guide header intro label — verbatim legacy wording "לפני הכל:".
/// Verbatim port of new/atoms/guide-intro-label.mjs (`GUIDE_INTRO_LABEL`).
const String guideIntroLabel = 'לפני הכל:';
