// Real PDF generation for the finance-hub "הפק והורד דוח PDF" report.
//
// Builds a `pw.Document` that mirrors, 1:1, the on-screen `_FinReportView`
// (finance_hub_sheets.dart): the budget summary (total · spent + % · balance)
// and the per-category breakdown — from the SAME finance-repo data the screen
// renders. RTL Hebrew, so the document is typeset with the app's bundled Heebo
// font (the PDF default Helvetica has no Hebrew glyphs).

import 'package:buildsmart/data/contractor_seeds.dart' show BudgetCategory, fMoney;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The exact data the finance report shows — captured from the finance repo so
/// the PDF and the on-screen `_FinReportView` stay byte-identical.
class FinanceReportData {
  const FinanceReportData({
    required this.budgetTotal,
    required this.budgetSpent,
    required this.budgetPct,
    required this.balance,
    required this.today,
    required this.categories,
  });

  final int budgetTotal;
  final int budgetSpent;
  final int budgetPct;
  final int balance;
  final String today;
  final List<BudgetCategory> categories;
}

/// Strip non-typesettable runes (emoji category icons) so Heebo never hits a
/// missing-glyph crash — the substantive data (Hebrew name + ₪ amount) stays.
/// Keeps Hebrew, Latin, digits, and common punctuation/whitespace.
String _pdfSafe(String s) {
  final buf = StringBuffer();
  for (final rune in s.runes) {
    final keep =
        (rune >= 0x0590 && rune <= 0x05FF) || // Hebrew
        (rune >= 0x0020 && rune <= 0x007E) || // ASCII printable
        rune == 0x20AA; // ₪
    if (keep) buf.writeCharCode(rune);
  }
  return buf.toString().trim();
}

/// Build the real finance-report PDF document from [data]. Async because the
/// Heebo font is loaded from the asset bundle.
Future<pw.Document> buildFinanceReportPdf(FinanceReportData data) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Heebo-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Heebo-Bold.ttf'),
  );

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  pw.Widget kv(String label, String value, {bool big = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: big ? 14 : 12, font: regular),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: big ? 16 : 12,
                font: big ? bold : regular,
              ),
            ),
          ],
        ),
      );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            'BuildSmart — דוח פיננסי לפרויקט',
            style: pw.TextStyle(fontSize: 20, font: bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'תאריך הפקה: ${data.today}',
            style: pw.TextStyle(fontSize: 11, font: regular),
          ),
          pw.SizedBox(height: 18),
          pw.Text('תמצית תקציב', style: pw.TextStyle(fontSize: 15, font: bold)),
          pw.Divider(),
          kv('תקציב כולל', fMoney(data.budgetTotal), big: true),
          kv('הוצאות בפועל', '${fMoney(data.budgetSpent)} (${data.budgetPct}%)'),
          kv('יתרה', fMoney(data.balance)),
          pw.SizedBox(height: 18),
          pw.Text(
            'פירוט לפי סעיפים',
            style: pw.TextStyle(fontSize: 15, font: bold),
          ),
          pw.Divider(),
          for (final c in data.categories)
            kv(_pdfSafe(c.name), fMoney(c.amount)),
          pw.SizedBox(height: 24),
          pw.Text(
            'הופק על ידי מערכת BuildSmart · ${data.today}',
            style: pw.TextStyle(fontSize: 10, font: regular),
          ),
        ],
      ),
    ),
  );

  return doc;
}
