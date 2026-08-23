// Journey-decomposer golden (DECOMP-DEPTH phase N). BuildSmart routes with
// Navigator 1.0 IMPERATIVE — no router, no named table — so the journey graph is
// invisible to any route tool and must be recovered from the pushes. The tool
// must reproduce the manual map (spec steps 71-82):
//   • the browse→order golden path: Suppliers→Brand→Section→Products (a
//     contiguous `push` chain), then the order completes via provider-SWAPS on
//     the global CartFab (Navigator-invisible) — the graph shows that seam.
//   • the 3 bypass surfaces (step 73): HomeShell tabs · store-section · startup.
//   • the gaps (step 78): off-convention raw-pushes (Install/Audit/Camera),
//     dormant flag-gated edges, pop-return dialogs.
//
// Read-only: documents the graph + flags the gaps; never adds a router.
import 'dart:io';

import 'package:atom_decompose/decompose.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _repo = p.canonicalize(p.join(Directory.current.path, '../../..'));
String _lib(String rel) => p.join(_repo, 'app_flutter/lib/$rel');

void main() {
  final screensDir = Directory(_lib('screens'));

  group('journey · per-screen edges (browse chain)', () {
    final present = File(_lib('screens/suppliers_screen.dart')).existsSync();
    test('suppliers screen reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final sup = decomposeJourneys(_lib('screens/suppliers_screen.dart'));

    test('SuppliersScreen — route-addressable node · push → Brand', () {
      final node = sup.nodes.firstWhere((n) => n.screen == 'SuppliersScreen');
      expect(node.routeAddressable, isTrue,
          reason: 'exposes static Route route()');
      expect(
          sup.edges.any((e) =>
              e.from == 'SuppliersScreen' &&
              e.to == 'LipskeyBrandScreen' &&
              e.kind == 'push'),
          isTrue,
          reason: 'the first browse hop, a Navigator.push via .route()');
    });
  });

  group('journey · the CartFab bypass seam (step 73)', () {
    final present = File(_lib('screens/home_shell.dart')).existsSync();
    test('home_shell reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final hs = decomposeJourneys(_lib('screens/home_shell.dart'));

    test('CartFab.openCart — provider-swaps to Store/cart AND tab 3', () {
      final swaps = hs.edges
          .where((e) => e.from == 'CartFab' && e.kind == 'provider-swap')
          .map((e) => e.to)
          .toList();
      expect(swaps, containsAll(['Store/cart', 'HomeShell#tab3']),
          reason: 'the order-forward hop is Navigator-INVISIBLE — two provider '
              'swaps on the global FAB, not a push');
    });

    test('HomeShell hosts the tabs bypass surface', () {
      final home = hs.nodes.firstWhere((n) => n.screen == 'HomeShell');
      expect(home.bypassSurface, 'tabs',
          reason: 'IndexedStack + mainTabProvider — 4 tabs, no routes');
    });
  });

  group('journey · the whole graph (batch over screens/)', () {
    if (!screensDir.existsSync()) {
      test('screens/ present', () => markTestSkipped('screens/ not found'));
      return;
    }
    final files = screensDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.path)
        .toList();
    final g = decomposeJourneyGraph(files);

    test('scale — dozens of screens, hundreds of edges', () {
      expect(g.nodes.length, greaterThanOrEqualTo(100));
      expect(g.edges.length, greaterThanOrEqualTo(120));
      expect(g.edges.where((e) => e.kind == 'push').length,
          greaterThanOrEqualTo(80));
    });

    test('browse→order path — Suppliers reaches Products by push chain', () {
      expect(g.hasPath('SuppliersScreen', 'LipskeyBrandScreen'), isTrue);
      expect(g.hasPath('SuppliersScreen', 'LipskeySectionScreen'), isTrue);
      expect(g.hasPath('SuppliersScreen', 'LipskeyProductsScreen'), isTrue,
          reason: 'the contiguous Suppliers→Brand→Section→Products push chain');
      // The order completes via a provider-swap seam, NOT a push out of Products.
      expect(g.hasPath('SuppliersScreen', 'Store/cart'), isFalse,
          reason: 'the cart is reached by the global CartFab swap, so it is NOT '
              'push-reachable from the product screen — the documented seam');
    });

    test('the 3 bypass surfaces are all present (step 73)', () {
      final surfaces =
          g.nodes.values.map((n) => n.bypassSurface).whereType<String>().toSet();
      expect(surfaces, containsAll(['tabs', 'store-section', 'startup']));
    });

    test('gaps (step 78) — raw-push · dormant · pop-return', () {
      // Off-convention screens pushed raw (no route()): Install / Audit / Camera.
      final rawTargets =
          g.edges.where((e) => e.kind == 'raw-push').map((e) => e.to).toSet();
      expect(rawTargets.any((t) => t == 'AuditScreen' || t == 'CameraScreen'),
          isTrue,
          reason: 'InstallStudio/Audit/Camera are raw-pushed, route-tool blind');
      // At least one flag-gated (dormant) edge.
      expect(g.edges.where((e) => e.dormant).isNotEmpty, isTrue,
          reason: 'some edges sit behind a feature flag — default-OFF, dormant');
      // Some screen pops a value back to its caller.
      expect(g.nodes.values.where((n) => n.returnsValue).isNotEmpty, isTrue,
          reason: 'scanner/dialogs pop a result up (Navigator.pop(ctx, value))');
    });

    test('provider-swap edges carry the tab / section / startup arcs', () {
      final swaps =
          g.edges.where((e) => e.kind == 'provider-swap').map((e) => e.to).toSet();
      expect(swaps.any((t) => t.startsWith('HomeShell#tab')), isTrue);
      expect(swaps.any((t) => t.startsWith('Store/')), isTrue);
      expect(swaps.any((t) => t.startsWith('startup#')), isTrue);
    });
  });
}
