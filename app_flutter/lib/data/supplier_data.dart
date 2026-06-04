// Supplier-side persona data — the 🏪 store + 🛵 courier role-apps (T9).
//
// Source of truth: app_flutter/knowledge/port/proto/06-personas-engine-selftest.md
//   §1 (shared order engine + SYS_ORDERS_SEED [L11970]) · §7 (STORES [L11930],
//   HAUL_TYPES [L11950], FLEET [L20720], SUPPLIER_RATINGS [L20741],
//   DIST_ZONES [L20727], BULK_TIERS [L20734]). UI companion:
//   knowledge/port/preact/03-persona-dashboards.md §1/§2.
//
// Every Hebrew string and number is VERBATIM from the prototype (R6/R8) — do
// NOT paraphrase or invent. Immutable `const` seeds only; the mutable live
// order list lives in state/sys_orders.dart (the SysOrders StateNotifier).

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// §1.1 · Order stage model — `ORDER_STAGE` [L12041] + `ORDER_FLOW` [L16943].
//   6 canonical stages. Store owns new→preparing→ready; courier owns
//   ready→pickup→transit→delivered; manager can nudge any single step.
// ─────────────────────────────────────────────────────────────────────────────
enum OrderStage { newOrder, preparing, ready, pickup, transit, delivered }

/// Verbatim stage label (`ORDER_STAGE[k].label`).
const Map<OrderStage, String> kOrderStageLabel = {
  OrderStage.newOrder: 'התקבלה',
  OrderStage.preparing: 'בהכנה',
  OrderStage.ready: 'מוכן לאיסוף',
  OrderStage.pickup: 'נאסף',
  OrderStage.transit: 'בדרך לאתר',
  OrderStage.delivered: 'נמסר ✓',
};

/// The linear flow used by the manager stepper + `mgrAdvanceOrder`.
const List<OrderStage> kOrderFlow = [
  OrderStage.newOrder,
  OrderStage.preparing,
  OrderStage.ready,
  OrderStage.pickup,
  OrderStage.transit,
  OrderStage.delivered,
];

// ─────────────────────────────────────────────────────────────────────────────
// §1.2 · Order object shape + `SYS_ORDERS_SEED` [L11970] — 4 demo orders.
//   Shape `{id, who, site, items, sum, stage, haul, lines:[{name,qty}]}`.
//   (Runtime split/missing/POD fields are deferred — not in Phase-1 scope.)
// ─────────────────────────────────────────────────────────────────────────────
@immutable
class OrderLine {
  const OrderLine(this.name, this.qty);
  final String name;
  final int qty;
}

@immutable
class SysOrder {
  const SysOrder({
    required this.id,
    required this.who,
    required this.site,
    required this.items,
    required this.sum,
    required this.stage,
    required this.haul,
    required this.lines,
  });

  final String id;
  final String who;
  final String site;
  final int items;
  final int sum;
  final OrderStage stage;

  /// Haulage id — small | van | truck (keys into [kHaulTypes]).
  final String haul;
  final List<OrderLine> lines;

  SysOrder copyWith({OrderStage? stage}) => SysOrder(
    id: id,
    who: who,
    site: site,
    items: items,
    sum: sum,
    stage: stage ?? this.stage,
    haul: haul,
    lines: lines,
  );
}

/// `SYS_ORDERS_SEED` — 4 demo orders, verbatim (proto 06 §1.2 [L11970]).
const List<SysOrder> kSysOrdersSeed = [
  SysOrder(
    id: 'BS-1042',
    who: 'יוסי כהן',
    site: 'מגדל הרצליה',
    items: 7,
    sum: 1240,
    stage: OrderStage.newOrder,
    haul: 'van',
    lines: [
      OrderLine('ברז לכיור', 2),
      OrderLine('צינורות חיבור גמישים', 4),
      OrderLine('ברזי ניל זוויתיים', 4),
      OrderLine('סרט טפלון', 3),
      OrderLine('אטם גומי לברז', 6),
      OrderLine('סיליקון סניטרי', 1),
      OrderLine('מפתח צינורות', 1),
    ],
  ),
  SysOrder(
    id: 'BS-1041',
    who: 'אבי מזרחי',
    site: 'דירה — רמת גן',
    items: 3,
    sum: 680,
    stage: OrderStage.preparing,
    haul: 'small',
    lines: [
      OrderLine('אסלה תלויה', 1),
      OrderLine('מיכל הדחה סמוי', 1),
      OrderLine('מושב אסלה', 1),
    ],
  ),
  SysOrder(
    id: 'BS-1040',
    who: 'משה אברהם',
    site: 'וילה — סביון',
    items: 12,
    sum: 3150,
    stage: OrderStage.ready,
    haul: 'truck',
    lines: [
      OrderLine('צינור PEX מים חמים/קרים', 24),
      OrderLine('מחברי PEX', 18),
      OrderLine('גוף סמוי לסוללת מקלחת', 2),
      OrderLine('ראש מקלחת', 2),
      OrderLine('זרוע למקלחת', 2),
      OrderLine('סוללת מקלחת', 2),
    ],
  ),
  SysOrder(
    id: 'BS-1039',
    who: 'דוד לוי',
    site: 'משרדים — תל אביב',
    items: 4,
    sum: 420,
    stage: OrderStage.transit,
    haul: 'van',
    lines: [
      OrderLine('ברז למטבח', 1),
      OrderLine('צינורות חיבור גמישים', 2),
      OrderLine('סרט טפלון', 1),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// §7 · STORES [L11930] — 3 demo supplier stores (store login + analytics).
// ─────────────────────────────────────────────────────────────────────────────
@immutable
class StoreInfo {
  const StoreInfo(this.name, this.area, this.eta, {this.on = true});
  final String name;
  final String area;
  final String eta;
  final bool on;
}

const List<StoreInfo> kStores = [
  StoreInfo('מחסני אינסטלציה תל-אביב', 'גוש דן', 'עד שעתיים'),
  StoreInfo('ספקי סניטריה השרון', 'השרון', 'עד שעתיים'),
  StoreInfo('חומרי בניין הרצליה', 'הרצליה והסביבה', 'עד שעה'),
];

// ─────────────────────────────────────────────────────────────────────────────
// §3.1 / §7 · HAUL_TYPES [L11950] + VEHICLE_RANK [L17946] — courier vehicles.
// ─────────────────────────────────────────────────────────────────────────────
@immutable
class HaulType {
  const HaulType(this.id, this.name, this.ic, this.extra);
  final String id;
  final String name;
  final String ic;
  final int extra;
}

const List<HaulType> kHaulTypes = [
  HaulType('small', 'משלוח קטן', '🛵', 0),
  HaulType('van', 'טנדר', '🚐', 40),
  HaulType('truck', 'משאית', '🚛', 90),
];

const Map<String, int> kVehicleRank = {'small': 0, 'van': 1, 'truck': 2};

/// `haulInfo(id)` [L11947] — falls back to the smallest type.
HaulType haulInfo(String id) =>
    kHaulTypes.firstWhere((h) => h.id == id, orElse: () => kHaulTypes.first);

/// `vehicleCanCarry(vehicle, need)` [L17951] — a bigger vehicle carries
/// everything ranked ≤ it (`need.rank <= vehicle.rank`).
bool vehicleCanCarry(String vehicle, String need) =>
    (kVehicleRank[need] ?? 0) <= (kVehicleRank[vehicle] ?? 2);

// ─────────────────────────────────────────────────────────────────────────────
// §7 · Portal supporting tables (verbatim) — feed the store/courier portals.
// ─────────────────────────────────────────────────────────────────────────────
/// `FLEET` [L20720] — 4 vehicles `{id,name,cap,status,driver}`.
@immutable
class FleetVehicle {
  const FleetVehicle(this.id, this.name, this.cap, this.status, this.driver);
  final String id;
  final String name;
  final String cap;
  final String status;
  final String driver;
}

const List<FleetVehicle> kFleet = [
  FleetVehicle('V14', 'משאית 14', 'עד 5 טון', 'בדרך', 'אבי'),
  FleetVehicle('V08', 'מסחרית 08', 'עד 1.2 טון', 'פנוי', 'רונן'),
  FleetVehicle('V21', 'משאית 21', 'עד 8 טון', 'בתחזוקה', '—'),
  FleetVehicle('V05', 'טנדר 05', 'עד 800 ק״ג', 'פנוי', 'מאי'),
];

/// `DIST_ZONES` [L20727] — 4 distribution zones `{name,eta,fee}`.
@immutable
class DistZone {
  const DistZone(this.name, this.eta, this.fee);
  final String name;
  final String eta;
  final int fee;
}

const List<DistZone> kDistZones = [
  DistZone('תל-אביב והמרכז', 'עד שעתיים', 0),
  DistZone('השרון', 'עד 3 שעות', 40),
  DistZone('ירושלים והסביבה', 'יום עסקים', 90),
  DistZone('חיפה והצפון', 'יום עסקים', 120),
];

/// `BULK_TIERS` [L20734] — quantity-discount tiers `{min,discount}`.
@immutable
class BulkTier {
  const BulkTier(this.min, this.discount);
  final int min;
  final int discount;
}

const List<BulkTier> kBulkTiers = [
  BulkTier(1, 0),
  BulkTier(20, 5),
  BulkTier(50, 9),
  BulkTier(100, 14),
];

/// `SUPPLIER_RATINGS` [L20741] — 3 rows `{score,orders,onTime}`. The prototype
/// row names are not transcribed in proto 06 §7, so only the verbatim numbers
/// are modelled (R8 — no invented names).
@immutable
class SupplierRating {
  const SupplierRating(this.score, this.orders, this.onTime);
  final double score;
  final int orders;
  final int onTime;
}

const List<SupplierRating> kSupplierRatings = [
  SupplierRating(4.7, 182, 96),
  SupplierRating(4.4, 140, 91),
  SupplierRating(4.1, 97, 88),
];

/// `SIM_CUSTOMERS` [L17159] / `SIM_SITES` [L17160] — customer + site names the
/// store's "סימולציית הזמנה נכנסת" demo tool stamps onto a generated order.
const List<String> kSimCustomers = [
  'אלי בניין בע״מ',
  'קבלן דוד שמש',
  'י. לוי שיפוצים',
  'מ.כ. הנדסה',
  'אחים ברק בנייה',
];

const List<String> kSimSites = [
  'מגדל יוקרה — רמת גן',
  'וילה פרטית — כפר שמריהו',
  'בניין מגורים — פתח תקווה',
  'שיפוץ דירה — תל אביב',
  'פרויקט מסחרי — ראשל״צ',
];

// ─────────────────────────────────────────────────────────────────────────────
// Stage-bucket helpers (operate on the live order list from sys_orders.dart).
// ─────────────────────────────────────────────────────────────────────────────
extension SysOrderBuckets on List<SysOrder> {
  /// Orders still in the supplier's active queue (new|preparing|ready).
  List<SysOrder> get storeQueue => where(
    (o) =>
        o.stage == OrderStage.newOrder ||
        o.stage == OrderStage.preparing ||
        o.stage == OrderStage.ready,
  ).toList();

  int countAt(OrderStage s) => where((o) => o.stage == s).length;

  /// Σ sum of new+preparing+ready (`todayRevenue`).
  int get todayRevenue => where(
    (o) =>
        o.stage == OrderStage.newOrder ||
        o.stage == OrderStage.preparing ||
        o.stage == OrderStage.ready,
  ).fold(0, (a, o) => a + o.sum);

  /// Courier jobs the [vehicle] can carry, in the active stages, sorted
  /// ready→pickup→transit (proto renderCourierList [L18067]).
  List<SysOrder> courierJobs(String vehicle) {
    const active = [OrderStage.ready, OrderStage.pickup, OrderStage.transit];
    final list =
        where(
          (o) => active.contains(o.stage) && vehicleCanCarry(vehicle, o.haul),
        ).toList()..sort(
          (a, b) =>
              active.indexOf(a.stage).compareTo(active.indexOf(b.stage)),
        );
    return list;
  }
}
