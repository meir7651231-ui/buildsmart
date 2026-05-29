// Roadmap steps 71/72/74 — per-product project assignment model.
import 'package:buildsmart/state/card_projects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProjectItem _item(String project, String loc, {int qty = 1}) => ProjectItem(
      project: project,
      location: loc,
      productKey: 'faucet',
      brandName: 'AQUATEC',
      sku: 'SKU1',
      qty: qty,
    );

void main() {
  group('projectItemsAfterAdd (pure)', () {
    test('adds a new item', () {
      final r = projectItemsAfterAdd(const [], _item('A', 'מטבח'));
      expect(r.length, 1);
      expect(r.first.qty, 1);
    });

    test('merges qty for the same id', () {
      final r1 = projectItemsAfterAdd(const [], _item('A', 'מטבח', qty: 2));
      final r2 = projectItemsAfterAdd(r1, _item('A', 'מטבח', qty: 3));
      expect(r2.length, 1);
      expect(r2.first.qty, 5);
    });

    test('different location → separate entry', () {
      final r1 = projectItemsAfterAdd(const [], _item('A', 'מטבח'));
      final r2 = projectItemsAfterAdd(r1, _item('A', 'אמבטיה'));
      expect(r2.length, 2);
    });
  });

  group('CardProjectsNotifier', () {
    test('add persists + totalUnits/forProject/projects', () async {
      SharedPreferences.setMockInitialValues({});
      final n1 = CardProjectsNotifier();
      n1.add(_item('דירה 4', 'מטבח', qty: 2));
      n1.add(_item('דירה 4', 'אמבטיה'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n1.totalUnits, 3);
      expect(n1.forProject('דירה 4').length, 2);
      expect(n1.projects, {'דירה 4'});

      final n2 = CardProjectsNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n2.totalUnits, 3);
    });

    test('addToLocations (step 72) creates one entry per location', () {
      SharedPreferences.setMockInitialValues({});
      final n = CardProjectsNotifier();
      n.addToLocations(_item('P', 'x'), ['חדר 1', 'חדר 2', 'חדר 3']);
      expect(n.forProject('P').length, 3);
      expect(n.totalUnits, 3);
    });

    test('removeProject clears only that project', () {
      SharedPreferences.setMockInitialValues({});
      final n = CardProjectsNotifier();
      n.add(_item('A', 'm'));
      n.add(_item('B', 'm'));
      n.removeProject('A');
      expect(n.projects, {'B'});
    });
  });

  group('projectQuoteText (step 75)', () {
    test('lists each item with its location/brand/qty + a total + footer', () {
      final items = [
        _item('דירה 4', 'מטבח', qty: 2),
        _item('דירה 4', 'אמבטיה'),
      ];
      final q = projectQuoteText('דירה 4', items);
      expect(q, contains('פרויקט "דירה 4"'));
      expect(q, contains('מטבח'));
      expect(q, contains('אמבטיה'));
      expect(q, contains('×2'));
      expect(q, contains('סה"כ משוער'));
      expect(q, contains('BuildSmart'));
    });

    test('empty project → just header + zero total', () {
      final q = projectQuoteText('ריק', const []);
      expect(q, contains('סה"כ משוער: ~₪0'));
    });
  });
}
