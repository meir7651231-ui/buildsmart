// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · clean-profile COMPANY-CATALOG IMPORT — "קוד אחד → כל חברה יוצקת
// את הקטלוג שלה": the pure domain module behind the company import flow,
// template → dry-run → ATOMIC commit (the trade_import.dart s48 contract,
// cloned for the full [LipskeyCatalogProduct] column set).
//
// PURE Dart (dart:convert + the catalog model ONLY — no Flutter, no I/O, and
// deliberately NOT the bundled const catalog: a company's poured catalog
// never mixes with the built-in BuildSmart content at this layer):
//   · [companyCatalogTemplateCsv] — the downloadable, SELF-DOCUMENTING CSV
//     template: UTF-8 BOM first char (Excel opens the Hebrew columns right),
//     an RFC-4180-quoted header, then '#'-comment legend + example rows the
//     parser skips — the template explains itself, no manual needed;
//   · [parseCompanyCatalogCsv] — real RFC-4180-ish parsing (quoted fields,
//     "" escapes, newlines-in-quotes, CRLF, ','/';' auto-detect) with honest
//     per-row Hebrew errors; row numbers are PHYSICAL 1-based file lines
//     (the header is line 1, '#' rows count) so they match what Excel shows;
//   · [encodeCompanyCatalog] / [decodeCompanyCatalog] — the {"v":1,"items":…}
//     persistence codec (the toDoc/fromDoc key naming, nulls omitted); decode
//     is TOLERANT per stage-2 iron-rule-1 ("לא קורס לעולם"): null ONLY on
//     structural corruption, a garbled item is skipped, never a throw.
//
// [CompanyImportReport.canCommit] is the ONLY gate to a commit — zero errors
// AND ≥1 valid row → the caller persists report.valid as a whole; anything
// less commits NOTHING (the atomicity is the gate, not a transaction).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;

/// The UTF-8 BOM (U+FEFF), spelled ONCE — the invisible codepoint sits
/// between the quotes; do NOT "clean" it away. It is load-bearing: as the
/// template's FIRST char it makes Excel decode the Hebrew columns as UTF-8,
/// and the parser strips it back off uploaded files.
const String _kBom = '﻿';

/// U+FFFD REPLACEMENT CHARACTER — what `utf8.decode(…, allowMalformed: true)`
/// leaves behind when the bytes were not valid UTF-8. Its presence anywhere
/// fails the whole file honestly instead of importing mojibake names.
const String _kReplacementChar = '�';

/// The downloadable CSV template. The FIRST char is the UTF-8 BOM
/// (load-bearing: without it Excel mis-decodes the Hebrew columns); line 1 is
/// the canonical header (מק"ט is RFC-4180-quoted — the cell itself contains a
/// '"'); the rest are '#'-comment rows — the legend (חובה = מק"ט · שם המוצר ·
/// קטגוריה), the no-prices-yet note, and two realistic example rows — all
/// skipped by [parseCompanyCatalogCsv], so re-uploading the untouched template
/// parses to zero errors and zero rows ([CompanyImportReport.canCommit] stays
/// false — nothing is fabricated).
String companyCatalogTemplateCsv() {
  final header = [for (final col in _kCols) _csvCell(col.he)].join(',');
  return '$_kBom$header\n'
      '# חובה = מק"ט · שם המוצר · קטגוריה, השאר רשות\n'
      '# מחירים — יתווספו בשלב חיבור-השרת\n'
      '# ABC-100,ברז מטבח נשלף,ברזים,אלפא,כרום,1,48,,Kitchen Faucet,Faucets,🚰\n'
      '# ABC-205,סיפון לכיור מטבח,ניקוז,אלפא,לבן,6,144,קוטר 40 מ"מ,Kitchen Trap,Drainage,🚿';
}

/// One validation failure. [row] is the 1-based PHYSICAL line number in the
/// uploaded file (the header is line 1 and '#'/blank lines count, so the
/// number matches the row the user sees in Excel); 0 marks a FILE-level error
/// (encoding / size cap). [messageHe] is the full honest Hebrew sentence —
/// render it verbatim.
class CompanyImportRowError {
  const CompanyImportRowError(this.row, this.messageHe);

  final int row;
  final String messageHe;
}

/// The dry-run verdict: the rows that parsed clean (as ready-to-persist
/// [LipskeyCatalogProduct]s) and every error found. [canCommit] is the ATOMIC
/// gate — a commit happens only when the WHOLE file validates.
class CompanyImportReport {
  const CompanyImportReport({required this.valid, required this.errors});

  final List<LipskeyCatalogProduct> valid;
  final List<CompanyImportRowError> errors;

  /// True iff there is something to import AND nothing wrong — the ONLY
  /// state the UI offers the commit action in (the s48 atomic gate).
  bool get canCommit => errors.isEmpty && valid.isNotEmpty;
}

/// Parse + validate an uploaded/pasted company-catalog CSV. NEVER throws —
/// every failure is an honest [CompanyImportRowError].
///
/// The caller decodes file bytes with `utf8.decode(…, allowMalformed: true)`;
/// if U+FFFD replacement chars made it in, the whole file fails with the
/// single row-0 error 'הקובץ אינו בקידוד UTF-8 — שמור מחדש כ-CSV UTF-8'.
///
/// The separator (',' vs ';' — Hebrew Excel often saves ';') is auto-detected:
/// whichever tokenization makes the header line match more known columns
/// wins (tie → ','). Header cells accept the canonical Hebrew names AND the
/// English aliases (case-insensitive, trimmed): sku · name/name_he ·
/// category/category_he · brand · color · qty_pack · qty_pallet · dims ·
/// name_en · category_en · emoji. Unknown extra columns are ignored silently,
/// but each missing REQUIRED column (מק"ט · שם המוצר · קטגוריה) stops the
/// parse with its own 'חסרה עמודת חובה: <עמודה>' error at row 1.
///
/// Per data row (blank and '#' rows are skipped): required cells present,
/// else 'שורה N — חסר <עמודה>'; an in-file duplicate מק"ט →
/// 'שורה N — מק"ט כפול: <sku>'; a non-numeric כמות →
/// 'שורה N — <עמודה> חייב להיות מספר'; past 5,000 data rows the parse stops
/// with the single row-0 error 'הקובץ גדול מדי — עד 5,000 שורות בשלב זה'.
/// A row with ANY error contributes no product (the s48 contract).
CompanyImportReport parseCompanyCatalogCsv(String raw) {
  // A leading BOM (our own template ships one) is transport, not data.
  var text = raw;
  while (text.startsWith(_kBom)) {
    text = text.substring(1);
  }

  // Honest encoding check — U+FFFD means the bytes were NOT valid UTF-8 (the
  // caller decodes with allowMalformed: true); refuse the whole file rather
  // than import mojibake product names.
  if (text.contains(_kReplacementChar)) {
    return const CompanyImportReport(
      valid: [],
      errors: [
        CompanyImportRowError(
          0,
          'הקובץ אינו בקידוד UTF-8 — שמור מחדש כ-CSV UTF-8',
        ),
      ],
    );
  }

  // Separator auto-detect: Hebrew Excel often saves ';'-CSV — pick whichever
  // of ',' / ';' makes the header line match more known columns (tie → ',').
  final byComma = _parseRecords(text, ',');
  final bySemicolon = _parseRecords(text, ';');
  final records = _headerScore(bySemicolon) > _headerScore(byComma)
      ? bySemicolon
      : byComma;
  final headerIdx = _headerIndex(records);

  final errors = <CompanyImportRowError>[];

  // ── the header: canonical Hebrew titles / English aliases → column index.
  // First occurrence wins on a duplicated title; unknown columns are ignored
  // silently — only a MISSING required column is an error.
  final colIndex = <String, int>{};
  if (headerIdx >= 0) {
    final headerCells = records[headerIdx].cells;
    for (var i = 0; i < headerCells.length; i++) {
      final h = _normHeader(headerCells[i]);
      if (h.isEmpty) continue;
      for (final col in _kCols) {
        if (col.match.contains(h)) {
          colIndex.putIfAbsent(col.key, () => i);
          break;
        }
      }
    }
  }
  if (!colIndex.containsKey('sku')) {
    errors.add(const CompanyImportRowError(1, 'חסרה עמודת חובה: מק"ט'));
  }
  if (!colIndex.containsKey('name')) {
    errors.add(const CompanyImportRowError(1, 'חסרה עמודת חובה: שם המוצר'));
  }
  if (!colIndex.containsKey('category')) {
    errors.add(const CompanyImportRowError(1, 'חסרה עמודת חובה: קטגוריה'));
  }
  if (errors.isNotEmpty) {
    return CompanyImportReport(valid: const [], errors: errors);
  }

  final seenSkus = <String>{};
  final valid = <LipskeyCatalogProduct>[];
  var dataRows = 0;

  // Data rows. N in every message is the record's PHYSICAL 1-based file line
  // — '#' comments, blank lines and in-quote newlines all advance it, so it
  // matches the row the user sees in Excel.
  for (var r = headerIdx + 1; r < records.length; r++) {
    final rec = records[r];
    if (_isBlank(rec.cells) || _isComment(rec.cells)) continue;

    dataRows++;
    if (dataRows > 5000) {
      errors.add(
        const CompanyImportRowError(
          0,
          'הקובץ גדול מדי — עד 5,000 שורות בשלב זה',
        ),
      );
      break;
    }

    final n = rec.line;
    final cells = rec.cells;
    // A short row reads missing cells as empty (never a range error).
    String cell(String key) {
      final i = colIndex[key];
      return i == null || i >= cells.length ? '' : cells[i].trim();
    }

    final sku = cell('sku');
    final name = cell('name');
    final category = cell('category');
    final rowErrors = <CompanyImportRowError>[];

    // (1) the three required cells.
    if (sku.isEmpty) {
      rowErrors.add(CompanyImportRowError(n, 'שורה $n — חסר מק"ט'));
    }
    if (name.isEmpty) {
      rowErrors.add(CompanyImportRowError(n, 'שורה $n — חסר שם המוצר'));
    }
    if (category.isEmpty) {
      rowErrors.add(CompanyImportRowError(n, 'שורה $n — חסר קטגוריה'));
    }

    // (2) duplicate sku — earlier in THIS file (add() is false on a repeat).
    if (sku.isNotEmpty && !seenSkus.add(sku)) {
      rowErrors.add(CompanyImportRowError(n, 'שורה $n — מק"ט כפול: $sku'));
    }

    // (3) the two quantity columns must be numbers when present.
    int? qtyPack;
    final qtyPackCell = cell('qtyPack');
    if (qtyPackCell.isNotEmpty) {
      qtyPack = int.tryParse(qtyPackCell);
      if (qtyPack == null) {
        rowErrors.add(
          CompanyImportRowError(n, 'שורה $n — כמות באריזה חייב להיות מספר'),
        );
      }
    }
    int? qtyPallet;
    final qtyPalletCell = cell('qtyPallet');
    if (qtyPalletCell.isNotEmpty) {
      qtyPallet = int.tryParse(qtyPalletCell);
      if (qtyPallet == null) {
        rowErrors.add(
          CompanyImportRowError(n, 'שורה $n — כמות במשטח חייב להיות מספר'),
        );
      }
    }

    if (rowErrors.isNotEmpty) {
      errors.addAll(rowErrors);
      continue; // a row with ANY error contributes no product
    }

    final colorCell = cell('color');
    final dimsCell = cell('dims');
    final emojiCell = cell('emoji');
    valid.add(
      LipskeyCatalogProduct(
        sku: sku,
        nameHe: name,
        nameEn: cell('nameEn'),
        color: colorCell.isEmpty ? null : colorCell,
        qtyPack: qtyPack,
        qtyPallet: qtyPallet,
        categoryHe: category,
        categoryEn: cell('categoryEn'),
        categoryEmoji: emojiCell.isEmpty ? '📦' : emojiCell,
        page: 0, // not a catalog-book product — no page to point at
        // The free-text מידות cell lands under its own Hebrew key — the
        // product sheet renders dims entries as 'key: value' rows verbatim.
        dims: dimsCell.isEmpty ? null : <String, dynamic>{'מידות': dimsCell},
        // The cell verbatim, or EXPLICITLY '' when absent — a company product
        // must NEVER silently become 'ליפסקי'-branded (the ctor default is
        // BuildSmart catalog content, not company content).
        brand: cell('brand'),
      ),
    );
  }

  return CompanyImportReport(valid: valid, errors: errors);
}

/// Persistence codec — encode. Compact `{"v":1,"items":[…]}` JSON; per-item
/// keys mirror the repo's toDoc/fromDoc naming so the server codec and this
/// local one stay one vocabulary, and nulls are OMITTED (the sparse-product
/// round-trip idiom). The image fields are deliberately absent — a v1 company
/// import carries no images.
String encodeCompanyCatalog(List<LipskeyCatalogProduct> items) =>
    jsonEncode(<String, dynamic>{
      'v': 1,
      'items': <Map<String, dynamic>>[
        for (final p in items)
          <String, dynamic>{
            'sku': p.sku,
            'nameHe': p.nameHe,
            'nameEn': p.nameEn,
            'categoryHe': p.categoryHe,
            'categoryEn': p.categoryEn,
            'categoryEmoji': p.categoryEmoji,
            'page': p.page,
            'brand': p.brand,
            if (p.color != null) 'color': p.color,
            if (p.qtyPack != null) 'qtyPack': p.qtyPack,
            if (p.qtyPallet != null) 'qtyPallet': p.qtyPallet,
            if (p.dims != null) 'dims': p.dims,
          },
      ],
    });

/// Persistence codec — decode. TOLERANT (stage-2 iron-rule-1, "לא קורס
/// לעולם"): returns null ONLY on STRUCTURAL corruption — not JSON at all, not
/// a `{"v":1,"items":[…]}` map, wrong version, items not a list. A garbled
/// ITEM (missing/empty sku or nameHe, wrong-typed fields) is SKIPPED — one
/// bad item never tears the whole catalog — and this NEVER throws. An
/// intact-but-empty items list decodes to an empty list.
List<LipskeyCatalogProduct>? decodeCompanyCatalog(String raw) {
  final Object? root;
  try {
    root = jsonDecode(raw);
  } on Object {
    return null; // not JSON at all — structural corruption
  }
  if (root is! Map) return null;
  final version = root['v'];
  if (version is! num || version != 1) return null;
  final items = root['items'];
  if (items is! List) return null;

  final out = <LipskeyCatalogProduct>[];
  for (final item in items) {
    if (item is! Map) continue; // per-item garbage — skip, never throw
    try {
      final sku = item['sku'];
      final nameHe = item['nameHe'];
      // Missing/empty sku or nameHe ⇒ the item is unusable — skip it.
      if (sku is! String || sku.isEmpty) continue;
      if (nameHe is! String || nameHe.isEmpty) continue;
      out.add(
        LipskeyCatalogProduct(
          sku: sku,
          nameHe: nameHe,
          nameEn: (item['nameEn'] as String?) ?? '',
          color: item['color'] as String?,
          qtyPack: (item['qtyPack'] as num?)?.toInt(),
          qtyPallet: (item['qtyPallet'] as num?)?.toInt(),
          categoryHe: (item['categoryHe'] as String?) ?? '',
          categoryEn: (item['categoryEn'] as String?) ?? '',
          categoryEmoji: (item['categoryEmoji'] as String?) ?? '📦',
          page: (item['page'] as num?)?.toInt() ?? 0,
          dims: (item['dims'] as Map?)?.cast<String, dynamic>(),
          // '' (not the ctor's 'ליפסקי' default) — the same company-brand
          // rule as the parser: absent stays absent.
          brand: (item['brand'] as String?) ?? '',
        ),
      );
    } on Object {
      continue; // a type-garbled item is per-item corruption — skip it
    }
  }
  return out;
}

// ── internals ────────────────────────────────────────────────────────────────

/// One template/header column: [key] the internal lookup key, [he] the
/// canonical Hebrew header (the template cell + the error-string vocabulary),
/// [match] every accepted normalized header form — the canonical Hebrew plus
/// the English aliases (stored lowercase; matching is trimmed + lowercased).
class _Col {
  const _Col(this.key, this.he, this.match);

  final String key;
  final String he;
  final Set<String> match;
}

/// The canonical column set, in template order. The first three (מק"ט ·
/// שם המוצר · קטגוריה) are REQUIRED; the rest are optional.
const List<_Col> _kCols = [
  _Col('sku', 'מק"ט', {'מק"ט', 'sku'}),
  _Col('name', 'שם המוצר', {'שם המוצר', 'name', 'name_he'}),
  _Col('category', 'קטגוריה', {'קטגוריה', 'category', 'category_he'}),
  _Col('brand', 'מותג', {'מותג', 'brand'}),
  _Col('color', 'צבע', {'צבע', 'color'}),
  _Col('qtyPack', 'כמות באריזה', {'כמות באריזה', 'qty_pack'}),
  _Col('qtyPallet', 'כמות במשטח', {'כמות במשטח', 'qty_pallet'}),
  _Col('dims', 'מידות', {'מידות', 'dims'}),
  _Col('nameEn', 'שם באנגלית', {'שם באנגלית', 'name_en'}),
  _Col('categoryEn', 'קטגוריה באנגלית', {'קטגוריה באנגלית', 'category_en'}),
  _Col('emoji', "אימוג'י", {"אימוג'י", 'emoji'}),
];

/// RFC-4180 cell quoting for the TEMPLATE side: a cell containing a quote /
/// separator / newline is wrapped in '"' with inner quotes doubled — this is
/// what puts מק"ט on the wire as "מק""ט".
String _csvCell(String s) {
  final needsQuoting = s.contains('"') ||
      s.contains(',') ||
      s.contains(';') ||
      s.contains('\n');
  if (!needsQuoting) return s;
  return '"${s.replaceAll('"', '""')}"';
}

/// Header-cell normalization: stray BOMs out, trimmed, lowercased (the
/// English aliases are case-insensitive; Hebrew is untouched by lowercase).
String _normHeader(String s) => s.replaceAll(_kBom, '').trim().toLowerCase();

/// A record whose every cell is whitespace — skipped silently.
bool _isBlank(List<String> cells) => cells.every((c) => c.trim().isEmpty);

/// A '#'-comment record (first non-space char is '#') — the template's
/// legend / example rows; skipped silently.
bool _isComment(List<String> cells) =>
    cells.isNotEmpty && cells.first.trimLeft().startsWith('#');

/// Index of the header record — the first that is neither blank nor a
/// '#'-comment; -1 when the file has none (headers then read as missing).
int _headerIndex(List<_CsvRecord> records) {
  for (var i = 0; i < records.length; i++) {
    if (_isBlank(records[i].cells) || _isComment(records[i].cells)) continue;
    return i;
  }
  return -1;
}

/// How many header cells match a known column under this tokenization — the
/// separator-detection score ([parseCompanyCatalogCsv] picks the winner).
int _headerScore(List<_CsvRecord> records) {
  final idx = _headerIndex(records);
  if (idx < 0) return 0;
  var score = 0;
  for (final c in records[idx].cells) {
    final h = _normHeader(c);
    for (final col in _kCols) {
      if (col.match.contains(h)) {
        score++;
        break;
      }
    }
  }
  return score;
}

/// One parsed CSV record: [line] is the 1-based PHYSICAL file line it starts
/// on (newlines inside quoted cells advance the count), [cells] the raw
/// cells, unquoted and unescaped.
class _CsvRecord {
  const _CsvRecord(this.line, this.cells);

  final int line;
  final List<String> cells;
}

/// The RFC-4180-ish tokenizer (zero deps, never throws): '"'-quoted cells
/// with '""' escapes may contain [sep] and newlines; CRLF and LF both end a
/// record; a '"' NOT at cell start is a literal (so an unquoted hand-typed
/// מק"ט survives); an unterminated quote just flushes what accumulated.
/// Empty physical lines produce NO record but still advance the line count.
List<_CsvRecord> _parseRecords(String text, String sep) {
  final out = <_CsvRecord>[];
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
    out.add(_CsvRecord(recordLine, cells));
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
