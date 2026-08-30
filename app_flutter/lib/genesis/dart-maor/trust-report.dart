// ⚛️ אטום-Dart (דרגת-חוזה) · trustReport — דוח-אמון פר-עמותה (טלפוניה · item 18).
// מוצא: maor/telephony/lib/report.mjs:22-81 · המקור: new/atoms/trust-report.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS. ששת השכנים מוזרקים כאובייקט-שקעים eng (Map — חוק-1):
//        featureOn · auditRoutes · failsafeRoute · recordingEncryption ·
//        secretPreflight · crossTenantLeakScan. הקבוע הפרטי SEV = חלק מהיחידה.
//
// הערות-המרה (הנקודות שהמנוע נטה לפספס):
//  • truthiness של JS (חוק-7): ‏`!!pass` · ‏`ar.ok ?` · ‏`toll ?` · ‏`rec.enabled ?` ·
//    ‏`if (opt.env)` · ‏`opt.peers.length` · ‏`totalW ?` · ‏`n.kosher &&` — כולם דרך
//    ‏`_truthy` (null/false/0/-0/NaN/'' כוזבים; ‏[]/{}/'0' אמת — זהה ל-JS).
//  • ‏`bundle.tenant || {}` ו-`n.channels || []` = נפילת-||-על-falsy (לא ??) — דרך _truthy.
//  • ‏`Number.isInteger` → ‏_isIntegerNum (מספר סופי שלם-ערך; 2.0 ⇒ true, לא-מספר ⇒ false).
//  • ‏`Math.round` על ציון ∈[0,100] (אי-שלילי) ⇒ ‏.round() של Dart זהה (חצי-מעלה).
//  • ‏`checks.filter(...)` מחזיר מערך ⇒ ‏.toList() (אותם אובייקטי-check בהפניה משותפת).
//  • גישה לשדות = Map (`tenant['x']`) — הנתונים הם Map, לא record.

// חומרת-כשל פר-בדיקה: critical=חוסם-חי · high=סיכון · info=מידע.
const Map<String, int> _sev = {'critical': 3, 'high': 2, 'info': 1};

/// truthiness של JS: null/undefined · false · 0/-0/NaN · '' — כוזבים; כל השאר אמת.
bool _truthy(dynamic v) =>
    !(v == null || v == false || v == 0 || v == '' || (v is double && v.isNaN));

/// Number.isInteger של JS: מספר סופי בעל ערך-שלם (2.0 ⇒ true); לא-מספר ⇒ false.
bool _isIntegerNum(dynamic v) =>
    v is int || (v is double && v.isFinite && v == v.truncateToDouble());

/// כרטיס-אמון לוועד: מאגד את האורקלים לרשימת-בדיקות + ציון משוקלל-חומרה,
/// דרגה A–F ומוכנות-להפעלה. המרה נאמנה של new/atoms/trust-report.mjs.
Map<String, dynamic> trustReport(dynamic bundle,
    [dynamic opt = const <String, dynamic>{},
    dynamic eng = const <String, dynamic>{}]) {
  final featureOn = eng['featureOn'];
  final auditRoutes = eng['auditRoutes'];
  final failsafeRoute = eng['failsafeRoute'];
  final recordingEncryption = eng['recordingEncryption'];
  final secretPreflight = eng['secretPreflight'];
  final crossTenantLeakScan = eng['crossTenantLeakScan'];
  final tenant = _truthy(bundle['tenant']) ? bundle['tenant'] : <String, dynamic>{};
  final checks = <dynamic>[];
  void add(dynamic key, dynamic label, dynamic pass, dynamic severity, dynamic detail) =>
      checks.add(<String, dynamic>{
        'key': key,
        'label': label,
        'pass': _truthy(pass),
        'severity': severity,
        'detail': detail,
      });

  // 1. סגירת-מסלולים (⭐1) — אין גשר/transfer/שער יתום.
  final ar = auditRoutes(bundle);
  add(
      'route-closure',
      'סגירת-מסלולים (אין ניתוב-יתום)',
      ar['ok'],
      'critical',
      _truthy(ar['ok'])
          ? 'כל גשר/transfer/שער מוביל ליעד-קיים'
          : 'יתומים: ' +
              [...((ar['dangling']) as Iterable), ...((ar['orphanTransfers']) as Iterable), ...((ar['missingGateways']) as Iterable)]
                  .join(', '));

  // 2. מסלול-חירום (fail-safe) — תמיד יש מנהל לחזור אליו.
  final fs = failsafeRoute(tenant);
  add('failsafe', 'מסלול-חירום (השיחה תמיד עונה)', fs['ok'], 'critical',
      _truthy(fs['ok']) ? 'נפילה למנהל ${fs['fallback']}' : 'אין מנהל — מבוי-סתום אפשרי');

  // 3. תקרות-toll-fraud — הגנת חשבון-הסלולר.
  final toll = featureOn(tenant, 'voice.hardening');
  add('toll-caps', 'תקרות חיוג-יוצא (toll-fraud)', toll, 'high',
      _truthy(toll) ? 'בו-זמניות+משך מוגבלים' : 'כבוי — cred-גנוב יכול להצטבר (voice.hardening)');

  // 4. שלמות-כשרות — מצב-כשר עם SIM-כשר ליציאה.
  if (_truthy(featureOn(tenant, 'voice.kosher'))) {
    final nums = _truthy(tenant['numbers']) ? tenant['numbers'] : <dynamic>[];
    final hasK = (nums as List).any((n) =>
        _truthy(n['kosher']) &&
        n['onramp'] == 'sim-in-gateway' &&
        _isIntegerNum(n['gatewayChannel']) &&
        ((_truthy(n['channels']) ? n['channels'] : <dynamic>[]) as List).contains('voice'));
    add('kosher-integrity', 'שלמות-כשרות (יציאה כשרה)', hasK, 'high',
        hasK ? 'יש SIM-כשר ליציאה' : 'מצב-כשר בלי SIM-כשר — יציאה מושבתת');
  }

  // 5. הצפנת-הקלטות (במנוחה) — רק אם הקלטה פעילה. **נחיל-5 F4:** דורמנטי ⇒
  // ‏pass:false בשני המצבים (אסור להצהיר לוועד על-סמך דגל-קונפיג).
  if (_truthy(featureOn(tenant, 'recording'))) {
    final rec = recordingEncryption(tenant);
    add(
        'recording-encryption',
        'הצפנת-הקלטות',
        false,
        'high',
        _truthy(rec['enabled'])
            ? 'מוגדר אך דורמנטי — record_session כותב .wav גולמי, REC_KEY טרם מחווט (חלון-בעלים)'
            : 'הקלטות פעילות בלי הצפנה');
  }

  // 6. preflight-סודות — env מלא (אם נמסר).
  if (_truthy(opt['env'])) {
    final pf = secretPreflight([bundle], opt['env']);
    add('secrets', 'סודות-סביבה מוזרקים', pf['ok'], 'critical',
        _truthy(pf['ok']) ? 'כל הסודות קיימים' : 'חסרים ${pf['missing'].length} (שער-דומם)');
  }

  // 7. בידוד חוצה-דיירים — אם נמסרו peers.
  if (opt['peers'] is List && _truthy((opt['peers'] as List).length)) {
    final leak = crossTenantLeakScan(<dynamic>[bundle, ...((opt['peers']) as Iterable)]);
    add('isolation', 'בידוד חוצה-דיירים', leak['clean'], 'critical',
        _truthy(leak['clean']) ? 'אין דליפת-סוד/זהות בין-לקוחות' : '${leak['violations'].length} דליפות');
  }

  // 8. אינווריאנטים (תמיד עוברים — הצהרה לוועד).
  add('downstream', 'pure-downstream (אין תלות-ספק)', true, 'info', 'מדבר רק עם ציוד-הלקוח');
  add('cti-readonly', 'זיהוי-מתקשר קריאה-בלבד', true, 'info', 'לעולם לא כותב למאור');

  final failing = checks.where((c) => !_truthy(c['pass'])).toList();
  // ציון: משוקלל לפי חומרה (critical=3, high=2, info=1).
  final totalW = checks.fold<num>(0, (s, c) => s + _sev[c['severity']]!);
  final gotW = checks.fold<num>(0, (s, c) => s + (_truthy(c['pass']) ? _sev[c['severity']]! : 0));
  // ‏Math.round של JS ≡ ‏.round() של Dart על ערך אי-שלילי (הציון ∈[0,100]).
  final score = _truthy(totalW) ? ((gotW / totalW) * 100).round() : 100;
  final anyCritical = failing.any((c) => c['severity'] == 'critical');
  final grade = anyCritical
      ? 'F'
      : score >= 95
          ? 'A'
          : score >= 85
              ? 'B'
              : score >= 70
                  ? 'C'
                  : 'D';
  return <String, dynamic>{
    'tenantId': tenant['tenantId'],
    'checks': checks,
    'failing': failing,
    'score': score,
    'grade': grade,
    'ready': !anyCritical,
  };
}
