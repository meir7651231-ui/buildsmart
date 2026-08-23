import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:flutter/material.dart';

/// 💰 תלושי שכר (cluster #85ח) — SERVER-READY sheet: the complete months UI
/// with an honest 'יחובר עם חיבור השרת' state on every row. Real payslips
/// REQUIRE the payroll server — no fake PDFs, no invented amounts (אין
/// המצאות). SERVER-SWAP: each month row becomes a tappable payslip download
/// once the payroll backend lands; the list/row layout below stays as-is.
Future<void> showWorkerPayslipsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
    ),
    builder: (sheetCtx) => const Directionality(
      textDirection: TextDirection.rtl,
      child: _PayslipsSheetBody(),
    ),
  );
}

/// Hebrew month names (calendar labels, not business data).
const List<String> _kHebMonths = [
  'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
  'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר',
];

class _PayslipsSheetBody extends StatelessWidget {
  const _PayslipsSheetBody();

  @override
  Widget build(BuildContext context) {
    // The last 12 calendar months, newest first — pure calendar derivation,
    // no business data.
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
                      'worker_payslips_sheet.t01',
                      '💰 תלושי שכר',
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
            // HONEST server-needed banner — real payslips are a server
            // feature; nothing here pretends otherwise.
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
                child: const Text(
                  '🔌 תלושי השכר האמיתיים יחוברו עם חיבור השרת — '
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

/// One month row — honestly NOT tappable (no InkWell): there is no payslip to
/// open until the server lands, and the pill says exactly that.
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Row(
          children: [
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
            // composite hide: whole status pill gone when the org hides this element
            CfgVisible(
              'worker_payslips_sheet.t02',
              child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F5),
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              ),
              child: const CfgText(
                'worker_payslips_sheet.t02',
                'יחובר עם חיבור השרת',
                style: TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
