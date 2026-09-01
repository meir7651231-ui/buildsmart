// ⚛️ אטום-Dart (דרגת-חוזה) · sizeLabels — תוויות-עברית לגודלי-ארגון (תמחור).
// מוצא: maor/src/lib/pricing.ts:76-80 (הטווח ברישום 76-121 היה מזוהם-ריבוי-הצהרות —
//        חולץ נקי) · המקור: new/atoms/size-labels.mjs (`SIZE_LABELS`).
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מיפוי גודל-ארגון (small/medium/large) → תווית-עברית לתצוגת-התמחור.
// קלט:  אין. פלט: Map<String, String> עם בדיוק 3 מפתחות, בסדר-המקור —
//        {'small': 'קטן', 'medium': 'בינוני', 'large': 'גדול'}.
//
// הערות-המרה (מקור→Dart):
//  • `export const SIZE_LABELS = {...}` → getter top-level שמחזיר `const {...}`.
//    ליטרל-map של Dart שומר סדר-הכנסה (LinkedHashMap) — כמו סדר-מפתחות-אובייקט ב-JS.
//  • הערכים מועתקים verbatim: 'קטן'/'בינוני'/'גדול' (ערבות-חוזה 2).
//  • תאימות ל-sizeMult של default-prices נאכפת בבדיקת-קופסת-התמחור (חוק-2) —
//    לא כאן; האטום לא מייבא אטום-שכן.
//  • אין locale/פורמט/תאריך/truthiness/מודולו — נתון-קבוע בלבד.

/// Hebrew labels for organization sizes (pricing display).
/// Verbatim port of new/atoms/size-labels.mjs (`SIZE_LABELS`).
Map<String, String> get sizeLabels => const {
      'small': 'קטן',
      'medium': 'בינוני',
      'large': 'גדול',
    };
