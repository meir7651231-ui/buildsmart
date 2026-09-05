// ⚛️ אטום-Dart (דרגת-חוזה) · explainOne — תיאור-שיחה יחיד:
//    קונפיג-טלפוניה ⇒ tenant ⇒ אימות ⇒ סימולציה, ומחזיר {summary, outcome, reason}.
// מוצא: maor/src/components/telephony/lib.ts:199-206 · המקור: new/atoms/explain-one.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקעים (חוק-1, הוזרקו כשכנים מהמקור): telephonyToTenant / validateTenant /
//    explainCall / anchorToday — כולם פונקציות. ה-tenant/הוואל/התוצאה = Maps.
// זרימה: raw ← telephonyToTenant(tc,orgName,tenantId); v ← validateTenant(raw);
//    אם ‎!v.ok‎ ⇒ הודעת-כשל מרוכזת (errors.join(' · '), outcome 'invalid', reason '')
//    — וה-explainCall/anchorToday **לא** נקראים (short-circuit נשמר).
//    אחרת ⇒ e ← explainCall(v.tenant, call, {anchorDate: anchorToday(), calendarWindow: 400});
//    ומוחזרים בדיוק שלושת השדות summary/outcome/reason (שדה-עודף כמו extra נחתך).
//
// הערות-המרה (מקור→Dart, לפי DART-PORTING-RULES):
//  • גישת-שדה: אובייקטי-JS ⇒ Maps ב-Dart ⇒ ‎v['ok']‎/‎e['summary']‎ (לא ‎.ok‎).
//  • ‎!v.ok‎ (truthiness של JS, כלל-7) ⇒ שקע ‎_falsy‎ מפורש, לא ‎!(bool)‎.
//  • זהות-הפניה (‎===‎ במקור) נשמרת: v['tenant']/call/raw/tc מועברים כמו-שהם.

/// Verbatim behaviour of the JS source `explainOne`. Injected neighbours are the
/// four function sockets; tenant/validation/result objects are Maps.
Map<String, dynamic> explainOne(
  dynamic tc,
  dynamic orgName,
  dynamic tenantId,
  dynamic call,
  dynamic telephonyToTenant,
  dynamic validateTenant,
  dynamic explainCall,
  dynamic anchorToday,
 {required String Function(String) term}) {
  final raw = telephonyToTenant(tc, orgName, tenantId);
  final v = validateTenant(raw);
  if (_falsy(v['ok'])) {
    return {
      'summary': term('ttsvrh-latkynh') + (v['errors'] as List).join(' · '),
      'outcome': 'invalid',
      'reason': '',
    };
  }
  final e = explainCall(
    v['tenant'],
    call,
    {'anchorDate': anchorToday(), 'calendarWindow': 400},
  );
  return {'summary': e['summary'], 'outcome': e['outcome'], 'reason': e['reason']};
}

/// חיקוי ‎!x‎ של JS (truthiness): null/false/0/NaN/'' ⇒ נכשל (true).
bool _falsy(dynamic x) {
  if (x == null) return true;
  if (x is bool) return !x;
  if (x is num) return x == 0 || (x is double && x.isNaN);
  if (x is String) return x.isEmpty;
  return false;
}
