// ⚛️ אטום-Dart (דרגת-חוזה) · actionHe
// מוצא: buildsmart/app_flutter/lib/logic/studio/action_catalog.dart:254-260 (חצב-בינה · חוק-3/4).
// שקע: actionDescriptor ← השכן `actionDescriptor(id)` — רשומת-הפעולה מהקטלוג או null.
// מוטבע verbatim (טיפוסי-נתונים מקומיים, כלל-1): ActionDescriptor + ActionEffectKind
//        (action_catalog.dart:65-129). actionHe = הלייבל העברי, או null אם אין פעולה.

enum ActionEffectKind {
  /// Push a screen route (`Navigator.push(Screen.route())`) — the target is
  /// resolved by [matchScreenId] against the ~38 no-arg screens ONLY.
  navScreen,

  /// Open a modal bottom sheet (`showModalBottomSheet`) — WHICH sheet is carried
  /// in [ActionDescriptor.sheetId] (one of the three contractor sheets).
  openSheet,

  /// Add a line to the smart cart (`smartCartProvider.notifier.add`) — the ONLY
  /// state-mutating kind, hence always `confirmGated`.
  cartAdd,

  /// Bring the cart forward (`mainTabProvider = 3` + `StoreSection.cart`) — pure
  /// navigation, no business-state write.
  cartOpen,

  /// Copy/share text to the clipboard (`Clipboard.setData`) — no app-state write.
  shareText,
}

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

  /// The CLOSED action id — the only string the model is allowed to emit for a
  /// `SetAction` (grounded via [matchCatalogActionId]).
  final String id;

  /// The Hebrew label shown beside the id in preview / the manual builder (§6).
  final String he;

  /// The ONE deterministic effect this action performs.
  final ActionEffectKind kind;

  /// The real app effect this is grounded in (`file.dart:line · symbol`) — a
  /// human audit trail proving the id is not invented.
  final String groundedIn;

  /// For [ActionEffectKind.openSheet] — WHICH contractor sheet
  /// (`scanPlan` / `cheaperAlternatives` / `priceCompare`); `null` otherwise.
  final String? sheetId;

  /// True when the action WRITES business state. Only `cart.add` does; it is
  /// therefore `confirmGated`. The catalog test asserts `mutates ⇒ confirmGated`.
  final bool mutates;

  /// True when the action is reachable ONLY behind an explicit confirm-tap
  /// (the `_confirmAdd` G5 gate). Required for every mutator (§7.5).
  final bool confirmGated;
}

String? actionHe(String id,
        {required ActionDescriptor? Function(String) actionDescriptor}) =>
    actionDescriptor(id)?.he;
