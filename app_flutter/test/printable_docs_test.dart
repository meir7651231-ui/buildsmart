// Pure tests for the printable-document builder (#106/#107 · contract Builder-2).
// Runs on the Dart VM — printable_docs.dart is web-free, so no binding needed.

import 'package:buildsmart/logic/printable_docs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildPrintableHtml', () {
    test('contains the title (heading + footer)', () {
      final html = buildPrintableHtml(
        title: 'טופס 101',
        rows: const [(label: 'שם', value: 'דנה')],
      );
      expect(html, contains('טופס 101'));
      expect(html, contains('dir="rtl"'));
      expect(html, contains('מסמך דיגיטלי — BuildSmart · טופס 101'));
    });

    test('contains a non-empty row value', () {
      final html = buildPrintableHtml(
        title: 'דוח',
        rows: const [(label: 'שם מלא', value: 'דנה כהן')],
      );
      expect(html, contains('דנה כהן'));
      expect(html, contains('שם מלא'));
    });

    test('SKIPS a row whose value is empty', () {
      final html = buildPrintableHtml(
        title: 'דוח',
        rows: const [
          (label: 'שם', value: 'דנה'),
          (label: 'כתובת', value: ''),
        ],
      );
      expect(html, contains('דנה'));
      // The empty row's label must not be emitted.
      expect(html, isNot(contains('כתובת')));
    });

    test('escapes a value containing <', () {
      final html = buildPrintableHtml(
        title: 'דוח',
        rows: const [(label: 'הערה', value: 'a < b & "c"')],
      );
      expect(html, contains('a &lt; b &amp; &quot;c&quot;'));
      // The raw, unescaped injection must not survive.
      expect(html, isNot(contains('a < b & "c"')));
    });

    test('includes <img when a signature data-URL is passed', () {
      const sig = 'data:image/png;base64,AAAA';
      final html = buildPrintableHtml(
        title: 'דוח',
        rows: const [(label: 'שם', value: 'דנה')],
        signatureDataUrl: sig,
      );
      expect(html, contains('<img'));
      expect(html, contains(sig));
      expect(html, contains('חתימה'));
    });

    test('includes NO <img when signature data-URL is null', () {
      final html = buildPrintableHtml(
        title: 'דוח',
        rows: const [(label: 'שם', value: 'דנה')],
      );
      expect(html, isNot(contains('<img')));
    });

    test('renders the declaration paragraph when provided', () {
      final html = buildPrintableHtml(
        title: 'דוח',
        rows: const [(label: 'שם', value: 'דנה')],
        declaration: 'אני מצהיר/ה כי הפרטים נכונים.',
      );
      expect(html, contains('אני מצהיר/ה כי הפרטים נכונים.'));
    });
  });
}
