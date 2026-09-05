// ⚛️ אטום-Dart (דרגת-חוזה) · validateOp
// תפקיד: אימות-מלא של op-אחד מול הרג'יסטרי — הכול-או-כלום: פספוס בכל שדה ⇒ null (drop).
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:171-214
//        (‏_validateOp; פרטי-במקור; ענף claude/align-main; חוק-4 — התנהגות זהה, לא-משופרת).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3) — תשעה:
//   • opFromJson           — במקור `configOpFromJson(m)` (config_op.dart, step 69; אטום-מדף config_op_from_json).
//   • matchElementId       — במקור `matchElementId(reg, shape.id)` (registry_view.dart; ה-reg מוזרק-מראש בקופסה).
//   • matchPropKey         — במקור `matchPropKey(reg, target, axis)`.
//   • axisOf               — במקור `_axisOf(shape)` (edit_intent.dart:218; אטום-מדף axis_of).
//   • freeValueOk          — במקור `_freeValueOk(reg, target, prop, value)` (edit_intent.dart:231; אטום-מדף free_value_ok).
//   • resolveStyle         — במקור `_resolveStyle(reg, target, style)` (edit_intent.dart:241) ⇒ ({ok, style}).
//   • actionIdOf           — במקור `_actionIdOf(m)` (edit_intent.dart:287; אטום-מדף action_id_of).
//   • matchActionId        — במקור `matchActionId(reg, target, id)` (חוקי על-האלמנט?).
//   • matchCatalogActionId — במקור `matchCatalogActionId(id)` (action_catalog.dart, step 72 — קיים-בקטלוג?).
//
// טיפוסי-שכן מוטבעים (הכרעה-2 של הקידום; class מינימלי verbatim מהמקור):
//   • משפחת-ה-ConfigOp הסגורה (config_store.dart:51-…): id + payload פר-וריאנט.
//     ה-apply/toJson של המקור הם חיווט-קופסה (גוררים CfgNode) — לא חלק מהאטום.
//   • CfgAction (config_node.dart:157-166): kind + args, מינימלי (הבנייה-מחדש
//     `CfgAction(kind: onElement)` בשורה 212 היא חלק-מגוף-האטום).
//   • CfgStyle לא הוטבע: ה-style עובר אטוּם (Object?) דרך שקע-resolveStyle — האטום
//     לא קורא אף שדה שלו (חוק-5: אפס ידע-הקשר).
//
// קלט:  entry — Object? : איבר-מערך גולמי אחד מפענוח-JSON (מפה, או כל דבר אחר).
//       תשעה שקעים required (מעל).
// פלט:  ConfigOp? — ה-op המאומת עם ערכים RESOLVED (מזהה-רג'יסטרי אמיתי), או null (drop).
//        ‏TOTAL — לעולם לא זריקה.

/// §75 — אימות op-בודד: צורה (opFromJson) ⇒ יעד-אמיתי (matchElementId, ה-RESOLVED
/// נישא הלאה) ⇒ ציר-עריך (matchPropKey על axisOf) ⇒ ערך/פעולה פר-סוג. פספוס בכל
/// שלב ⇒ null. ‏verbatim edit_intent.dart:171-214.
ConfigOp? validateOp(
  Object? entry, {
  required ConfigOp? Function(Map<String, dynamic> m) opFromJson,
  required String? Function(String id) matchElementId,
  required String? Function(String target, String axis) matchPropKey,
  required String Function(ConfigOp op) axisOf,
  required bool Function(String target, String prop, String? value) freeValueOk,
  required ({bool ok, Object? style}) Function(String target, Object? style)
      resolveStyle,
  required String? Function(Map<String, dynamic> m) actionIdOf,
  required String? Function(String target, String id) matchActionId,
  required String? Function(String id) matchCatalogActionId,
}) {
  if (entry is! Map) return null; // a stray non-object array element.
  final m = entry.map((k, v) => MapEntry(k.toString(), v));

  // SHAPE (step 69): a real ConfigOp tag with a non-empty id, or null. An
  // `addComponent`/`addRule` (no P1 variant) drops here → invented component gone.
  final shape = opFromJson(m);
  if (shape == null) return null;

  // FIELD 1 — target must be a REAL registry id (else drop). The RESOLVED id (exact
  // or longest-contained) is carried through, mirroring assistant_intent.dart:195.
  final target = matchElementId(shape.id);
  if (target == null) return null;

  // FIELD 2 — the op-kind's axis must be an EDITABLE prop of that element (else drop).
  if (matchPropKey(target, axisOf(shape)) == null) return null;

  // FIELD 3/4 — value / action per kind, grounded where the registry constrains it.
  switch (shape) {
    case SetText(:final text):
      if (!freeValueOk(target, 'text', text)) return null;
      return SetText(target, text);
    case SetEmoji(:final emoji):
      if (!freeValueOk(target, 'emoji', emoji)) return null;
      return SetEmoji(target, emoji);
    case SetHidden(:final hidden):
      return SetHidden(target, hidden); // bool — no closed set (editability gated it).
    case SetOrder(:final order):
      return SetOrder(target, order); // int — no closed set.
    case SetStyle(:final style):
      final resolved = resolveStyle(target, style);
      if (!resolved.ok) return null; // an invented style token → drop.
      return SetStyle(target, resolved.style);
    case SetAction():
      // The action id is a bare string per the grammar (edit_prompt.dart:113), which
      // `configOpFromJson` leaves as a null CfgAction — so read it from the raw map.
      final id = actionIdOf(m);
      if (id == null) return null;
      final onElement = matchActionId(target, id); // legal ON this element?
      final inCatalog = matchCatalogActionId(id); // a REAL catalog action?
      if (onElement == null || inCatalog == null) return null;
      return SetAction(target, CfgAction(kind: onElement));
  }
}

// — טיפוסי-שכן מוטבעים (config_store.dart — משפחת-העריכה הסגורה, מינימלי-verbatim:
//   id + payload; ‏apply/toJson של המקור = חיווט-קופסה, מחוץ-לאטום) —

/// עריכת ציר-יחיד על אלמנט [id] (config_store.dart:51-54, מינימלי).
sealed class ConfigOp {
  const ConfigOp(this.id);
  final String id;
}

final class SetText extends ConfigOp {
  const SetText(super.id, this.text);
  final String? text;
}

final class SetEmoji extends ConfigOp {
  const SetEmoji(super.id, this.emoji);
  final String? emoji;
}

final class SetHidden extends ConfigOp {
  const SetHidden(super.id, this.hidden);
  final bool? hidden;
}

final class SetOrder extends ConfigOp {
  const SetOrder(super.id, this.order);
  final int? order;
}

final class SetStyle extends ConfigOp {
  const SetStyle(super.id, this.style);

  /// אטוּם לאטום-זה (במקור CfgStyle?) — נצרך רק דרך שקע-resolveStyle (חוק-5).
  final Object? style;
}

final class SetAction extends ConfigOp {
  const SetAction(super.id, this.action);
  final CfgAction? action;
}

/// פעולת-אלמנט (config_node.dart:157-166, מינימלי-verbatim: kind + args).
class CfgAction {
  const CfgAction({required this.kind, this.args = const {}});
  final String kind;
  final Map<String, dynamic> args;
}
