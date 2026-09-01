// ⚛️ אטום-Dart (דרגת-חוזה) · computeQuote — מנוע הצעת-מחיר מטבלת-מחירים נתונה.
// מוצא: maor/src/lib/pricing.ts:152-187 · המקור: new/atoms/compute-quote.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core/dart:math).
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). שני השכנים כבר-פרמטרים
//        במקור: allModules (השכן ALL_MODULES הוזרק כשקע · חוק-1) · nameOf (termOf).
//
// תפקיד: מחשב פירוט-חיוב מלא — מודולים דלוקים (חסר=דלוק, רק false מכבה) + הרחבות
//        ⇒ שורות-חיוב (מחיר>0) · "כלול בבסיס" (מחיר 0) · חודשי=round((base+subtotal)
//        ×sizeMult) · תשלום-ראשון=חודשי+הקמה · שנתי=×12 · שנתי-מוזל=×10 · העברת-Enterprise.
// קלט:  cfg {modules?} · size · prices {base,modules,integrations,sizeMult,setup,
//        enterprise} · nameOf(m)⇒label · allModules · addons=[] [{key,label}] ·
//        mode='subscription'. פלט: Map<String,dynamic> — אובייקט-Quote מלא.
//
// הערות-המרה (מקור→Dart · כללי DART-PORTING-RULES):
//  • `cfg.modules?.[m] !== false` (מודול דלוק אם אינו-false-מפורש): optional-chaining
//    על cfg.modules → `(cfg['modules'] as Map?)?[m]`; `!== false` נשמר כ-`!= false`
//    (חסר/null/undefined כולם ≠ false ⇒ דלוק. הערה: כאן false-הבוליאני בלבד מכבה,
//    ולכן `!= false` נכון — אין הבחנת null/undefined רלוונטית לשקע-זה).
//  • `?? 0` / `?? 1` על lookup-מפה נשמר verbatim (`X ?? 0`).
//  • Math.round: המקור floor(x+0.5) (חצי-כלפי-מעלה); מחירים חיוביים ⇒ `.round()` של
//    Dart (חצי-מהאפס) זהה, אך שומרים סמנטיקת-JS מדויקת עם `(raw + 0.5).floor()`.
//  • truthiness של המסננים = השוואת-num מפורשת (`> 0` / `== 0`) — זהה JS↔Dart.
//  • מוטביליות: כל הביניים final (המקור const); אין מיון ⇒ אין סוגיית-יציבות.
//  • `[...a, ...b]` → `[...a, ...b]` (spread זהה); `.filter`→`.where(...).toList()`.

/// Price-quote engine — verbatim port of new/atoms/compute-quote.mjs
/// (`computeQuote`). `allModules` is the injected ALL_MODULES socket (Law 1);
/// `nameOf` was already a parameter in the source (termOf).
Map<String, dynamic> computeQuote(
  Map<String, dynamic> cfg,
  String size,
  Map<String, dynamic> prices,
  String Function(String m) nameOf,
  List<String> allModules, [
  List<Map<String, dynamic>> addons = const [],
  String mode = 'subscription',
]) {
  final modulesCfg = cfg['modules'] as Map?;
  final onModules =
      allModules.where((m) => (modulesCfg?[m]) != false).toList();

  final pricesModules = prices['modules'] as Map;
  final pricesIntegrations = prices['integrations'] as Map;

  final all = onModules
      .map<Map<String, dynamic>>((m) => <String, dynamic>{
            'key': m,
            'label': nameOf(m),
            'price': pricesModules[m] ?? 0,
            'kind': 'module',
          })
      .toList();

  final addonLines = addons
      .map<Map<String, dynamic>>((a) => <String, dynamic>{
            'key': a['key'],
            'label': a['label'],
            'price': pricesIntegrations[a['key']] ?? 0,
            'kind': 'integration',
          })
      .toList();

  final lines = <Map<String, dynamic>>[
    ...all.where((l) => (l['price'] as num) > 0),
    ...addonLines.where((l) => (l['price'] as num) > 0),
  ];
  final included = all.where((l) => (l['price'] as num) == 0).toList();

  final modulesSubtotal =
      lines.fold<num>(0, (s, l) => s + (l['price'] as num));

  final sizeMult = (prices['sizeMult'] as Map)[size] ?? 1;
  final base = prices['base'] as num;
  final num raw = (base + modulesSubtotal) * (sizeMult as num);
  final monthly = (raw + 0.5).floor();
  final setup = (prices['setup'] ?? 0) as num;
  final enterprise = prices['enterprise'] as Map;

  return <String, dynamic>{
    'lines': lines,
    'included': included,
    'base': base,
    'modulesSubtotal': modulesSubtotal,
    'size': size,
    'sizeMult': sizeMult,
    'monthly': monthly,
    'setup': setup,
    'firstPayment': monthly + setup,
    'yearly': monthly * 12,
    'yearlyDiscounted': monthly * 10,
    'mode': mode,
    'enterpriseOneTime': enterprise['oneTime'],
    'enterpriseAnnual': enterprise['annualMaintenance'],
  };
}
