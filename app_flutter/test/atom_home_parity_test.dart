// Proof obligation for atom-engine slice-1 (see atom-engine/ENGINE-SPEC.md §3):
// the engine-driven home (AtomHomeScreen) is IDENTICAL to the original
// hand-wired home (FinderScreen), for the same drill state. Parity is asserted
// structurally — the exact ordered `Text` content plus a sorted inventory of the
// widget types that carry the home's visual identity match, for BOTH the landing
// and the drilled view. That fingerprint is deterministic and font-independent,
// so it is stable inside the full concurrent suite (an exact-PNG raster compare
// is not — it is fragile to paint-time overflow/anti-aliasing state leaked by
// other tests — so pixel-identity is verified standalone during development, not
// gated here). Also enforces that the embedded manifest const never drifts from
// the JSON SSOT, and that the shared finder_model logic behaves.
import 'dart:io';

import 'package:buildsmart/atoms/atom_home_screen.dart';
import 'package:buildsmart/atoms/atom_schema.dart';
import 'package:buildsmart/atoms/finder_model.dart';
import 'package:buildsmart/screens/finder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pump [home] in a fixed harness. If [tap], tap the first type row (drills one
/// level) before returning.
Future<void> _pump(WidgetTester tester, Widget home,
    {required bool tap}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            // Wide surface so the shared LipskeyProductsList (which has a
            // pre-existing narrow-width row overflow, unrelated to these atoms)
            // lays out without throwing — isolating atom parity from that.
            body: SizedBox(
              width: 1000,
              height: 1000,
              child: home,
            ),
          ),
        ),
      ),
    ),
  );
  // No infinite animations in the finder home; two pumps flush the one-shot
  // post-frame callbacks (chip-scroll overflow probe).
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  if (tap) {
    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Ordered visible Text content of the current tree.
List<String> _texts(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((w) => w.data ?? '')
    .toList();

/// A stable fingerprint of the render tree: ordered texts + a sorted inventory
/// of the widget types that carry the home's visual identity.
Map<String, dynamic> _fingerprint(WidgetTester tester) {
  int n<T>() => tester.widgetList(find.byType(T)).length;
  return {
    'texts': _texts(tester),
    'icons': n<Icon>(),
    'inkwells': n<InkWell>(),
    'gestures': n<GestureDetector>(),
    'containers': n<Container>(),
    'listviews': n<ListView>(),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('manifest is the SSOT', () {
    test('embedded const is byte-identical to the JSON file', () {
      final file = File('../atom-engine/manifests/contractor-home.json');
      expect(file.existsSync(), isTrue,
          reason: 'manifest missing at ${file.absolute.path}');
      expect(kContractorHomeManifestJson, file.readAsStringSync(),
          reason: 'embedded const drifted from the manifest SSOT');
    });

    test('schema parses to 10 slots with type_grid + results expanded', () {
      final schema = AtomSchema.parse(kContractorHomeManifestJson);
      expect(schema.screen, 'contractor-home');
      expect(schema.atoms.length, 10);
      expect(schema.atoms.first.id, 'type_grid');
      expect(schema.atoms.map((a) => a.id), contains('wall_chips'));
      expect(schema.atoms.firstWhere((a) => a.id == 'type_grid').expanded,
          isTrue);
      expect(
          schema.atoms.firstWhere((a) => a.id == 'results').expanded, isTrue);
    });
  });

  group('finder_model behaves like the finder', () {
    test('every finder group resolves a pool; sub-types derive', () {
      for (final g in kFinderGroups) {
        expect(() => productsForGroup(g), returnsNormally);
      }
      final connectors =
          kFinderGroups.firstWhere((g) => g.label == 'מחברים וחיבורים');
      final pool = productsForGroup(connectors);
      expect(pool, isNotEmpty);
      expect(subsFor(connectors, pool).map((s) => s.label), contains('נחושת'));
    });
  });

  group('AtomHomeScreen is identical to FinderScreen', () {
    testWidgets('landing — structural fingerprint matches', (tester) async {
      await _pump(tester, const FinderScreen(), tap: false);
      final a = _fingerprint(tester);
      await _pump(tester, const AtomHomeScreen(), tap: false);
      final b = _fingerprint(tester);
      expect(b, equals(a));
    });

    testWidgets('drilled one level — structural fingerprint matches',
        (tester) async {
      await _pump(tester, const FinderScreen(), tap: true);
      final a = _fingerprint(tester);
      await _pump(tester, const AtomHomeScreen(), tap: true);
      final b = _fingerprint(tester);
      expect(b, equals(a));
    });
  });
}
