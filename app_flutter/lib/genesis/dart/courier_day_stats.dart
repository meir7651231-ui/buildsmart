// ⚛️ אטום-Dart (דרגת-חוזה) · courierDayStats
// מוצא: buildsmart/app_flutter/lib/screens/courier_reports_tab.dart:571-597
//        (‏_openAiCourierReport) ≡ :622-657 (‏_sendDailyReport) — שתי-ההופעות
//        כמעט-זהות; חולץ אטום-אחד טהור (חוק-4 — התנהגות verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core).
//
// שקעים שהוזרקו (קריאה-לשכן / שעון ⇒ פרמטר-שקע · חוק-1/3/6, דיבר-3/8):
//   • orders + fulfillment[o.id] + clock[o.id]  (reports_tab:571-597) — שלוש
//     המפות שטוחות למחזיק-קלט יחיד `CourierDelivery`: כל משלוח מחזיק רק את
//     השדות הנקראים (stage · sum · courierUser · podCaptured · deliveredAt).
//     • stage: OrderStage בקוד ⇒ כאן מחרוזת ('delivered'/'ready'/'pickup'/
//       'transit'/…). המונים משווים לפי אותן מחרוזות-מפתח (התנהגות זהה).
//     • courierUser: fulfillment[o.id]?.courierUser (יכול null בלגאסי).
//     • podCaptured: fulfillment[o.id]?.podCaptured ?? false — ברירת-המחדל false.
//     • deliveredAt: clock[o.id]?.deliveredAt (יכול null).
//   • s.username  (BoardAuthSession) ⇒ שקע `username` — זהות, לא-אטום (חוק-6).
//   • DateTime.now() → today  (reports_tab:592-593) ⇒ שקע `today` — חצות היום
//     (DateTime(y,m,d)); שעון אסור באטום (חוק-6/דיבר-8). המחשב-הקורא מזריק
//     DateTime(now.year, now.month, now.day) כפי שהמקור עושה.
//
// קלט:  deliveries — List<CourierDelivery> (כל המשלוחים במערכת, שטוחים).
//       username   — שקע-זהות: שם-המשתמש של השליח המחובר.
//       today      — שקע-שעון: חצות היום (DateTime(y,m,d)).
// פלט:  CourierDayStats — חמשת המונים (deliveredToday · mineCount · active ·
//       podCount · deliveredSum).

/// מחזיק-קלט טהור: רק חמשת השדות ש-courierDayStats קורא (reports_tab:571-597).
class CourierDelivery {
  /// מפתח-שלב ('delivered'/'ready'/'pickup'/'transit'/…) — OrderStage במקור.
  final String stage;

  /// ערך כספי של ההזמנה (o.sum).
  final int sum;

  /// fulfillment[o.id]?.courierUser — מי השליח שביצע (null בלגאסי לא-מיוחס).
  final String? courierUser;

  /// fulfillment[o.id]?.podCaptured ?? false — האם נלכד POD.
  final bool podCaptured;

  /// clock[o.id]?.deliveredAt — מתי נמסר בפועל (null אם אין רישום-שעון).
  final DateTime? deliveredAt;

  const CourierDelivery({
    required this.stage,
    this.sum = 0,
    this.courierUser,
    this.podCaptured = false,
    this.deliveredAt,
  });
}

/// חמשת המונים המוצגים בדוח-היום ובדוח-ה-AI (reports_tab:600-606 / 660-665).
class CourierDayStats {
  /// נמסרו-היום ע"י השליח (נמדד מ-deliveredAt מול today).
  final int deliveredToday;

  /// סך נמסרו ע"י השליח (mine.length).
  final int mineCount;

  /// משלוחים פעילים — כלל-מערכתי (ready/pickup/transit).
  final int active;

  /// POD שנלכדו ע"י השליח.
  final int podCount;

  /// סך-הערך הכספי שנמסר ע"י השליח.
  final int deliveredSum;

  const CourierDayStats({
    required this.deliveredToday,
    required this.mineCount,
    required this.active,
    required this.podCount,
    required this.deliveredSum,
  });
}

/// אגרגציית מוני-היום של השליח — verbatim של courier_reports_tab.dart:571-597.
/// [today] = חצות היום (שקע-שעון); [username] = זהות-השליח (שקע-זהות).
CourierDayStats courierDayStats(
  List<CourierDelivery> deliveries, {
  required String username,
  required DateTime today,
}) {
  // delivered = orders where stage == delivered  (reports_tab:576)
  final delivered = deliveries.where((o) => o.stage == 'delivered').toList();
  // mine = delivered where courierUser == username  (reports_tab:577-579)
  final mine = delivered.where((o) => o.courierUser == username).toList();
  // deliveredSum = Σ mine.sum  (reports_tab:580)
  final deliveredSum = mine.fold<int>(0, (a, o) => a + o.sum);
  // active = orders where stage ∈ {ready,pickup,transit}  (reports_tab:581-586)
  const activeStages = ['ready', 'pickup', 'transit'];
  final active = deliveries.where((o) => activeStages.contains(o.stage)).length;
  // podCount = orders where courierUser == username && podCaptured  (:587-591)
  final podCount = deliveries
      .where((o) => o.courierUser == username && o.podCaptured)
      .length;
  // deliveredToday = mine where deliveredAt on `today`  (reports_tab:594-597)
  final deliveredToday = mine.where((o) {
    final d = o.deliveredAt;
    return d != null && DateTime(d.year, d.month, d.day) == today;
  }).length;

  return CourierDayStats(
    deliveredToday: deliveredToday,
    mineCount: mine.length,
    active: active,
    podCount: podCount,
    deliveredSum: deliveredSum,
  );
}
