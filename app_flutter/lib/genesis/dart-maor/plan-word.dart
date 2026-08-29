// ⚛️ אטום-Dart (דרגת-חוזה) · planWord — שם מסלול-התמחור של חוג (יחיד).
// מוצא: maor/src/components/courses/lib.ts:184-194 · המקור: new/atoms/plan-word.mjs.
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: קסקדת שוויון-מחרוזות — 'punch'⇒כרטיסייה · 'half_year'⇒מנוי חצי-שנתי ·
//        'year'⇒מנוי שנתי · כל ערך אחר (כולל 'month')⇒מנוי חודשי (ברירת-מחדל).
// קלט: model (מחרוזת). פלט: מחרוזת-שם בעברית.
//
// הערות-המרה (מקור→Dart):
//  • שרשרת השלישיות של JS (=== על מחרוזות) → אותה שרשרת עם == של Dart.
//    == על String ב-Dart = שוויון-ערך, זהה ל-=== של JS על מחרוזות. אין locale/
//    פורמט/getMonth/truthiness/מודולו/מוטביליות — שוויון-מחרוזות טהור בלבד.
//  • ענף ברירת-המחדל של הקסקדה מכסה כל קלט שאינו אחד משלושת הידועים.

/// Course pricing-plan name (singular). Verbatim port of new/atoms/plan-word.mjs.
String planWord(String model, {required String Function(String) term}) => model == 'punch'
    ? term('krtysyyh')
    : model == 'half_year'
        ? term('mnvy-chtsyshnty')
        : model == 'year'
            ? term('mnvy-shnty')
            : term('mnvy-chvdshy');
