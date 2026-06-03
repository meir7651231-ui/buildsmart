// flutter_test mirror of the protocol content engine's v3 regression suite, so
// the engine is also exercised by `flutter test` (gates 31/32/94 + CI).
//
// The authoritative tests live in the engine's --self-test (runnable without the
// `test` package). This file imports the SAME pure functions and asserts the
// headline v3 closes: semantic color, name-agnostic / split secrets, emoji
// allowlist, RTL-as-ERR, persistence-key quote/interp, kLipskey alias, print
// sinks, runtime registry parity + malformed-tsv, path scoping, tree mode.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../tool/protocol_check.dart';

String added(String content) => '+++ b/x\n+$content';

/// Added hunk with a REAL `+++ b/<path>` header (F1 per-file scoping resolves
/// scope from the diff itself, like `git diff`).
String addedIn(String path, String content) => '+++ b/$path\n+$content';

/// Multiple files concatenated into one diff (F1 cross-file scoping tests).
String addedFiles(List<List<String>> files) => files
    .map(
      (f) => '+++ b/${f[0]}\n${f[1].split('\n').map((l) => '+$l').join('\n')}',
    )
    .join('\n');

void main() {
  group('R4 colors — semantic luminance, surface-scoped', () {
    test(
      'legacy dark-surface token fires in a SURFACE context (upper & lower)',
      () {
        // F3 (v5): the 0xFF111111 token fires ONLY in a surface context (a bare
        // `color:` is ambiguous ink/surface — see the ink guard test below).
        expect(
          gateNoDarkSurface(added('backgroundColor: const Color(0xFF111111),')),
          isNotEmpty,
        );
        expect(
          gateNoDarkSurface(
            added('Container(color: const Color(0xff111111)),'),
          ),
          isNotEmpty,
        );
      },
    );
    test('F3: the REAL 0xFF111111 as TextStyle ink is NOT a dark surface', () {
      // Honest assertion of the EXACT 0xFF111111 the v4 mirror laundered.
      expect(
        gateNoDarkSurface(
          added('style: const TextStyle(color: Color(0xFF111111)),'),
        ),
        isEmpty,
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
          diff: addedIn(
            'app_flutter/test/x_test.dart',
            'const k = "AKIAIOSFODNN7EXAMPLE1";',
          ),
          names: ['app_flutter/test/x_test.dart'],
        ),
        isEmpty,
      );
      expect(
        runAllContentGates(
          diff: addedIn(
            'app_flutter/lib/data/x.dart',
            'const k = "AKIAIOSFODNN7EXAMPLE1";',
          ),
          names: ['app_flutter/lib/data/x.dart'],
        ),
        isNotEmpty,
      );
    });
  });

  // ── v4 residual closes (mirror of the engine --self-test v4 block) ──
  group('v5 C1/N1/F2 — secret shape; hex DIGESTS are NOT secrets', () {
    test('hex secret fires WHEN named a credential; base64 blob fires', () {
      // v5 reconciliation (N1/F2): a CONTEXTLESS 40-hex literal is git-SHA-shaped
      // and is NOT a secret; it fires when NAMED as a credential.
      expect(
        gateNoSecrets(
          added(
            'const apiSecret = "deadbeefcafebabedeadbeefcafebabe12345678";',
          ),
        ),
        isNotEmpty,
      );
      expect(
        gateNoSecrets(
          added(
            'const clientSecret = "DEADBEEFCAFEBABEDEADBEEFCAFEBABE12345678";',
          ),
        ),
        isNotEmpty,
      );
      expect(
        gateNoSecrets(
          added('const e = "aGVsbG93b3JsZHRoaXNpc2Fsb25nYmFzZTY0c3RyaW5n";'),
        ),
        isNotEmpty,
      );
    });
    test('N1: the all-zero 40-hex SHA is NOT a secret (engine clean-tree)', () {
      expect(
        gateNoSecrets(
          added(
            r'''if [[ "$BEFORE" != "0000000000000000000000000000000000000000" ]]; then''',
          ),
        ),
        isEmpty,
      );
    });
    test('F2: git sha1 / md5 / sha256 digests are NOT secrets', () {
      expect(
        gateNoSecrets(
          added('const buildSha = "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3";'),
        ),
        isEmpty,
      );
      expect(
        gateNoSecrets(
          added('const cacheKey = "5d41402abc4b2a76b9719d911017c592";'),
        ),
        isEmpty,
      );
      expect(
        gateNoSecrets(
          added(
            'const assetHash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";',
          ),
        ),
        isEmpty,
      );
    });
    test('A1: base32 TOTP/2FA secrets ARE caught', () {
      expect(
        gateNoSecrets(added('const totp = "JBSWY3DPEHPK3PXP";')),
        isNotEmpty,
      );
      expect(
        gateNoSecrets(
          added('const seed = "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ";'),
        ),
        isNotEmpty,
      );
    });
    test('short SKU / persistence key do not fire', () {
      expect(gateNoSecrets(added('const sku = "94517251";')), isEmpty);
      expect(gateNoSecrets(added('const k = "bs.cart.v1";')), isEmpty);
    });
  });

  group('v4 F2 — SRI / integrity digests are not secrets', () {
    test(
      'sha384- SRI and integrity: context allowlisted; fingerprint still wins',
      () {
        expect(
          gateNoSecrets(
            added(
              'const s = "sha384-oqVuAfXRKap7fdgcCY5uykM6R9GqQ8KuxyHNQlGYl1kPzQho1wx4JwY8wC";',
            ),
          ),
          isEmpty,
        );
        expect(
          gateNoSecrets(
            added(
              "const x = {'integrity': '47DEQpj8HBSaTImW5JCeuQeRkm5NMpJWZG3hSuFU'};",
            ),
          ),
          isEmpty,
        );
        expect(
          gateNoSecrets(
            added("const x = {'integrity': 'AKIAIOSFODNN7EXAMPLE1'};"),
          ),
          isNotEmpty,
        );
      },
    );
  });

  group('v4 C3 — wider --tree extensions', () {
    test(
      'kt/swift/html/css/toml are secret-scannable; secret in .kt caught',
      () {
        expect(isSecretScannablePath('android/app/Main.kt'), isTrue);
        expect(isSecretScannablePath('ios/Runner/AppDelegate.swift'), isTrue);
        expect(isSecretScannablePath('web/index.html'), isTrue);
        expect(isSecretScannablePath('web/style.css'), isTrue);
        expect(isSecretScannablePath('Cargo.toml'), isTrue);
        expect(
          runTreeGates(
            files: {
              'android/Main.kt': 'val apiSecret = "AKIAIOSFODNN7EXAMPLE1"',
            },
          ).any((f) => f.gateId == '52'),
          isTrue,
        );
      },
    );
  });

  group('v4 C4 — print sinks', () {
    test(
      'stdout.add / x=print / log("msg") fire; math.log / log(value) do not',
      () {
        expect(
          gateNoPrint(added('  stdout.add(utf8.encode("x"));')),
          isNotEmpty,
        );
        expect(gateNoPrint(added('  final f = print;')), isNotEmpty);
        expect(gateNoPrint(added('  log("user did the thing");')), isNotEmpty);
        expect(gateNoPrint(added('  final y = math.log(2.0);')), isEmpty);
        expect(gateNoPrint(added('  final z = log(value);')), isEmpty);
        expect(gateNoPrint(added('  catalog.logSomething();')), isEmpty);
      },
    );
  });

  group('v4 C5 — gate65 isolate must be a real context', () {
    test(
      'bare "isolate" substring no longer bypasses; Directionality/Bidi do',
      () {
        expect(
          gateNoTextDirectionLtr(added('final isolate = TextDirection.ltr;')),
          isNotEmpty,
        );
        expect(
          gateNoTextDirectionLtr(
            added('Directionality(textDirection: TextDirection.ltr, child: x)'),
          ),
          isEmpty,
        );
        expect(
          gateNoTextDirectionLtr(added('Bidi.isolate(TextDirection.ltr)')),
          isEmpty,
        );
      },
    );
  });

  group('v4 C6/F3/F4 — colour luminance', () {
    test('grey surfaces fire (C6); ink does not (F3); blue does not (F4)', () {
      expect(
        gateNoDarkSurface(added('backgroundColor: const Color(0xFF2E2E2E),')),
        isNotEmpty,
      );
      expect(
        gateNoDarkSurface(
          added('scaffoldBackgroundColor: const Color(0xFF333333),'),
        ),
        isNotEmpty,
      );
      expect(
        gateNoDarkSurface(added('style: TextStyle(color: Color(0xFF1A1A1A)),')),
        isEmpty,
      );
      expect(
        gateNoDarkSurface(added('backgroundColor: const Color(0xFF0D47A1),')),
        isEmpty,
      );
      expect(
        gateNoDarkColoredBox(added('ColoredBox(color: Color(0xFF0D47A1)),')),
        isEmpty,
      );
      expect(
        gateNoDarkColoredBox(added('ColoredBox(color: Color(0xFF222225)),')),
        isNotEmpty,
      );
    });
  });

  group('v5 E4 — multi-line dark SURFACE (dart-format wrap)', () {
    test('wrapped backgroundColor fires; wrapped INK does not', () {
      expect(
        gateNoDarkSurface(
          '+++ b/x\n'
          '+      return Scaffold(\n'
          '+        backgroundColor:\n'
          '+            const Color(0xFF0A0A0A),\n'
          '+      );',
        ),
        isNotEmpty,
      );
      // Ink wrapped to the next line is NOT a surface (F3 preserved).
      expect(
        gateNoDarkSurface(
          '+++ b/x\n'
          '+      style: const TextStyle(\n'
          '+        color: Color(0xFF111111),\n'
          '+      ),',
        ),
        isEmpty,
      );
    });
    test('wrapped ColoredBox fires; translucent shadow does not (alpha)', () {
      expect(
        gateNoDarkColoredBox(
          '+++ b/x\n'
          '+      return ColoredBox(\n'
          '+        color: Color(0xFF101012),\n'
          '+      );',
        ),
        isNotEmpty,
      );
      // F4 alpha hardening: a translucent shadow black is not a dark surface.
      expect(
        gateNoDarkSurface(
          added(
            'decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x14000000))]),',
          ),
        ),
        isEmpty,
      );
    });
  });

  group('v4 F1 — per-file scoping (no cross-file contamination)', () {
    test('46 not on theme co-committed with screen; 114 not on data/', () {
      expect(
        runAllContentGates(
          diff: addedFiles([
            [
              'app_flutter/lib/theme/app_theme.dart',
              'scaffoldBackgroundColor: isDark ? BsTokens.bgDark : const Color(0xFFF5F6FA),',
            ],
            [
              'app_flutter/lib/screens/home.dart',
              "return Scaffold(body: Text('hi'));",
            ],
          ]),
          names: const [
            'app_flutter/lib/theme/app_theme.dart',
            'app_flutter/lib/screens/home.dart',
          ],
        ).where((f) => f.gateId == '46'),
        isEmpty,
      );
      expect(
        runAllContentGates(
          diff: addedFiles([
            [
              'app_flutter/lib/data/lipskey_catalog.dart',
              'for (final p in kLipskeyCatalog) {}',
            ],
            [
              'app_flutter/lib/screens/home.dart',
              "return Scaffold(body: Text('hi'));",
            ],
          ]),
          names: const [
            'app_flutter/lib/data/lipskey_catalog.dart',
            'app_flutter/lib/screens/home.dart',
          ],
        ).where((f) => f.gateId == '114'),
        isEmpty,
      );
    });
    test('114 STILL fires when the screen file itself uses the symbol', () {
      expect(
        runAllContentGates(
          diff: addedFiles([
            ['app_flutter/lib/data/lipskey_catalog.dart', 'const x = 1;'],
            [
              'app_flutter/lib/screens/home.dart',
              'final p = kLipskeyCatalog.first;',
            ],
          ]),
          names: const [
            'app_flutter/lib/data/lipskey_catalog.dart',
            'app_flutter/lib/screens/home.dart',
          ],
        ).where((f) => f.gateId == '114'),
        isNotEmpty,
      );
    });
  });

  group('v4 C2 — context-line smuggling: 46/54/48/114 in tree mode', () {
    test('48 print + 46 dark surface + 54 ColoredBox fire; 114 is WARN', () {
      expect(
        runTreeGates(
          files: {
            'app_flutter/lib/screens/home.dart': 'void f(){ print("x"); }',
          },
        ).any((f) => f.gateId == '48'),
        isTrue,
      );
      expect(
        runTreeGates(
          files: {
            'app_flutter/lib/screens/home.dart':
                'Widget b()=>Container(color: const Color(0xFF111111));',
          },
        ).any((f) => f.gateId == '46'),
        isTrue,
      );
      final g114 = runTreeGates(
        files: {
          'app_flutter/lib/screens/home.dart':
              'final p = kLipskeyCatalog.first;',
        },
      ).where((f) => f.gateId == '114');
      expect(g114, isNotEmpty);
      expect(g114.every((f) => f.sev == Sev.warn), isTrue);
    });
    test('tree-mode dark-surface does NOT fire on a screen of TEXT ink', () {
      expect(
        runTreeGates(
          files: {
            'app_flutter/lib/screens/home.dart':
                'Text("a", style: TextStyle(color: Color(0xFF1A1A1A)));',
          },
        ).where((f) => f.gateId == '46' || f.gateId == '54'),
        isEmpty,
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

  group('v6 — silent-skip class + slash-laundering + logic-coupled RAN', () {
    test('H1 unquoteGitPath decodes a C-quoted Hebrew path to true UTF-8', () {
      const quoted = '"app_flutter/lib/screens/'
          '\\327\\236\\327\\241\\327\\232.dart"';
      final want = 'app_flutter/lib/screens/'
          '${String.fromCharCodes([0x05DE, 0x05E1, 0x05DA])}.dart';
      expect(unquoteGitPath(quoted), want);
      expect(unquoteGitPath('app_flutter/lib/a.dart'), 'app_flutter/lib/a.dart');
    });

    test('H1 a C-quoted Hebrew .dart header with a secret is CAUGHT', () {
      final diff = '+++ "b/app_flutter/lib/screens/'
          '\\327\\236\\327\\241\\327\\232.dart"\n'
          '+const apiSecret = "AKIAIOSFODNN7EXAMPLE1234567890ABCD";';
      final f = runAllContentGates(
        diff: diff,
        names: const ['app_flutter/lib/screens/x.dart'],
      );
      expect(f.any((x) => x.gateId == '52' && x.sev == Sev.err), isTrue);
    });

    test('H2 a high-bit byte does not throw and the secret is still caught', () {
      final bytes = <int>[
        ...utf8.encode('const k = "AKIAIOSFODNN7EXAMPLE1234567890ABCD";\n'),
        0xE9, // lone Latin-1 byte — invalid as standalone UTF-8
        ...utf8.encode(' tail\n'),
      ];
      final body = utf8.decode(bytes, allowMalformed: true);
      final f = runTreeGates(files: {'app_flutter/web/x.html': body});
      expect(f.any((x) => x.gateId == '52' && x.sev == Sev.err), isTrue);
    });

    test('H4 slash-laundered NAMED credential is CAUGHT', () {
      expect(
        lineHasSecret(
          'const clientSecret = "abcdEFGH1234/ijklMNOP5678/qrstUVWX/CDEFghij9012";',
        ),
        isTrue,
      );
    });

    test('H4 real path/URL with a credential name stays exempt (no FP)', () {
      expect(
        lineHasSecret('const tokenFile = "assets/config/auth_token.json";'),
        isFalse,
      );
      expect(
        lineHasSecret('const authUrl = "https://auth.example.com/oauth/cb";'),
        isFalse,
      );
      expect(
        lineHasSecret('const secretPath = "/etc/app/secrets/key";'),
        isFalse,
      );
    });

    test('H5 --emit-ran is logic-coupled: every canary fires', () {
      expect(emitRanIds().toSet(), kDartEngineGateIds.toSet());
    });
  });

  // ── v8 S1 — AIRTIGHT base64 image exemption (decode-and-scan). HONEST
  //    fixtures: real images DECODE to a valid PNG/JPEG; laundering blobs carry
  //    the magic but hide a secret and must be CAUGHT as ERR. ──
  group('S1 — airtight base64 image exemption (decode-and-scan)', () {
    // REAL 1x1 PNG (decodes; low-entropy IHDR) and a real minimal JPEG.
    const pngReal =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAAHxXEiQAAAA1JREFUeJxiAAAAAP//AwAABgAF';
    const jpgReal =
        '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/2Q==';
    // LAUNDER vectors (the v7 hole): magic-text+secret, magic-bytes+secret,
    // fingerprint-in-decoded-bytes.
    const launderTextPrefix =
        'iVBORw0KGgoktM5SGxdCgFuAfhCmCF7tqhqRCLtcqgHD4pMt0fCC/XCsi1bq2JazoWHXYvkFZfI';
    const launderByteSplice =
        'iVBORw0KGgr0hn60leqiLSid62JtMVSP4OJLjacDaKjrsdBdzeLqN7EoB1C5sflT3rXq4/mmsug=';
    const launderFpInDecoded =
        'iVBORw0KGgpnaHBfYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhQUFBQUFBQUFBQUFBQUFBQUFBQUE=';
    const randomSecret = 'U8JZpDE0iGXlD6gNCFbaEPFjbD0kH8Oool8DklZDOCj2ISaJ';

    // v9 (V9-A) REMOVED the base64-image WARN exemption entirely: ANY literal
    // meeting the base64-blob criteria is now an ERR (move images to assets/),
    // killing the laundering class. These mirror tests are updated from the old
    // v7 WARN expectation to the v9 ERR behavior the shipped engine enforces.
    test('a REAL (decodable) PNG blob is an ERR (v9: no image WARN exemption)', () {
      final f = gateNoSecrets(added('const img = "$pngReal";'));
      expect(f.length, 1);
      expect(f.first.sev, Sev.err);
    });
    test('a REAL (decodable) JPEG blob is an ERR (v9: no image WARN exemption)', () {
      final f = gateNoSecrets(added('const img = "$jpgReal";'));
      expect(f.length, 1);
      expect(f.first.sev, Sev.err);
    });
    test('LAUNDER magic-TEXT-prefix + secret (same blob) is an ERR secret', () {
      // THE HOLE: v7 downgraded this to WARN and shipped it.
      final f = gateNoSecrets(added('const k = "$launderTextPrefix";'));
      expect(f.length, 1);
      expect(f.first.sev, Sev.err);
    });
    test('LAUNDER magic-BYTES + secret splice is an ERR secret', () {
      final f = gateNoSecrets(added('const k = "$launderByteSplice";'));
      expect(f.length, 1);
      expect(f.first.sev, Sev.err);
    });
    test('LAUNDER fingerprint hidden in DECODED bytes is an ERR secret', () {
      final f = gateNoSecrets(added('const k = "$launderFpInDecoded";'));
      expect(f.length, 1);
      expect(f.first.sev, Sev.err);
    });
    test('SPLIT literal "magic" "secret" (joined) is an ERR secret', () {
      final f =
          gateNoSecrets(added('const k = "iVBORw0KGgo" "$randomSecret";'));
      expect(f.isNotEmpty, isTrue);
      expect(f.first.sev, Sev.err);
    });
    test('a random high-entropy secret is STILL an ERR (no loss)', () {
      final f = gateNoSecrets(added('const k = "$randomSecret";'));
      expect(f.length, 1);
      expect(f.first.sev, Sev.err);
    });
    test('naming a secret "imageData" does NOT launder it (still ERR)', () {
      final f = gateNoSecrets(added('const imageData = "$randomSecret";'));
      expect(f.isNotEmpty, isTrue);
      expect(f.first.sev, Sev.err);
    });
    test('a provider-fingerprint secret in an image field still fires', () {
      final f = gateNoSecrets(added('const imageData = "AKIAIOSFODNN7EXAMPLE";'));
      expect(f.isNotEmpty, isTrue);
      expect(f.first.sev, Sev.err);
    });
    test('DX7b dark-surface (gate 46) message names lib/theme/', () {
      final f =
          gateNoDarkSurface(added('backgroundColor: const Color(0xFF111111),'));
      expect(f.isNotEmpty, isTrue);
      expect(f.first.message, contains('lib/theme/'));
    });
    test('DX7b dark ColoredBox (gate 54) message names lib/theme/', () {
      final f = gateNoDarkColoredBox(added('ColoredBox(color: Color(0xFF111111))'));
      expect(f.isNotEmpty, isTrue);
      expect(f.first.message, contains('lib/theme/'));
    });
  });

  // ── V10-A — ReDoS / self-DoS guards (gate 103) ──────────────────────────
  // These RUN under `flutter test`, so the wall-clock kill (guard 3) is proven
  // in the same harness the brief requires (not only via the engine binary).
  group('V10-A ReDoS guards', () {
    test('guard 2: (a+)+\$ is rejected at parse (never compiled)', () {
      final rej = <({String pattern, String reason})>[];
      final aps = parseAntipatterns(r'ANTIPATTERN: (a+)+$', rejected: rej);
      expect(aps, isEmpty);
      expect(rej.length, 1);
    });

    test('guard 3: a poison pattern that SLIPS static detection TIMES OUT '
        '(killed) — does not hang flutter test', () async {
      // `a?^30 a^30` has NO nested group and NO large {N}, so guard 2 misses it,
      // but it ReDoS-hangs Dart's backtracking RegExp. Guard 3 must kill it.
      final pat = ('a?' * 30) + ('a' * 30);
      expect(antipatternCatastrophicReason(pat), isNull,
          reason: 'this shape intentionally slips the static detector');
      final sw = Stopwatch()..start();
      final r = await boundedAnyMatch(pat, ['a' * 29]);
      sw.stop();
      expect(r.timedOut, isTrue, reason: 'runaway scan must be killed');
      expect(r.matched, isFalse);
      // Killed at the 500ms budget (+ isolate spawn); MUST be well under a hang.
      expect(sw.elapsed.inSeconds, lessThan(5));
    });

    test('boundedAnyMatch returns a real match for a safe pattern', () async {
      final r = await boundedAnyMatch('FORBIDDEN', ['x', 'has FORBIDDEN here']);
      expect(r.timedOut, isFalse);
      expect(r.matched, isTrue);
    });

    test('gateAntipatternRecurrenceBounded: poison pattern → WARN, never ERR/hang',
        () async {
      final sw = Stopwatch()..start();
      final f = await gateAntipatternRecurrenceBounded(
        stuckLog: r'ANTIPATTERN: (a+)+$',
        dartAdded: ['const s = "${'a' * 40}";'],
        hookAdded: const [],
      );
      sw.stop();
      expect(sw.elapsed.inSeconds, lessThan(5));
      expect(f.where((x) => x.sev == Sev.err), isEmpty);
      expect(f.where((x) => x.sev == Sev.warn), isNotEmpty);
    });

    test('gateAntipatternRecurrenceBounded: real recurrence still ERRs',
        () async {
      final f = await gateAntipatternRecurrenceBounded(
        stuckLog: 'ANTIPATTERN: FORBIDDEN_X',
        dartAdded: const ['var y = FORBIDDEN_X;'],
        hookAdded: const [],
      );
      expect(f.where((x) => x.gateId == '103' && x.sev == Sev.err), isNotEmpty);
    });
  });

  // ── V10-B — whole-tree scan SKIP class (submodule / symlink / LFS) ───────
  group('V10-B tree-scan skip class', () {
    test('parseTreeEntries exposes 160000 gitlink and 120000 symlink', () {
      final e = parseTreeEntries(
        '100644 blob a\tlib/main.dart\n'
        '160000 commit b\tvendored_sub\n'
        '120000 blob c\tlib/aliased.dart',
      );
      expect(e.length, 3);
      expect(e[1].isGitlink, isTrue);
      expect(e[2].isSymlink, isTrue);
    });
    test('looksLikeLfsPointer detects pointer, ignores normal source', () {
      expect(
        looksLikeLfsPointer(
          'version https://git-lfs.github.com/spec/v1\noid sha256:${'a' * 64}\n',
        ),
        isTrue,
      );
      expect(looksLikeLfsPointer('class A {}\n'), isFalse);
    });
    test('symlinkIsDangerous: scannable name or scannable target', () {
      expect(symlinkIsDangerous('lib/x.dart', '../s.txt'), isTrue);
      expect(symlinkIsDangerous('d/link', '../lib/r.dart'), isTrue);
      expect(symlinkIsDangerous('README.md', 'docs/R.md'), isFalse);
    });
  });
}
