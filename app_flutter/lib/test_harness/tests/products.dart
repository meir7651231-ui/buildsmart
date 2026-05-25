import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/test_harness/types.dart';

/// Per-product validation — one TestResult per SmartProduct.
List<TestResult> testProducts() {
  return kSmartProducts.map((p) {
    final checks = <TestCheck>[];
    void add(String name, bool pass, {String? detail, String? got}) {
      checks.add(TestCheck(name: name, pass: pass, detail: detail, got: got));
    }

    add('שדה key קיים', p.key.isNotEmpty, got: p.key);
    add('שדה name קיים', p.name.isNotEmpty, got: p.name);
    add('שדה emoji קיים', p.emoji.isNotEmpty, got: p.emoji);
    add('שדה cat קיים', p.cat.isNotEmpty, got: p.cat);

    add(
      'יש לפחות מותג אחד',
      p.brands.isNotEmpty,
      got: '${p.brands.length}',
    );

    final recBrands = p.brands.where((b) => b.rec).toList();
    add(
      'יש בדיוק מותג מומלץ אחד',
      recBrands.length == 1,
      got: '${recBrands.length}',
      detail: recBrands.length == 1
          ? ''
          : 'מותגים מומלצים: ${recBrands.map((b) => b.name).join(", ")}',
    );

    for (final b in p.brands) {
      add('מותג ${b.name} עם תיוג', b.tag.isNotEmpty);
      if (b.price != null) {
        add(
          'מחיר מותג ${b.name} ≥ 0',
          b.price! >= 0,
          got: '${b.price}',
        );
      }
    }

    add(
      'יש לפחות אביזר אחד',
      p.acc.isNotEmpty,
      got: '${p.acc.length}',
    );

    for (final a in p.acc) {
      add('אביזר עם שם: ${a.name}', a.name.isNotEmpty);
      add('אביזר עם emoji: ${a.name}', a.emoji.isNotEmpty);
      add('אביזר עם הסבר why: ${a.name}', a.why.isNotEmpty);
      if (a.price != null) {
        add('מחיר אביזר ${a.name} ≥ 0', a.price! >= 0, got: '${a.price}');
      }
    }

    // Stages — if present, every stage has emoji + label + sub
    if (p.stages.isNotEmpty) {
      var badStages = 0;
      for (final s in p.stages) {
        if (s.emoji.isEmpty || s.label.isEmpty || s.sub.isEmpty) badStages++;
      }
      add(
        'כל שלב התקנה תקין (emoji+label+sub)',
        badStages == 0,
        got: '$badStages פגומים',
      );
      // Exactly one final stage
      final finals = p.stages.where((s) => s.isFinal).length;
      add(
        'יש בדיוק שלב final אחד',
        finals == 1,
        got: '$finals',
      );
    }

    return TestResult(
      id: 'product:${p.key}',
      category: TestCategory.products,
      label: '${p.emoji} ${p.name}',
      area: p.cat,
      checks: checks,
    );
  }).toList();
}
