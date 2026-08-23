// The shared CSV kernel — extracted verbatim from company_catalog_import so
// every importer tokenizes identically. The company parser's own suite proves
// byte-identity end-to-end; this pins the primitives directly.

import 'package:buildsmart/data/csv_kernel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCsvRecords', () {
    test('plain rows → cells split on the separator', () {
      final r = parseCsvRecords('a,b,c\n1,2,3\n', ',');
      expect(r.length, 2);
      expect(r[0].cells, ['a', 'b', 'c']);
      expect(r[1].cells, ['1', '2', '3']);
    });

    test('quoted cell keeps the separator and "" unescapes to a literal quote',
        () {
      final r = parseCsvRecords('"a,b","he said ""hi"""\n', ',');
      expect(r.single.cells, ['a,b', 'he said "hi"']);
    });

    test('a newline inside quotes stays in the cell and advances line count',
        () {
      final r = parseCsvRecords('x\n"line1\nline2",y\n', ',');
      expect(r.length, 2);
      expect(r[1].cells, ['line1\nline2', 'y']);
      expect(r[1].line, 2, reason: 'physical 1-based start line');
    });

    test('CRLF and a missing trailing newline both end a record', () {
      final r = parseCsvRecords('a,b\r\nc,d', ',');
      expect(r.length, 2);
      expect(r[1].cells, ['c', 'd']);
    });

    test('a bare quote NOT at cell start is a literal', () {
      final r = parseCsvRecords('מק"ט\n', ',');
      expect(r.single.cells, ['מק"ט']);
    });
  });

  group('header helpers', () {
    test('normHeader strips BOM, trims, lowercases', () {
      expect(normHeader('${kCsvBom}  SKU  '), 'sku');
    });

    test('csvHeaderIndex skips blank + #comment records', () {
      final r = parseCsvRecords('\n# legend\nsku,name\n1,2\n', ',');
      expect(csvHeaderIndex(r), 1,
          reason: 'blank line makes no record; # legend is record 0, skipped');
      expect(r[csvHeaderIndex(r)].cells, ['sku', 'name']);
    });

    test('csvIsBlank / csvIsComment', () {
      expect(csvIsBlank(['   ', '']), isTrue);
      expect(csvIsComment(['  # hi', 'x']), isTrue);
      expect(csvIsComment(['x', '# hi']), isFalse);
    });
  });

  group('tokenizeCsvAutodetect', () {
    const known = {'sku', 'name', 'category'};
    test('semicolon file → picks the ; tokenization', () {
      final r = tokenizeCsvAutodetect('sku;name;category\n1;2;3\n', known);
      expect(r[0].cells, ['sku', 'name', 'category']);
    });

    test('comma file → picks the , tokenization', () {
      final r = tokenizeCsvAutodetect('sku,name,category\n1,2,3\n', known);
      expect(r[0].cells, ['sku', 'name', 'category']);
    });

    test('ambiguous / no known headers → tie falls back to comma', () {
      final r = tokenizeCsvAutodetect('a,b\n1,2\n', known);
      expect(r[0].cells, ['a', 'b']);
    });
  });
}
