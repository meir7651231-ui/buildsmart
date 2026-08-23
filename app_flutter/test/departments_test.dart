import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/departments_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Departments home (Benzi #2/#3). The `toolCats` tool departments must map to
/// REAL catalog categories — every listed `categoryHe` has products (R8 — no
/// invented data); the trade placeholders with no catalog data stay non-live.
void main() {
  int countOf(String cat) =>
      kCatalogProducts.where((p) => p.categoryHe == cat).length;

  group('departments — live data only (R8)', () {
    test('every toolCats department maps to real products (per category)', () {
      final toolDepts =
          DepartmentsScreen.departments.where((d) => d.toolCats != null);
      expect(toolDepts, isNotEmpty, reason: 'expected the tool departments');
      for (final d in toolDepts) {
        expect(d.live, isTrue, reason: '${d.name}: has toolCats but not live');
        expect(d.system, isNull, reason: '${d.name}: tool dept has no system');
        expect(d.toolCats!, isNotEmpty);
        for (final cat in d.toolCats!) {
          expect(countOf(cat), greaterThan(0),
              reason: '${d.name}: category "$cat" has no products (R8)');
        }
      }
    });

    test('trade placeholders with no data stay non-live (בקרוב)', () {
      const placeholders = [
        'חשמל',
        'חומרי בניין',
        'צבע וכלים לצבע',
        'גבס ופרופילים',
        'אספקה טכנית',
      ];
      for (final name in placeholders) {
        final d =
            DepartmentsScreen.departments.firstWhere((x) => x.name == name);
        expect(d.live, isFalse, reason: '$name should stay בקרוב (no data)');
        expect(d.toolCats, isNull);
      }
    });

    test('water-system departments keep their system, no toolCats', () {
      for (final name in ['אינסטלציה', 'ברזים וסניטריים']) {
        final d =
            DepartmentsScreen.departments.firstWhere((x) => x.name == name);
        expect(d.live, isTrue);
        expect(d.system, isNotNull);
        expect(d.toolCats, isNull);
      }
    });
  });

  group('departmentProducts (Benzi #5 — flat "all products" per branch)', () {
    test('water department = all its in-system products', () {
      for (final sys in WaterSystem.values) {
        final flat = departmentProducts(system: sys);
        expect(flat, isNotEmpty);
        expect(flat, equals(filterBySystem(kCatalogProducts, sys)));
      }
    });

    test('tool department = exactly its toolCats products', () {
      final hand = DepartmentsScreen.departments
          .firstWhere((d) => d.name == 'כלי עבודה ידני');
      final flat = departmentProducts(toolCats: hand.toolCats);
      expect(flat, isNotEmpty);
      for (final p in flat) {
        expect(hand.toolCats!.contains(p.categoryHe), isTrue);
      }
      final expected = kCatalogProducts
          .where((p) => hand.toolCats!.contains(p.categoryHe))
          .length;
      expect(flat.length, expected);
    });

    test('no scope (placeholder) → empty', () {
      expect(departmentProducts(), isEmpty);
    });
  });
}
