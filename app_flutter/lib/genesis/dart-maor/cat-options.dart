// ⚛️ אטום-Dart · CAT_OPTIONS — נורמל מ-const-דאטה לפונקציה (מנוע-טהור; העברית תחולץ למטרה).
// ignore_for_file: non_constant_identifier_names
// ⚛️ אטום-Dart (דרגת-חוזה) · CAT_OPTIONS — קטגוריות-חוגים לבורר.
// מוצא: maor/src/components/courses/lib.ts · המקור: new/atoms/cat-options.mjs.
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: תשע קטגוריות-החוגים הקבועות שמאכלסות את בורר-הקטגוריה, כלשונן ובסדרן.
// קלט:  אין. פלט: List<String> קבוע באורך 9, בסדר-המקור.
//
// הערות-המרה (מקור→Dart):
//  • המקור `export const CAT_OPTIONS = [...]` = מערך-קבוע — לכן `const List<String>`
//    (מוטביליות: המקור const/read-only ⇒ קבוע-קומפילציה בלתי-משתנה, לא `var`).
//  • אפס locale/פורמט/getMonth/truthiness/מודולו — רשימת-מחרוזות-מילולית טהורה.
//  • שמות-הקטגוריות הן code-points עבריים מילוליים, זהים-ביט למקור.

/// The nine fixed course-category options for the category picker, verbatim and
/// in source order. Verbatim port of new/atoms/cat-options.mjs (`CAT_OPTIONS`).
List<String> CAT_OPTIONS({required String Function(String) term}) => [
  term('mlakh'),
  term('amnvt'),
  term('hashrh'),
  term('spvrt'),
  term('mvzykh'),
  term('rvvchh'),
  term('typvch'),
  term('kvlynry'),
  term('khylh'),
];