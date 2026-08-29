// 🤖 מרכז-AI — pure logic + seed data for the AI hub (T3.H).
//
// Faithful port of proto Category G — AI & AUTOMATION (index.html:21123-21400,
// `openAIHub` @21123). Nine tools; barcode + voice are REAL (they drive the
// catalog's live [searchQueryProvider] — wired in the screen), the rest show a
// SIMULATED on-screen AI result (NOT a toast):
//   • aiPredictStock   @21155 — stock run-out prediction.
//   • aiAlternatives   @21232 — cheaper same-product brand options. REUSES the
//                              [cheaperAlternativeBrand] helper + catalog data.
//   • aiPlanResult     @21283 — PDF plan → bill-of-materials.
//   • aiThreeWay       @21303 — order/delivery/invoice match.
//   • aiWeather        @21333 — forecast-driven scheduling.
//   • aiWearDetect     @21355 — equipment wear.
//   • aiAnalytics      @21383 — smart insights.
//
// All numbers/strings are VERBATIM from the prototype (R8).

import 'package:buildsmart/data/contractor_seeds.dart'
    show
        BrandTier,
        ProductBrands,
        fMoney,
        kBudgetSpent,
        kBudgetTotal,
        kHomeProductBrands;
import 'package:buildsmart/data/related_info.dart' show cheaperAlternativeBrand;
import 'package:buildsmart/data/smart_tree.dart' show SmartBrand, SmartProduct;
import 'package:buildsmart/screens/contractor_tools_sheets.dart'
    show CheaperAlt, cheaperAlternativesAcrossCatalog;
import 'package:buildsmart/state/orders_engine.dart' show Order;
import 'package:buildsmart/state/smart_cart.dart' show SmartCartLine;

// ─── 62. PREDICTIVE STOCK — proto preds @21157-21162 ──────────────────────────
class StockPred {
  const StockPred({
    required this.name,
    required this.stock,
    required this.rate,
    required this.days,
    this.emoji = '📦',
    this.unitPrice = 0,
  });

  final String name;
  final int stock;
  final int rate;
  final int days;

  /// The product emoji, carried verbatim from the order line that generated
  /// this forecast (defaults to 📦 for the proto seed, which has none). Real
  /// captured data — lets "הזמן עכשיו" rebuild a faithful cart line.
  final String emoji;

  /// Unit price (₪) of the product, derived from the most-recent order line
  /// that consumed it (`lineTotal / qty`, rounded). 0 for the proto seed.
  final int unitPrice;

  bool get urgent => days <= 3;
}

/// Proto demo seed — kept ONLY as the verbatim reference the proto shipped (the
/// `t3_ghi` DoD guard still pins its shape). The hub no longer RENDERS this: the
/// 📦 חיזוי מלאי tool now COMPUTES its forecast from the live orders engine +
/// cart via [computeStockForecast] (see the screen). Not wired to the UI.
const List<StockPred> kStockPreds = [
  StockPred(name: 'שק מלט 25 ק״ג', stock: 42, rate: 14, days: 3),
  StockPred(name: 'ברזל זיון 12מ״מ', stock: 180, rate: 22, days: 8),
  StockPred(name: 'צינור PEX 16מ״מ', stock: 24, rate: 18, days: 1),
  StockPred(name: 'דבק אריחים', stock: 96, rate: 8, days: 12),
];

/// 🟢 REAL — predictive-stock forecast computed from in-app data, NOT a model.
///
/// Inputs are the live providers (the screen passes `ref.watch`ed values):
///   • [orders]  — the shared orders engine (`ordersEngineProvider`). Each
///                 placed order carries its captured line items (name·qty), the
///                 genuine consumption history.
///   • [cart]    — the live `smartCartProvider`: what is staged on-hand right
///                 now (the most recent replenishment not yet ordered).
///
/// Per product (keyed by line name), DETERMINISTICALLY:
///   • consumed  = Σ qty across ALL order lines for that name (real usage).
///   • spanDays  = days between the earliest and latest order carrying it
///                 (≥ 1 — a single order ⇒ a 1-day window), using [now] as the
///                 anchor for any order missing a timestamp.
///   • rate      = max(1, round(consumed / spanDays)) units/day.
///   • stock     = current on-hand = this product's qty in the live [cart]
///                 (0 when none staged).
///   • days      = round(stock / rate) — runway until it runs out.
/// Urgent (`StockPred.urgent`) when `days <= 3`, exactly the proto rule.
///
/// Honest empty: with only the seed orders (no captured lines) the history is
/// empty, so the result is empty and the UI shows an honest "no data yet" note
/// — never invented rows. Sorted by soonest run-out, urgent first.
List<StockPred> computeStockForecast(
  List<Order> orders,
  List<SmartCartLine> cart, {
  DateTime? now,
}) {
  final anchor = now ?? DateTime.now();

  // On-hand per product name from the live cart (real staged stock).
  final onHand = <String, int>{};
  for (final l in cart) {
    onHand[l.productName] = (onHand[l.productName] ?? 0) + l.productQty;
  }

  // Consumption history per product name from the order lines. Alongside the
  // run-out math we capture the REAL emoji + unit price from the most-recent
  // order line carrying each name — genuine captured purchase data the cart
  // needs so "הזמן עכשיו" rebuilds a faithful line (no fabricated fields).
  final consumed = <String, int>{};
  final firstSeen = <String, DateTime>{};
  final lastSeen = <String, DateTime>{};
  final emojiByName = <String, String>{};
  final unitPriceByName = <String, int>{};
  for (final o in orders) {
    final ts = o.createdAt ?? anchor;
    for (final li in o.lines) {
      consumed[li.name] = (consumed[li.name] ?? 0) + li.qty;
      final f = firstSeen[li.name];
      if (f == null || ts.isBefore(f)) firstSeen[li.name] = ts;
      final l = lastSeen[li.name];
      if (l == null || !ts.isBefore(l)) {
        // On the latest line for this name, snapshot its emoji + unit price
        // (line total / qty). `!isBefore` (>= ) keeps the last writer to win
        // within the same timestamp.
        lastSeen[li.name] = ts;
        emojiByName[li.name] = li.emoji;
        unitPriceByName[li.name] = li.qty > 0 ? (li.price / li.qty).round() : 0;
      }
    }
  }

  final out = <StockPred>[];
  for (final name in consumed.keys) {
    final used = consumed[name]!;
    if (used <= 0) continue;
    final span = lastSeen[name]!.difference(firstSeen[name]!).inDays;
    final spanDays = span < 1 ? 1 : span;
    final rate = (used / spanDays).round();
    final r = rate < 1 ? 1 : rate;
    final stock = onHand[name] ?? 0;
    final days = (stock / r).round();
    out.add(StockPred(
      name: name,
      stock: stock,
      rate: r,
      days: days,
      emoji: emojiByName[name] ?? '📦',
      unitPrice: unitPriceByName[name] ?? 0,
    ));
  }

  out.sort((a, b) {
    final byDays = a.days.compareTo(b.days);
    return byDays != 0 ? byDays : a.name.compareTo(b.name);
  });
  return out;
}

// ─── 65. CHEAPER ALTERNATIVES — proto aiAlternatives @21232 ───────────────────
// REUSES [cheaperAlternativeBrand] + catalog data. The smart-tree brands carry
// no curated price ("מחיר לפי ספק"), so the AI hub builds priced [SmartProduct]s
// from the verbatim [kHomeProductBrands] tiers and runs the real comparison
// helper over each — genuinely exercising `cheaperAlternativeBrand`. Results are
// merged with the home sheet's [cheaperAlternativesAcrossCatalog] (same data
// source) and de-duplicated, then sorted by savings desc, top-5 (proto @21255).

class AiAlt {
  const AiAlt({
    required this.cat,
    required this.fromName,
    required this.fromPrice,
    required this.toName,
    required this.toPrice,
  });

  final String cat;
  final String fromName;
  final int fromPrice;
  final String toName;
  final int toPrice;

  int get save => fromPrice - toPrice;
}

/// Build a priced [SmartProduct] from one [ProductBrands] tier list, so the
/// real [cheaperAlternativeBrand] helper can run over actual catalog prices.
SmartProduct _pricedSmartProduct(ProductBrands pb) => SmartProduct(
      key: pb.product,
      name: pb.product,
      emoji: '📦',
      cat: pb.product,
      brands: [
        for (final BrandTier t in pb.tiers)
          SmartBrand(name: t.brand, tag: '', price: t.price, rec: t.rec),
      ],
      acc: const [],
    );

List<AiAlt> aiAlternatives() {
  final out = <AiAlt>[];
  final seen = <String>{};

  // 1) The real helper over priced catalog products (reuses cheaperAlternativeBrand).
  for (final pb in kHomeProductBrands) {
    final sp = _pricedSmartProduct(pb);
    final recI = sp.brands.indexWhere((b) => b.rec);
    final rec = sp.brands[recI >= 0 ? recI : 0];
    final alt = cheaperAlternativeBrand(sp, recI >= 0 ? recI : 0);
    if (alt == null || rec.price == null) continue;
    if (!seen.add(pb.product)) continue;
    out.add(AiAlt(
      cat: pb.product,
      fromName: rec.name,
      fromPrice: rec.price!,
      toName: alt.name,
      toPrice: alt.price,
    ));
  }

  // 2) Merge the home sheet's own cross-catalog scan (same data, sorted) for
  //    any product not already covered.
  for (final CheaperAlt a in cheaperAlternativesAcrossCatalog()) {
    if (!seen.add(a.product)) continue;
    out.add(AiAlt(
      cat: a.product,
      fromName: a.recName,
      fromPrice: a.recPrice,
      toName: a.altName,
      toPrice: a.altPrice,
    ));
  }

  out.sort((a, b) => b.save.compareTo(a.save));
  return out.length > 5 ? out.sublist(0, 5) : out;
}

// ─── 67. THREE-WAY MATCHING — proto docs @21308-21312 ─────────────────────────
class ThreeWayDoc {
  const ThreeWayDoc({
    required this.id,
    required this.order,
    required this.delivery,
    required this.invoice,
  });

  final String id;
  final int order;
  final int delivery;
  final int invoice;

  bool get match => order == delivery && delivery == invoice;
}

const List<ThreeWayDoc> kThreeWayDocs = [
  ThreeWayDoc(id: 'BS-1041', order: 8400, delivery: 8400, invoice: 8400),
  ThreeWayDoc(id: 'BS-1042', order: 5200, delivery: 5200, invoice: 5460),
  ThreeWayDoc(id: 'BS-1039', order: 3100, delivery: 2900, invoice: 3100),
];

// ─── 68. WEATHER AUTOMATION — proto fc @21338-21343 ───────────────────────────
class WeatherDay {
  const WeatherDay({
    required this.day,
    required this.ic,
    required this.temp,
    required this.note,
  });

  final String day;
  final String ic;
  final String temp;
  final String note;

  bool get warn => note.contains('⚠️');
}

const List<WeatherDay> kWeather = [
  WeatherDay(day: 'היום', ic: '☀️', temp: '28°', note: 'מזג אוויר אידיאלי ליציקות'),
  WeatherDay(day: 'מחר', ic: '⛅', temp: '24°', note: 'מתאים לעבודות גמר'),
  WeatherDay(day: 'יום ג׳', ic: '🌧️', temp: '17°', note: '⚠️ גשם — לדחות יציקות בטון'),
  WeatherDay(day: 'יום ד׳', ic: '🌧️', temp: '16°', note: '⚠️ גשם — עבודות פנים בלבד'),
];

// ─── 69. EQUIPMENT WEAR — proto gear @21361-21366 ─────────────────────────────
class GearWear {
  const GearWear({
    required this.name,
    required this.hours,
    required this.life,
    required this.ic,
  });

  final String name;
  final int hours;
  final int life;
  final String ic;

  int get pct => (hours / life * 100).round();
  bool get worn => pct >= 85;
}

const List<GearWear> kGear = [
  GearWear(name: 'מערבל בטון', hours: 420, life: 500, ic: '🛢️'),
  GearWear(name: 'פטיש חשמלי', hours: 180, life: 600, ic: '🔨'),
  GearWear(name: 'גנרטור 5kW', hours: 880, life: 900, ic: '⚡'),
  GearWear(name: 'מסור דיסק', hours: 95, life: 400, ic: '⚙️'),
];

// ─── 70. SMART ANALYTICS — proto insights @21387-21391 ────────────────────────
class Insight {
  const Insight({required this.ic, required this.title, required this.sub});

  final String ic;
  final String title;
  final String sub;
}

/// Proto demo seed — kept ONLY as the verbatim reference (the `t3_ghi` guard
/// still pins its length). The hub no longer RENDERS this: 📊 Analytics חכם now
/// COMPUTES its insights from the live orders engine + budget + the real
/// cheaper-alternatives scan via [computeAnalyticsInsights]. Not wired to UI.
const List<Insight> kInsights = [
  Insight(ic: '📈', title: 'הרכש עלה ב-12% החודש', sub: 'בעיקר בקטגוריית גמר'),
  Insight(ic: '⏱️', title: 'זמן אספקה ממוצע: 2.4 שעות', sub: 'שיפור של 18% מהחודש שעבר'),
  Insight(ic: '💰', title: 'חיסכון אפשרי: ₪3,200', sub: 'מעבר לספקים זולים יותר'),
  Insight(ic: '⚠️', title: '3 הזמנות חרגו מ-SLA', sub: 'מומלץ לבדוק את ספק הצפון'),
];

/// 🟢 REAL — smart-analytics insights computed from in-app data, NOT a model.
///
/// Folds the LIVE shared orders engine ([orders] = `ordersEngineProvider`)
/// together with the budget seeds and the real cheaper-alternatives scan
/// ([aiAlternatives], itself a fold over the catalog price tiers). Every line is
/// a deterministic aggregate — no invented numbers, no language model:
///   • 📦 total orders + Σ spend       — `orders.length`, `Σ o.sum`.
///   • 💵 average order value          — `round(Σ spend / orders.length)`.
///   • 🚚 open vs delivered            — `where(isOpen).length` / total.
///   • 💰 possible savings             — `Σ aiAlternatives().save` (real catalog
///                                       recommended-vs-cheaper deltas).
///   • 📊 budget utilization           — `round(kBudgetSpent/kBudgetTotal*100)`
///                                       + remaining `kBudgetTotal-kBudgetSpent`.
/// Stable order; with the seed-only engine every number is reproducible.
List<Insight> computeAnalyticsInsights(List<Order> orders) {
  final out = <Insight>[];

  final orderCount = orders.length;
  final totalSpend = orders.fold<int>(0, (s, o) => s + o.sum);
  final openCount = orders.where((o) => o.isOpen).length;
  final deliveredCount = orderCount - openCount;

  if (orderCount > 0) {
    out.add(Insight(
      ic: '📦',
      title: '$orderCount הזמנות · ${fMoney(totalSpend)} סה״כ רכש',
      sub: 'מתוך מנוע ההזמנות המשותף',
    ));
    final avg = (totalSpend / orderCount).round();
    out
      ..add(Insight(
        ic: '💵',
        title: 'שווי הזמנה ממוצע: ${fMoney(avg)}',
        sub: 'ממוצע על פני כל ההזמנות',
      ))
      ..add(Insight(
        ic: '🚚',
        title: '$openCount הזמנות פתוחות · $deliveredCount סופקו',
        sub: 'לפי שלב ההזמנה הנוכחי',
      ));
  }

  final savings = aiAlternatives().fold<int>(0, (s, a) => s + a.save);
  if (savings > 0) {
    out.add(Insight(
      ic: '💰',
      title: 'חיסכון אפשרי: ${fMoney(savings)}',
      sub: 'מעבר למותגים זולים יותר באותו מוצר',
    ));
  }

  final budgetPctValue =
      kBudgetTotal > 0 ? (kBudgetSpent / kBudgetTotal * 100).round() : 0;
  const budgetLeft = kBudgetTotal - kBudgetSpent;
  out.add(Insight(
    ic: '📊',
    title: 'ניצול תקציב: $budgetPctValue%',
    sub: 'נותרו ${fMoney(budgetLeft)} מתוך ${fMoney(kBudgetTotal)}',
  ));

  return out;
}
