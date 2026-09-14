// ⚛️ אטום-Dart (דרגת-חוזה) · parseCsvRecords
// מוצא: buildsmart/app_flutter/lib/data/csv_kernel.dart:69 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): CsvRecord.

/// One parsed CSV record: [line] is the 1-based PHYSICAL file line it starts on
/// (newlines inside quoted cells advance the count), [cells] the raw cells,
/// unquoted and unescaped.
class CsvRecord {
  const CsvRecord(this.line, this.cells);

  final int line;
  final List<String> cells;
}

/// The RFC-4180-ish tokenizer (zero deps, never throws): '"'-quoted cells with
/// '""' escapes may contain [sep] and newlines; CRLF and LF both end a record;
/// a '"' NOT at cell start is a literal (so an unquoted hand-typed מק"ט
/// survives); an unterminated quote just flushes what accumulated. Empty
/// physical lines produce NO record but still advance the line count.
List<CsvRecord> parseCsvRecords(String text, String sep) {
  final out = <CsvRecord>[];
  var cells = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  var atCellStart = true;
  var wroteAny = false;
  var line = 1;
  var recordLine = 1;

  void endCell() {
    cells.add(cell.toString());
    cell.clear();
    atCellStart = true;
  }

  void endRecord() {
    endCell();
    out.add(CsvRecord(recordLine, cells));
    cells = <String>[];
    wroteAny = false;
  }

  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"'); // the '""' escape
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        if (c == '\n') line++;
        if (c != '\r') cell.write(c);
      }
      continue;
    }
    if (c == '"' && atCellStart) {
      inQuotes = true;
      atCellStart = false;
      wroteAny = true;
    } else if (c == sep) {
      endCell();
      wroteAny = true;
    } else if (c == '\n') {
      line++;
      if (wroteAny) endRecord();
      recordLine = line;
    } else if (c != '\r') {
      cell.write(c);
      atCellStart = false;
      wroteAny = true;
    }
  }
  if (wroteAny) endRecord(); // a last record without a trailing newline
  return out;
}
