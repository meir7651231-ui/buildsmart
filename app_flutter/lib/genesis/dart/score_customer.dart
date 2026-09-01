// ⚛️ אטום-Dart (דרגת-חוזה) · scoreCustomer
// מוצא: buildsmart/app_flutter/lib/logic/customer_score.dart:65-110 (חוק-4).
//        הקובץ אינו קיים עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: ניקוד-RFM טהור. הטבעות ושקעים:
//        · `RfmInput` / `CustomerScore` — data-classes-שכנים קטנים ⇒ הוטבעו inline verbatim
//          (רק השדות שהטיוטה חושפת: orderCount/totalSpend/recencyDays · r/f/m/points/
//          maxPoints/tier/atRisk).
//        · `_band(v, high, mid)` — עוזר-שכן פרטי שגופו **אינו בטיוטה**; הוסק מהחשבון
//          (‏maxPoints=6 עם 3 רכיבים ⇒ כל רכיב ∈{0,1,2}; שני-ספים High/Mid) ⇒
//          `v>=high?2:v>=mid?1:0`. מתועד כהסקה.
//        · `kRfmFreqHigh/Mid`, `kRfmMoneyHigh/Mid`, `kRfmRecentDays`, `kRfmStaleDays` —
//          const-שכנים לא-ניתנים-לשחזור ⇒ שקעים בשם, ברירות-מחדל מוסקות ומתועדות.
//
// פלט:  CustomerScore (r/f/m/points/maxPoints/tier/atRisk).

/// Immutable RFM inputs (inlined neighbour data-class, verbatim fields).
class RfmInput {
  const RfmInput({
    required this.orderCount,
    required this.totalSpend,
    this.recencyDays,
  });

  /// Number of orders (the Frequency axis).
  final int orderCount;

  /// Total spend (the Monetary axis).
  final num totalSpend;

  /// Days since the last order; `null` = unknown (Recency dropped from the max).
  final int? recencyDays;
}

/// Immutable RFM verdict (inlined neighbour data-class, verbatim fields).
class CustomerScore {
  const CustomerScore({
    required this.r,
    required this.f,
    required this.m,
    required this.points,
    required this.maxPoints,
    required this.tier,
    required this.atRisk,
  });

  /// Recency band: 2 fresh · 1 stale · 0 cold · -1 unknown (dropped from max).
  final int r;

  /// Frequency band 0..2.
  final int f;

  /// Monetary band 0..2.
  final int m;

  /// Summed points (F + M + R, R only when known).
  final int points;

  /// Denominator: 6 when recency is known, else 4.
  final int maxPoints;

  /// One of `champion` / `loyal` / `occasional` / `dormant`.
  final String tier;

  /// Was valuable (F+M ≥ 3 of 4) but went cold (recency known and cold).
  final bool atRisk;
}

// הוסק — ראה כותרת. `v >= high ? 2 : (v >= mid ? 1 : 0)`.
int _band(num v, num high, num mid) => v >= high ? 2 : (v >= mid ? 1 : 0);

/// Score a customer from RFM [input]. Verbatim logic of customer_score.dart:65-110
/// with `_band` inferred and the six thresholds injected as sockets.
CustomerScore scoreCustomer(
  RfmInput input, {
  num freqHigh = 5,
  num freqMid = 2,
  num moneyHigh = 1000,
  num moneyMid = 300,
  int recentDays = 30,
  int staleDays = 90,
}) {
  final f = _band(input.orderCount, freqHigh, freqMid);
  final m = _band(input.totalSpend, moneyHigh, moneyMid);
  final rd = input.recencyDays;
  // recency: טרי=2, מתיישן=1, קר/לא-ידוע→ר=-1 (מושמט מ-max) או 0.
  final int r;
  if (rd == null) {
    r = -1; // לא-ידוע — FM בלבד
  } else if (rd <= recentDays) {
    r = 2;
  } else if (rd <= staleDays) {
    r = 1;
  } else {
    r = 0; // קר
  }

  final hasR = r >= 0;
  final points = f + m + (hasR ? r : 0);
  final maxPoints = hasR ? 6 : 4;
  final ratio = maxPoints == 0 ? 0.0 : points / maxPoints;

  final String tier;
  if (ratio >= 0.75) {
    tier = 'champion';
  } else if (ratio >= 0.5) {
    tier = 'loyal';
  } else if (ratio >= 0.25) {
    tier = 'occasional';
  } else {
    tier = 'dormant';
  }

  // בסיכון: היה בעל-ערך (F+M≥3 מתוך 4) אך התקרר (recency ידוע וקר).
  final atRisk = hasR && r == 0 && (f + m) >= 3;

  return CustomerScore(
    r: r,
    f: f,
    m: m,
    points: points,
    maxPoints: maxPoints,
    tier: tier,
    atRisk: atRisk,
  );
}
