import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('סריקת התנגשות קטגוריה↔קצוות', () {
    // For each hard-classified category, count products whose actual ends
    // disagree with the category's assigned system.
    final conflicts = <String, List<String>>{}; // category -> [sku:endsys]
    final catCounts = <String, int>{};

    for (final p in kCompatCatalog) {
      final spec = kVerifiedSpecs[p.sku];
      if (spec == null) continue;
      final cat = p.categoryHe;
      catCounts[cat] = (catCounts[cat] ?? 0) + 1;
      final endSys = spec.endSystems; // {supply}/{drainage}/{both}
      // category-only system (re-derive the hard buckets)
      final catSys = productSystems(p); // uses category map; falls to ends if ambiguous
      // A conflict: the product's ends point ENTIRELY at a system that the
      // category-system does NOT include.
      if (endSys.isNotEmpty && endSys.intersection(catSys).isEmpty) {
        conflicts.putIfAbsent(cat, () => []).add('${p.sku}=${endSys.map((s)=>s.name).join("+")}');
      }
    }

    print('\n════════ קטגוריות עם התנגשות (קצוות ⊄ קטגוריה) ════════');
    if (conflicts.isEmpty) {
      print('   ✅ אין התנגשויות — כל הקצוות עקביים עם סיווג הקטגוריה');
    } else {
      final sorted = conflicts.keys.toList()
        ..sort((a, b) => conflicts[b]!.length.compareTo(conflicts[a]!.length));
      for (final cat in sorted) {
        print('   🚩 "$cat" (${catCounts[cat]} סה"כ): ${conflicts[cat]!.length} מתנגשים');
        print('      ${conflicts[cat]!.take(8).join(", ")}');
      }
    }

    // Regression guard: every product's ends must overlap its category system.
    // A new conflict means a category is mixed and needs per-SKU classification.
    expect(conflicts, isEmpty,
        reason: 'קטגוריות מעורבות חדשות — דורש פיצול לפי הקשר: ${conflicts.keys}');
  });
}
