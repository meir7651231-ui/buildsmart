// TASK → PRODUCT SKUs (board W v2, cluster #85ה) — which catalog products a
// seeded §6 task actually works with, powering the task-detail "מה להביא"
// section (install-kit recommendation aggregated over these products).
//
// DEMO-SEED: the mapping itself is demo wiring (a manager does not attach
// products to tasks yet), but every SKU below is a REAL product from the
// unified catalog ([resolvedCatalogProducts] = the active source), picked
// to match the seeded task's trade — verified against `lipskey_catalog.dart`
// and `huliot_smartlock_catalog.dart`. No invented products (אין המצאות).
//
// SERVER-SWAP: when the server lands, the manager attaches products to a task
// and this local map is replaced by the task's own product list.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/catalog_source.dart'
    show resolvedCatalogProducts;

/// Seeded task id (`kPersonaTasks` / `tasksProvider`) → catalog SKUs.
///
/// Task 3 (איטום רצפת מקלחת) deliberately has NO entry: the plumbing catalogs
/// carry no waterproofing materials, and inventing one would violate
/// אין-המצאות — the task-detail sheet honestly omits the section for it.
const Map<int, List<String>> kTaskSkus = {
  // 1 · התקנת קו מים חם — חדר רחצה (detail: 'חיבור צנרת PEX מהדוד לנקודות'):
  //     NTM 16 press fittings — the PEX-press couplers of the hot-water line.
  1: [
    '77401622', // מקשר כפול NTM 16×16 (AQUATEC, page 82)
    '77402222', // מקשר הברגה פנימית NTM 16×1/2" (AQUATEC, page 82)
  ],
  // 2 · הרכבת מיכל הדחה סמוי: the concealed-toilet nipple set + the toilet
  //     angle valve feeding the cistern.
  2: [
    '77777400', // סט ניפל לאסלה סמויה קצר (AQUATEC, page 55)
    '77775261', // דיור מסוט אסלה (AQUATEC, page 44)
  ],
  // 4 · התקנת נקזון רצפה (detail: 'חיבור לקו ניקוז 50 מ"מ'):
  //     SmartLock floor drain DN50 + the DN50 drainage pipe it connects to.
  4: [
    '70145960', // מחסום 80/50 סגור (חוליות SmartLock, page 21)
    '64051300', // צינור חלק 50 אורך 3000 (חוליות SmartLock, page 11)
  ],
  // 5 · חיבור ברז כיור + ברזי ניל: the page-44 nile (angle) valves.
  5: [
    '77775262', // דיור ברז ניל 1/2"×3/8" (AQUATEC, page 44)
    '77775263', // דיור ברז ניל 1/2"×1/2" (AQUATEC, page 44)
  ],
};

/// Exact-SKU lookup over the unified catalog — null when the code matches no
/// product (callers show an honest "not found" state, never a fake product).
LipskeyCatalogProduct? productBySku(String sku) {
  final s = sku.trim();
  // stage-3.1 — follows the ACTIVE catalog source (v2-aware).
  for (final p in resolvedCatalogProducts) {
    if (p.sku == s) return p;
  }
  return null;
}

/// Resolve [taskId]'s mapped SKUs to live catalog products. Unknown SKUs are
/// skipped (honest — nothing renders for them); empty list ⇒ no mapping, the
/// caller omits its section entirely.
List<LipskeyCatalogProduct> productsForTask(int taskId) {
  final skus = kTaskSkus[taskId];
  if (skus == null) return const [];
  final out = <LipskeyCatalogProduct>[];
  for (final sku in skus) {
    final p = productBySku(sku);
    if (p != null) out.add(p);
  }
  return out;
}

/// All catalog products sharing [p]'s category — the sibling list the product
/// sheet's variant pager expects (same shape the catalog screens pass).
List<LipskeyCatalogProduct> catalogSiblingsFor(LipskeyCatalogProduct p) =>
    resolvedCatalogProducts.where((x) => x.categoryHe == p.categoryHe).toList();
