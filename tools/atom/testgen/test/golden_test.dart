// Golden — the test-generator run on the contractor-home graph must reproduce
// the frozen fixture at test/golden/contractor-home_generated_test.dart
// byte-for-byte, at the spec anchors (the smartTree ST-3 wiring/hide/verb tests).
//
// The companion guarantee — that those generated tests actually PASS against
// smart_home_screen.dart — is enforced by the separate CI job that runs
// `flutter test app_flutter/test/generated/` (opt-in, non-blocking). Here we pin
// the GENERATOR's output shape.
import 'dart:io';

import 'package:atom_testgen/testgen.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _rel = p.canonicalize(p.join(Directory.current.path, '../../..'));
final _graph =
    p.join(_rel, 'tools/atom/decompose/test/golden/contractor-home');
final _goldenFile = p.join(Directory.current.path,
    'test/golden/contractor-home_generated_test.dart.txt');

void main() {
  final present = Directory(_graph).existsSync();

  group('testgen · contractor-home golden', () {
    test('the anchor graph is reachable', () {
      expect(present, isTrue, reason: 'run `dart test` from tools/atom/testgen');
    }, skip: present ? false : 'graph not found from cwd');

    if (!present) return;

    final r = generateForScreen(_graph)!;

    test('generates the smartTree ST-3 anchors — wiring · hide · verb-toast', () {
      final c = r.contents;
      // registry-ID → wired
      expect(c, contains('wired · _SmartTreeRow · "הוסף לסל" [smart_home_screen.add_to_cart]'));
      // CfgVisible → hide
      expect(c, contains('hide · _SmartTreeRow · smart_home_screen.add_to_cart → gone when hidden'));
      // verb → effect (add-to-cart write + toast, observed via the toast)
      expect(c, contains('tap "הוסף לסל" → toast "נוסף לסל"'));
      // formula → input/output (priceLabel: null → constant · 1234 → ₪1,234)
      expect(c, contains("expect(f(null), 'מחיר לפי ספק');"));
      expect(c, contains("expect(f(1234), '₪1,234');"));
      // all 6 registry ids are wired
      for (final id in const [
        'smart_home_screen.add_to_cart',
        'smart_home_screen.workpath_badge',
        'smart_home_screen.workpath_title',
        'smart_home_screen.workpath_sub',
        'smart_home_screen.install_title',
        'smart_home_screen.install_sub',
      ]) {
        expect(c, contains('[$id]'), reason: '$id has a wired test');
      }
    });

    test('14 tests · preview/const-gated atoms skipped (not renderable)', () {
      expect(r.testCount, 14);
      // The preview + gated super-finder atoms produce NO wired test.
      expect(r.contents, isNot(contains('_SuperFinderHero')));
      expect(r.contents, isNot(contains('_SuperFinderOpen')));
    });

    test('rendered file matches the frozen golden byte-for-byte', () {
      expect(File(_goldenFile).readAsStringSync(), r.contents,
          reason: 'generator drifted — regenerate test/golden/');
    });
  });
}
