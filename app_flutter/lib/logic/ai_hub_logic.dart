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
    show BrandTier, ProductBrands, kHomeProductBrands;
import 'package:buildsmart/data/related_info.dart' show cheaperAlternativeBrand;
import 'package:buildsmart/data/smart_tree.dart' show SmartBrand, SmartProduct;
import 'package:buildsmart/screens/home_shell.dart'
    show CheaperAlt, cheaperAlternativesAcrossCatalog;

// ─── 62. PREDICTIVE STOCK — proto preds @21157-21162 ──────────────────────────
class StockPred {
  const StockPred({
    required this.name,
    required this.stock,
    required this.rate,
    required this.days,
  });

  final String name;
  final int stock;
  final int rate;
  final int days;

  bool get urgent => days <= 3;
}

const List<StockPred> kStockPreds = [
  StockPred(name: 'שק מלט 25 ק״ג', stock: 42, rate: 14, days: 3),
  StockPred(name: 'ברזל זיון 12מ״מ', stock: 180, rate: 22, days: 8),
  StockPred(name: 'צינור PEX 16מ״מ', stock: 24, rate: 18, days: 1),
  StockPred(name: 'דבק אריחים', stock: 96, rate: 8, days: 12),
];

// ─── 64. VOICE-TO-TASK transcript samples — proto samples @21219-21221 ─────────
const List<String> kVoiceSamples = [
  'להזמין 20 שקי מלט לאתר הרצליה',
  'לתאם ביקורת מהנדס ליום חמישי',
  'לבדוק אטימה בחדר רחצה קומה 3',
];

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

// ─── 66. PDF PLAN SCAN result — proto items @21284-21289 ──────────────────────
class PlanItem {
  const PlanItem({required this.name, required this.qty});

  final String name;
  final String qty;
}

const List<PlanItem> kPlanResult = [
  PlanItem(name: 'אריחי קרמיקה 60×60', qty: '48 מ״ר'),
  PlanItem(name: 'דבק אריחים', qty: '12 שקים'),
  PlanItem(name: 'רובה למישקים', qty: '4 ק״ג'),
  PlanItem(name: 'פרופיל פינה', qty: '18 מטר'),
];

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

const List<Insight> kInsights = [
  Insight(ic: '📈', title: 'הרכש עלה ב-12% החודש', sub: 'בעיקר בקטגוריית גמר'),
  Insight(ic: '⏱️', title: 'זמן אספקה ממוצע: 2.4 שעות', sub: 'שיפור של 18% מהחודש שעבר'),
  Insight(ic: '💰', title: 'חיסכון אפשרי: ₪3,200', sub: 'מעבר לספקים זולים יותר'),
  Insight(ic: '⚠️', title: '3 הזמנות חרגו מ-SLA', sub: 'מומלץ לבדוק את ספק הצפון'),
];
