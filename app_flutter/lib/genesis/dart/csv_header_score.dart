// ⚛️ אטום-Dart · csvHeaderScore
// מוצא: buildsmart/app_flutter/lib/data/csv_kernel.dart:54-68 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: `CsvRecord` (:23) הוטבע verbatim (line+cells); הקבוע `kCsvBom` (:13) והשקעים
//        `normHeader`/`csvIsBlank`/`csvIsComment`/`csvHeaderIndex` (:32-50) הוטבעו verbatim
//        ⇒ האטום עומד בפני-עצמו.

/// BOM שיש לנקות מכותרות.
const String kCsvBom = '﻿';

/// רשומת-CSV מפוענחת: [line] = מספר-השורה-הפיזית (1-based), [cells] = התאים הגולמיים.
class CsvRecord {
  const CsvRecord(this.line, this.cells);

  final int line;
  final List<String> cells;
}

/// נרמול תא-כותרת: BOM החוצה, trim, lowercase.
String normHeader(String s) => s.replaceAll(kCsvBom, '').trim().toLowerCase();

/// רשומה שכל-תאיה רווח ⇒ מדולגת.
bool csvIsBlank(List<String> cells) => cells.every((c) => c.trim().isEmpty);

/// רשומת-הערה ('#' כתו הראשון הלא-רווח) ⇒ מדולגת.
bool csvIsComment(List<String> cells) =>
    cells.isNotEmpty && cells.first.trimLeft().startsWith('#');

/// אינדקס רשומת-הכותרת — הראשונה שאינה ריקה ואינה '#'-הערה; ‏-1 אם אין.
int csvHeaderIndex(List<CsvRecord> records) {
  for (var i = 0; i < records.length; i++) {
    if (csvIsBlank(records[i].cells) || csvIsComment(records[i].cells)) continue;
    return i;
  }
  return -1;
}

/// How many header cells match a [knownHeaders] name under this tokenization —
/// the separator-detection score.
int csvHeaderScore(List<CsvRecord> records, Set<String> knownHeaders) {
  final idx = csvHeaderIndex(records);
  if (idx < 0) return 0;
  var score = 0;
  for (final c in records[idx].cells) {
    if (knownHeaders.contains(normHeader(c))) score++;
  }
  return score;
}
