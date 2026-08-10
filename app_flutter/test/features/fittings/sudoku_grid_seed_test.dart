import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart' show compatibleProductsFor;
import 'package:buildsmart/features/fittings/engine/catalog_map.dart'
    show familyOf;
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/ui/sudoku_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The seed bridge (D11/D13) — the grid/3D must SEED from the real product the
// card was opened from. The PPR engine (`familyOf`/`odOf`) can't type the
// lipskey plumbing catalog, so `runElementFor` falls back to the verified
// connector spec: family by port-count, OD by end size.
void main() {
  test('runElementFor types a lipskey product from its verified spec ends', () {
    // A product the PPR engine CANNOT type (familyOf == null) but which carries
    // a verified connector spec — the fallback must still type it.
    final p = kLipskeyCatalog.firstWhere(
      (p) =>
          familyOf(p) == null &&
          (kVerifiedSpecs[p.sku]?.ends.isNotEmpty ?? false),
    );
    final el = runElementFor(p);
    expect(el, isNotNull,
        reason: 'a spec-carrying product must seed even when the PPR '
            'engine cannot type it');

    // Family follows the port-count rule (1 = plug · 2 = coupler/reducer · 3+ = tee).
    final n = kVerifiedSpecs[p.sku]!.ends.length;
    final allowed = switch (n) {
      1 => {Family.plug},
      2 => {Family.coupler, Family.reducer},
      _ => {Family.tee},
    };
    expect(allowed.contains(el!.family), isTrue, reason: '$n ends → ${el.family}');
  });

  test('the spec bridge makes most of the catalog seedable', () {
    final typable = kLipskeyCatalog.where((p) => runElementFor(p) != null).length;
    // Before the bridge this was 0 (the engine only knew PPR categories).
    expect(typable, greaterThan(500));
  });

  testWidgets('a seeded grid shows the product family in the centre cell',
      (tester) async {
    final p = kLipskeyCatalog.firstWhere(
      (p) => runElementFor(p) != null && compatibleProductsFor(p).isNotEmpty,
    );
    final el = runElementFor(p)!;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: SingleChildScrollView(child: SudokuGrid(seedProduct: p))),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(famEmoji(el.family)), findsWidgets);
  });

  testWidgets('a seeded coupler grid offers its REAL mates as suggestions',
      (tester) async {
    // A coupler has collinear east/west ports, so its east neighbour always has
    // a facing port — the suggestions here are the product's real mates.
    final p = kLipskeyCatalog.firstWhere(
      (p) =>
          runElementFor(p)?.family == Family.coupler &&
          compatibleProductsFor(p).isNotEmpty,
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SudokuGrid(seedProduct: p, initialActive: const (1, 2)),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('מתחברים לשכן'), findsOneWidget);
    expect(find.byKey(const Key('suggest_0')), findsOneWidget);
  });
}
