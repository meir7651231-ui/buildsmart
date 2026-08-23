// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · קרנל-דירוג-לקוחות RFM — PURE Dart, אפס Flutter,
// נקי-משעון.
//
// דירוג-לקוח לפי RFM (Recency·Frequency·Monetary) — כל ממד → 0/1/2 נקודות מול
// ספים מוחלטים (לא-אחוזונים → טהור פר-לקוח, בלי צורך באוכלוסייה). Frequency=
// מספר-הזמנות · Monetary=סך-רכש (שניהם על ManagerCustomer) · Recency=ימים-מאז-
// ההזמנה-האחרונה (מחושב בפרוביידר מ-Order.createdAt; null → הממד מושמט, FM-בלבד
// לזרעים חסרי-תאריך). מחזיר מפתח-דרגה (לא תווית — ה-widget ממפה דרך termOf).
//
// אות-פעולה `atRisk`: לקוח שהיה בעל-ערך (F+M גבוה) אך התקרר (recency ישן) — מי
// שכדאי להחזיר. תבנית: attention_engine.dart (DTO-פנימה · ספים-כ-const · טהור).
// ─────────────────────────────────────────────────────────────────────────────

/// ספי-הדירוג (const → חשופים, ניתנים-לכיול, נבדקים).
const int kRfmFreqHigh = 5; // הזמנות ל-Frequency=2
const int kRfmFreqMid = 2; // הזמנות ל-Frequency=1
const int kRfmMoneyHigh = 10000; // ₪ ל-Monetary=2
const int kRfmMoneyMid = 2000; // ₪ ל-Monetary=1
const int kRfmRecentDays = 30; // ימים ל-Recency=2 (טרי)
const int kRfmStaleDays = 90; // ימים ל-Recency=1 (מעבר לזה=0, קר)

/// קלט-הדירוג — הפרוביידר בונה אותו; [recencyDays] null כשאין הזמנה מתוארכת.
class RfmInput {
  const RfmInput({
    required this.orderCount,
    required this.totalSpend,
    this.recencyDays,
  });

  final int orderCount;
  final int totalSpend;
  final int? recencyDays;
}

/// תוצאת-הדירוג. [r] = -1 כשה-recency לא-ידוע (FM-בלבד). [tier] מפתח:
/// `champion`·`loyal`·`occasional`·`dormant`.
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

  final int r; // 0..2, או -1 אם recency לא-ידוע
  final int f; // 0..2
  final int m; // 0..2
  final int points; // סכום הממדים הזמינים
  final int maxPoints; // 4 (FM) או 6 (RFM)
  final String tier; // מפתח-דרגה
  final bool atRisk; // היה בעל-ערך, התקרר

  /// יחס-הדירוג ב-[0,1] — למיון/סינון ("המאתר": מי הכי-בעל-ערך).
  double get ratio => maxPoints == 0 ? 0 : points / maxPoints;
}

int _band(int value, int high, int mid) =>
    value >= high ? 2 : (value >= mid ? 1 : 0);

/// מדרג לקוח בודד. טהור, נקי-משעון (ה-recency כבר בא כמספר-ימים).
CustomerScore scoreCustomer(RfmInput input) {
  final f = _band(input.orderCount, kRfmFreqHigh, kRfmFreqMid);
  final m = _band(input.totalSpend, kRfmMoneyHigh, kRfmMoneyMid);
  final rd = input.recencyDays;
  // recency: טרי=2, מתיישן=1, קר/לא-ידוע→ר=-1 (מושמט מ-max) או 0.
  final int r;
  if (rd == null) {
    r = -1; // לא-ידוע — FM בלבד
  } else if (rd <= kRfmRecentDays) {
    r = 2;
  } else if (rd <= kRfmStaleDays) {
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
