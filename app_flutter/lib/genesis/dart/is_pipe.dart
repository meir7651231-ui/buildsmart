// ⚛️ אטום-Dart (דרגת-חוזה) · isPipe
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:624-632
//        (‏pipeCats + _isPipe + isPipe; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//       ‏pipeCats = דאטה-קבוע פנימי של האטום (רשימת-קטגוריות, לא הקשר/זהות/סוד).
//       במקור isPipe עוטף את _isPipe הפרטי — האטום מאחד לפונקציה-אחת (זהה-התנהגות).
//
// אין שקע: האטום קורא אך ורק את `p.categoryHe` — מועבר ישירות כ-String.
//   (במקור `_isPipe(p) => pipeCats.contains(p.categoryHe)`, מקור:628).
//
// התנהגות (מקור:632): true כשהמוצר נמכר לפי-אורך (צינור), כך שה-BOM נושא מטרים
//   במקום מניית-יחידות.
//
// קלט:  categoryHe — קטגוריית-המוצר בעברית (‏p.categoryHe).
// פלט:  bool — האם המוצר הוא צינור (נמכר לפי-מטר).

/// Pipe categories — sold by length (verbatim: install_engine.dart:624-627).

/// Public: true when a product is sold by length (a pipe), so the BOM should
/// carry meters rather than a unit count.
bool isPipe(String categoryHe, {required Set pipeCats}) => pipeCats.contains(categoryHe);
