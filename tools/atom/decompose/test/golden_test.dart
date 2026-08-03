// Golden test — the decomposer run on smart_home_screen.dart must reproduce the
// committed manual golden at app_flutter/knowledge/screens/contractor-home/,
// byte-for-byte, and hit the spec's registry 6/6 · 8 atoms.
//
// Runs with cwd = the package root (tools/atom/decompose), so the repo files sit
// three levels up. If someone edits smart_home_screen.dart (or the registry) and
// the decomposition drifts, this test fails and the golden must be regenerated:
//   dart run bin/decompose.dart ../../../app_flutter/lib/screens/smart_home_screen.dart \
//     --name contractor-home --registry ../../../app_flutter/lib/state/studio/element_registry.dart \
//     --out ../../../app_flutter/knowledge/screens
import 'dart:io';

import 'package:atom_decompose/decompose.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Repo-relative paths from the package root, made ABSOLUTE (the analyzer's
/// parseFile requires an absolute path). Code inputs come from the live
/// whats-happening tree (per knowledge/AGENT-SOURCES.md); the golden fixture is
/// self-contained in this package (the published knowledge lives on nice-volta).
final _rel = p.canonicalize(p.join(Directory.current.path, '../../..'));
final _pkg = Directory.current.path;
final _source =
    p.join(_rel, 'app_flutter/lib/screens/smart_home_screen.dart');
final _registry =
    p.join(_rel, 'app_flutter/lib/state/studio/element_registry.dart');
final _goldenDir = p.join(_pkg, 'test/golden/contractor-home');

void main() {
  final present = File(_source).existsSync() && File(_registry).existsSync();

  group('atom decomposer · smart_home_screen → contractor-home golden', () {
    test('inputs are reachable from the package root', () {
      expect(present, isTrue,
          reason: 'run `dart test` from tools/atom/decompose (cwd matters)');
    }, skip: present ? false : 'source/registry not found from cwd');

    if (!present) return;

    final d = decompose(_source, _registry, screenName: 'contractor-home');

    // Spec anchor: the screen started at 8 atoms; parallel screen-mgmt slices
    // (s6/s9/s10) added the two super-finder sections and routed the trailing
    // blocks through the dispatch, so the FULL current screen is 10 atoms — a
    // superset, never a subset. Registry stays 6/6 (the new sections use plain
    // Text, no CfgText ids). If the screen shrinks/grows again, update here.
    test('spec anchors — full coverage (10 atoms), one composer, registry 6/6',
        () {
      expect(d.atoms.length, 10);
      expect(d.atoms.where((a) => a.role == 'composer').length, 1);
      expect(d.atoms.first.name, 'SmartHomeBody');
      expect(d.registry.total, 6);
      expect(d.registry.matched, 6, reason: 'every id resolves in the registry');
    });

    test('section→HomeSection mapping is recovered from the dispatch switch', () {
      final byName = {for (final a in d.atoms) a.name: a.section};
      expect(byName['_Departments'], 'categories');
      expect(byName['_SmartTreeRow'], 'products');
      expect(byName['_WorkPath'], 'workPath');
      expect(byName['_QuickTools'], 'promise');
      expect(byName['_SuperFinderHero'], 'superFinder');
      expect(byName['_InstallStudioHero'], 'installHero');
      expect(byName['_Favorites'], 'favorites');
      expect(byName['_RecentOrders'], 'reorderHistory');
    });

    test('the add-to-cart id rolls up from _SmartTreeCard into its section', () {
      final row = d.atoms.firstWhere((a) => a.name == '_SmartTreeRow');
      expect(
        row.nodes.any((n) => n.registryId == 'smart_home_screen.add_to_cart'),
        isTrue,
      );
      expect(
        row.edges.any((e) => e.kind == 'writes' && e.target == 'smartCartProvider'),
        isTrue,
      );
    });

    test('super-finder LIVE vs PREVIEW is distinguished (kAxisDive)', () {
      final open = d.atoms.firstWhere((a) => a.name == '_SuperFinderOpen');
      final hero = d.atoms.firstWhere((a) => a.name == '_SuperFinderHero');
      expect(open.variant, 'live');
      expect(open.gate, 'kAxisDive');
      expect(open.section, 'superFinder');
      expect(hero.variant, 'preview');
      expect(hero.section, 'superFinder');
    });

    test('untangle contract — writes → callbacks, embeds → split', () {
      final row = d.atoms.firstWhere((a) => a.name == '_SmartTreeRow');
      expect(row.contract.extractable, 'needs-untangle');
      expect(row.contract.untangle.any((u) => u.contains('smartCartProvider')),
          isTrue);
      final open = d.atoms.firstWhere((a) => a.name == '_SuperFinderOpen');
      expect(open.contract.extractable, 'embeds-shared');
      expect(open.contract.untangle.any((u) => u.contains('CatalogWheelScreen')),
          isTrue);
    });

    test('gaps — unregistered visible text is surfaced per atom', () {
      final row = d.atoms.firstWhere((a) => a.name == '_SmartTreeRow');
      // The section title has no CfgText id → it is a gap.
      expect(row.unregistered, contains('🌳 עץ חכם — אינסטלציה'));
      // The add-to-cart button IS registered → not a gap.
      expect(row.unregistered, isNot(contains('הוסף לסל')));
    });

    test('rendered files match the committed golden byte-for-byte', () {
      final rendered = renderFiles(d);
      for (final entry in rendered.entries) {
        final goldenFile = File(p.join(_goldenDir, entry.key));
        expect(goldenFile.existsSync(), isTrue,
            reason: 'missing golden ${entry.key} — regenerate the golden dir');
        expect(goldenFile.readAsStringSync(), entry.value,
            reason: '${entry.key} drifted — regenerate the golden dir');
      }
      // No stray golden files beyond what the tool emits.
      final onDisk = Directory(_goldenDir)
          .listSync()
          .whereType<File>()
          .map((f) => p.basename(f.path))
          .toSet();
      expect(onDisk, equals(rendered.keys.toSet()));
    });
  });
}
