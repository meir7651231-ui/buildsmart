// Roadmap step 86 — i18n scaffold guard.
//
// Verifies the curated SmartProduct card string palette
// (`lib/l10n/smart_card_strings.dart`) is:
//   1. fully populated (no empty constants),
//   2. duplicate-free (each value is unique), and
//   3. grounded in the real card UI — every value (except a small explicit
//      exempt set) is currently rendered somewhere in
//      `lib/screens/catalog_screen.dart`. This proves the scaffold lists REAL
//      strings, not invented ones, so the future i18n pass can find their
//      call sites by literal search.

import 'dart:io';

import 'package:buildsmart/l10n/smart_card_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartCardStringsHe (i18n scaffold)', () {
    test('no constant is empty or whitespace-only', () {
      expect(SmartCardStringsHe.all, isNotEmpty,
          reason: 'curated list must contain at least one entry');
      for (final s in SmartCardStringsHe.all) {
        expect(s.trim().isNotEmpty, isTrue,
            reason: 'empty/whitespace-only entry in SmartCardStringsHe.all: '
                '"$s"');
      }
    });

    test('no two constants share the same value', () {
      final list = SmartCardStringsHe.all;
      final set = list.toSet();
      expect(set.length, equals(list.length),
          reason: 'duplicate value in SmartCardStringsHe.all — every entry '
              'must be a distinct label');
    });

    test('every non-exempt value appears in lib/screens/catalog_screen.dart',
        () {
      final file = File('lib/screens/catalog_screen.dart');
      expect(file.existsSync(), isTrue,
          reason: 'expected to find lib/screens/catalog_screen.dart relative '
              'to the package root');
      final src = file.readAsStringSync();
      final missing = <String>[];
      for (final value in SmartCardStringsHe.all) {
        if (SmartCardStringsHe.screenContainmentExempt.contains(value)) {
          continue;
        }
        if (!src.contains(value)) {
          missing.add(value);
        }
      }
      expect(missing, isEmpty,
          reason: 'the following curated strings are NOT present in '
              'catalog_screen.dart (either add them to the exempt set or '
              'verify the literal): $missing');
    });
  });
}
