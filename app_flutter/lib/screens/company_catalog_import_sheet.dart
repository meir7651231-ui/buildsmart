// 📦 טעינת קטלוג החברה — the CLEAN-profile company-catalog import sheet
// (import-feature wave). Reached from the suppliers empty state and the
// catalog-tab entry card, BOTH mounted behind [kProfileEmptyCatalog]
// (const-false on demo/buildsmart — this sheet is unreachable there, so those
// builds stay byte-identical).
//
// Flow (owner-approved): download the CSV template → fill in Excel → upload.
// Parsing is ATOMIC — any row error renders the full per-row Hebrew error list
// IN the sheet and commits NOTHING. A valid file persists (the
// company_catalog_store), applies in-memory (setCompanyCatalog) and prompts a
// reload — a few caches snapshot the catalog at startup, so the reload is the
// honest way to apply it everywhere.

import 'package:buildsmart/data/catalog_source.dart'
    show resolvedCatalogProducts, setCompanyCatalog;
import 'package:buildsmart/data/company_catalog_import.dart'
    show CompanyImportReport, companyCatalogTemplateCsv, parseCompanyCatalogCsv;
import 'package:buildsmart/services/file_transfer.dart'
    show downloadTextFileProvider, pickTextFileProvider, reloadAppProvider;
import 'package:buildsmart/state/company_catalog_store.dart'
    show persistCompanyCatalog;
import 'package:buildsmart/theme/app_theme.dart' show bsOnAccent;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open the company-catalog import sheet (a bottom sheet, RTL, the
/// role-request-sheet idiom: transparent modal, the sheet draws its own
/// rounded-top card).
void showCompanyCatalogImportSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CompanyCatalogImportSheet(),
  );
}

class _CompanyCatalogImportSheet extends ConsumerStatefulWidget {
  const _CompanyCatalogImportSheet();

  @override
  ConsumerState<_CompanyCatalogImportSheet> createState() =>
      _CompanyCatalogImportSheetState();
}

class _CompanyCatalogImportSheetState
    extends ConsumerState<_CompanyCatalogImportSheet> {
  bool _busy = false;

  /// Last FAILED parse — renders the per-row Hebrew error list in the sheet.
  /// Atomic contract: while this is non-null, NOTHING was committed.
  CompanyImportReport? _report;

  /// Non-null after a successful persist+apply — the success state (count +
  /// the reload prompt) replaces the two action buttons.
  int? _committedCount;

  Future<void> _downloadTemplate() async {
    final ok = await ref.read(downloadTextFileProvider)(
      'catalog-template.csv',
      companyCatalogTemplateCsv(),
      'text/csv;charset=utf-8',
    );
    if (!mounted) return;
    showToast(
      context,
      ok ? 'התבנית ירדה — פתחו באקסל, מלאו והעלו' : 'הורדה זמינה בגרסת-הדפדפן',
    );
  }

  Future<void> _uploadCsv() async {
    if (_busy) return;
    final picked = await ref.read(pickTextFileProvider)('.csv');
    if (picked == null) return; // picker dismissed — silent, nothing to report
    final report = parseCompanyCatalogCsv(picked.content);
    if (!mounted) return;
    if (!report.canCommit) {
      // Atomic contract: ANY error ⇒ commit NOTHING — show the full list.
      setState(() => _report = report);
      return;
    }
    setState(() {
      _busy = true;
      _report = null;
    });
    final saved = await persistCompanyCatalog(report.valid);
    if (!mounted) return;
    if (!saved) {
      // Honest STOP: nothing persisted ⇒ nothing applied (a catalog that
      // evaporates on the next launch would be a fake success).
      setState(() => _busy = false);
      showToast(context, 'השמירה נכשלה — ייתכן שהקובץ גדול מדי לאחסון המקומי');
      return;
    }
    setCompanyCatalog(report.valid);
    setState(() {
      _busy = false;
      _committedCount = report.valid.length;
    });
  }

  ButtonStyle _brandFill(BuildContext context) => ElevatedButton.styleFrom(
        backgroundColor: BsTokens.brand,
        foregroundColor: bsOnAccent(context),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      );

  @override
  Widget build(BuildContext context) {
    final report = _report;
    final committed = _committedCount;
    // File-level errors (row 0/1 — encoding/header) first, then data rows in
    // parser order (a stable partition, not a sort).
    final errors = report == null
        ? null
        : [
            for (final e in report.errors)
              if (e.row <= 1) e,
            for (final e in report.errors)
              if (e.row > 1) e,
          ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          BsTokens.space4,
          BsTokens.space3,
          BsTokens.space4,
          BsTokens.space5,
        ),
        decoration: const BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.86,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: BsTokens.space3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    ),
                  ),
                ),
                const Text(
                  '📦 טעינת קטלוג החברה',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    color: BsTokens.inkLight,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'המערכת עובדת על הקטלוג שתטענו — חיפוש, סל והזמנות. מחירים והשוואת-חנויות יתווספו בשלב חיבור-השרת.',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                ),
                const SizedBox(height: BsTokens.space2),
                Text(
                  resolvedCatalogProducts.isNotEmpty
                      ? 'נטענו ${resolvedCatalogProducts.length} מוצרים'
                      : 'עדיין לא נטען קטלוג',
                  style: TextStyle(
                    color: resolvedCatalogProducts.isNotEmpty
                        ? BsTokens.successDark
                        : BsTokens.mutedLight,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: BsTokens.space3),
                if (committed != null) ...[
                  Text(
                    '✅ נטענו $committed מוצרים',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: BsTokens.successDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  ElevatedButton(
                    onPressed: () => ref.read(reloadAppProvider)(),
                    style: _brandFill(context),
                    child: const Text('🔄 רענן להחלת הקטלוג בכל המסכים'),
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: _busy ? null : _downloadTemplate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BsTokens.brandDark,
                      side: const BorderSide(color: BsTokens.brand),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    child: const Text('⬇️ הורד תבנית לדוגמה'),
                  ),
                  const SizedBox(height: BsTokens.space2),
                  ElevatedButton(
                    onPressed: _busy ? null : _uploadCsv,
                    style: _brandFill(context),
                    child: const Text('⬆️ העלה נתונים'),
                  ),
                  if (errors != null) ...[
                    const SizedBox(height: BsTokens.space3),
                    Text(
                      'נמצאו ${errors.length} שגיאות — תקנו והעלו שוב',
                      style: const TextStyle(
                        color: BsTokens.dangerDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: BsTokens.space2),
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(BsTokens.space3),
                          itemCount: errors.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 12,
                            color: BsTokens.divider,
                          ),
                          itemBuilder: (context, i) => Text(
                            'שורה ${errors[i].row} — ${errors[i].messageHe}',
                            style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
