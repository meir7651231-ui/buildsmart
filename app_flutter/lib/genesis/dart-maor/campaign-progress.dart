// ⚛️ אטום-Dart (דרגת-חוזה) · campaignProgress — מדדי-התקדמות של מבצע-קופות.
// מוצא: maor/src/components/tzedaka/lib.ts:149-154 · המקור: new/atoms/campaign-progress.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core + dart:math ל-min).
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// שקע (חוק-1): campaignTotal — השכן שהוזרק כפרמטר; מסכם את סכומי-הריקונים של
//        המבצע. num Function(List boxes, Object? campaignId).
// קלט: campaign (Map עם id ו-goal אופציונלי) · boxes (List) · השקע campaignTotal.
// פלט: Map<String,num>{'sum','goal','pct'}.
//
// הערות-המרה (מקור→Dart):
//   • `campaign.goal || 0` (truthiness) — goal=0/חסר/null ⇒ 0, אחרת הערך.
//   • `Math.round` (חצי-כלפי-מעלה, ערכים אי-שליליים בלבד בחוזה) ⇒ `.round()` ב-Dart.
//   • `Math.min(100, …)` ⇒ `min` מ-dart:math. אין locale/פורמט/getMonth.
import 'dart:math';

/// Progress metrics for a tzedaka campaign. Verbatim behaviour of the JS source
/// `campaignProgress`: sums the campaign's box collections via the injected
/// [campaignTotal] socket, reads the goal (falsy ⇒ 0), and computes the capped
/// rounded percentage (0 when goal ≤ 0).
Map<String, num> campaignProgress(
  Map campaign,
  List boxes,
  num Function(List boxes, Object? campaignId) campaignTotal,
) {
  final num sum = campaignTotal(boxes, campaign['id']);
  final goalRaw = campaign['goal'];
  final num goal = (goalRaw is num && goalRaw != 0) ? goalRaw : 0;
  final int pct = goal > 0 ? min(100, ((sum / goal) * 100).round()) : 0;
  return {'sum': sum, 'goal': goal, 'pct': pct};
}
