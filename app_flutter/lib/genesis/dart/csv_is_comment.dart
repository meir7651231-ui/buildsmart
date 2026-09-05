// ⚛️ אטום-Dart (דרגת-חוזה) · csvIsComment
// מוצא: buildsmart/app_flutter/lib/data/csv_kernel.dart:39-43
//        (חוק-4 — התנהגות זהה).
// טוהר: פונקציית top-level ציבורית עצמאית, אפס import (רק dart:core).
//
// קלט:  cells — רשומת-CSV (תאים).
// פלט:  true אם התו-הראשון-שאינו-רווח של התא-הראשון הוא '#' (רשומת-הערה/דוגמה).

/// רשומת-הערת-'#' (התו הראשון שאינו רווח בתא הראשון הוא '#') — יבואנים מדלגים עליה.
bool csvIsComment(List<String> cells) =>
    cells.isNotEmpty && cells.first.trimLeft().startsWith('#');
