// ⚛️ אטום-Dart (דרגת-חוזה) · connectionMethodLabel
// מוצא: install_engine.dart:111-150 (origin/main — ‏connectionMethodLabel; חוק-4, verbatim).
//        חתימת-main: `String connectionMethodLabel(a, b, {TradeResolution? trade})`
//        (השקע `trade` = תפר-s41 שנוסף ב-main מול ה-snapshot הישן).
//        TradeResolution (מחזיק) = install_engine.dart:99-105 · legacy-branch = :132-149.
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//       ‏enum EndType + מחזיק-הקצה ConnEnd (מחזיקי-קלט טהורים) verbatim מ-
//       lipskey_verified_connections.dart:24,32-36. שתי המתודות על ConnectorEnd —
//       directMatesWith (lvc.dart:38-48) ו-pipeSharedWith (lvc.dart:50-53) — שוכפלו
//       כעוזרים-פרטיים (אטום אינו מייבא טיפוס-דומיין; חוק-1/דיבר-3).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kVerifiedSpecs[a.sku]?.ends` / `[b.sku]?.ends`  (install_engine.dart:132-135)
//     — המפה-הגלובלית קורסת לשקע `endsOf(p) → List<ConnEnd>?` (‏null כשאין spec).
//   • טיפוס-המוצר מופשט לגנריקה <P>; במקור P≡LipskeyCatalogProduct.
//   • `trade` (install_engine.dart:114,120-129) — תפר-הַאֲצָלָה s41. במקור
//     TradeResolution נושא ConnectionResolver + specOf(sku)→ProductConnectorSpec?;
//     שני טיפוסי-הדומיין מופשטים לשקעים טהורים (חוק-1/6):
//       - `specOf(p) → Object?` — מגלם `trade.specOf(a.sku)` (ה-sku מוסתר במוצר,
//         עקבי עם endsOf); Object=spec-אטום. null-לצד-אחד ⇒ '' (מסלול-לא-legacy).
//       - `resolve(sa, sb) → String` — מגלם `trade.resolver.canConnect(sa,sb).methodLabelHe`.
//     חסר `trade` ⇒ null ⇒ נתיב-ללא-trade זהה-ל-snapshot הישן (ביט-זהה).
//
// התנהגות (מקור:111-150):
//   1. תפר-s41 (:120-129): trade!=null **וגם** tradeId!='plumbing' ⇒ מנסים האצלה.
//      אינסטלציה ('plumbing') לעולם אינה נכנסת לפותר (R1-2 KEYSTONE, :116-120).
//      בתוך ה-try: spec לצד-אחד null ⇒ '' (:124). אחרת ⇒ resolve(:125).
//      **כל** חריגה בפותר/spec ⇒ נבלעת שקט ונופלים ל-legacy (kill-switch, :126-129).
//   2. legacy (:132-149): צד ללא-spec (endsOf==null) ⇒ ''. אחרת סורקים זוגות-קצוות;
//      הזוג-הראשון המתאים-ישירות ⇒ תווית לפי-סוג-הקצה של a:
//        pexPress→'Press / טבעת כיווץ' · copperPress→'Press / O-ring' ·
//        bspMale/bspFemale→'תבריג + PTFE' · hdpeCompression→'אום הידוק' ·
//        drainOpening→'כיסוי ניקוז'. אם אין התאמה-ישירה אך יש שיתוף-צינור ⇒
//        'אום הידוק (compression)'. אחרת ⇒ ''.
//
// קלט:  a, b   — שני המוצרים המחוברים (מועברים ל-endsOf / trade.specOf).
//       endsOf — שקע: p → רשימת-קצוות (List<ConnEnd>) או null כשאין spec.
//       trade  — שקע-אופציונלי: תפר-האצלה s41. חסר/null ⇒ legacy בלבד.
// פלט:  String — שם-שיטת-החיבור הפיזית, או '' כשלא-ניתן-לגזור.

/// End connection type (verbatim: lipskey_verified_connections.dart:24).
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }

/// Pure input holder for a connector end (verbatim fields: lvc.dart:32-36).
class ConnEnd {
  final EndType type;
  final String size;
  const ConnEnd(this.type, this.size);
}

/// תפר-האצלה s41 (מחזיק-שקע · verbatim shape: install_engine.dart:99-105).
/// טיפוסי-הדומיין (ConnectionResolver/ProductConnectorSpec) מופשטים לשקעים טהורים:
///   • specOf   — מגלם `trade.specOf(sku)` (ה-sku מוסתר במוצר P); spec כ-Object אטום.
///   • resolve  — מגלם `trade.resolver.canConnect(a,b).methodLabelHe`.
class TradeResolution<P> {
  final String tradeId;
  final Object? Function(P p) specOf;
  final String Function(Object a, Object b) resolve;
  const TradeResolution({
    required this.tradeId,
    required this.specOf,
    required this.resolve,
  });
}

/// `ConnectorEnd.directMatesWith` (verbatim: lvc.dart:38-48).
bool _directMates(ConnEnd a, ConnEnd b) {
  if (a.type == EndType.bspMale && b.type == EndType.bspFemale && a.size == b.size) return true;
  if (a.type == EndType.bspFemale && b.type == EndType.bspMale && a.size == b.size) return true;
  if (a.type == EndType.pexPress && b.type == EndType.pexPress && a.size == b.size) return true;
  if (a.type == EndType.copperPress && b.type == EndType.copperPress && a.size == b.size) return true;
  if (a.type == EndType.drainOpening && b.type == EndType.drainOpening && a.size == b.size) return true;
  return false;
}

/// `ConnectorEnd.pipeSharedWith` (verbatim: lvc.dart:50-53).
bool _pipeShared(ConnEnd a, ConnEnd b) =>
    a.type == EndType.hdpeCompression &&
    b.type == EndType.hdpeCompression &&
    a.size == b.size;

/// The physical join method between two mating products, derived from end types.
/// [trade]: optional s41 authored-trade delegation seam — see [TradeResolution].
String connectionMethodLabel<P>(
  P a,
  P b, {required String Function(String) term, 
  required List<ConnEnd>? Function(P) endsOf,
  TradeResolution<P>? trade,
}) {
  // s41 delegation seam. R1-2 KEYSTONE: plumbing NEVER enters the resolver —
  // unconditional runtime guard (install_engine.dart:116-120). Any resolver/spec
  // failure falls through silently to the legacy branch (kill-switch, :126-129).
  if (trade != null && trade.tradeId != 'plumbing') {
    try {
      final sa = trade.specOf(a);
      final sb = trade.specOf(b);
      if (sa == null || sb == null) return '';
      return trade.resolve(sa, sb);
    } on Object {
      // fall through to legacy — silently, no print (verbatim).
    }
  }

  final ea = endsOf(a), eb = endsOf(b);
  if (ea == null || eb == null) return '';
  for (final eA in ea) {
    for (final eB in eb) {
      if (_directMates(eA, eB)) {
        switch (eA.type) {
          case EndType.pexPress:
            return term('tbat-kyvvts');
          case EndType.copperPress:
            return 'Press / O-ring';
          case EndType.bspMale:
          case EndType.bspFemale:
            return term('tbryg');
          case EndType.hdpeCompression:
            return term('avm-hydvk');
          case EndType.drainOpening:
            return term('kysvy-nykvz');
        }
      }
      if (_pipeShared(eA, eB)) return term('t4');
    }
  }
  return '';
}
