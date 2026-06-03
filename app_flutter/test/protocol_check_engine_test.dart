// Mirror of tool/protocol_check.dart's built-in self-test, expressed as a
// flutter_test so the protocol content engine is also exercised by
// `flutter test` (and therefore by gates 31/32/94 and CI).
//
// The authoritative tests live in the engine's --self-test (runnable without
// the test package). This file imports the SAME pure functions and asserts the
// headline cases — most importantly the MSYS-class regressions (emoji +
// antipattern recurrence) that the old bash greps silently missed.
//
// NOTE: importing a file under tool/ from test/ is fine — it's plain Dart with
// no entrypoint side effects (main() only runs when executed directly).

import 'package:flutter_test/flutter_test.dart';

import '../tool/protocol_check.dart';

String added(String content) => '+++ b/x\n+$content';

void main() {
  group(
    'MSYS-class regressions (the bug class this engine exists to kill)',
    () {
      test('gate64 catches invented emoji deterministically', () {
        expect(gateNoInventedEmoji(added('Text("🎯 target")')), isNotEmpty);
        expect(gateNoInventedEmoji(added('Text("🏠 home")')), isEmpty);
      });

      test('gate103 catches a recorded antipattern recurring in code', () {
        const stuckLog = r'''
ANTIPATTERN: greaterThan\(0\)
ANTIPATTERN[hook]: grep -cvE.*\|\| echo 0
ANTIPATTERN-EXAMPLE: ignored
''';
        final dartHit = gateAntipatternRecurrence(
          stuckLog: stuckLog,
          dartAdded: ['expect(x, greaterThan(0));'],
          hookAdded: const [],
        );
        expect(dartHit, hasLength(1));
        expect(dartHit.first.gateId, '103');

        final hookHit = gateAntipatternRecurrence(
          stuckLog: stuckLog,
          dartAdded: const [],
          hookAdded: [r'C=$(grep -cvE "x" f || echo 0)'],
        );
        expect(hookHit, hasLength(1));

        expect(
          gateAntipatternRecurrence(
            stuckLog: stuckLog,
            dartAdded: ['expect(x, equals(3));'],
            hookAdded: const [],
          ),
          isEmpty,
        );
      });

      test('gate103 ignores ANTIPATTERN-EXAMPLE lines', () {
        const stuckLog = 'ANTIPATTERN-EXAMPLE: [regex placeholder]';
        expect(parseAntipatterns(stuckLog), isEmpty);
      });
    },
  );

  group('content gates', () {
    test(
      'gate52 secrets: catches literal, allows regex-named, ignores short',
      () {
        expect(
          gateNoSecrets(added('const apiKey = "abcdef0123456789xyz";')),
          isNotEmpty,
        );
        expect(
          gateNoSecrets(added('final passwordRegex = "abcdef0123456789xyz";')),
          isEmpty,
        );
        expect(gateNoSecrets(added('const token = "short";')), isEmpty);
      },
    );

    test('gate46 dark surface', () {
      expect(gateNoDarkSurface(added('color: Color(0xFF111111),')), isNotEmpty);
      expect(gateNoDarkSurface(added('color: Color(0xFFFFFFFF),')), isEmpty);
    });

    test('gate48 print vs debugPrint vs comment', () {
      expect(gateNoPrint(added('  print("x");')), isNotEmpty);
      expect(gateNoPrint(added('  debugPrint("x");')), isEmpty);
      expect(gateNoPrint(added('  // print("x");')), isEmpty);
    });

    test('gate114 kLipskeyCatalog vs kCatalogProducts', () {
      expect(
        gateNoKLipskeyInUi(added('var p = kLipskeyCatalog.first;')),
        isNotEmpty,
      );
      expect(
        gateNoKLipskeyInUi(added('var p = kCatalogProducts.first;')),
        isEmpty,
      );
    });

    test('RTL family 62/63/65', () {
      expect(
        gateNoHardLeftRight(added('padding: EdgeInsets.only(left: 8),')),
        isNotEmpty,
      );
      expect(
        gateNoHardLeftRight(
          added('padding: EdgeInsetsDirectional.only(start: 8),'),
        ),
        isEmpty,
      );
      expect(
        gateNoTextAlignLR(added('textAlign: TextAlign.left,')),
        isNotEmpty,
      );
      expect(
        gateNoTextDirectionLtr(added('textDirection: TextDirection.ltr,')),
        isNotEmpty,
      );
      expect(
        gateNoTextDirectionLtr(added('Bidi.isolate(TextDirection.ltr)')),
        isEmpty,
      );
    });

    test('gate50 dart:html / gate28 local uri', () {
      expect(gateNoDartHtml(added("import 'dart:html';")), isNotEmpty);
      expect(gateNoLocalUri(added("const p = 'file:///x';")), isNotEmpty);
    });

    test('gitignore guards 70/97', () {
      expect(gateGitignoreSecretsGuard('--- a/.gitignore\n-.env'), isNotEmpty);
      expect(gateGitignoreNoHideClaude(added('.claude/')), isNotEmpty);
    });
  });

  group('registry parity (gate reg)', () {
    const tsv =
        'id\tg\tn\ts\tt\ttr\te\tstatus\td\n'
        '1\tg\tn\terr\talways\tcheap\tbash\tenforced\td\n'
        '2\tg\tn\terr\talways\tcheap\tbash\tmoved\td\n'
        '3\tg\tn\terr\talways\tcheap\tbash\tenforced\td\n';

    test('parses enforced ids only', () {
      final ids = registryEnforcedIds(tsv);
      expect(ids, {'1', '3'});
    });

    test('registryDiff detects both directions of drift', () {
      final clean = registryDiff({'1', '3'}, {'1', '3'});
      expect(clean.missingFromCode, isEmpty);
      expect(clean.missingFromRegistry, isEmpty);

      final drift = registryDiff({'1', '9'}, {'1', '3'});
      expect(drift.missingFromCode, contains('3'));
      expect(drift.missingFromRegistry, contains('9'));
    });
  });
}
