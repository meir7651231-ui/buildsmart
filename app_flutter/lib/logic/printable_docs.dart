// Printable-document builder (#106/#107 · Wave-3 contract Builder-2) — PURE,
// web-free, VM-testable.
//
// Builds a self-contained RTL HTML document (heading + label/value table +
// optional declaration + optional signature image + footer) for the worker
// forms (101 / חופשה / מחלה). NO flutter UI imports, NO package:web here — the
// browser print itself lives behind the conditional import in doc_print.dart,
// so this body stays a pure string builder that compiles + unit-tests on the
// Dart VM (mirrors logic/input_validators.dart).

/// HTML-escapes the five entity-significant characters so a user-supplied value
/// can never break out of an attribute or inject markup (`&` first, so the
/// replacements it produces are not re-escaped).
String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// A self-contained, A4-friendly RTL `<html dir="rtl">` document for printing or
/// saving a worker form as PDF.
///
/// - [title] is the heading and is woven into the footer.
/// - [rows] render as a two-column (label/value) table; a row whose [value] is
///   empty is SKIPPED (no fabricated blanks — honest empty).
/// - [declaration], when non-empty, renders as a paragraph above the signature.
/// - [signatureDataUrl], when non-null, adds a `חתימה:` line + an `<img>` of the
///   data-URL (omitted entirely when null).
///
/// Every dynamic value is HTML-escaped. Dependency-free by design.
String buildPrintableHtml({
  required String title,
  required List<({String label, String value})> rows,
  String? signatureDataUrl,
  String? declaration,
}) {
  final b = StringBuffer();
  final safeTitle = _esc(title);

  final rowsHtml = StringBuffer();
  for (final r in rows) {
    if (r.value.isEmpty) continue; // skip empty value — no fabricated blanks
    rowsHtml
      ..write('<tr><th>')
      ..write(_esc(r.label))
      ..write('</th><td>')
      ..write(_esc(r.value))
      ..write('</td></tr>');
  }

  b.write('<!doctype html>');
  b.write('<html dir="rtl" lang="he"><head><meta charset="utf-8">');
  b.write('<meta name="viewport" content="width=device-width, '
      'initial-scale=1">');
  b.write('<title>');
  b.write(safeTitle);
  b.write('</title><style>');
  b.write('@page{size:A4;margin:18mm}');
  b.write('*{box-sizing:border-box}');
  b.write('body{direction:rtl;text-align:right;'
      'font-family:Arial,"Segoe UI",sans-serif;color:#1a1a1a;'
      'margin:0;padding:24px;line-height:1.5}');
  b.write('h1{font-size:22px;margin:0 0 16px;'
      'border-bottom:2px solid #1a1a1a;padding-bottom:8px}');
  b.write('table{width:100%;border-collapse:collapse;margin:0 0 16px}');
  b.write('th,td{border:1px solid #ccc;padding:8px 10px;'
      'text-align:right;vertical-align:top;font-size:14px}');
  b.write('th{background:#f3f3f3;width:38%;font-weight:600}');
  b.write('.declaration{margin:16px 0;padding:10px 12px;'
      'background:#f7f7f7;border-radius:6px;font-size:14px}');
  b.write('.signature{margin:16px 0}');
  b.write('.signature .label{font-weight:600;margin-bottom:6px}');
  b.write('.signature img{max-width:280px;height:auto;'
      'border:1px solid #ccc;border-radius:6px;background:#fff}');
  b.write('footer{margin-top:24px;padding-top:8px;'
      'border-top:1px solid #ccc;color:#777;font-size:11px}');
  b.write('</style></head><body>');

  b.write('<h1>');
  b.write(safeTitle);
  b.write('</h1>');

  b.write('<table>');
  b.write(rowsHtml.toString());
  b.write('</table>');

  if (declaration != null && declaration.isNotEmpty) {
    b.write('<p class="declaration">');
    b.write(_esc(declaration));
    b.write('</p>');
  }

  if (signatureDataUrl != null) {
    b.write('<div class="signature"><div class="label">חתימה:</div>');
    b.write('<img src="');
    b.write(_esc(signatureDataUrl));
    b.write('" alt="חתימה"/></div>');
  }

  b.write('<footer>מסמך דיגיטלי — BuildSmart · ');
  b.write(safeTitle);
  b.write('</footer>');

  b.write('</body></html>');
  return b.toString();
}
