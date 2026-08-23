// Lipski hierarchy parity — gate 117 follow-up.
//
// After PDF data sync (gate 117 9/9), Lipski now has clean nameHe. This test
// asserts that `parseChips` produces breadcrumb-quality output for Lipski
// products, matching the Polyroll/Huliot bar (type set + path populated +
// minimal leftover). Once GREEN, the card UI flips Lipski to `_HierarchyChips`.

import 'package:buildsmart/data/chip_hierarchy.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _Exp {
  final String sku;
  final String type;
  final List<String> pathContains; // chip values that MUST appear in the path
  const _Exp(this.sku, this.type, this.pathContains);
}

const _expected = <_Exp>[
  // toilet tanks
  _Exp('152785', 'מיכל הדחה', ['טיטאן', 'לבן']),
  _Exp('178862', 'מיכל הדחה', ['ברקת', 'לבן']),
  _Exp('168525', 'מיכל הדחה', ['כנרת', 'מונובלוק', 'לבן']),
  // toilet seats
  _Exp('116700', 'מושב אסלה', ['לבן']),
  _Exp('187133', 'מושב אסלה', ['תבור', 'סגירה רכה', 'לבן']),
  _Exp('179611', 'מושב אסלה', ['ציר ניירוסטה', 'אנטי ונדליזם', 'לבן']),
  _Exp('220943', 'מושב אסלה', ['משולב', 'לבן']),
  _Exp('224286', 'מושב אסלה', ['טרמו', 'ULTRA', 'לבן']),
  // visible bottle traps
  _Exp('217861', 'מחסום', ['אמריקאי', 'סיפון', '1.25"']),
  _Exp('116649', 'מחסום', ['סיפון', '2"']),
  // standard floor traps
  _Exp('218681', 'מחסום', ['תיקני', 'פתוח', '140/50']),
  // insertion bends/branches
  _Exp('116624', 'ברך',  ['87°']),
  _Exp('116573', 'מסעף', ['45°', '50/50']),
  // screw-on
  _Exp('197091', 'ברך', ['90°', 'תבריג', '32/32']),
  _Exp('187463', 'מסעף', ['45°', 'תבריג', '32/32/32']),
  // pipes
  _Exp('116603', 'צינור', ['אפור']),
  // gaskets + collectors
  _Exp('506510', 'אטם',   ['דו צדדי']),
  _Exp('116148', 'קולט',  ['למקלחת']),
];

void main() {
  group('Lipski hierarchy parity (gate 117 follow-up)', () {
    for (final e in _expected) {
      test('SKU ${e.sku} · type=${e.type} · path contains ${e.pathContains}', () {
        final p = kLipskeyCatalog.firstWhere(
          (q) => q.sku == e.sku && q.brand == 'ליפסקי',
          orElse: () => throw StateError('SKU ${e.sku} missing'),
        );
        final c = parseChips(p.nameHe);
        expect(c.type, e.type,
            reason: 'SKU ${e.sku} · "${p.nameHe}" — type expected "${e.type}", got "${c.type}". path=${c.path} leftover=${c.leftover}');
        for (final must in e.pathContains) {
          expect(c.path, contains(must),
              reason: 'SKU ${e.sku} · "${p.nameHe}" — path missing "$must". path=${c.path} leftover=${c.leftover}');
        }
      });
    }
  });
}
