// ⚛️ אטום-Dart (דרגת-חוזה) · scopeTokenHe
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:202-212 (‏_scopeTokenHe; חוק-4).
//        פרטי-במקור → נחשף כ-top-level. קובץ-המקור אינו קיים עוד; הטיוטה = מקור-האמת.
// טוהר: dispatch טהור. `kScopeAll`/`kScopeScreenPrefix` const-שכנים לא-ניתנים-לשחזור ⇒
//        הורמו לשקעים בשם (חוק-3), ברירות-מחדל מייצגות.
//
// קלט:  token — מחרוזת-טווח (‏Stage-A closed-set).
// פלט:  'כל האלמנטים' / 'מרחב «ns»' / ה-token עצמו (fall-through, לא '(לא מזוהה)').

/// The compact Hebrew description of a Stage-A scope [token] (for the
/// `token = תיאור` list). Only all-elements + per-namespace ("מרחב") are
/// translated; anything else falls through to the raw token verbatim.
/// Verbatim branching of edit_prompt.dart:202-212 with the vocabulary injected.
String scopeTokenHe(
  String token, {required String Function(String) term, 
  String all = 'all',
  String screenPrefix = 'screen:',
}) {
  if (token == all) return term('kl-halmntym');
  if (token.startsWith(screenPrefix)) {
    return '${term('xi_mrchb')}${token.substring(screenPrefix.length)}»';
  }
  return token;
}
