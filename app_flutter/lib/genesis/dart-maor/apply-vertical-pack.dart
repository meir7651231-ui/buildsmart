// ⚛️ אטום-Dart (דרגת-חוזה) · applyVerticalPack — החלת חבילת-ורטיקל על קונפיג (זהות מלאה).
// מוצא: maor/src/lib/verticalPacks.ts:467-495 · המקור: new/atoms/apply-vertical-pack.mjs —
//        `export function applyVerticalPack(config, packId, packs) { ... }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מאתר את החבילה לפי packId; לא-נמצאה ⇒ מוחזר config עצמו (אותה הפניה).
//        נמצאה ⇒ מפה חדשה: terms/modules/features מוחלפים בערכי-החבילה (עותקים
//        טריים), שאר הקונפיג שורד. ערכת-נושא מוחלפת רק כשהחבילה מגדירה. אימוג'י
//        ותנועה: מוגדר-בחבילה ⇒ נכתב, חסר ⇒ מוסר (נפילה לברירת-מחדל). צבע-הדגשה:
//        accentCustom (צבע-ידני) שורד תמיד; אחרת ⇐ צבע-החבילה; אין ⇒ מוסר.
// שקע (חוק-1): packs — רשימת-החבילות (השכן VERTICAL_PACKS הוזרק, אפס import פנימי).
// קלט: config (Map) · packId (String) · packs (List<Map>).
// פלט: Map — קונפיג מעודכן, או config עצמו כשה-packId לא-מוכר.
//
// הערת-המרה (מקור→Dart):
//   * אין locale/פורמט/getMonth מעורבים.
//   * truthiness-של-JS על `pack.theme`/`pack.icon`/`pack.motion`/`pack.accent`/
//     `config.accentCustom`: undefined/null/''/0/false ⇒ falsy. ממומש ב-`_truthy`
//     (String ריק=falsy, num 0/NaN=falsy, bool כמות-שהיא). מפתח-חסר ב-Map ⇒ null ⇒ falsy.
//   * `{ ...config, terms: { ...pack.terms }, ... }` ⇒ spread של Map ⇒ מפות חדשות.
//     `{ ...pack.features }` כש-features חסר (undefined) ⇒ `{}` ⇒ spread null-aware `{...?}`.
//   * `delete next.emoji` ⇒ `next.remove('emoji')`.
//   * ההחזרה כשה-packId לא-מוכר היא `config` עצמו ⇒ identical(out, config) נשמר.
//   * `next`/`pack` לא מוקצים-מחדש ⇒ final.

bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

/// Applies vertical pack [packId] (looked up in [packs]) onto [config].
/// Verbatim behaviour of the JS source new/atoms/apply-vertical-pack.mjs
/// (`applyVerticalPack`). Unknown [packId] returns [config] unchanged (same
/// reference). [packs] is an injected socket (חוק-1 — no internal imports).
Map<String, dynamic> applyVerticalPack(
  Map<String, dynamic> config,
  String packId,
  List<Map<String, dynamic>> packs,
) {
  Map<String, dynamic>? pack;
  for (final p in packs) {
    if (p['id'] == packId) {
      pack = p;
      break;
    }
  }
  if (pack == null) return config;
  // terms/modules/features מוחלפים בערכי-החבילה (עותקים טריים); שאר הקונפיג שורד.
  // features חסר בחבילה = {} = הכול דלוק (ברירת-המחדל, לחבילות העמותתיות).
  final next = <String, dynamic>{
    ...config,
    'terms': {...?(pack['terms'] as Map<String, dynamic>?)},
    'modules': {...?(pack['modules'] as Map<String, dynamic>?)},
    'features': {...?(pack['features'] as Map<String, dynamic>?)},
  };
  // ערכת-נושא: מוחלפת רק כשהחבילה מגדירה (חבילה בלי theme ⇒ שמירת הערכה).
  if (_truthy(pack['theme'])) next['theme'] = pack['theme'];
  // אימוג'י-אייקון: מוגדר בחבילה ⇒ נכתב; חסר ⇒ מוסר (נפילה לברירת-המחדל).
  if (_truthy(pack['icon'])) {
    next['emoji'] = pack['icon'];
  } else {
    next.remove('emoji');
  }
  // תנועה: כנ"ל — מוגדר ⇒ נכתב; חסר ⇒ מוסר (ברירת-המחדל).
  if (_truthy(pack['motion'])) {
    next['motion'] = pack['motion'];
  } else {
    next.remove('motion');
  }
  // צבע-הדגשה: צבע-ידני (accentCustom) שורד בכל מקרה; אחרת ⇐ צבע-החבילה, ואם אין —
  // מוסר (צבע-הערכה). את הדגל accentCustom משמרים רק כשהצבע-הידני שרד.
  if (_truthy(config['accentCustom'])) {
    next['accent'] = config['accent'];
    next['accentCustom'] = true;
  } else if (_truthy(pack['accent'])) {
    next['accent'] = pack['accent'];
    next.remove('accentCustom');
  } else {
    next.remove('accent');
    next.remove('accentCustom');
  }
  return next;
}
