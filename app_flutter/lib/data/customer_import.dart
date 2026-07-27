// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · CUSTOMER bulk-import — CSV → [SavedCustomer], on the shared
// [csv_kernel] tokenizer (same RFC-4180-ish parse, separator auto-detect,
// UTF-8 gate, physical-line error numbers as the catalog importer). PURE Dart.
//
// Contract mirrors company_catalog_import (the s48 atomic gate):
//   · name is the ONLY required column; phone/email are validated when present
//     (validIsraeliMobile / validEmail — wave-2a); notes/tags are free.
//   · id is DETERMINISTIC — 'imp:' + the CRM dedup key (normName|normalizePhone),
//     NEVER the wall clock: a bulk loop on Flutter web mints many rows in the
//     same millisecond, so a clock id would collide and upsertCustomer would
//     silently collapse distinct rows. A dedup-key id also makes a re-import
//     idempotent (same rows → same ids → replace-in-place, no duplicates).
//   · an in-file EXACT duplicate (same normName+phone) is a hard error, exactly
//     as the catalog treats a duplicate מק"ט; softer normName-name-only
//     collisions surface later through the wave-3a quality-warnings lane.
//   · [CustomerImportReport.canCommit] (zero errors AND ≥1 row) is the only
//     gate — anything less commits NOTHING.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/csv_kernel.dart';
import 'package:buildsmart/logic/input_validators.dart'
    show normalizePhone, validBusinessId, validEmail, validIsraeliMobile;
import 'package:buildsmart/logic/text_normalize.dart' show normName;
import 'package:buildsmart/state/customers_store.dart' show SavedCustomer;

/// One per-row failure — [row] is the 1-based PHYSICAL file line (0 = file
/// level); [messageHe] is the full honest Hebrew sentence, rendered verbatim.
class CustomerImportRowError {
  const CustomerImportRowError(this.row, this.messageHe);

  final int row;
  final String messageHe;
}

/// The dry-run result: the clean rows and every error. Commit iff [canCommit].
class CustomerImportReport {
  const CustomerImportReport({required this.valid, required this.errors});

  final List<SavedCustomer> valid;
  final List<CustomerImportRowError> errors;

  bool get canCommit => errors.isEmpty && valid.isNotEmpty;
}

class _CustCol {
  const _CustCol(this.key, this.he, this.match);

  final String key;
  final String he;
  final Set<String> match;
}

/// Columns in template order — only `name` is required.
const List<_CustCol> _kCustCols = [
  _CustCol('name', 'שם הלקוח', {'שם הלקוח', 'שם', 'name', 'name_he', 'לקוח'}),
  _CustCol('phone', 'טלפון', {'טלפון', 'נייד', 'phone', 'mobile', 'tel'}),
  _CustCol('email', 'אימייל', {'אימייל', 'email', 'mail'}),
  _CustCol('businessId', 'ח.פ', {
    'ח.פ', 'ח"פ', 'ח״פ', 'חפ', 'עוסק מורשה', 'businessid', 'business_id', 'tax_id',
  }),
  _CustCol('notes', 'הערות', {'הערות', 'הערה', 'notes', 'note'}),
  _CustCol('tags', 'תגיות', {'תגיות', 'תגית', 'tags', 'tag'}),
];

final Set<String> _kKnownHeaders = {
  for (final col in _kCustCols) ...col.match,
};

/// The CRM dedup identity, spelled once so the id, the in-file dup check and
/// the store's own [SavedCustomer.dedupKey] all agree.
String _dedupKey(String name, String phone) =>
    '${normName(name)}|${normalizePhone(phone)}';

/// The downloadable, self-documenting template: UTF-8 BOM first (Excel), the
/// header, then '#'-comment legend + one example row the parser skips (so
/// re-uploading it untouched → zero rows, canCommit false).
String customerCatalogTemplateCsv() {
  const header = 'שם הלקוח,טלפון,אימייל,ח.פ,הערות,תגיות';
  return '$kCsvBom$header\n'
      '# חובה = שם הלקוח בלבד; השאר רשות\n'
      '# טלפון — נייד ישראלי (05XXXXXXXX); אימייל — כתובת תקינה\n'
      '# ח.פ — 9 ספרות עם ספרת-ביקורת; תגיות — בקו-אנכי, למשל: קמעונאי|VIP\n'
      '# דוגמה (מחקו את ה-# והחליפו בנתונים שלכם):\n'
      '# ישראל ישראלי,0501234567,israel@example.com,514999997,לקוח קבוע,קמעונאי|VIP\n';
}

/// Parse + validate a customer CSV. Never throws; every problem is an error row.
CustomerImportReport parseCustomerCsv(String raw) {
  var text = raw;
  while (text.startsWith(kCsvBom)) {
    text = text.substring(1);
  }
  if (text.contains(kCsvReplacementChar)) {
    return const CustomerImportReport(
      valid: [],
      errors: [
        CustomerImportRowError(
          0,
          'הקובץ אינו בקידוד UTF-8 — שמור מחדש כ-CSV UTF-8',
        ),
      ],
    );
  }

  final records = tokenizeCsvAutodetect(text, _kKnownHeaders);
  final headerIdx = csvHeaderIndex(records);

  final errors = <CustomerImportRowError>[];
  final colIndex = <String, int>{};
  if (headerIdx >= 0) {
    final headerCells = records[headerIdx].cells;
    for (var i = 0; i < headerCells.length; i++) {
      final h = normHeader(headerCells[i]);
      if (h.isEmpty) continue;
      for (final col in _kCustCols) {
        if (col.match.contains(h)) {
          colIndex.putIfAbsent(col.key, () => i);
          break;
        }
      }
    }
  }
  if (!colIndex.containsKey('name')) {
    errors.add(const CustomerImportRowError(1, 'חסרה עמודת חובה: שם הלקוח'));
    return CustomerImportReport(valid: const [], errors: errors);
  }

  final seenKeys = <String>{};
  final valid = <SavedCustomer>[];
  var dataRows = 0;

  for (var r = headerIdx + 1; r < records.length; r++) {
    final rec = records[r];
    if (csvIsBlank(rec.cells) || csvIsComment(rec.cells)) continue;
    dataRows++;
    if (dataRows > 5000) {
      errors.add(CustomerImportRowError(
        rec.line,
        'הקובץ גדול מדי — עד 5000 לקוחות בייבוא אחד',
      ));
      break;
    }
    final n = rec.line;
    String cell(String key) {
      final idx = colIndex[key];
      if (idx == null || idx >= rec.cells.length) return '';
      return rec.cells[idx].trim();
    }

    final rowErrors = <CustomerImportRowError>[];
    final name = cell('name');
    if (name.isEmpty) {
      rowErrors.add(CustomerImportRowError(n, 'שורה $n — חסר שם הלקוח'));
    }
    final phone = cell('phone');
    if (phone.isNotEmpty && !validIsraeliMobile(phone)) {
      rowErrors.add(
        CustomerImportRowError(n, 'שורה $n — טלפון לא תקין: $phone'),
      );
    }
    final email = cell('email');
    if (email.isNotEmpty && !validEmail(email)) {
      rowErrors.add(
        CustomerImportRowError(n, 'שורה $n — אימייל לא תקין: $email'),
      );
    }
    final businessId = cell('businessId');
    if (businessId.isNotEmpty && !validBusinessId(businessId)) {
      rowErrors.add(
        CustomerImportRowError(n, 'שורה $n — ח.פ לא תקין: $businessId'),
      );
    }

    if (name.isNotEmpty) {
      final key = _dedupKey(name, phone);
      if (!seenKeys.add(key)) {
        rowErrors.add(
          CustomerImportRowError(n, 'שורה $n — לקוח כפול: $name'),
        );
      }
    }

    if (rowErrors.isNotEmpty) {
      errors.addAll(rowErrors);
      continue;
    }

    final tags = <String>[
      for (final t in cell('tags').split('|'))
        if (t.trim().isNotEmpty) t.trim(),
    ];
    valid.add(SavedCustomer(
      id: 'imp:${_dedupKey(name, phone)}',
      name: name,
      phone: phone,
      email: email,
      businessId: businessId,
      notes: cell('notes'),
      tags: tags,
    ));
  }

  return CustomerImportReport(valid: valid, errors: errors);
}
