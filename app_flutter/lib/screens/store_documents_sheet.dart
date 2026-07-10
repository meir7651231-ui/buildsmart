import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';

/// 🧾 מסמכים — חשבוניות ודוח חודשי (#87.4, F-24) — SERVER-READY sheet for the
/// supplier board, in the exact honest pattern of `worker_payslips_sheet.dart`
/// (which is untouchable + worded for payslips, so it cannot be reused here):
/// the complete 12-month UI with an honest 'יחובר עם חיבור השרת' state on
/// every row. Real invoices / monthly reports REQUIRE the billing server —
/// no fake PDFs, NO invented amounts, no invoice numbers (אין המצאות: not a
/// single business field is rendered).
///
/// SERVER-SWAP: each month row becomes a tappable invoice / monthly-report
/// download once the billing backend lands; the list/row layout below stays
/// as-is.
Future<void> showStoreDocumentsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: BsTokens.cardLight,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
    ),
    // Explicit RTL on every modal sheet (the sheets convention, F-46).
    builder: (sheetCtx) => const Directionality(
      textDirection: TextDirection.rtl,
      child: _DocumentsSheetBody(),
    ),
  );
}

/// Hebrew month names (calendar labels, not business data).
const List<String> _kHebMonths = [
  'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
  'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר',
];

class _DocumentsSheetBody extends StatelessWidget {
  const _DocumentsSheetBody();

  @override
  Widget build(BuildContext context) {
    // The last 12 calendar months, newest first — pure calendar derivation
    // (Dart normalizes negative months, so a year boundary is safe); no
    // business data.
    final now = DateTime.now();
    final months = [
      for (var i = 0; i < 12; i++) DateTime(now.year, now.month - i),
    ];

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                BsTokens.space4,
                BsTokens.space3,
                BsTokens.space4,
                0,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: CfgText(
                      'store_documents_sheet.t01',
                      '🧾 חשבוניות ודוח חודשי',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // Explicit X close (sheet rule) — IconButton is 48dp.
                  IconButton(
                    tooltip: 'סגור',
                    icon: const Icon(Icons.close, color: BsTokens.mutedLight),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // HONEST server-needed banner — real invoices/reports are a
            // server feature; nothing here pretends otherwise.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                BsTokens.space4,
                BsTokens.space2,
                BsTokens.space4,
                BsTokens.space3,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space4,
                  vertical: BsTokens.space3,
                ),
                decoration: BoxDecoration(
                  color: BsTokens.brand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                ),
                child: const CfgText(
                  'store_documents_sheet.t02',
                  '🔌 החשבוניות והדוחות האמיתיים יחוברו עם חיבור השרת — '
                  'המסך מוכן ויתמלא אוטומטית.',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  BsTokens.space4,
                  0,
                  BsTokens.space4,
                  BsTokens.space4,
                ),
                children: [
                  for (final m in months) _MonthRow(month: m),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One month row — honestly NOT tappable (no InkWell): there is no invoice or
/// monthly report to open until the server lands, and the pill says exactly
/// that. No ₪, no sums, no invoice numbers — nothing invented.
class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space3,
          vertical: BsTokens.space2,
        ),
        decoration: BoxDecoration(
          color: BsTokens.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Row(
          children: [
            // Decorative lock — the pill beside it carries the meaning.
            const Icon(Icons.lock_outline,
                size: 18, color: BsTokens.mutedLight),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: Text(
                '${_kHebMonths[month.month - 1]} ${month.year}',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F5),
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              ),
              child: const CfgText(
                'store_documents_sheet.t03',
                'יחובר עם חיבור השרת',
                style: TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
