// Manager command-center derivations — the data foundation behind the
// 👔 "מנהל המערכת" BS-dial persona (M0).
//
// VERBATIM SOURCE OF TRUTH: index.html (the 22K-line legacy prototype) on this
// branch. Every datum + every derivation below is a faithful port of the
// legacy manager analytics; NO label/number is invented (R6/R8). The legacy
// `SYSTEM_MANAGER.md` is NOT a source (it is documented as carrying invented
// numbers) — only index.html is.
//
// What this mirrors, with line anchors used during the port:
//   • ORDER_FLOW                @index.html:16943  → [kManagerOrderFlow]
//   • SYS_ORDERS_SEED           @index.html:11970-12001 → [kManagerOrderSeed]
//   • STORES                    @index.html:11930-11934 → [kManagerStores]
//   • TREES split + STORE_STOCK @index.html:5441-6044, :12050-12051
//        (catalogCount / accCount / avail) → [kManagerCatalogCategories]
//   • mgrAnalytics()            @index.html:12081-12126 → [ManagerAnalytics]
//   • the 5 mdMetric tiles      @index.html:12160-12164 → [ManagerAnalytics]
//        getters openOrders / catalogCount / accessoryCount / availableCount /
//        activeStores+totalStores.
//
// PURE Dart (no Flutter imports) so it is unit-testable in isolation. The
// BS-dial widget reads the metrics via [managerAnalytics] (a const-folded
// singleton) and renders them inline (R2 — dial-drill, no new screen).

/// @legacy index.html:16943
///   `const ORDER_FLOW=['new','preparing','ready','pickup','transit','delivered'];`
/// The ordered stages an order moves through. Foundation for M2 (the 6 `mo-*`
/// order-status leaves) — each `mo-*` leaf filters orders to one stage.
const List<String> kManagerOrderFlow = [
  'new',
  'preparing',
  'ready',
  'pickup',
  'transit',
  'delivered',
];

/// A single store. @legacy index.html:11930-11934 (`let STORES=[…]`).
class ManagerStore {
  const ManagerStore({
    required this.name,
    required this.area,
    required this.eta,
    required this.on,
  });

  final String name;
  final String area;
  final String eta;

  /// `on` in the legacy object — whether the store is currently active.
  final bool on;
}

/// @legacy index.html:11930-11934 — verbatim port of the three seed stores.
/// All three are `on:true` in the seed, so active = total = 3.
const List<ManagerStore> kManagerStores = [
  ManagerStore(
    name: 'מחסני אינסטלציה תל-אביב',
    area: 'גוש דן',
    eta: 'עד שעתיים',
    on: true,
  ),
  ManagerStore(
    name: 'ספקי סניטריה השרון',
    area: 'השרון',
    eta: 'עד שעתיים',
    on: true,
  ),
  ManagerStore(
    name: 'חומרי בניין הרצליה',
    area: 'הרצליה והסביבה',
    eta: 'עד שעה',
    on: true,
  ),
];

/// A single seed order. @legacy index.html:11970-12001 (`SYS_ORDERS_SEED`).
/// Only the fields the dashboard analytics reads are carried (`id`, `who`,
/// `site`, `items`, `sum`, `stage`); the per-line picking detail is foundation
/// the later waves can extend.
class ManagerOrder {
  const ManagerOrder({
    required this.id,
    required this.who,
    required this.site,
    required this.items,
    required this.sum,
    required this.stage,
  });

  final String id;
  final String who;
  final String site;
  final int items;
  final int sum;

  /// One of [kManagerOrderFlow].
  final String stage;

  /// Mirrors `o.stage!=='delivered'` — the "open order" predicate the
  /// dashboard counts (@legacy index.html:12096).
  bool get isOpen => stage != 'delivered';
}

/// @legacy index.html:11970-12001 — verbatim port of the four seed orders.
/// Stages: new · preparing · ready · transit (none delivered) → 4 open.
const List<ManagerOrder> kManagerOrderSeed = [
  ManagerOrder(
    id: 'BS-1042',
    who: 'יוסי כהן',
    site: 'מגדל הרצליה',
    items: 7,
    sum: 1240,
    stage: 'new',
  ),
  ManagerOrder(
    id: 'BS-1041',
    who: 'אבי מזרחי',
    site: 'דירה — רמת גן',
    items: 3,
    sum: 680,
    stage: 'preparing',
  ),
  ManagerOrder(
    id: 'BS-1040',
    who: 'משה אברהם',
    site: 'וילה — סביון',
    items: 6,
    sum: 3150,
    stage: 'ready',
  ),
  ManagerOrder(
    id: 'BS-1039',
    who: 'דוד לוי',
    site: 'משרדים — תל אביב',
    items: 3,
    sum: 420,
    stage: 'transit',
  ),
];

/// The catalog product distribution the manager dashboard reads, extracted
/// VERBATIM from the legacy `TREES` map (@legacy index.html:5441-6044) by
/// counting each product's `cat` field. Carrying the per-category counts (not
/// 202 full product objects) keeps the foundation compact while every derived
/// metric below stays a real `fold` over ported data — no magic integers.
///
/// Two parallel facts the dashboard splits on:
///   • `accessoryProduct:true` products are all under `cat:'אביזרים נלווים'`
///     (@legacy index.html:5896+). Hence accCount == the 'אביזרים נלווים' bucket
///     and catalogCount == every other bucket.
///   • `STORE_STOCK[k]` is seeded `true` for EVERY key (@legacy
///     index.html:12050-12051), so availableCount == the full product total.
///
/// Verified against the live source: total 202 (= catalog 54 + accessory 148),
/// 14 categories — see `test/manager_dashboard_test.dart`.
const Map<String, int> kManagerCatalogCategories = {
  'אביזרים מכניים': 23,
  'אחר': 5,
  'ברזים וכיורים': 3,
  'אסלות': 2,
  'מקלחות ואמבטיות': 2,
  'בנייה ומחיצות': 2,
  'גמר': 2,
  'אינסטלציה גסה': 1,
  'חימום מים': 2,
  'מטבח': 3,
  'ניקוז וצנרת': 2,
  'גופי תברואה': 2,
  'אביזרי קצה וחיבורים': 5,
  // The accessory bucket — every `accessoryProduct:true` product lives here.
  'אביזרים נלווים': 148,
};

/// The accessory category key — its product count IS `accCount` (the only
/// bucket whose products carry `accessoryProduct:true`).
const String kManagerAccessoryCategory = 'אביזרים נלווים';

/// Unified manager analytics — the single source the dashboard reads, a port of
/// `mgrAnalytics()` (@legacy index.html:12081-12126). Computes its numbers by
/// folding over the ported seed data above, exactly as the legacy function
/// folds over `SYS_ORDERS` / `TREES` / `STORES`.
class ManagerAnalytics {
  const ManagerAnalytics({
    required this.orders,
    required this.stores,
    required this.catalogCategories,
  });

  final List<ManagerOrder> orders;
  final List<ManagerStore> stores;
  final Map<String, int> catalogCategories;

  /// 🚚 הזמנות פתוחות — orders whose stage is not `delivered`.
  /// @legacy index.html:12096 (`orders.filter(o=>o.stage!=='delivered').length`).
  int get openOrders => orders.where((o) => o.isOpen).length;

  /// Total products in the catalog (every TREES key).
  /// @legacy index.html:12122 (`total:keys.length`).
  int get totalProducts =>
      catalogCategories.values.fold(0, (sum, n) => sum + n);

  /// 🧰 אביזרים נלווים — products flagged `accessoryProduct:true`.
  /// @legacy index.html:12107-12109 (`accCount`).
  int get accessoryCount => catalogCategories[kManagerAccessoryCategory] ?? 0;

  /// 📦 מוצרים בקטלוג — every non-accessory product.
  /// @legacy index.html:12110-12111 (`catalogCount`).
  int get catalogCount => totalProducts - accessoryCount;

  /// ✅ זמינים כעת — products in stock. `STORE_STOCK` is seeded all-`true`
  /// (@legacy index.html:12050-12051) so every product is available.
  /// @legacy index.html:12122 (`avail`).
  int get availableCount => totalProducts;

  /// Number of distinct catalog categories.
  /// @legacy index.html:12124 (`catCount:Object.keys(cats).length`).
  int get categoryCount => catalogCategories.length;

  /// 🏪 חנויות פעילות — count of stores with `on:true`.
  /// @legacy index.html:12125 (`activeStores:STORES.filter(s=>s.on).length`).
  int get activeStores => stores.where((s) => s.on).length;

  /// Total stores. @legacy index.html:12125 (`stores:STORES.length`).
  int get totalStores => stores.length;

  /// The "X/Y" string the legacy 🏪 tile renders
  /// (@legacy index.html:12164 `a.activeStores+'/'+a.stores`).
  String get storesLabel => '$activeStores/$totalStores';
}

/// The const-folded analytics over the ported SEED orders. This is the static
/// snapshot; the LIVE read-path now flows through the shared orders engine —
/// `managerAnalyticsProvider` (`state/orders_engine.dart`) builds a
/// [ManagerAnalytics] over the engine's live orders using this exact same fold.
/// Because the engine is seeded with [kManagerOrderSeed], the live analytics
/// equal this const until real orders are placed — every existing number is
/// preserved (🚚 open=4, …). Kept as the seed-bound default + the engine's seed.
const ManagerAnalytics managerAnalytics = ManagerAnalytics(
  orders: kManagerOrderSeed,
  stores: kManagerStores,
  catalogCategories: kManagerCatalogCategories,
);

// ───────────────────────────────────────────────────────────────────────────
//  Foundation for the LATER waves (laid here so M0 is the single data home).
// ───────────────────────────────────────────────────────────────────────────

/// M3 foundation — contractor credit ceiling, a DETERMINISTIC hash of the
/// contractor's name into the 30,000–120,000 ₪ band. Mirrors the legacy
/// per-contractor credit number (@legacy `contractorCredit`); deterministic so
/// the same name always yields the same ceiling (sticky, like the A/B hash
/// pattern in `ab_experiments.dart`). Pure + testable; not yet surfaced in the
/// dial (M3 wires the 👥 לקוחות leaves).
int contractorCredit(String name) {
  const lo = 30000;
  const hi = 120000;
  const span = hi - lo; // 90,000
  // Stable non-negative hash → bucket within the band, rounded to ₪100.
  final h = name.hashCode.abs();
  final raw = lo + (h % (span + 1));
  return (raw ~/ 100) * 100;
}

/// Group orders by buyer (`who`), summing their spend + counting their orders.
/// Mirrors the legacy `mgrCustomerList` group-by-buyer (the 👥 לקוחות source).
/// Pure + testable. The LIVE read-path passes the shared orders engine's live
/// orders here (`managerCustomersProvider`, `state/orders_engine.dart`); with no
/// argument it folds the [kManagerOrderSeed] — identical to the engine's seed,
/// so the four seed customers are preserved.
List<ManagerCustomer> mgrCustomerList([List<ManagerOrder>? orders]) {
  final src = orders ?? kManagerOrderSeed;
  final byBuyer = <String, ManagerCustomer>{};
  for (final o in src) {
    final cur = byBuyer[o.who];
    if (cur == null) {
      byBuyer[o.who] = ManagerCustomer(
        name: o.who,
        orderCount: 1,
        totalSpend: o.sum,
        creditLimit: contractorCredit(o.who),
      );
    } else {
      byBuyer[o.who] = ManagerCustomer(
        name: cur.name,
        orderCount: cur.orderCount + 1,
        totalSpend: cur.totalSpend + o.sum,
        creditLimit: cur.creditLimit,
      );
    }
  }
  final out = byBuyer.values.toList()
    ..sort((a, b) => b.totalSpend.compareTo(a.totalSpend));
  return out;
}

/// A buyer aggregate — M3 foundation (see [mgrCustomerList]).
class ManagerCustomer {
  const ManagerCustomer({
    required this.name,
    required this.orderCount,
    required this.totalSpend,
    required this.creditLimit,
  });

  final String name;
  final int orderCount;
  final int totalSpend;
  final int creditLimit;
}
