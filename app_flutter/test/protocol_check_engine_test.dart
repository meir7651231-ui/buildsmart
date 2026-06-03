// flutter_test mirror of the protocol content engine's v3 regression suite, so
// the engine is also exercised by `flutter test` (gates 31/32/94 + CI).
//
// The authoritative tests live in the engine's --self-test (runnable without the
// `test` package). This file imports the SAME pure functions and asserts the
// headline v3 closes: semantic color, name-agnostic / split secrets, emoji
// allowlist, RTL-as-ERR, persistence-key quote/interp, kLipskey alias, print
// sinks, runtime registry parity + malformed-tsv, path scoping, tree mode.

import 'package:flutter_test/flutter_test.dart';

import '../tool/protocol_check.dart';

String added(String content) => '+++ b/x\n+$content';

void main() {
  group('R4 colors — semantic luminance, surface-scoped', () {
    test('legacy dark-surface token fires (upper & lower case)', () {
      expect(
        gateNoDarkSurface(added('color: const Color(0xFF111111),')),
        isNotEmpty,
      );
      expect(
        gateNoDarkSurface(added('color: const Color(0xff111111),')),
        isNotEmpty,
      );
    });
    test('fromARGB / fromRGBO / HSL dark BACKGROUND fires', () {
      expect(
        gateNoDarkSurface(
          added('backgroundColor: Color.fromARGB(255, 17, 17, 17),'),
        ),
        isNotEmpty,
      );
      expect(
        gateNoDarkSurface(
          added('Container(color: Color.fromRGBO(20, 20, 20, 1.0)),'),
        ),
        isNotEmpty,
      );
      expect(
        gateNoDarkSurface(
          added(
            'BoxDecoration(color: HSLColor.fromAHSL(1, 0, 0, 0.05).toColor())',
          ),
        ),
        isNotEmpty,
      );
    });
    test('dark TEXT ink is NOT a dark surface (false-positive guard)', () {
      expect(
        gateNoDarkSurface(added('style: TextStyle(color: Color(0xFF1A1A1A)),')),
        isEmpty,
      );
      expect(
        gateNoDarkSurface(added('backgroundColor: const Color(0xFFFFFFFF),')),
        isEmpty,
      );
    });
    test('lowercase dark ColoredBox fires', () {
      expect(
        gateNoDarkColoredBox(added('ColoredBox(color: Color(0xff121212)),')),
        isNotEmpty,
      );
    });
  });

  group('R4 secrets — fingerprint + entropy + split literals', () {
    test('provider fingerprints fire', () {
      expect(
        gateNoSecrets(added('const k = "AKIAIOSFODNN7EXAMPLE1";')),
        isNotEmpty,
      );
      expect(
        gateNoSecrets(added('var g = "AIzaSyA1234567890abcdefghijklmnop";')),
        isNotEmpty,
      );
      expect(
        gateNoSecrets(added('final t = "ghp_0123456789abcdefghijABCDEF";')),
        isNotEmpty,
      );
      expect(
        gateNoSecrets(added('"-----BEGIN RSA PRIVATE KEY-----"')),
        isNotEmpty,
      );
    });
    test('name-agnostic high-entropy value fires', () {
      expect(
        gateNoSecrets(added('const q = "Zx9Kq2Lm8Pw5Rt7Yv3Bn6Hc1Df4";')),
        isNotEmpty,
      );
    });
    test('split / concatenated secret is reconstructed and fires', () {
      expect(
        gateNoSecrets(added('const k = "AKIA" "IOSFODNN7" "EXAMPLE1";')),
        isNotEmpty,
      );
      expect(
        gateNoSecrets(added('const k = "AKIAIOSFOD" + "NN7EXAMPLE1";')),
        isNotEmpty,
      );
    });
    test('path / id / asset / regex-named values do NOT fire', () {
      expect(gateNoSecrets(added("id: 'drainage.traps.floor',")), isEmpty);
      expect(
        gateNoSecrets(added("imageAsset: 'assets/lipskey/x/217861.jpeg',")),
        isEmpty,
      );
      expect(
        gateNoSecrets(added('final passwordRegex = "aaaaaaaaaaaaaaaaaaaa";')),
        isEmpty,
      );
      expect(gateNoSecrets(added('const label = "submit";')), isEmpty);
    });
  });

  group('R4 emoji — allowlist over the legacy set', () {
    test(
      'legacy emoji allowed; non-legacy flagged (incl. escape & modifier)',
      () {
        expect(gateNoInventedEmoji(added('Text("🏠 home")')), isEmpty);
        expect(gateNoInventedEmoji(added('Text("🦄 unicorn")')), isNotEmpty);
        expect(gateNoInventedEmoji(added(r'Text("\u{1F984} x")')), isNotEmpty);
        expect(
          gateNoInventedEmoji(added('Text("\u{2699}\u{FE0F} settings")')),
          isEmpty,
        );
      },
    );
  });

  group('R4 RTL family — now ERR, fromLTRB, ASCII multiply', () {
    test('62 EdgeInsets.only/fromLTRB ERR; Directional ok', () {
      expect(
        gateNoHardLeftRight(
          added('padding: EdgeInsets.only(left: 8),'),
        ).where((f) => f.sev == Sev.err),
        isNotEmpty,
      );
      expect(
        gateNoHardLeftRight(added('padding: EdgeInsets.fromLTRB(8,0,4,0),')),
        isNotEmpty,
      );
      expect(
        gateNoHardLeftRight(
          added('padding: EdgeInsetsDirectional.only(start: 8),'),
        ),
        isEmpty,
      );
    });
    test('63 TextAlign.left ERR; 65 ltr not bypassed by // LTR comment', () {
      expect(
        gateNoTextAlignLR(
          added('textAlign: TextAlign.left,'),
        ).where((f) => f.sev == Sev.err),
        isNotEmpty,
      );
      expect(
        gateNoTextDirectionLtr(
          added('textDirection: TextDirection.ltr, // LTR override'),
        ),
        isNotEmpty,
      );
      expect(
        gateNoTextDirectionLtr(added('Bidi.isolate(TextDirection.ltr)')),
        isEmpty,
      );
    });
    test('95 ASCII x multiply fires', () {
      expect(gateNumberIsolate(added('Text("מידה 30x40")')), isNotEmpty);
    });
  });

  group('R4 persistence key / kLipskey / print', () {
    test('73 both quote styles + interpolation/concat', () {
      expect(gatePersistenceKey(added("const k = 'bs.cart.v1';")), isEmpty);
      expect(gatePersistenceKey(added('const k = "bs.cart.v1";')), isEmpty);
      expect(
        gatePersistenceKey(added("const k = 'bs.saved_projects.v1';")),
        isEmpty,
      );
      expect(gatePersistenceKey(added("const k = 'bs.Bad.vX';")), isNotEmpty);
      expect(
        gatePersistenceKey(added("final k = 'bs.cart.v\$n';")),
        isNotEmpty,
      );
    });
    test('114 symbol + alias, but type-only import is allowed', () {
      expect(
        gateNoKLipskeyInUi(added('final p = kLipskeyCatalog.first;')),
        isNotEmpty,
      );
      expect(
        gateNoKLipskeyInUi(
          '+++ b/x\n'
          "+import '../data/lipskey_catalog.dart' as lk;\n"
          '+final p = lk.kLipskeyCatalog.first;',
        ),
        isNotEmpty,
      );
      expect(
        gateNoKLipskeyInUi(
          '+++ b/x\n'
          "+import '../data/lipskey_catalog.dart';\n"
          '+final p = kCatalogProducts.first;',
        ),
        isEmpty,
      );
    });
    test(
      '48 print sinks: print/stdout/stderr/developer.log; debugPrint ok',
      () {
        expect(gateNoPrint(added('  print("d");')), isNotEmpty);
        expect(gateNoPrint(added('  stdout.write("d");')), isNotEmpty);
        expect(gateNoPrint(added('  developer.log("d");')), isNotEmpty);
        expect(gateNoPrint(added('  debugPrint("d");')), isEmpty);
        expect(gateNoPrint(added('  // print("d");')), isEmpty);
        expect(gateNoPrint(added('  final s = "please print this";')), isEmpty);
      },
    );
  });

  group('R6 registry — runtime parity + malformed rows FAIL', () {
    const tsv =
        'id\tg\tn\ts\tt\ttr\te\tstatus\td\n'
        '1\tg\tn\terr\talways\tcheap\tbash\tenforced\td\n'
        '2\tg\tn\terr\talways\tcheap\tbash\tmoved\td\n'
        '3\tg\tn\terr\talways\tcheap\tbash\tenforced\td\n';
    test('parses enforced only; no errors on good tsv', () {
      final r = parseRegistry(tsv);
      expect(r.enforced, {'1', '3'});
      expect(r.errors, isEmpty);
    });
    test('a commented-out gate (missing from runtime) is flagged', () {
      expect(registryDiff({'1'}, {'1', '3'}).missingFromCode, contains('3'));
    });
    test('malformed rows FAIL (cols / blank id / status / duplicate)', () {
      expect(parseRegistry('x\tonly\ttwo').errors, isNotEmpty);
      expect(
        parseRegistry('\tg\tn\terr\talways\tcheap\tbash\tenforced\td').errors,
        isNotEmpty,
      );
      expect(
        parseRegistry('9\tg\tn\terr\talways\tcheap\tbash\tBOGUS\td').errors,
        isNotEmpty,
      );
      expect(
        parseRegistry(
          '1\tg\tn\te\ta\tc\tb\tenforced\td\n'
          '1\tg\tn\te\ta\tc\tb\tenforced\td',
        ).errors,
        isNotEmpty,
      );
    });
  });

  group('R2 tree mode + R4 path scoping', () {
    test(
      'split secret caught in a lib post-image; exempt test file ignored',
      () {
        expect(
          runTreeGates(
            files: {
              'app_flutter/lib/data/k.dart':
                  'const k = "AKIA" "IOSFODNN7" "EXAMPLE1";',
            },
          ).any((f) => f.gateId == '52'),
          isTrue,
        );
        expect(
          runTreeGates(
            files: {
              'app_flutter/test/x_test.dart':
                  'const k = "AKIAIOSFODNN7EXAMPLE1";',
            },
          ),
          isEmpty,
        );
      },
    );
    test('content gates are scoped away from tests via runAllContentGates', () {
      expect(
        runAllContentGates(
          diff: added('const k = "AKIAIOSFODNN7EXAMPLE1";'),
          names: ['app_flutter/test/x_test.dart'],
        ),
        isEmpty,
      );
      expect(
        runAllContentGates(
          diff: added('const k = "AKIAIOSFODNN7EXAMPLE1";'),
          names: ['app_flutter/lib/data/x.dart'],
        ),
        isNotEmpty,
      );
    });
  });

  group('preserved v2 behavior (lose NO protection)', () {
    test('antipattern recurrence + gitignore guards + manual container', () {
      const stuckLog = r'ANTIPATTERN: greaterThan\(0\)';
      expect(
        gateAntipatternRecurrence(
          stuckLog: stuckLog,
          dartAdded: ['expect(x, greaterThan(0));'],
          hookAdded: const [],
        ),
        hasLength(1),
      );
      expect(gateGitignoreSecretsGuard('--- a/.gitignore\n-.env'), isNotEmpty);
      expect(gateGitignoreNoHideClaude(added('.claude/')), isNotEmpty);
      expect(
        gateNoManualContainer(added('final c = ProviderContainer();')),
        isNotEmpty,
      );
      expect(gateNoDartHtml(added("import 'dart:html';")), isNotEmpty);
      expect(gateNoLocalUri(added("const p = 'file:///x';")), isNotEmpty);
    });
  });
}
