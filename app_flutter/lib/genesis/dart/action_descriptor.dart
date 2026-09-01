// ⚛️ אטום-Dart (דרגת-חוזה) · actionDescriptor
// מוצא: buildsmart/app_flutter/lib/logic/studio/action_catalog.dart:245-250 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
// שקע: המקור קורא לקבוע-השכן `kActionCatalog` (:131). לפי חוק-3 הוא הופך לפרמטר-שקע
//       `catalog` מתועד — האטום לא מכיר קטלוג ספציפי, מקבל אותו בהזרקה.
// טיפוסים: `ActionDescriptor` + `ActionEffectKind` מוגדרים כאן verbatim מהמקור (:65-126) —
//          זהו הטיפוס שהאטום פועל עליו (data-shape), לא ייבוא-אטום-אחר (חוק-1).
//
// קלט:  catalog — רשימת מתארי-פעולה (השקע; במקור `kActionCatalog`). · id — מזהה-הפעולה המבוקש.
// פלט:  המתאר שה-`id` שלו זהה בדיוק ל-`id` המבוקש, או `null` (fail-closed — מזהה תלוש/מומצא ⇒ אין מתאר).

/// The CLOSED set of effect KINDS a catalog action can have (verbatim מהמקור :65-84).
enum ActionEffectKind {
  /// Push a screen route.
  navScreen,

  /// Open a modal bottom sheet.
  openSheet,

  /// Add a line to the smart cart — the ONLY state-mutating kind, hence always `confirmGated`.
  cartAdd,

  /// Bring the cart forward — pure navigation.
  cartOpen,

  /// Copy/share text to the clipboard.
  shareText,
}

/// One catalog entry (verbatim מהמקור :90-126): a closed [id] the model may NAME,
/// its Hebrew [he] label, the deterministic [kind] it resolves to, the real app
/// effect it is [groundedIn], plus [sheetId] / [mutates] / [confirmGated]. Pure data.
class ActionDescriptor {
  const ActionDescriptor({
    required this.id,
    required this.he,
    required this.kind,
    required this.groundedIn,
    this.sheetId,
    this.mutates = false,
    this.confirmGated = false,
  });

  /// The CLOSED action id — the only string the model is allowed to emit.
  final String id;

  /// The Hebrew label shown beside the id in preview / the manual builder.
  final String he;

  /// The ONE deterministic effect this action performs.
  final ActionEffectKind kind;

  /// The real app effect this is grounded in (`file.dart:line · symbol`).
  final String groundedIn;

  /// For [ActionEffectKind.openSheet] — WHICH contractor sheet; `null` otherwise.
  final String? sheetId;

  /// True when the action WRITES business state. Only `cart.add` does.
  final bool mutates;

  /// True when the action is reachable ONLY behind an explicit confirm-tap.
  final bool confirmGated;
}

/// The descriptor in [catalog] whose id exactly equals [id], or `null` when [id]
/// is not in the catalog (fail-closed — a dangling/invented id resolves to NO
/// effect). Exact lookup, first-match-wins, `==` comparison (case-sensitive).
///
/// [catalog] is the injected socket (the source read the neighbor const
/// `kActionCatalog`; חוק-3 turns that into this parameter).
ActionDescriptor? actionDescriptor(List<ActionDescriptor> catalog, String id) {
  for (final a in catalog) {
    if (a.id == id) return a;
  }
  return null;
}
