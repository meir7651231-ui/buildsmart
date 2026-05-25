// Headless catalog regression (צעד 54) — runs the in-app `testCatalog()` suite
// under `flutter test` so CI gates every catalog change, independent of the UI
// widget tests. Mirrors the "קטלוג" pill in BS → מנהל → ניהול → בדיקות רגרסיה.
import 'package:buildsmart/test_harness/tests/catalog.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final results = testCatalog();

  test('catalog regression suite produced results', () {
    expect(results, isNotEmpty);
  });

  for (final r in results) {
    group('${r.category.he} · ${r.label}', () {
      for (final c in r.checks) {
        test(c.name, () {
          expect(
            c.pass,
            isTrue,
            reason: [
              if (c.expected != null) 'expected: ${c.expected}',
              if (c.got != null) 'got: ${c.got}',
              if (c.detail != null) 'detail: ${c.detail}',
            ].join(' · '),
          );
        });
      }
    });
  }
}
