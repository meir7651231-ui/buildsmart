// ✨ חולל ע"י מנוע-הרינדור (render-ds) — רישום גרף-הקשרים לשלמות-מחיקה. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_sechirut_relations_content.dart';
import '../dart-ui-bs/ds/ds_store.dart';

void registerAppRelations(AppStore s) {
  s.registerRelation('app_sechirut_ent2', gen_app_sechirut_relations_c0, 'app_sechirut_ent1', 1, multi: false);
  s.registerRelation('app_sechirut_ent3', gen_app_sechirut_relations_c1, 'app_sechirut_ent1', 1, multi: false);
  s.registerRelation('app_sechirut_ent4', gen_app_sechirut_relations_c2, 'app_sechirut_ent1', 1, multi: false);
}
