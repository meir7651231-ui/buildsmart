// ✨ חולל ע"י מנוע-הרינדור (render-ds) — רישום גרף-הקשרים לשלמות-מחיקה. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_peruk05_relations_content.dart';
import '../dart-ui-bs/ds/ds_store.dart';

void registerAppRelations(AppStore s) {
  s.registerRelation('app_peruk05_ent2', gen_app_peruk05_relations_c0, 'app_peruk05_ent1', 1, multi: false);
}
