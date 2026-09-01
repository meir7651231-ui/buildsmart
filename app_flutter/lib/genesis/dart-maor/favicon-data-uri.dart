// ⚛️ אטום-Dart (דרגת-חוזה) · faviconDataUri — אימוג'י/טקסט ⇒ SVG data-URI ל-favicon
// מוצא: maor/src/lib/config.ts:890-898 · המקור: new/atoms/favicon-data-uri.mjs
//        (חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core).
//
// תפקיד: עוטף מחרוזת (אימוג'י/טקסט) בתוך <svg><text>…</text></svg> ומחזיר
//        data:image/svg+xml עם המטען מקודד-URI.
// קלט:  emoji — String (טקסט לשיבוץ ב-<text>).
// פלט:  String — "data:image/svg+xml," + הקידוד של ה-SVG.
//
// הערת-המרה (מקור→Dart): ה-JS משתמש ב-`encodeURIComponent`; המנוע-האוטומטי פלט
//   `encodeURIComponent(...)` — פונקציה שאינה קיימת ב-Dart. המקבילה המדויקת היא
//   `Uri.encodeComponent`, שקבוצת-התווים-הבלתי-שמורה שלה (A-Za-z0-9 -_.!~*'()) זהה
//   ל-encodeURIComponent, קידוד UTF-8, hex-רישיות-גדולות — ולכן ביט-זהה (מאומת
//   ברתמת-הזהב מול 12 הקלטות-Golden, כולל עברית %D7 ורווחים %20). אין
//   locale/getMonth/truthiness/תאריך-מגלגל מעורבים.

/// Emoji/text → SVG data-URI for a browser favicon. Verbatim behaviour of the JS
/// source new/atoms/favicon-data-uri.mjs (`encodeURIComponent` → `Uri.encodeComponent`).
String faviconDataUri(String emoji) {
  final svg =
      "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text x='50' y='52' font-size='72' text-anchor='middle' dominant-baseline='central'>" +
          emoji +
          '</text></svg>';
  return 'data:image/svg+xml,' + Uri.encodeComponent(svg);
}
