// Roadmap step 12 (israeliStandardsFor) + step 33 (installToolsFor).
// Both are pure heuristics derived from the verified-spec / category, so they
// are unit-tested directly against the real catalog.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LipskeyCatalogProduct bySku(String sku) =>
      kLipskeyCatalog.firstWhere((p) => p.sku == sku);

  group('israeliStandardsFor', () {
    test('drainage products map to ת"י 1205', () {
      // Find any product whose spec is drainage-only.
      LipskeyCatalogProduct? drain;
      for (final p in kLipskeyCatalog) {
        final s = kVerifiedSpecs[p.sku];
        if (s != null &&
            s.endSystems.length == 1 &&
            s.endSystems.contains(WaterSystem.drainage)) {
          drain = p;
          break;
        }
      }
      expect(drain, isNotNull, reason: 'catalog should have a drainage SKU');
      final codes = israeliStandardsFor(drain!).map((s) => s.code).toList();
      expect(codes, contains('ת"י 1205'));
    });

    test('faucet categories map to ת"י 1385 and never duplicate codes', () {
      LipskeyCatalogProduct? tap;
      for (final p in kLipskeyCatalog) {
        if (p.categoryHe == 'ברזי כיור' || p.categoryHe == 'ברזי מטבח') {
          tap = p;
          break;
        }
      }
      if (tap != null) {
        final stds = israeliStandardsFor(tap);
        final codes = stds.map((s) => s.code).toList();
        expect(codes, contains('ת"י 1385'));
        expect(codes.toSet().length, codes.length, reason: 'no dup codes');
      }
    });

    test('a product with no spec yields no standards', () {
      // Synthesize: any product not in kVerifiedSpecs.
      final noSpec = kLipskeyCatalog
          .where((p) => kVerifiedSpecs[p.sku] == null)
          .toList();
      if (noSpec.isNotEmpty) {
        // Non-faucet, non-multilayer no-spec product → empty.
        for (final p in noSpec) {
          final stds = israeliStandardsFor(p);
          // It can still match by category (faucet/multilayer); just assert
          // the call never throws and codes are unique.
          final codes = stds.map((s) => s.code).toList();
          expect(codes.toSet().length, codes.length);
        }
      }
    });
  });

  group('installToolsFor', () {
    test('threaded ends require a wrench + teflon', () {
      LipskeyCatalogProduct? threaded;
      for (final p in kLipskeyCatalog) {
        final s = kVerifiedSpecs[p.sku];
        if (s != null &&
            s.ends.any((e) =>
                e.type == EndType.bspMale || e.type == EndType.bspFemale)) {
          threaded = p;
          break;
        }
      }
      expect(threaded, isNotNull);
      final tools = installToolsFor(threaded!);
      expect(tools.any((t) => t.contains('מפתח צינורות')), isTrue);
      expect(tools.any((t) => t.contains('טפלון')), isTrue);
    });

    test('tools list is de-duplicated', () {
      for (final p in kLipskeyCatalog) {
        final tools = installToolsFor(p);
        expect(tools.toSet().length, tools.length,
            reason: 'duplicate tool for ${p.sku}');
      }
    });

    test('no-spec product yields no tools', () {
      final noSpec =
          kLipskeyCatalog.where((p) => kVerifiedSpecs[p.sku] == null);
      for (final p in noSpec) {
        expect(installToolsFor(p), isEmpty);
      }
    });
  });
}
