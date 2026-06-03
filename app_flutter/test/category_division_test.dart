import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/logic/category_division.dart';
import 'package:buildsmart/screens/departments_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Benzi #1 (reframed) — fixtures-vs-pipes department layout. Guards the
/// per-category mapping: every heading category must resolve to a real,
/// non-empty catalog node (R8 — no invented/empty rows), and no tool category
/// may leak into a plumbing heading.
void main() {
  // All leaf categoryHe reachable under a heading title (top-node → its leaves;
  // bare leaf → itself).
  Set<String> leavesUnder(String title) {
    final node = resolveCatTitle(title);
    if (node == null) return {};
    final out = <String>{};
    void walk(CatalogNode n) {
      if (n.isLeaf) {
        final l = n.lipskeyCategory;
        if (l != null) out.add(l);
      } else {
        for (final c in n.children) {
          walk(c);
        }
      }
    }

    walk(node);
    return out;
  }

  test('catalog departments are ברזים/אינסטלציה only', () {
    expect(isCatalogDept('ברזים וסניטריים'), isTrue);
    expect(isCatalogDept('אינסטלציה'), isTrue);
    expect(isCatalogDept('חשמל'), isFalse);
    expect(isCatalogDept('כלי עבודה ידני'), isFalse);
  });

  test('every heading category resolves to a node with real products (R8)', () {
    for (final entry in kDeptCatHeadings.entries) {
      for (final h in entry.value) {
        expect(h.titles, isNotEmpty, reason: '${entry.key}/${h.label} empty');
        for (final title in h.titles) {
          final node = resolveCatTitle(title);
          expect(node, isNotNull,
              reason: '${entry.key}/${h.label}: "$title" does not resolve');
          expect(catNodeProductCount(node!), greaterThan(0),
              reason: '${entry.key}/${h.label}: "$title" has no products');
        }
      }
    }
  });

  test('no tool category leaks into a plumbing heading', () {
    const tools = {'כלי עבודה', 'חותך צינורות', 'כלי ריתוך PPR'};
    // Tools may sit *under* a collapsed top-node (e.g. PPR), but must never be a
    // heading title themselves.
    for (final entry in kDeptCatHeadings.entries) {
      for (final h in entry.value) {
        for (final title in h.titles) {
          expect(tools.contains(title), isFalse,
              reason: '${entry.key}/${h.label}: tool "$title" listed directly');
        }
      }
    }
  });

  test('אינסטלציה flat products span both water and sewage', () {
    final all = departmentProducts(name: 'אינסטלציה');
    expect(all, isNotEmpty);
    // a known water category (PPR) and a known sewage category (HDPE) are both in
    final cats = all.map((p) => p.categoryHe).toSet();
    expect(cats.any((c) => c.contains('PPR')), isTrue, reason: 'no water (PPR)');
    expect(cats.contains('מחברי HDPE'), isTrue, reason: 'no sewage (HDPE)');
  });

  test('ברזים flat products include אסלות white-ware', () {
    final all = departmentProducts(name: 'ברזים וסניטריים');
    expect(all, isNotEmpty);
    final inToilets = leavesUnder('אסלות');
    expect(
        all.any((p) => inToilets.contains(p.categoryHe)), isTrue,
        reason: 'ברזים should include the אסלות white-ware');
  });
}
