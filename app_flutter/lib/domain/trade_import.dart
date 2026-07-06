// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 48 — the BULK-IMPORT
// contract: template → dry-run → ATOMIC commit.
//
// PURE Dart (imports only trade_schema + foundation for @immutable): the CSV
// template generator + the parse-and-validate pass that turns pasted CSV text
// into an [ImportReport] — the dry-run verdict the UI renders and the ONLY
// gate to a commit ([ImportReport.canCommit]: zero errors AND at least one
// valid row → the caller upserts report.valid as a whole; anything less
// commits NOTHING — that is the atomicity: the gate, not a transaction).
//
// v1 scope notes (deliberate):
//   · cells split on a bare ',' — quoted-CSV (embedded commas/quotes) is OUT
//     of v1 scope (Pillar-5 owns the heavy sheet pipeline);
//   · header columns beyond the fixed three map to the trade's [AttributeDef]s
//     by EXACT nameHe; unknown extra columns are IGNORED (never an error);
//   · only TRAILING empty lines are trimmed — an interior empty line is a data
//     row and fails the required-field checks at its own rowIndex.
//
// Consumed by the flag-gated (kTradeImportFlag, default OFF) import section of
// ProductAuthoringScreen ⇒ zero regression on a normal build.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:flutter/foundation.dart';

/// The template's FIXED leading columns — sku (the product id), the Hebrew
/// name, and the category (titleHe or id). Every import header must open with
/// exactly these three, in this order.
const List<String> kImportFixedColumns = ['sku', 'name', 'category'];

/// The downloadable CSV template for a trade: line 1 is the header — the
/// fixed columns plus one column PER [AttributeDef] (its nameHe, the same
/// key [parseAndValidateCsv] maps back by) — and line 2 is a single blank
/// data row (the same number of cells, all empty), '\n'-separated.
String generateCsvTemplate(List<AttributeDef> defs) {
  final header = [...kImportFixedColumns, for (final d in defs) d.nameHe];
  final blankRow = List.filled(header.length, '').join(',');
  return '${header.join(',')}\n$blankRow';
}

/// One validation failure. [rowIndex] is 0 for the header line, else the
/// 1-based DATA-row index (the first row under the header is row 1).
@immutable
class ImportRowError {
  const ImportRowError(this.rowIndex, this.messageHe);

  final int rowIndex;
  final String messageHe;

  @override
  bool operator ==(Object other) =>
      other is ImportRowError &&
      other.rowIndex == rowIndex &&
      other.messageHe == messageHe;

  @override
  int get hashCode => Object.hash(rowIndex, messageHe);
}

/// The dry-run verdict: the rows that parsed clean (as ready-to-upsert
/// [TradeProduct]s) and every row error found. [canCommit] is the ATOMIC
/// gate — a commit happens only when the WHOLE paste validates.
@immutable
class ImportReport {
  const ImportReport({required this.valid, required this.errors});

  final List<TradeProduct> valid;
  final List<ImportRowError> errors;

  /// True iff there is something to import AND nothing wrong — the ONLY
  /// state the UI offers the commit action in.
  bool get canCommit => errors.isEmpty && valid.isNotEmpty;
}

/// Parse + validate pasted CSV against the trade's authored schema.
///
/// [categories] and [defs] are the trade's OWN slices (already trade-scoped
/// by the caller); [existingProducts] likewise — the duplicate-sku check runs
/// against their ids (the sku IS the id) and against earlier rows in-file.
///
/// Per data row: the three fixed cells are required ('שדה חובה חסר: <col>');
/// the category cell must match a category's titleHe OR id (→ the resolved
/// id lands on the product, else 'קטגוריה לא קיימת: <cell>'); a NON-EMPTY
/// cell under a def WITH values must equal one value's labelHe or id
/// (→ attributes[def.id] = value.id, else 'ערך לא בסכמה: <cell>'); a def
/// with NO values (freeText / number) takes the raw trimmed cell; an EMPTY
/// attribute cell is always fine (no entry, no error). A row with ANY error
/// contributes no product. A bad header short-circuits IMMEDIATELY with the
/// single row-0 error 'כותרות לא תקינות'.
ImportReport parseAndValidateCsv({
  required String csv,
  required String tradeId,
  required List<TradeCategory> categories,
  required List<AttributeDef> defs,
  required List<TradeProduct> existingProducts,
}) {
  const badHeader = ImportReport(
    valid: [],
    errors: [ImportRowError(0, 'כותרות לא תקינות')],
  );

  // Lines, with TRAILING empty lines trimmed (a paste almost always ends in
  // '\n'); cells split on a bare ',' (quoted-CSV is out of v1 scope).
  final lines = csv.split('\n');
  while (lines.isNotEmpty && lines.last.trim().isEmpty) {
    lines.removeLast();
  }
  if (lines.isEmpty) return badHeader;

  // ── the header: the first 3 cells (trimmed) must BE kImportFixedColumns ──
  final headerCells = [for (final c in lines.first.split(',')) c.trim()];
  if (headerCells.length < kImportFixedColumns.length) return badHeader;
  for (var i = 0; i < kImportFixedColumns.length; i++) {
    if (headerCells[i] != kImportFixedColumns[i]) return badHeader;
  }

  // Remaining header cells → defs by EXACT nameHe (column index → def).
  // Unknown / empty extra columns are ignored — never an error.
  final colDef = <int, AttributeDef>{};
  for (var i = kImportFixedColumns.length; i < headerCells.length; i++) {
    final title = headerCells[i];
    if (title.isEmpty) continue;
    for (final d in defs) {
      if (d.nameHe == title) {
        colDef[i] = d;
        break;
      }
    }
  }

  final existingIds = {for (final p in existingProducts) p.id};
  final seenSkus = <String>{};
  final valid = <TradeProduct>[];
  final errors = <ImportRowError>[];

  // Data rows. rowIndex is 1-based over DATA rows — which is exactly the
  // line index, since line 0 is the header.
  for (var rowIndex = 1; rowIndex < lines.length; rowIndex++) {
    final cells = lines[rowIndex].split(',');
    // A short row reads missing cells as empty (never a range error).
    String cell(int i) => i < cells.length ? cells[i].trim() : '';

    final sku = cell(0);
    final name = cell(1);
    final categoryCell = cell(2);
    final rowErrors = <ImportRowError>[];

    // (1) the three fixed cells are required.
    if (sku.isEmpty) {
      rowErrors.add(ImportRowError(rowIndex, 'שדה חובה חסר: sku'));
    }
    if (name.isEmpty) {
      rowErrors.add(ImportRowError(rowIndex, 'שדה חובה חסר: name'));
    }
    if (categoryCell.isEmpty) {
      rowErrors.add(ImportRowError(rowIndex, 'שדה חובה חסר: category'));
    }

    // (2) duplicate sku — earlier in THIS file, or an existing product's id.
    if (sku.isNotEmpty) {
      if (seenSkus.contains(sku) || existingIds.contains(sku)) {
        rowErrors.add(ImportRowError(rowIndex, 'מק"ט כפול: $sku'));
      }
      seenSkus.add(sku);
    }

    // (3) the category cell matches a category's titleHe OR id → resolved id.
    String? categoryId;
    if (categoryCell.isNotEmpty) {
      for (final c in categories) {
        if (c.titleHe == categoryCell || c.id == categoryCell) {
          categoryId = c.id;
          break;
        }
      }
      if (categoryId == null) {
        rowErrors.add(
          ImportRowError(rowIndex, 'קטגוריה לא קיימת: $categoryCell'),
        );
      }
    }

    // (4) attribute columns. EMPTY cells are always fine (no entry) — also
    // under a def WITH values; a non-empty cell under a valued def must be
    // in-schema (labelHe or id → the value ID lands, the trade_schema.dart
    // contract); a no-values def (freeText / number) takes the raw trim.
    final attrs = <String, String>{};
    for (final e in colDef.entries) {
      final raw = cell(e.key);
      if (raw.isEmpty) continue;
      final d = e.value;
      if (d.values.isNotEmpty) {
        String? valueId;
        for (final v in d.values) {
          if (v.labelHe == raw || v.id == raw) {
            valueId = v.id;
            break;
          }
        }
        if (valueId == null) {
          rowErrors.add(ImportRowError(rowIndex, 'ערך לא בסכמה: $raw'));
        } else {
          attrs[d.id] = valueId;
        }
      } else {
        attrs[d.id] = raw;
      }
    }

    if (rowErrors.isNotEmpty) {
      errors.addAll(rowErrors);
      continue; // a row with ANY error contributes no product
    }
    valid.add(
      TradeProduct(
        id: sku, // the sku IS the id — verbatim, no slug (the s46 contract)
        tradeId: tradeId,
        categoryId: categoryId!,
        // The import surface authors neither a brand nor an English name —
        // both REQUIRED by the ctor, both land empty (the s46 add-form shape).
        brandId: '',
        nameHe: name,
        nameEn: '',
        attributes: attrs,
      ),
    );
  }

  return ImportReport(valid: valid, errors: errors);
}
