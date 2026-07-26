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

import 'package:buildsmart/data/csv_kernel.dart';
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;

/// The downloadable CSV template. The FIRST char is the UTF-8 BOM
/// (load-bearing: without it Excel mis-decodes the Hebrew columns); line 1 is
/// the canonical header (מק"ט is RFC-4180-quoted — the cell itself contains a
/// '"'); the rest are '#'-comment rows — the legend (חובה = מק"ט · שם המוצר ·
/// קטגוריה), the no-prices-yet note, the image-link note, the open-spec-column
/// note, and two realistic example rows — all skipped by
/// [parseCompanyCatalogCsv], so re-uploading the untouched template parses to
/// zero errors and zero rows ([CompanyImportReport.canCommit] stays false —
/// nothing is fabricated).
String companyCatalogTemplateCsv() {
  final header = [for (final col in _kCols) _csvCell(col.he)].join(',');
  return '$kCsvBom$header\n'
      '# חובה = מק"ט · שם המוצר · קטגוריה, השאר רשות\n'
      '# מחירים — יתווספו בשלב חיבור-השרת\n'
      '# תמונה/תמונות — קישור מלא (https://…) או שם קובץ\n'
      '# כל עמודה נוספת שתוסיפו תופיע ככרטיס-מפרט: חומר, תקן, קצה 1, קצה 2, מחלקה, ברקוד…\n'
      '# ABC-100,ברז מטבח נשלף,ברזים,אלפא,כרום,1,48,,Kitchen Faucet,Faucets,🚰,https://example.co.il/p/abc.jpg,https://example.co.il/p/abc-2.jpg|https://example.co.il/p/abc-3.jpg,,\n'
      '# ABC-205,סיפון לכיור מטבח,ניקוז,אלפא,לבן,6,144,קוטר 40 מ"מ,Kitchen Trap,Drainage,🚿,ABC-205.jpg,,https://example.co.il/p/abc-205-spec.jpg,';
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
/// name_en · category_en · emoji · image · images · spec_image · spec_images.
/// The four image cells take a full http(s) URL or a bare filename, stored
/// AS-IS (the image-resolution chain handles both); the plural cells are
/// '|'-separated lists (parts trimmed, empties dropped). Every UNRECOGNIZED
/// non-empty header is an OPEN SPEC COLUMN: its non-empty cells land in the
/// product's dims as 'title → cell' (file order, after מידות, the title
/// verbatim) — a company adds חומר / תקן / DN / ברקוד… columns and they show
/// on the product sheet with zero code. Each missing REQUIRED column
/// (מק"ט · שם המוצר · קטגוריה) still stops the parse with its own
/// 'חסרה עמודת חובה: <עמודה>' error at row 1.
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
  while (text.startsWith(kCsvBom)) {
    text = text.substring(1);
  }

  // Honest encoding check — U+FFFD means the bytes were NOT valid UTF-8 (the
  // caller decodes with allowMalformed: true); refuse the whole file rather
  // than import mojibake product names.
  if (text.contains(kCsvReplacementChar)) {
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
  final records = tokenizeCsvAutodetect(text, _kKnownHeaders);
  final headerIdx = csvHeaderIndex(records);

  final errors = <CompanyImportRowError>[];

  // ── the header: canonical Hebrew titles / English aliases → column index.
  // First occurrence wins on a duplicated title; every UNRECOGNIZED non-empty
  // header is an OPEN SPEC COLUMN (index → title, insertion order = file
  // order) whose cells land in dims — only a MISSING required column is an
  // error.
  final colIndex = <String, int>{};
  final openCols = <int, String>{};
  if (headerIdx >= 0) {
    final headerCells = records[headerIdx].cells;
    for (var i = 0; i < headerCells.length; i++) {
      final h = normHeader(headerCells[i]);
      if (h.isEmpty) continue;
      var known = false;
      for (final col in _kCols) {
        if (col.match.contains(h)) {
          colIndex.putIfAbsent(col.key, () => i);
          known = true;
          break;
        }
      }
      if (!known) {
        // The title as the company typed it (BOM-stripped + trimmed, NOT
        // lowercased — 'DN' stays 'DN'): it becomes the dims key the product
        // sheet renders verbatim.
        openCols[i] = headerCells[i].replaceAll(kCsvBom, '').trim();
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
    if (csvIsBlank(rec.cells) || csvIsComment(rec.cells)) continue;

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
    // Image cells — a full http(s) URL or a bare filename, stored AS-IS (the
    // image-resolution chain handles both); the plural cells are '|'-lists.
    final imageCell = cell('imageFile');
    final specImageCell = cell('specImageFile');
    final imageFiles = _splitImageCell(cell('imageFiles'));
    final specImageFiles = _splitImageCell(cell('specImageFiles'));
    // The spec map: the free-text מידות cell first, under its own Hebrew key
    // as always, then every OPEN SPEC COLUMN as 'title → cell' in file order
    // (empty cells contribute nothing) — the product sheet renders dims
    // entries as 'key: value' rows verbatim.
    final dims = <String, dynamic>{
      if (dimsCell.isNotEmpty) 'מידות': dimsCell,
    };
    for (final open in openCols.entries) {
      final v = open.key < cells.length ? cells[open.key].trim() : '';
      if (v.isNotEmpty) dims[open.value] = v;
    }
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
        dims: dims.isEmpty ? null : dims,
        imageFile: imageCell.isEmpty ? null : imageCell,
        imageFiles: imageFiles,
        specImageFile: specImageCell.isEmpty ? null : specImageCell,
        specImageFiles: specImageFiles,
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
/// round-trip idiom). dims rides whole (the מידות cell AND every open spec
/// column) and the four image fields ride along — the import persists the
/// FULL product card.
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
            if (p.imageFile != null) 'imageFile': p.imageFile,
            if (p.imageFiles != null) 'imageFiles': p.imageFiles,
            if (p.specImageFile != null) 'specImageFile': p.specImageFile,
            if (p.specImageFiles != null) 'specImageFiles': p.specImageFiles,
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
          imageFile: item['imageFile'] as String?,
          imageFiles: _decodeImageList(item['imageFiles']),
          specImageFile: item['specImageFile'] as String?,
          specImageFiles: _decodeImageList(item['specImageFiles']),
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
  _Col('imageFile', 'תמונה', {'תמונה', 'image'}),
  _Col('imageFiles', 'תמונות נוספות', {'תמונות נוספות', 'תמונות', 'images'}),
  _Col('specImageFile', 'תמונת מפרט', {'תמונת מפרט', 'spec_image'}),
  _Col('specImageFiles', 'תמונות מפרט', {'תמונות מפרט', 'spec_images'}),
];

/// Every recognized header alias, flattened — the separator-detection set the
/// shared [tokenizeCsvAutodetect] scores against (was the inlined per-col loop).
final Set<String> _kKnownHeaders = {for (final col in _kCols) ...col.match};

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

/// A multi-image cell is a '|'-separated list: parts trimmed, empties
/// dropped, each part stored AS-IS (a full http(s) URL or a bare filename —
/// the image-resolution chain handles both); null when nothing survives, so
/// an empty cell stays an absent field (the sparse-product idiom).
List<String>? _splitImageCell(String cell) {
  final parts = <String>[
    for (final part in cell.split('|'))
      if (part.trim().isNotEmpty) part.trim(),
  ];
  return parts.isEmpty ? null : parts;
}

/// Tolerant image-list decode (the per-item iron rule, list edition): any
/// List becomes a List<String> via per-element '$…' toString — never a cast
/// throw; not-a-list / nothing inside → null, so absent stays absent and an
/// encode→decode→encode round-trip is byte-stable (nulls are omitted).
List<String>? _decodeImageList(Object? v) {
  if (v is! List) return null;
  final out = <String>[for (final e in v) '$e'];
  return out.isEmpty ? null : out;
}

