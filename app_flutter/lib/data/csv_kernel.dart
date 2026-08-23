// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · shared CSV kernel — the PURE RFC-4180-ish tokenizer + header
// helpers, EXTRACTED verbatim from company_catalog_import so every importer
// (catalog, customers, …) tokenizes identically instead of re-implementing it.
// Zero deps (no Flutter, no I/O), never throws. The company parser's pinned
// suite (test/company_catalog_import_test.dart) proves this extraction is
// byte-identical to the inlined original.
// ─────────────────────────────────────────────────────────────────────────────

/// The UTF-8 BOM (U+FEFF). Load-bearing: as a template's FIRST char it makes
/// Excel decode Hebrew columns as UTF-8, and the parser strips it back off
/// uploaded files. Do NOT "clean" it away.
const String kCsvBom = '﻿';

/// U+FFFD REPLACEMENT CHARACTER — what `utf8.decode(…, allowMalformed: true)`
/// leaves behind when the bytes were not valid UTF-8. Its presence anywhere
/// lets a caller fail the whole file honestly instead of importing mojibake.
const String kCsvReplacementChar = '�';

/// One parsed CSV record: [line] is the 1-based PHYSICAL file line it starts on
/// (newlines inside quoted cells advance the count), [cells] the raw cells,
/// unquoted and unescaped.
class CsvRecord {
  const CsvRecord(this.line, this.cells);

  final int line;
  final List<String> cells;
}

/// Header-cell normalization: stray BOMs out, trimmed, lowercased (English
/// aliases are case-insensitive; Hebrew is untouched by lowercase).
String normHeader(String s) => s.replaceAll(kCsvBom, '').trim().toLowerCase();

/// A record whose every cell is whitespace — importers skip it silently.
bool csvIsBlank(List<String> cells) => cells.every((c) => c.trim().isEmpty);

/// A '#'-comment record (first non-space char is '#') — a template's legend /
/// example rows; importers skip it silently.
bool csvIsComment(List<String> cells) =>
    cells.isNotEmpty && cells.first.trimLeft().startsWith('#');

/// Index of the header record — the first that is neither blank nor a
/// '#'-comment; -1 when the file has none (headers then read as missing).
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

/// Separator auto-detect: parse with ',' and ';', keep whichever tokenization
/// makes the header line match more [knownHeaders] (tie → ','). The shared
/// entry every importer uses instead of hand-rolling the ','/';'​ choice.
List<CsvRecord> tokenizeCsvAutodetect(String text, Set<String> knownHeaders) {
  final byComma = parseCsvRecords(text, ',');
  final bySemicolon = parseCsvRecords(text, ';');
  return csvHeaderScore(bySemicolon, knownHeaders) >
          csvHeaderScore(byComma, knownHeaders)
      ? bySemicolon
      : byComma;
}
