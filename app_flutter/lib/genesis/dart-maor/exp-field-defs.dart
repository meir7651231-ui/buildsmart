// ⚛️ אטום-Dart (דרגת-חוזה) · expFieldDefs — הגדרות-שדות (key+label) של "הדו"ח
// המותאם" לפי יעד: חוגים / אירועים / תומכות.
// מוצא: maor/src/lib/customExport.ts:36-126 · המקור: new/atoms/exp-field-defs.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). חמשת השכנים
//        featureOn/termOf/featLabel/itemLabel/unitLabel הוזרקו כשקעים (חוק-1/חוק-3).
//
// תפקיד: הדגל 'reports.custom.full' (חסר=פעיל) בוחר רשימה מלאה או מקוצרת; ביעד
//        תומכות שדות מעקב-הטיפול נוספים רק כשדגל 'supporters.ayin' דלוק. התוויות
//        עוברות דרך מילון-המונחים (termOf) והשקעים.
// קלט:  cfg · target∈{'courses','events','supporters'} + חמשת השקעים.
// פלט:  List<Map<String,String>> — כל איבר {'key':…, 'label':…}.
//
// הערות-המרה (מקור→Dart):
//  • אובייקט-JS {key, label} → Map<String,String> ‏({'key':…, 'label':…}). כל שדה
//    הוא זוג-מחרוזות בלבד ⇒ אין דו-משמעות-טיפוס.
//  • שרשור-מחרוזות `'א' + termOf(...)` → אותו `+` ב-Dart (String+String) זהה-ביט.
//  • `!full` → `!full` — full הוא bool מהשקע featureOn ⇒ truthiness-JS אינה מעורבת
//    (השקע מחזיר bool אמיתי, לא ערך-נפילה); אין צורך ב-_falsy. אין locale/פורמט/
//    getMonth/מיון/תאריך ⇒ אף אחד מ-7 מלכודות-ההמרה אינו רלוונטי כאן.
//  • מוטביליות: `defs` הוא var מקומי (final list עם push/add) — הרשימה משתנה,
//    ההצבעה קבועה; `full`/`ayinOn` הם final.
//  • שקעי-הקריאה-לשכן: פרמטרי-פונקציה — לא import (חוק-3).

/// Field definitions (key+label) for the "custom report", by target:
/// courses / events / supporters. Verbatim port of new/atoms/exp-field-defs.mjs.
/// The five neighbour calls are injected as sockets (Law 1/3).
List<Map<String, String>> expFieldDefs<C>(
  C cfg,
  String target,
  bool Function(C, String) featureOn,
  String Function(C, String, String) termOf,
  String Function(C) featLabel,
  String Function(C) itemLabel,
  String Function(C) unitLabel,
 {required String Function(String) term, required Map<String, String> T}) {
  final full = featureOn(cfg, 'reports.custom.full');
  if (target == 'courses') {
    if (!full) {
      return [
        {'key': 'name', 'label': term('shm-hchvg')},
        {'key': 'teacher', 'label': term('mvrh-tlpvn')},
        {'key': 'model', 'label': term('mslvl-vmchyr')},
        {'key': 'occ', 'label': term('tpvsh')},
        {'key': 'students', 'label': term('rshymt') + termOf(cfg, 'entity.students', T['k14']!)},
        {'key': 'pays', 'label': term('tshlvmym-btvvch')},
        {'key': 'abs', 'label': term('chysvrym-btvvch')},
      ];
    }
    return [
      {'key': 'name', 'label': term('shm-h') + termOf(cfg, 'entity.course', T['k21']!)},
      {'key': 'teacher', 'label': termOf(cfg, 'entity.teacher', T['k23']!) + term('tlpvn')},
      {'key': 'grade', 'label': term('kytvt')},
      {'key': 'audience', 'label': term('khl-yad')},
      {'key': 'room', 'label': termOf(cfg, 'entity.room', T['k31']!)},
      {'key': 'schedule', 'label': term('yvm-vshah')},
      {'key': 'model', 'label': term('mslvl-vmchyr')},
      {'key': 'occ', 'label': term('tpvsh')},
      {'key': 'students', 'label': term('rshymt') + termOf(cfg, 'entity.students', T['k14']!)},
      {'key': 'studentsFull', 'label': termOf(cfg, 'entity.students', T['k14']!) + term('tlpvn-ytrh')},
      {'key': 'pays', 'label': term('tshlvmym-btvvch')},
      {'key': 'revenue', 'label': term('shk-hknsvt')},
      {'key': 'abs', 'label': term('chysvrym-btvvch')},
      {'key': 'notes', 'label': term('harvt')},
    ];
  }
  if (target == 'events') {
    return [
      {'key': 'title', 'label': term('kvtrt')},
      {'key': 'type', 'label': term('svg-ayrva')},
      {'key': 'hdate', 'label': term('taryk-abry')},
      {'key': 'gdate', 'label': term('taryk-lvazy')},
      {'key': 'time', 'label': term('shah')},
      {'key': 'fam', 'label': termOf(cfg, 'entity.family', T['k53']!)},
      {'key': 'notes', 'label': term('harvt')},
      {'key': 'done', 'label': term('bvtsa')},
    ];
  }
  final ayinOn = featureOn(cfg, 'supporters.ayin');
  if (!full) {
    final defs = <Map<String, String>>[
      {'key': 'name', 'label': term('shm')},
      {'key': 'phone', 'label': term('t22')},
      {'key': 'email', 'label': term('aymyyl')},
      {'key': 'dons', 'label': termOf(cfg, 'entity.donations', T['k64']!) + term('btvvch-mspr-skvm')},
    ];
    if (ayinOn) {
      defs.add({'key': 'stage', 'label': term('shlb') + featLabel(cfg)});
      defs.add({'key': 'names', 'label': itemLabel(cfg) + ' + ' + unitLabel(cfg)});
      defs.add({'key': 'answers', 'label': term('tshvbvtharvt-btvvch')});
      defs.add({'key': 'next', 'label': term('taryk-yad-lkshr')});
    }
    return defs;
  }
  final defs = <Map<String, String>>[
    {'key': 'name', 'label': term('shm')},
    {'key': 'phone', 'label': term('t22')},
    {'key': 'email', 'label': term('aymyyl')},
    {'key': 'address', 'label': term('ktvbt')},
    {'key': 'city', 'label': term('ayr')},
    {'key': 'cat', 'label': term('ktgvryh')},
    {'key': 'forWho', 'label': term('abvr-my')},
    {'key': 'dons', 'label': termOf(cfg, 'entity.donations', T['k64']!) + term('btvvch-mspr-skvm')},
    {'key': 'donsAll', 'label': term('shk') + termOf(cfg, 'entity.donations', T['k64']!) + term('kl-hzmn')},
    {'key': 'tier', 'label': term('dyrvg')},
  ];
  if (ayinOn) {
    defs.add({'key': 'stage', 'label': term('shlb') + featLabel(cfg)});
    defs.add({'key': 'names', 'label': itemLabel(cfg) + ' + ' + unitLabel(cfg)});
    defs.add({'key': 'eyesTotal', 'label': term('shk') + unitLabel(cfg)});
    defs.add({'key': 'paid', 'label': term('shvlm')});
    defs.add({'key': 'answers', 'label': term('tshvbvtharvt-btvvch')});
    defs.add({'key': 'next', 'label': term('taryk-yad-lkshr')});
  }
  defs.add({'key': 'notes', 'label': term('harvt')});
  return defs;
}
