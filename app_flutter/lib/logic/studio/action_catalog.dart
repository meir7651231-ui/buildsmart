// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 4 · Step 72 — the static ACTION CATALOG: the closed
// "what a button does" set, every `ActionId` mapped to ONE deterministic effect
// GROUNDED in a REAL navigation / sheet / cart / share the app already performs.
//
// GOAL (step 72): a CLOSED catalog the AI co-editor (and the manual builder,
// step 82) grounds a `SetAction` against — the model may only NAME an id from this
// set; Dart deterministically resolves it to the real effect. No free-form action
// string ever reaches an effect (the anti-hallucination spine: matchers → closed
// set → verified diff), exactly like the step-71 registry matchers.
//
// GROUNDING (§4 — the 7 real effects, each a live file:line, nothing invented):
//   • nav.screen          → a `MaterialPageRoute` push, `manager_copilot_screen
//                            .dart:32` route() idiom. Valid ONLY for the ~38
//                            no-arg `route()` screens (see [kNavScreenIds]).
//   • sheet.scanPlan      → openScanPlanSheet          contractor_tools_sheets.dart:26
//   • sheet.cheaperAlt    → openCheaperAlternativesSheet contractor_tools_sheets.dart:39
//   • sheet.priceCompare  → openPriceCompareSheet       contractor_tools_sheets.dart:52
//   • cart.add            → smartCartProvider.notifier.add (the G5 confirm-only
//                            cart write) ai_assistant_screen.dart:210-222
//   • cart.open           → CartFab.openCart → tab 3 + StoreSection.cart
//                            home_shell.dart:296-304 (reached from the AI hub)
//   • share.text          → Clipboard.setData (copy-to-share) reject_reason_screen
//                            .dart:110-117
//
// CLOSED BY OMISSION (§7 safety · governance #84): there is deliberately NO
// nav-STRUCTURE action (no hide-tab / reorder-nav / remove-login) and NO auth
// action (no login / logout / grant-role / HR) anywhere in this catalog. The
// [ActionEffectKind] enum is CLOSED to the five grounded kinds, so such a
// capability cannot be expressed — the absence is asserted mechanically by
// studio_action_catalog_test (the #84 audit that closes in absentia).
//
// SAFETY (§7.5 · confirm-gate): the ONLY state-MUTATING action is `cart.add`, and
// it is marked `confirmGated` — grounded in `_confirmAdd` ("the ONLY cart-write
// path — reachable solely by the user tapping confirm", ai_assistant_screen.dart:
// 208). The invariant `mutates ⇒ confirmGated` is asserted; nav / sheet-open /
// cart-open / share touch no business state, so they are non-mutating.
//
// ADAPTATION — the step's detail is PRE-S3.K (stale). It said "~38 no-arg / 11
// typed-arg"; the live tree has 38 no-arg but **17** typed-arg route lines. The
// typed-arg screens need per-screen arg-builders that do not exist, so they are
// out-of-v1: they are NOT in [kNavScreenIds] ⇒ `matchScreenId` degrades them to
// `null` (in NL) and the manual builder GREYS them "צריך פרמטרים — לא זמין" —
// never a silent drop, never a guessed arg reaching an effect (R1-5).
//
// REUSE (step 71): grounding a nav.screen target / a catalog action id goes through
// the FROZEN `matchElementId` (exact → longest-contained → null) over a
// [FakeRegistryView] seeded with the closed id set — the SAME single matching path
// as the registry (DoD §8), no second algorithm.
//
// DORMANT: pure static data + pure functions — NO Widget, NO build, NO gateway, NO
// provider, Firebase-free. Nothing in `lib/` imports it yet ⇒ tree-shaken out ⇒
// byte-identical under every flag (the palette-rendering is Pillar-1's job, not
// this file's — DoD §8).
// ─────────────────────────────────────────────────────────────────────────────

import 'registry_view.dart' show FakeRegistryView, RegistryView, matchElementId;

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

/// The ~38 no-arg `route()` screen ids — the ONLY legal `nav.screen` targets
/// (R1-5). Enumerated LIVE from the tree (`grep 'static Route<…> route()'`), not
/// the plan's stale count. A typed-arg screen (e.g. `AiFinderScreen`,
/// `RejectReasonScreen`, `LipskeySectionScreen`) is DELIBERATELY absent — it needs
/// a per-screen arg-builder that does not exist, so it degrades / is greyed rather
/// than receiving a guessed arg. The golden-list test pins this exact set.
const Set<String> kNavScreenIds = <String>{
  'AIHubScreen',
  'AiAssistantScreen',
  'BudgetScreen',
  'ChatSettingsScreen',
  'CourierAttendanceScreen',
  'CourierCertsScreen',
  'CourierDashboardScreen',
  'CourierFormsScreen',
  'CourierProfileScreen',
  'CourierSettingsScreen',
  'DescribeToCartScreen',
  'HomeContentReorder',
  'LipskeyBrandScreen',
  'ManagerCopilotScreen',
  'ManagerDashboardScreen',
  'ManagerProfileScreen',
  'NotifSettingsScreen',
  'ProfileScreen',
  'ProjectsScreen',
  'RegressionPanelScreen',
  'RewardsHubScreen',
  'RoleRequestsInboxScreen',
  'SmartProjectScreen',
  'StockScreen',
  'StoreDashboardScreen',
  'StoreProfileScreen',
  'StoreSettingsScreen',
  'SuppliersScreen',
  'TasksScreen',
  'TradeBuilderHomeScreen',
  'TradeDefineStepScreen',
  'WorkerAppScreen',
  'WorkerAttendanceScreen',
  'WorkerFormsScreen',
  'WorkerProfileScreen',
  'WorkerSafetyScreen',
  'WorkerSettingsScreen',
  'WorkerTaskBoardScreen',
};

/// A closed [RegistryView] over the nav-screen id set — the vehicle that lets the
/// nav.screen grounding REUSE the frozen step-71 [matchElementId] (exact →
/// longest-contained → null) instead of forking a second matching algorithm.
final RegistryView _navScreenView = FakeRegistryView.of(ids: kNavScreenIds);

/// A closed [RegistryView] over the catalog action ids — same reuse for grounding
/// a model-emitted `SetAction` string against the closed action set.
final RegistryView _catalogActionView =
    FakeRegistryView.of(ids: actionCatalogIds());

/// Every ActionId in the catalog (the closed action set the model is confined to).
Set<String> actionCatalogIds() => {for (final a in kActionCatalog) a.id};

/// The descriptor for [id], or `null` when [id] is not a catalog action
/// (fail-closed — a dangling/invented id resolves to NO effect). Exact lookup.
ActionDescriptor? actionDescriptor(String id) {
  for (final a in kActionCatalog) {
    if (a.id == id) return a;
  }
  return null;
}

/// The Hebrew label for [id] (step-79 preview / step-82 builder), or `null` when
/// [id] is not a catalog action. Sugar over [actionDescriptor].
String? actionHe(String id) => actionDescriptor(id)?.he;

/// Ground a model-emitted string to a REAL `nav.screen` TARGET from the ~38 no-arg
/// screens ONLY (R1-5), or `null` (degrade — the caller greys it "צריך פרמטרים —
/// לא זמין" in the manual builder). Reuses the frozen step-71 matcher: exact →
/// longest-contained → null; a blank reply / a typed-arg screen id / an invented
/// id all fail-closed to `null`. NEVER throws, NEVER invents a target.
String? matchScreenId(String reply) => matchElementId(_navScreenView, reply);

/// Ground a model-emitted string to a REAL catalog [ActionDescriptor.id], or
/// `null` (degrade). Same frozen matcher over the closed action set — the ONE
/// path from a `SetAction` string to a real, grounded action id.
String? matchCatalogActionId(String reply) =>
    matchElementId(_catalogActionView, reply);

/// Addition-a (§7.5 precursor): the catalog subset legal for an element's editing
/// CONTEXT. A read-only surface (a display-only card / an immutable region,
/// [readOnly] = true) must NEVER expose a MUTATOR — it sees only nav / open /
/// share, never `cart.add`; a mutable context sees the whole catalog.
///
/// This is the CONTEXT axis that COMPLEMENTS — does not duplicate —
/// [RegistryView.actionIdsFor]: the registry says which actions an element ALLOWS
/// (its per-element closed set); THIS says which catalog actions the element's
/// read/write context permits. The step-82 builder intersects the two
/// (`reg.actionIdsFor(id) ∩ catalogActionIdsFor(id, readOnly: …)`). A blank
/// [elementId] is fail-closed (empty), mirroring the matchers.
Set<String> catalogActionIdsFor(String elementId, {required bool readOnly}) {
  if (elementId.trim().isEmpty) return const <String>{}; // fail-closed
  return {
    for (final a in kActionCatalog)
      if (!(readOnly && a.mutates)) a.id,
  };
}
