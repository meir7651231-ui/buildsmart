// Injectable PDF print/share seam for the finance-hub "הפק והורד דוח PDF" report.
//
// `printing`'s real `Printing.layoutPdf(...)` opens the native/Web print-or-save
// dialog — it cannot run in a unit/widget test (no platform channel / no
// browser), so the report goes through THIS provider instead of calling
// `printing` directly. Production binds it to the real print dialog; tests
// `overrideWithValue` a capturing fake to assert a real, NON-EMPTY `pw.Document`
// is produced — without a print dialog. Mirrors `lib/state/url_launcher_seam.dart`
// and `lib/state/share_seam.dart`.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Hands a built [doc] off to the platform print/save UI under [name].
/// Keeping the contract to the document itself lets a test capture the doc and
/// assert it renders to non-empty bytes (`doc.save()`), and the default is a
/// thin wrapper over `Printing.layoutPdf`.
typedef PdfDocPrinter = Future<void> Function(
  pw.Document doc, {
  String name,
});

/// The default real printer — opens the print/save dialog, rebuilding the bytes
/// from [doc] each time the user changes page format.
Future<void> printDocExternal(pw.Document doc, {String name = 'document'}) async {
  await Printing.layoutPdf(onLayout: (_) => doc.save(), name: name);
}

/// The seam. Production keeps [printDocExternal]; tests override it with a fake
/// that records the document (see `test/finance_pdf_export_test.dart`).
final pdfPrintProvider = Provider<PdfDocPrinter>((_) => printDocExternal);
