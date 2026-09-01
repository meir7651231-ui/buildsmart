// ⚛️ אטום-Dart (דרגת-חוזה) · planAyinAdvance — תכנון פעולת הכפתור-החכם של תיק-המעקב.
// מוצא: maor/src/lib/ayin.ts · המקור: new/atoms/plan-ayin-advance.mjs.
// חוזה: new/atoms/plan-ayin-advance.contract.md · טוהר: פונקציית top-level עצמאית,
//        אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: לפי שלב-התיק (stage) מחזיר תוכנית {patch, event, toast} לקידום-השלב, או
//        null כשהכפתור מוסתר. השלבים: new⇒lead · lead⇒eyes · eyes⇒answer ·
//        answer(לפני-דחיפה)⇒answerPushed · answer(אחרי)⇒done.
// שקעים (חוק-1, אפס import פנימי): ayinActionVisible · featLabel · itemLabel ·
//        unitLabel · stageLabel · eyesTotal — כולם הוזרקו כפרמטרים-פונקציה.
//
// הערות-המרה (מקור→Dart):
//  · truthiness: `if (!a.answerPushed)` — שדה נפילתי (null/false/'') ⇒ נכנס לענף
//    "לפני-דחיפה". מפתח חסר ב-Map ⇒ null ⇒ נפילתי, כמו undefined ב-JS. מומש ב-_truthy.
//  · `a.names.length` ⇒ (a['names'] as List).length — int, אינטרפולציה זהה.
//  · eyesTotal מחזיר num; אינטרפולציה של 5 ⇒ "5" (זהה ל-JS). אין locale/פורמט/getMonth.
//  · אין מוטציה על a/cfg — התוכנית היא מפות-ליטרל חדשות.

/// אמת-JS: null/false/0/NaN/'' נפילתיים; שאר הערכים אמיתיים.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

/// Plans the smart stage-advance action of a care-tracking case. Verbatim
/// behaviour of the JS source `planAyinAdvance`: returns a `{patch, event, toast}`
/// plan for the next stage, or null when the action button is hidden.
Map? planAyinAdvance(
  Map cfg,
  String name,
  Map a,
  bool Function(Map) ayinActionVisible,
  String Function(Map) featLabel,
  String Function(Map) itemLabel,
  String Function(Map) unitLabel,
  String Function(Map, String) stageLabel,
  num Function(Map) eyesTotal,
) {
  if (!ayinActionVisible(a)) return null;
  final feat = featLabel(cfg);
  final item = itemLabel(cfg);
  final unit = unitLabel(cfg);
  final st = a['stage'];
  final names = a['names'] as List;
  if (st == 'new') {
    return {
      'patch': {'stage': 'lead'},
      'event': {
        'title':
            '$feat: ${stageLabel(cfg, 'lead')} — $name (${names.length} $item)',
        'done': false,
      },
      'toast': 'נרשמו ${names.length} — נכנס ללוח: ${stageLabel(cfg, 'lead')}',
    };
  }
  if (st == 'lead') {
    return {
      'patch': {'stage': 'eyes'},
      'event': {
        'title': '$feat: ${stageLabel(cfg, 'lead')} ✓ — $name',
        'done': true,
      },
      'toast': 'אושר — נרשם בלוח ובדוח. עכשיו: ${stageLabel(cfg, 'eyes')}',
    };
  }
  if (st == 'eyes') {
    final eyes = eyesTotal(a);
    return {
      'patch': {'stage': 'answer'},
      'event': {
        'title': '$feat: ${stageLabel(cfg, 'answer')} — $name ($eyes $unit)',
        'done': false,
      },
      'toast': 'נרשם — נכנס ללוח: ${stageLabel(cfg, 'answer')}',
    };
  }
  // st === 'answer'
  if (!_truthy(a['answerPushed'])) {
    return {
      'patch': {'answerPushed': true},
      'event': {
        'title': '$feat: ${stageLabel(cfg, 'answer')} — $name',
        'done': false,
      },
      'toast': 'נמסר — נרשם בלוח היומי ובכרטיס',
    };
  }
  return {
    'patch': {'stage': 'done'},
    'event': {
      'title': '$feat: ${stageLabel(cfg, 'done')} — $name',
      'done': true,
    },
    'toast': 'הטיפול הושלם ✓ — נרשם בלוח',
  };
}
