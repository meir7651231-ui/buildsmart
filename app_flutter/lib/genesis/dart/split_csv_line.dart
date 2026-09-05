// ⚛️ אטום-Dart (דרגת-חוזה) · splitCsvLine
// מוצא: buildsmart/app_flutter/lib/data/repositories/supplier_onboarding.dart:214-232 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: פירוק שורת-CSV לשדות (כיבוד-מרכאות).

/// Split ONE CSV line, honouring `"quoted, fields"` (a comma inside quotes is data).
List<String> splitCsvLine(String line) {
  final out = <String>[];
  final sb = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      inQuotes = !inQuotes;
    } else if (c == ',' && !inQuotes) {
      out.add(sb.toString());
      sb.clear();
    } else {
      sb.write(c);
    }
  }
  out.add(sb.toString());
  return out;
}
