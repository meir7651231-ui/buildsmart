// ⚛️ אטום-Dart (דרגת-חוזה) · scopeHe
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:565-579 (‏scopeHe; חוק-4 —
//        התנהגות זהה). קובץ-המקור אינו קיים עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: פונקציית dispatch טהורה. אוצר-המילים של הטווחים (‏kScopeAll/kScopeActionable +
//        3 קידומות) הוא const-שכן שערכו **אינו ניתן לשחזור** (הקובץ נעלם + grep ריק
//        בכל buildsmart) ⇒ הוּרַם לשקעים בשם (חוק-3/דיבר-3), עם ברירות-מחדל
//        מייצגות ומתועדות. הקורא מזריק את האוצר האמיתי; הבדיקה מספקת ערכים מפורשים.
//
// קלט:  token — מחרוזת-טווח (‏Stage-A).
// פלט:  תווית עברית: התאמה-מדויקת (all/actionable), אחרת קידומת (every/screen/single),
//        אחרת '(טווח לא מזוהה)'.

/// Hebrew label for a Stage-A scope [token]. Exact matches ([all], [actionable])
/// win first, then the ordered prefixes ([everyPrefix], [screenPrefix],
/// [singlePrefix]); an unrecognised token yields `'(טווח לא מזוהה)'`.
/// Verbatim branching of edit_intent.dart:565-579 with the scope vocabulary
/// injected (its literal values are unrecoverable — representative defaults).
String scopeHe(
  String token, {required String Function(String) term, 
  String all = 'all',
  String actionable = 'actionable',
  String everyPrefix = 'every:',
  String screenPrefix = 'screen:',
  String singlePrefix = 'element:',
}) {
  if (token == all) return term('kl-halmntym');
  if (token == actionable) return term('kl-hkptvrym');
  if (token.startsWith(everyPrefix)) {
    return '${term('xi_kl')}${token.substring(everyPrefix.length)}»';
  }
  if (token.startsWith(screenPrefix)) {
    return '${term('xi_msk')}${token.substring(screenPrefix.length)}»';
  }
  if (token.startsWith(singlePrefix)) {
    return '${term('xi_halmnt')}${token.substring(singlePrefix.length)}»';
  }
  return term('tvvch-la-mzvhh');
}
