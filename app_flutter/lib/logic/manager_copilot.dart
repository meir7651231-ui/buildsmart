// ─────────────────────────────────────────────────────────────────────────────
// Manager Co-Pilot — "שאל את העסק שלך" (M2 · the owner's AI analyst).
//
// PURE + testable: builds a GROUNDED Hebrew snapshot of the live business state
// (KPIs · pipeline · top customers · credit · catalog) and the prompts that hand
// it to Claude. The model REASONS OVER TRUTH and is forbidden to invent any
// number/name not in the context — every figure here is folded from the real
// `ordersEngineProvider`/`managerCustomersProvider` by the screen, never the model.
//
// ANTI-HALLUCINATION: the system prompt pins "answer ONLY from מצב-העסק; if the
// datum is absent say so; never invent". The owner's question is length-capped
// (`promptSafeText`) before interpolation.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/manager_dashboard.dart'
    show ManagerAnalytics, ManagerCustomer;
import 'package:buildsmart/logic/prompt_sanitize.dart' show promptSafeText;

/// Short Hebrew label per order stage (canonical `kManagerOrderFlow` order).
const Map<String, String> kCopilotStageLabel = {
  'new': 'התקבלה',
  'preparing': 'בהכנה',
  'ready': 'מוכן',
  'pickup': 'נאסף',
  'transit': 'בדרך',
  'delivered': 'נמסר',
};

/// Suggested owner questions (chips) — phrased like a real owner would ask.
const List<String> kManagerCopilotSuggestions = [
  'מה בוער עכשיו?',
  'מי הלקוח הכי שווה?',
  'איפה יש סיכון-אשראי?',
  'מה תקוע בהזמנות?',
  'כמה מכרנו עד עכשיו?',
];

/// The grounded analyst system prompt — REASON OVER TRUTH, never invent.
const String managerCopilotSystem =
    'אתה האנליסט-העסקי האישי של בעל אפליקציית-אינסטלציה (BuildSmart). ענה בעברית, '
    'קצר וחד וישיר, אך ורק לפי הנתונים שתחת "מצב-העסק". אסור להמציא מספר, שם, או '
    'עובדה שלא מופיעים שם — אם המידע חסר אמור בכנות "אין לי על זה נתון". כשרלוונטי, '
    'הוסף שורת-תובנה אחת או המלצת-פעולה אחת. בלי הקדמות ובלי נימוסים מיותרים.';

/// Build the compact, GROUNDED business snapshot that anchors every answer.
/// All inputs are real, engine-folded values supplied by the screen. [stageCounts]
/// maps an order stage → live count. Revenue + order-total are derived from
/// [customers] (Σ spend / Σ orderCount) so they match the dashboard exactly.
String buildManagerContext({
  required ManagerAnalytics analytics,
  required List<ManagerCustomer> customers,
  required Map<String, int> stageCounts,
}) {
  final revenue =
      customers.fold<int>(0, (s, c) => s + c.totalSpend);
  final totalOrders =
      customers.fold<int>(0, (s, c) => s + c.orderCount);

  String money(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '₪$b';
  }

  // Pipeline line in canonical stage order, only stages with a count.
  final pipe = [
    for (final e in kCopilotStageLabel.entries)
      if ((stageCounts[e.key] ?? 0) > 0) '${e.value} ${stageCounts[e.key]}',
  ].join(' · ');

  // Top customers by spend (already sorted desc) — name, spend, orders, credit %.
  final top = [
    for (final c in customers.take(5))
      '  - ${c.name}: ${money(c.totalSpend)} ב-${c.orderCount} הזמנות'
          '${c.creditLimit > 0 ? ' (ניצול-אשראי ${((c.totalSpend / c.creditLimit) * 100).round()}%)' : ''}',
  ].join('\n');

  final creditLimitTotal =
      customers.fold<int>(0, (s, c) => s + c.creditLimit);

  final b = StringBuffer()
    ..writeln('— הזמנות: סה"כ $totalOrders · פתוחות ${analytics.openOrders} · מחזור ${money(revenue)}')
    ..writeln('— צינור-ההזמנות: ${pipe.isEmpty ? 'אין הזמנות' : pipe}')
    ..writeln('— קטלוג: ${analytics.catalogCount} מוצרים · ${analytics.categoryCount} קטגוריות · חנויות פעילות ${analytics.storesLabel}')
    ..writeln('— אשראי (פיקוח): סך-מסגרות ${money(creditLimitTotal)} · סך-ניצול ${money(revenue)}')
    ..writeln('— לקוחות מובילים (לפי רכש):')
    ..write(top.isEmpty ? '  (אין לקוחות עדיין)' : top);
  return b.toString();
}

/// The grounded Q&A prompt — context + the owner's (capped) question.
String managerCopilotPrompt(String context, String question) {
  final q = promptSafeText(question, maxLen: 400);
  return 'מצב-העסק כעת (נתוני-אמת):\n$context\n\n'
      'שאלת-הבעלים: "$q"\n'
      'ענה בעברית, אך ורק לפי הנתונים שלמעלה.';
}

/// One-tap "morning brief" — Claude flags what needs attention today.
String managerMorningBriefPrompt(String context) {
  return 'מצב-העסק כעת (נתוני-אמת):\n$context\n\n'
      'כתוב תדריך-בוקר קצר לבעלים: 3-4 נקודות-תבליט על מה שדורש תשומת-לב היום '
      '(הזמנות תקועות/פתוחות, ניצול-אשראי גבוה, מגמת-מחזור, לקוח בולט). '
      'אך ורק לפי הנתונים שלמעלה — בלי להמציא. פתח ב-"☀️ תדריך-בוקר:".';
}
