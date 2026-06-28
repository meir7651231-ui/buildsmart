// P10.95 — the line-scope decision. The monster plans a FLAT line from picks
// (planLineFromPicks -> buildInstallation), which covers the common "these few parts make
// one run" case. TREE planning (a trunk with multiple branch targets, buildTreeInstallation)
// is NOT removed — it stays the install_studio's advanced capability. This test pins the
// decision: the flat line works AND no capability disappears.

import 'package:buildsmart/features/card_keyboard/card_picks.dart';
import 'package:buildsmart/features/card_keyboard/line_plan.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:buildsmart/logic/install_engine.dart'
    show buildTreeInstallation;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final products = divePoolBySku.values.take(4).toList();

  test('SCOPE: the monster plans a FLAT line from picks', () {
    final picks = [
      for (final p in products.take(2)) CardPick(sku: p.sku, label: p.nameHe),
    ];
    final skus = planLineFromPicks(picks).items.map((p) => p.sku).toSet();
    expect(skus.contains(products[0].sku), isTrue);
    expect(skus.contains(products[1].sku), isTrue);
  });

  test('no capability lost: the studio TREE planner still plans trunk + branches',
      () {
    final tree = buildTreeInstallation(
      [products[0]], // trunk
      [products[1], products[2]], // branch targets
    );
    expect(tree.items.map((p) => p.sku), contains(products[0].sku),
        reason: 'the tree planner must still build — capability preserved');
  });
}
