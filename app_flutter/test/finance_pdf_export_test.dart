// LAUNCH FIX #4 — the finance-hub "הפק והורד דוח PDF" report
// (finance_hub_sheets.dart _FinReportView + logic/finance_report_pdf.dart).
//
// The print button used to ONLY toast 'בחר "שמור כ-PDF"…'. It now builds a REAL
// `pw.Document` (printing + pdf) from the SAME data the report view shows and
// hands it to the print/save dialog — through the injectable `pdfPrintProvider`
// seam, so this test CAPTURES the document and asserts it renders to non-empty
// PDF bytes, without a print dialog.

import 'package:buildsmart/data/contractor_seeds.dart' show BudgetCategory;
import 'package:buildsmart/data/repositories/finance_local.dart' show financeRepo;
import 'package:buildsmart/logic/finance_report_pdf.dart';
import 'package:buildsmart/screens/finance_hub_sheets.dart' show openFinanceLeaf;
import 'package:buildsmart/state/pdf_print_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> _loadFonts() async {
  final f = FontLoader('Heebo')
    ..addFont(rootBundle.load('assets/fonts/Heebo-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Heebo-Bold.ttf'));
  await f.load();
}

void main() {
  // ── pure builder: a real, non-empty PDF from the report data ───────────────
  test('buildFinanceReportPdf produces a non-empty PDF document', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final doc = await buildFinanceReportPdf(
      const FinanceReportData(
        budgetTotal: 15000,
        budgetSpent: 9840,
        budgetPct: 66,
        balance: 5160,
        today: '01/01/2026',
        categories: [
          BudgetCategory('חומרי גלם', '🧱', 5000),
          BudgetCategory('עבודה', '👷', 4000),
        ],
      ),
    );
    final bytes = await doc.save();
    expect(bytes, isNotEmpty);
    // A valid PDF starts with the "%PDF" magic header.
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  // ── wiring: tapping הדפסה hands a real doc to the print seam ────────────────
  testWidgets('tapping הדפסה invokes the PDF seam with a non-empty document',
      (t) async {
    await _loadFonts();

    pw.Document? captured;
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          pdfPrintProvider.overrideWithValue((doc, {String name = 'x'}) async {
            captured = doc;
          }),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Heebo', useMaterial3: true),
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => openFinanceLeaf(ctx, 'fin-reports'),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // open reports sheet → the report-view route → tap print.
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.tap(find.text('⬇️ הפק והורד דוח PDF'));
    await t.pumpAndSettle();

    expect(captured, isNull); // not until print is tapped
    await t.tap(find.text('הדפסה'));
    await t.pumpAndSettle();

    // The seam received a real document that renders to non-empty PDF bytes.
    expect(captured, isNotNull);
    final bytes = await captured!.save();
    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  // Guard: the report data the screen feeds the PDF is the live finance repo.
  test('financeRepo backs the report (non-empty categories + budget)', () {
    expect(financeRepo().budgetCategories(), isNotEmpty);
    expect(financeRepo().budgetTotal(), greaterThan(0));
  });
}
