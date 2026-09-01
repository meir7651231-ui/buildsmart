// חוט · build-tenant — תזמור: קונפיג-דייר גולמי ⇒ אימות ⇒ קבצי-מרכזייה.
// מוצא: maor/telephony/lib/index.mjs · המקור: new/atoms/build-tenant.mjs.
// המרה נאמנה מ-JS — התנהגות זהה-לחלוטין למקור (חוק-4: המקור קדוש).
// שלושת השכנים validateTenant/generateConfig/effectiveConfig מוזרקים כשקעים
// (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
//
// הערות-המרה (מקור→Dart):
//   • אין locale/פורמט/getMonth מעורבים — אין שקע-שפה להוסיף.
//   • truthiness של JS: `opts.layers && (opts.layers.base || opts.layers.member)` ⇒
//     בדיקות `!= null` (base/member הם מפה-או-undefined; מפה=truthy, undefined=falsy).
//     `opts.layers.base || {}` ו-`opts.layers.member || null` ⇒ `?? {}` / השארה-כמות-שהיא —
//     מפה-ריקה נשארת truthy בשני הצדדים, null נופל לברירת-המחדל.
//   • `genWarns || warnings`: genWarns הוא רשימה-או-חסר; מפתח-חסר ⇒ null ⇒ נפילה
//     לאזהרות-האימות. רשימה (גם ריקה) = truthy בשני הצדדים ⇒ `??` זהה-ביט ל-`||`.
//   • כשל-אימות מחזיר מפה עם ok/errors/warnings בלבד — אין files/manifest/tenant
//     (בדיוק כמו האובייקט המקוצר של ה-JS ⇒ `'files' in r` שקרי).
//   • מוטביליות: cfg מתחיל כרפרנס raw (var), נדרס רק כשיש layers.
Map<String, dynamic> buildTenant(
  Map<String, dynamic> raw,
  Map<String, dynamic> opts,
  Map<String, dynamic> Function(Map<String, dynamic> cfg) validateTenant,
  Map<String, dynamic> Function(
          dynamic tenant, dynamic warnings, Map<String, dynamic> opts)
      generateConfig,
  Map<String, dynamic> Function(Map<String, dynamic> base,
          Map<String, dynamic> raw, Map<String, dynamic>? member)
      effectiveConfig,
) {
  // שכבות-הרשאה (מפעיל→לקוח→עובד) — נמזגות לפני הוולידציה. בלי layers = ביט-זהה.
  Map<String, dynamic> cfg = raw;
  final layers = opts['layers'] as Map<String, dynamic>?;
  if (layers != null &&
      (layers['base'] != null || layers['member'] != null)) {
    final base =
        (layers['base'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final member = layers['member'] as Map<String, dynamic>?;
    final eff = effectiveConfig(base, raw, member);
    cfg = {...raw, 'features': eff['features'], 'terms': eff['terms']};
  }
  final v = validateTenant(cfg);
  final ok = v['ok'];
  final errors = v['errors'];
  final warnings = v['warnings'];
  if (ok != true) {
    return {'ok': false, 'errors': errors, 'warnings': warnings};
  }
  final tenant = v['tenant'];
  final g = generateConfig(tenant, warnings, opts);
  final genWarns = g['warnings'];
  return {
    'ok': true,
    'errors': <dynamic>[],
    'warnings': genWarns ?? warnings,
    'files': g['files'],
    'manifest': g['manifest'],
    'tenant': tenant,
  };
}
