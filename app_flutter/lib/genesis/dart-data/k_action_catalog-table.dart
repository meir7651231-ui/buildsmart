// 🗄️ טבלה-מוקלדת · kActionCatalog (const List<ActionDescriptor>) — אטום-דאטה משותף (G69 · חצב-AST, חוק-4 — verbatim מהמקור, כולל סגירת-הטיפוסים).
// מוצא: buildsmart/app_flutter/lib/logic/studio/action_catalog.dart:131
// טוהר: אפס-import; 2 הצהרות-סגירה + הטבלה. פונקציות-מדף **מייבאות** את הקובץ הזה (ייבוא-לפי-מוצא בחצב) במקום להטביע עותק.
// גודל: 7 רשומות (נמדד בהרצה).
// ייצוא: kActionCatalog ← buildsmart/app_flutter/lib/logic/studio/action_catalog.dart
// ייצוא: ActionEffectKind ← buildsmart/app_flutter/lib/logic/studio/action_catalog.dart
// ייצוא: ActionDescriptor ← buildsmart/app_flutter/lib/logic/studio/action_catalog.dart

/// The CLOSED set of effect KINDS a catalog action can have — every
/// [ActionDescriptor] is exactly one of these, each grounded in a real app effect
/// (file:line in the header). CLOSED BY OMISSION (§7 · governance #84): there is
/// deliberately NO `navStructure` (retab / hide-tab / reorder-nav) and NO `auth`
/// (login / logout / grant-role) kind, so those capabilities cannot be expressed;
/// their absence is asserted by the catalog test.
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

/// One catalog entry: a closed [id] the model may NAME, its Hebrew human [he]
/// label (so step-79 preview / step-82 builder need NO separate translation
/// table, §6), the single deterministic [kind] it resolves to, and the real app
/// effect it is [groundedIn] (an audit trail, never dead-reckoned). Pure data.
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

/// The CLOSED action catalog — the 7 grounded actions of §4. Extend DELIBERATELY
/// (the golden-list test forces an explicit edit here on any add/remove, gating
/// silent catalog-growth — "Extend deliberately", תוספת-ב).
const List<ActionDescriptor> kActionCatalog = <ActionDescriptor>[
  ActionDescriptor(
    id: 'nav.screen',
    he: 'מעבר למסך',
    kind: ActionEffectKind.navScreen,
    groundedIn: 'manager_copilot_screen.dart:32 · static Route<void> route()',
  ),
  ActionDescriptor(
    id: 'sheet.scanPlan',
    he: 'סרוק תוכנית עבודה',
    kind: ActionEffectKind.openSheet,
    sheetId: 'scanPlan',
    groundedIn: 'contractor_tools_sheets.dart:26 · openScanPlanSheet',
  ),
  ActionDescriptor(
    id: 'sheet.cheaperAlt',
    he: 'חלופות זולות',
    kind: ActionEffectKind.openSheet,
    sheetId: 'cheaperAlternatives',
    groundedIn: 'contractor_tools_sheets.dart:39 · openCheaperAlternativesSheet',
  ),
  ActionDescriptor(
    id: 'sheet.priceCompare',
    he: 'השוואת מחירים',
    kind: ActionEffectKind.openSheet,
    sheetId: 'priceCompare',
    groundedIn: 'contractor_tools_sheets.dart:52 · openPriceCompareSheet',
  ),
  ActionDescriptor(
    id: 'cart.add',
    he: 'הוסף לסל',
    kind: ActionEffectKind.cartAdd,
    mutates: true,
    confirmGated: true,
    groundedIn:
        'ai_assistant_screen.dart:210 · _confirmAdd (G5 confirm-only cart write)',
  ),
  ActionDescriptor(
    id: 'cart.open',
    he: 'פתח את הסל',
    kind: ActionEffectKind.cartOpen,
    groundedIn:
        'home_shell.dart:296 · CartFab.openCart → tab 3 + StoreSection.cart',
  ),
  ActionDescriptor(
    id: 'share.text',
    he: 'העתק / שתף טקסט',
    kind: ActionEffectKind.shareText,
    groundedIn: 'reject_reason_screen.dart:110 · _copy → Clipboard.setData',
  ),
];
