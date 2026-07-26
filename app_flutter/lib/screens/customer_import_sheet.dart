// 👥 ייבוא לקוחות — the manager customer bulk-import sheet (GIANT Phase-2
// wave-3d). Opened from the customers tab's import button, itself behind the
// opt-in `manager.customers` gate, so demo/default builds never reach it and
// stay byte-identical.
//
// Flow mirrors the company-catalog import sheet: download the CSV template →
// fill in Excel → upload. Parsing (customer_import) is ATOMIC — any row error
// renders the full per-row Hebrew list and commits NOTHING. A clean file folds
// every row through the CRM dedup (CustomersStore.importAll) and a NON-blocking
// quality pass (auditRows) surfaces softer duplicates the hard gate lets by.

import 'package:buildsmart/data/customer_import.dart'
    show CustomerImportReport, customerCatalogTemplateCsv, parseCustomerCsv;
import 'package:buildsmart/logic/data_quality.dart'
    show QualityReport, QualityRow, auditRows;
import 'package:buildsmart/services/file_transfer.dart'
    show downloadTextFileProvider, pickTextFileProvider;
import 'package:buildsmart/state/customers_store.dart'
    show savedCustomersProvider;
import 'package:buildsmart/theme/app_theme.dart' show bsOnAccent;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open the customer import sheet (transparent modal, the sheet draws its own
/// rounded-top card — the company-import-sheet idiom).
void showCustomerImportSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CustomerImportSheet(),
  );
}

class _CustomerImportSheet extends ConsumerStatefulWidget {
  const _CustomerImportSheet();

  @override
  ConsumerState<_CustomerImportSheet> createState() =>
      _CustomerImportSheetState();
}

class _CustomerImportSheetState extends ConsumerState<_CustomerImportSheet> {
  bool _busy = false;

  /// Last FAILED parse — renders the per-row Hebrew error list. Atomic
  /// contract: while this is non-null, NOTHING was committed.
  CustomerImportReport? _report;

  /// Non-null after a successful import — the count replaces the buttons.
  int? _committedCount;

  /// Non-blocking quality warnings over the committed rows (softer duplicates).
  QualityReport? _quality;

  Future<void> _downloadTemplate() async {
    final ok = await ref.read(downloadTextFileProvider)(
      'customers-template.csv',
      customerCatalogTemplateCsv(),
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
    if (picked == null) return; // picker dismissed — silent
    final report = parseCustomerCsv(picked.content);
    if (!mounted) return;
    if (!report.canCommit) {
      setState(() => _report = report);
      return;
    }
    ref.read(savedCustomersProvider.notifier).importAll(report.valid);
    setState(() {
      _busy = false;
      _report = null;
      _committedCount = report.valid.length;
      _quality = auditRows([
        for (var i = 0; i < report.valid.length; i++)
          QualityRow(
            line: i + 1,
            key: report.valid[i].phone,
            name: report.valid[i].name,
          ),
      ]);
    });
  }

  ButtonStyle _brandFill(BuildContext context) => ElevatedButton.styleFrom(
        backgroundColor: BsTokens.brand,
        foregroundColor: bsOnAccent(context),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      );

  @override
  Widget build(BuildContext context) {
    final report = _report;
    final committed = _committedCount;
    final quality = _quality;
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
                  '👥 ייבוא לקוחות',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    color: BsTokens.inkLight,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'טענו רשימת לקוחות מקובץ CSV — שם חובה, טלפון ואימייל נבדקים, כפילויות מסוננות אוטומטית.',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                ),
                const SizedBox(height: BsTokens.space3),
                if (committed != null) ...[
                  Text(
                    '✅ נטענו $committed לקוחות',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: BsTokens.successDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  if (quality != null && quality.flagged > 0) ...[
                    const SizedBox(height: BsTokens.space3),
                    Text(
                      '⚠️ ${quality.flagged} אזהרות איכות (לא חוסמות) — כדאי לבדוק',
                      style: const TextStyle(
                        color: BsTokens.warnText,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: BsTokens.space2),
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(BsTokens.space3),
                          itemCount: quality.warnings.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 12,
                            color: BsTokens.divider,
                          ),
                          itemBuilder: (context, i) => Text(
                            quality.warnings[i].message,
                            style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: BsTokens.space3),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: _brandFill(context),
                    child: const Text('סגור'),
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
                  if (report != null) ...[
                    const SizedBox(height: BsTokens.space3),
                    Text(
                      'נמצאו ${report.errors.length} שגיאות — תקנו והעלו שוב',
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
                          itemCount: report.errors.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 12,
                            color: BsTokens.divider,
                          ),
                          itemBuilder: (context, i) => Text(
                            report.errors[i].messageHe,
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
