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
Map<String, dynamic> trustReport(dynamic bundle, Map<String, dynamic> T, [dynamic opt = const <String, dynamic>{},
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
      (T['k2'] as String),
      ar['ok'],
      'critical',
      _truthy(ar['ok'])
          ? (T['k4'] as String)
          : (T['k39'] as String) +
              [...((ar['dangling']) as Iterable), ...((ar['orphanTransfers']) as Iterable), ...((ar['missingGateways']) as Iterable)]
                  .join(', '));

  // 2. מסלול-חירום (fail-safe) — תמיד יש מנהל לחזור אליו.
  final fs = failsafeRoute(tenant);
  add('failsafe', (T['k6'] as String), fs['ok'], 'critical',
      _truthy(fs['ok']) ? '${(T['k40'] as String)}${fs['fallback']}' : (T['k7'] as String));

  // 3. תקרות-toll-fraud — הגנת חשבון-הסלולר.
  final toll = featureOn(tenant, 'voice.hardening');
  add('toll-caps', (T['k10'] as String), toll, 'high',
      _truthy(toll) ? (T['k12'] as String) : (T['k13'] as String));

  // 4. שלמות-כשרות — מצב-כשר עם SIM-כשר ליציאה.
  if (_truthy(featureOn(tenant, 'voice.kosher'))) {
    final nums = _truthy(tenant['numbers']) ? tenant['numbers'] : <dynamic>[];
    final hasK = (nums as List).any((n) =>
        _truthy(n['kosher']) &&
        n['onramp'] == 'sim-in-gateway' &&
        _isIntegerNum(n['gatewayChannel']) &&
        ((_truthy(n['channels']) ? n['channels'] : <dynamic>[]) as List).contains('voice'));
    add('kosher-integrity', (T['k18'] as String), hasK, 'high',
        hasK ? (T['k19'] as String) : (T['k20'] as String));
  }

  // 5. הצפנת-הקלטות (במנוחה) — רק אם הקלטה פעילה. **נחיל-5 F4:** דורמנטי ⇒
  // ‏pass:false בשני המצבים (אסור להצהיר לוועד על-סמך דגל-קונפיג).
  if (_truthy(featureOn(tenant, 'recording'))) {
    final rec = recordingEncryption(tenant);
    add(
        'recording-encryption',
        (T['k23'] as String),
        false,
        'high',
        _truthy(rec['enabled'])
            ? (T['k24'] as String)
            : (T['k25'] as String));
  }

  // 6. preflight-סודות — env מלא (אם נמסר).
  if (_truthy(opt['env'])) {
    final pf = secretPreflight([bundle], opt['env']);
    add('secrets', (T['k27'] as String), pf['ok'], 'critical',
        _truthy(pf['ok']) ? (T['k28'] as String) : '${(T['k41'] as String)}${pf['missing'].length}${(T['k42'] as String)}');
  }

  // 7. בידוד חוצה-דיירים — אם נמסרו peers.
  if (opt['peers'] is List && _truthy((opt['peers'] as List).length)) {
    final leak = crossTenantLeakScan(<dynamic>[bundle, ...((opt['peers']) as Iterable)]);
    add('isolation', (T['k30'] as String), leak['clean'], 'critical',
        _truthy(leak['clean']) ? (T['k31'] as String) : '${leak['violations'].length}${(T['k43'] as String)}');
  }

  // 8. אינווריאנטים (תמיד עוברים — הצהרה לוועד).
  add('downstream', (T['k33'] as String), true, 'info', (T['k35'] as String));
  add('cti-readonly', (T['k37'] as String), true, 'info', (T['k38'] as String));

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
