// ⚛️ אטום-Dart (דרגת-חוזה) · scopeLabel
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:189-201 (‏scopeLabel; חוק-4).
//        קובץ-המקור אינו קיים עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: dispatch טהור. אוצר-הטווחים (‏kScopeAll/kScopeScreenPrefix/kScopeSinglePrefix)
//        const-שכן לא-ניתן-לשחזור ⇒ הורם לשקעים בשם (חוק-3), ברירות-מחדל מייצגות.
//
// קלט:  scope — מחרוזת-טווח.
// פלט:  שורת ה-'מתוך: …' שלפני הדיף (‏all / מרחב-מסך / אלמנט-בודד / לא-מזוהה).

/// The Hebrew "מתוך: …" preview line for a [scope]. All-elements, per-namespace
/// ("מרחב"), single-element, else a defensive "לא מזוהה".
/// Verbatim branching of edit_prompt.dart:189-201 with the scope vocabulary
/// injected (its literal values are unrecoverable — representative defaults).
String scopeLabel(
  String scope, {required String Function(String) term, 
  String all = 'all',
  String screenPrefix = 'screen:',
  String singlePrefix = 'element:',
}) {
  if (scope == all) return term('mtvk-kl-halmntym');
  if (scope.startsWith(screenPrefix)) {
    return '${term('xi_mtvk-mrchb')}${scope.substring(screenPrefix.length)}»';
  }
  if (scope.startsWith(singlePrefix)) {
    return '${term('xi_mtvk-halmnt')}${scope.substring(singlePrefix.length)}»';
  }
  return term('mtvk-tvvch-la-mzvhh'); // defensive — an unrecognised scope
}
