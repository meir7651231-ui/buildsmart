# Pillar 1 — The No-Code Config Engine + Studio Shell

> **The foundation everything else builds on.** A single layered, persisted config
> tree keyed by stable element-ids, thin editable-wrapper widgets that existing
> widgets adopt incrementally, an element registry, the Studio control-center, an
> app-wide edit-mode overlay, and a local draft→publish + version/rollback
> mechanism. Owner-only, gated `kStudio*` **default OFF → zero regression**, server-ready.
>
> **Scope of THIS pillar (what I own):** the config-data-model · the wrapper API ·
> the registry · the Studio shell UI · edit-mode · the draft/publish-**LOCAL** mechanism
> · safety guardrails · the adoption strategy.
> **Seams I expose (others plug in):** Pillar 2 (domain-builder) writes domain
> nodes into the same tree; Pillar 3 (analytics) reads the registry + subscribes to
> publish events; Pillar 4 (AI co-editor) proposes diffs into the draft layer +
> owns the behavior/component palette and action-catalog; Pillar 5 (scale/backend)
> swaps the local `ConfigStore` for Firestore + push. **I design the seams, not their
> internals.**

---

## 0. Grounding — what the repo already does (cite file:line)

Every decision below reuses an existing pattern. Studied first:

- **Persisted settings idiom (the template I clone for `ConfigStore`):**
  `lib/state/catalog_settings.dart:369-408` — `StateNotifier` + `unawaited(_load())`
  in ctor, `_persist()` via `jsonEncode(state.toJson())` to a versioned
  SharedPreferences key (`'bs.catalog-settings.v1'` :8), best-effort
  `try/catch (_)`, `reset()` that `prefs.remove`s. Same shape in
  `lib/state/app_settings.dart:271-314`.
- **The closest existing "override" stores (precedent for visibility/order/text):**
  - **Visibility override:** `lib/state/hidden_catalog_sections.dart` — a persisted
    `Set<String>` of HIDDEN labels, `hide/show/toggle/isHidden`, non-destructive
    ("stay in the list, filtered out", :5-7). This is *exactly* the `visibility`
    layer in miniature, keyed by string.
  - **Reorder override:** `lib/state/home_content_order.dart:53-128` — persisted
    `List<enum>` order, `reorder/moveUp/moveDown/reset`, forward-compat append of
    missing sections (:72-75). This is the `order` layer in miniature.
  - These two PROVE the owner already controls visibility + order for a couple of
    surfaces — the engine **generalises them to every element** under one tree.
- **The gating pattern (how I get zero-regression):** two idioms coexist —
  - **Compile-time const flag:** `lib/data/repositories/backend.dart:12-13`
    (`kUseFirebaseBackendFlag = bool.fromEnvironment(...)`) — the documented
    "flip is the ONLY thing that changes behaviour, OFF = byte-identical"
    invariant, repeated 8× in that file (`kUidScopedQueries`, `kServerCallables`,
    `kCloudPhotos`, …). I adopt this invariant verbatim for `kStudio*`.
  - **Runtime persisted flag-set:** `lib/state/feature_flags.dart:36-101` —
    `FeatureFlagsNotifier extends StateNotifier<Set<String>>`, `isOn/enable/disable/
    toggle`, `_forcedOnFlags` empty by default so a normal build is byte-identical
    (:63-64). Lets the owner stage a feature ON **without a rebuild**. The Studio
    master-switch uses BOTH (compile default OFF + a runtime owner toggle).
- **Owner gate (who may edit):** `lib/data/board_accounts_local.dart:98-103` —
  `kOwnerEmails = {'meir7651231@gmail.com'}`, `isOwnerEmail(email)`. The manager
  board is granted ONLY to that allowlist after Google sign-in
  (`lib/screens/welcome_screen.dart:362`), and the session role is
  `BoardRole.manager` (`lib/state/board_auth.dart:288-297`,
  enum `:24`). Edit-mode keys off **exactly** this: `isOwnerEmail(session.email)
  && session.role == BoardRole.manager`. Governance #84: manager = platform-admin
  (`knowledge/MANAGER-BUILD-PLAN.md:14,§1`).
- **Theme / design tokens (what `CfgStyle` writes against):**
  `lib/theme/tokens.dart` (`BsTokens` — spacing :9-17, radii :20-22, type-scale
  :32-39, brand `#FF7A18` :57, full color set), consumed via
  `lib/theme/app_theme.dart:14-69` (`ThemeData` from `ColorScheme.fromSeed(seedColor:
  BsTokens.brand)`, `fontFamily: 'Heebo'`). Note the **`ThemeExtension` precedent**
  `BsSemanticColors` (`app_theme.dart:77-105`) read via `bsOnAccent(context)` /
  `bsSuccess(context)` (:109-116) — the exact mechanism by which the theme-editor
  injects owner overrides without touching call-sites.
- **RTL root:** established once at `lib/main.dart:373-374`
  (`Directionality(textDirection: TextDirection.rtl)`) and re-asserted per
  full-screen role app (`manager_dashboard_screen.dart:79`,
  `home_shell.dart:1233`). The edit-mode overlay inherits it; **never** introduce
  an LTR subtree (gate 65).
- **Adoption cost (the central constraint):** `grep "Text("` over `lib/` =
  **2,361 call-sites** across **358 dart files**. Pervasive raw `Text(...)` is why
  the wrappers MUST be opt-in and incremental — a big-bang rewrite is impossible
  and would blow every visual-regression gate. (Mega-screens to be careful around:
  `catalog_screen.dart` ~330 KB, `manager_dashboard_screen.dart` 136 KB,
  `chats_screen.dart` 96 KB.)
- **Inline-edit (R9) precedent:** the manager plan mandates "every edit = inline
  input, no modal/prompt" (`MANAGER-BUILD-PLAN.md:99,188`). The Studio inspector
  honours R9.
- **Gate / test harness:** `analysis_options.yaml` = `very_good_analysis` (strict;
  excludes `*.g.dart`/`*.freezed.dart`). `flutter test` = **404 test files**;
  enforcement is **source-scanning** (`test/knowledge_protocol_test.dart` greps
  `lib/` for dark surfaces, missing helpers, contract drift). Gate registry next
  free id = **118** (`knowledge/GATE_REGISTRY.md`), critical gates 31 (analyze 0),
  32 (test 0 regressions), 33 (build web), 94 (knowledge_protocol_test), 64/65
  (emoji/RTL). **No `uuid`/`freezed`/`json_serializable` deps** — plan stays
  hand-rolled JSON (the repo's house style) to avoid gate-60 (new dep).

**Decision rule for the whole pillar:** *clone the catalog_settings notifier,
generalise hidden_catalog_sections + home_content_order to an id-keyed tree, gate
like backend.dart, key edit-mode off isOwnerEmail+manager, write JSON by hand.*

---

## 1. Architecture at a glance

```
        ┌──────────────────────────────────────────────────────────┐
        │  ConfigStore  (StateNotifier<ConfigDoc>)  ← Pillar-5 seam │
        │  PUBLISHED layer  +  DRAFT layer  +  versions[]           │
        │  local: SharedPreferences 'bs.studio-config.v1'          │
        │  (later: Firestore /studio/{env} doc — same toJson)      │
        └──────────────────────────────────────────────────────────┘
              ▲ writes (draft)              │ reads (resolved)
              │                             ▼
   ┌──────────────────┐         ┌─────────────────────────────────┐
   │  Studio shell    │         │  configResolverProvider(id)     │
   │  (owner-only)    │         │  = merge(defaults ⊕ published    │
   │  tree·inspector· │         │          ⊕ draft-if-editing)     │
   │  theme·history   │         └─────────────────────────────────┘
   └──────────────────┘                       │ family by elementId
              ▲                                ▼
   ┌──────────────────┐         ┌─────────────────────────────────┐
   │  Edit-mode       │ overlay │  Cfg* wrappers in real screens  │
   │  controller      │◄────────│  CfgText / CfgVisible /         │
   │  (owner toggle)  │  taps   │  CfgStyle / CfgAction / CfgList │
   └──────────────────┘         └─────────────────────────────────┘
                                            ▲
                                 ElementRegistry (compile-time
                                 manifest of every known id, even
                                 before a widget adopts a wrapper)
```

**Layered resolution (the heart).** Each element-id resolves through an ordered
merge, most-specific wins:

```
DEFAULT (code literal, the "ground truth" baseline)
  ⊕ PUBLISHED.global[id]            (owner's live edit, all users)
  ⊕ PUBLISHED.persona[role][id]     (per-persona override)
  ⊕ DRAFT.* (SAME shape)            ← applied ONLY in owner edit-preview
= resolved Cfg for this id, this viewer
```

Regular users only ever see `DEFAULT ⊕ PUBLISHED`. The draft layer is invisible to
them until publish. **This is the zero-regression keystone:** an empty published
layer ⊕ no edit-mode = every wrapper returns its code default = byte-identical app.

**Why layered (not flat).** Visibility, content, style, behavior, and per-persona
are *independent axes* with different validation, different safety rules (you may
restyle "צ'אט" but not hide the auth button), and different owners (Pillar-4 AI
proposes style+content; Pillar-2 domain-builder writes structure). A flat
"settings blob" couldn't express "hidden for courier, renamed globally, restyled
in draft." Sub-maps per axis keep each independently diff-able, validatable, and
resettable.

---

## 2. The config data model

All hand-rolled JSON (`toJson`/`fromJson`, the `_enum`/null-fallback style of
`catalog_settings.dart:283-357`). **Forward-compatible:** unknown keys are
preserved on round-trip (so a Pillar-2/4 field added later survives an old client),
and every getter has a default so a partial map never throws.

### 2.1 Element override (one node, all axes optional)

```dart
// lib/state/studio/config_node.dart   (NEW)
class CfgNode {                       // every field nullable = "inherit/default"
  // ── CONTENT ──
  final String? text;                 // CfgText override (Hebrew verbatim)
  final String? emoji;                // leading emoji override
  // ── VISIBILITY ──
  final bool? hidden;                 // CfgVisible: true = hide (null = show)
  // ── ORDER ──  (within a CfgList parent)
  final int? order;                   // sort key inside its list bucket
  // ── DESIGN ──  (CfgStyle: a small, validated, themeable subset)
  final CfgStyle? style;              // see 2.2 — color/size/weight/pad tokens
  // ── BEHAVIOR ──  (CfgAction — Pillar-4 OWNS the catalog of action kinds)
  final CfgAction? action;           // opaque-to-me action descriptor
  // forward-compat: keep any keys we don't recognise
  final Map<String, dynamic> extra;  // unknown future axes round-trip intact
}
```

`CfgNode` is a value object: `const` ctor, `copyWith`, `toJson` (omits nulls →
sparse maps → small docs → scales to 10Ks ids, §11), `fromJson` tolerant.
**A node with all-null = identity (no override).** Empty nodes are pruned on
publish so the doc only carries actual edits.

### 2.2 `CfgStyle` — design, but **token-bounded** (safety + theme-consistency)

The owner edits design through a *constrained* surface, not free CSS — so output
always honours `BsTokens` and can't produce an illegible/oversized element.

```dart
class CfgStyle {
  final String? colorToken;   // enum-name of an allowed BsTokens color
                              // (brand/ink/muted/success/danger/…) — NOT raw hex
  final String? bgToken;      // allowed surface token
  final double? fontScale;    // CLAMPED 0.8..1.6 of the resolved base size
  final String? weightToken;  // {regular, medium, bold} → FontWeight
  final String? sizeToken;    // type-scale step (typeBody/typeSubhead/…)
  final EdgeKey? pad;         // {none,sm,md,lg} → BsTokens.spaceN
}
```

Resolution maps tokens→`BsTokens`/`Theme.of(context)` values at read-time, so a
later theme/brand change flows through automatically (same indirection as
`bsOnAccent`). Raw hex is **deliberately not allowed in v1** (guardrail: prevents
contrast failures that would trip `test/a11y_contrast_theme_test.dart`); the global
**theme-editor** (§5.4) is the sanctioned place to change actual palette values,
and it edits a `CfgTheme` override consumed by an `AppTheme` extension.

### 2.3 `CfgAction` — behavior **seam** (Pillar-4 owns the content)

I define the envelope + the dispatch seam; I do **not** enumerate action kinds
(that's Pillar-4's action-catalog). v1 ships ONE safe built-in kind so the
mechanism is live and testable:

```dart
class CfgAction {
  final String kind;                 // e.g. 'navigate' | 'openSheet' | 'noop'
  final Map<String, dynamic> args;   // kind-specific (opaque to the engine)
}
// dispatch seam — Pillar-4 registers handlers; engine ships 'noop' + a guarded
// 'navigate' to a whitelisted set of EXISTING routes only (no arbitrary nav).
typedef CfgActionHandler = void Function(BuildContext, Map<String,dynamic> args);
final cfgActionRegistryProvider = Provider<Map<String, CfgActionHandler>>(...);
```

### 2.4 The document (layers + versions)

```dart
class ConfigDoc {
  final ConfigLayer published;       // live, every user
  final ConfigLayer draft;           // owner work-in-progress (not live)
  final List<ConfigVersion> history; // ring buffer, newest first (cap N=30)
  final int schemaVersion;           // for migrations
}
class ConfigLayer {                  // the LAYER = global + per-persona maps
  final Map<String, CfgNode> global;            // id → override
  final Map<String, Map<String, CfgNode>> persona; // role → (id → override)
  // (Pillar-2 also writes a `structure` sub-doc here — see §13 seam)
}
class ConfigVersion {
  final String id;                   // millis-based id (no uuid dep needed)
  final ConfigLayer snapshot;        // full published layer at publish time
  final int publishedAtMs;
  final String note;                 // "שינוי מחיר ברז", AI-summary-able
  final String byEmail;              // audit (owner email)
}
```

History stores **full published snapshots** (not diffs) for dead-simple one-tap
rollback — N≤30 sparse layers is tiny (§11). Diff *display* in the UI is computed
on the fly (newVsOld); we don't persist diffs.

### 2.5 The store (clone of the proven notifier)

```dart
// lib/state/studio/config_store.dart   (NEW)
class ConfigStore extends StateNotifier<ConfigDoc> {
  ConfigStore(this._sink) : super(ConfigDoc.empty) { unawaited(_load()); }
  final ConfigSink _sink;            // ← Pillar-5 seam (local now / Firestore later)
  static const _key = 'bs.studio-config.v1';
  // _load/_persist: byte-for-byte the catalog_settings.dart:374-389 pattern
  void editDraft(String id, CfgNode Function(CfgNode) f, {String? persona}); // R9 writes
  void resetDraftNode(String id, {String? persona});   // per-element reset
  void discardDraft();                                  // draft ← published
  void publish(String note, String byEmail);            // draft → published + version + push
  void rollback(String versionId);                      // published ← snapshot (+ new version)
}
final configStoreProvider =
    StateNotifierProvider<ConfigStore, ConfigDoc>((ref) =>
        ConfigStore(ref.watch(configSinkProvider)));   // sink injected → testable + server-ready
```

`ConfigSink` (`Future<void> save(ConfigDoc)` + optional `Stream<ConfigDoc> watch()`)
defaults to a `LocalPrefsSink`; Pillar-5 supplies a `FirestoreSink` with **no
change to the store, the wrappers, or the Studio** — the single swap point.

### 2.6 Read path (what wrappers call)

```dart
// resolved view for ONE id, for the CURRENT viewer (persona + edit-preview aware)
final resolvedNodeProvider = Provider.family<CfgNode, String>((ref, id) {
  final doc  = ref.watch(configStoreProvider);
  final role = ref.watch(viewerRoleProvider);          // BoardRole or null
  final live = ref.watch(editModeProvider).previewDraft; // owner sees draft live
  return mergeNode(id, doc, role, includeDraft: live);
});
```

`mergeNode` is a **pure function** (unit-testable without Flutter) — the merge
order of §1. Pure-helper purity matches the repo's "wired pure helper" convention
that `knowledge_protocol_test.dart` guards.

---

## 3. The wrapper API (`Cfg*`)

Thin, opt-in, *zero-cost when the engine is OFF*. Each wrapper:
(1) reads `resolvedNodeProvider(id)`, (2) renders the real widget with overrides
applied, (3) in edit-mode wraps itself in an `EditHandle` (tap → inspector;
dashed outline; long-press → quick actions). **`const`-friendly, RTL-inheriting,
a11y-preserving (Semantics pass-through).**

### 3.1 `CfgText` — content (the highest-leverage wrapper)

```dart
// lib/widgets/studio/cfg_text.dart   (NEW)
class CfgText extends ConsumerWidget {
  const CfgText(this.id, this.fallback, {this.style, this.semanticsLabel, super.key});
  final String id;          // STABLE element-id, e.g. 'home.cta.primary'
  final String fallback;    // the current Hebrew literal (verbatim) = DEFAULT
  final TextStyle? style;
  @override Widget build(ctx, ref) {
    final n = ref.watch(resolvedNodeProvider(id));
    final txt = n.text ?? fallback;                 // OFF/empty ⇒ fallback ⇒ identical
    final emoji = n.emoji;
    final eff = applyStyle(context, style, n.style); // token→TextStyle
    Widget w = Text(emoji == null ? txt : '$emoji $txt',
                     style: eff, semanticsLabel: semanticsLabel);
    return EditHandle.maybe(ref, id, child: w);      // no-op unless edit-mode
  }
}
```

**Migration is mechanical:** `Text('שלח')` → `CfgText('cart.cta.send', 'שלח')`.
The Hebrew literal stays in source as the fallback (gate 61/64 — verbatim emoji
still present), so a grep for the string still finds it and nothing breaks if the
engine is stripped. (Adoption strategy: §9.)

### 3.2 `CfgVisible` — show/hide/reorder (generalises hidden_catalog_sections)

```dart
class CfgVisible extends ConsumerWidget {            // wraps any subtree
  const CfgVisible(this.id, {required this.child, this.critical = false, super.key});
  final bool critical;                               // safety: cannot be hidden (§8)
  @override Widget build(ctx, ref) {
    final n = ref.watch(resolvedNodeProvider(id));
    final hidden = !critical && (n.hidden ?? false);
    if (hidden && !ref.watch(editModeProvider).isEditing) return const SizedBox.shrink();
    Widget w = Opacity(opacity: hidden ? 0.35 : 1, child: child); // shown ghosted in edit-mode
    return EditHandle.maybe(ref, id, child: w, badge: hidden ? 'מוסתר' : null);
  }
}
```

Hidden elements still render (ghosted) in edit-mode so the owner can re-show them —
the non-destructive principle from `hidden_catalog_sections.dart:5-7`.

### 3.3 `CfgList` — reorderable containers (generalises home_content_order)

A wrapper over `Column`/`Wrap`/`ListView` children: each child is tagged with an id;
`order` from each child's `CfgNode` re-sorts them (stable sort, missing order ⇒
declaration index, the forward-compat append of `home_content_order.dart:72-75`).
In edit-mode it swaps to a `ReorderableListView` (the exact widget
`home_content_order.dart` already drives via `reorder(old,new)` :91-101).

### 3.4 `CfgStyle` (modifier) + `CfgAction` (behavior)

`CfgStyle` is mostly folded into the other wrappers via `applyStyle`, but a
standalone `CfgBox(id, child)` exists for restyling arbitrary containers
(bg/pad/radius tokens). `CfgAction(id, builder)` wraps a tappable: it resolves the
node's `CfgAction` and routes through `cfgActionRegistryProvider`; with no override
it calls the widget's original `onTap` (so OFF = identical). Pillar-4 fills the
handler map; v1 ships `noop` + guarded `navigate`.

### 3.5 Common infra — `EditHandle` + ids

- `EditHandle.maybe(ref, id, {child, badge})` returns `child` **unchanged** unless
  `editModeProvider.isEditing` (owner). When editing: a `Stack` adds a 1px dashed
  brand outline + a tiny tap target that calls `studioSelect(id)` (opens the
  inspector) — pointer events for the underlying widget are suppressed while
  editing so a tap edits rather than activates.
- **Element-ids** are dotted, stable, human-meaningful strings
  (`'<screen>.<area>.<role>'`, e.g. `'manager.cockpit.kpi.revenue.title'`). They
  are the contract; **renaming an id orphans its override** → ids are append-only
  and centrally registered (§4), with a lint test that ids passed to wrappers exist
  in the registry (a new gate, §10).

**Zero-cost-when-off proof for every wrapper:** the only added work over a raw
`Text`/`child` is one `ref.watch(resolvedNodeProvider(id))`; with an empty doc +
no edit-mode that returns a cached identity `CfgNode` and the wrapper returns the
identical widget tree. `EditHandle.maybe` short-circuits on `isEditing==false`.

---

## 4. The element registry

So the Studio can list **"everything"** before full wrapper adoption.

```dart
// lib/state/studio/element_registry.dart   (NEW)
class ElementDescriptor {
  final String id;              // stable id
  final String screen;          // grouping: 'home' | 'manager' | 'catalog' | …
  final String area;            // 'cockpit' | 'cart' | …
  final String labelHe;         // human name in the tree ("כפתור שליחה")
  final Set<CfgAxis> axes;      // which axes apply {content, visible, style, action}
  final bool critical;          // safety: nav/auth — visibility locked (§8)
  final Set<BoardRole>? personas; // null = all
}
const List<ElementDescriptor> kElementRegistry = [ ... ];  // compile-time manifest
final elementRegistryProvider = Provider((_) => kElementRegistry);  // Pillar-2 appends domain ids
```

- The registry is the Studio's **source of truth for the tree** (§5.2). An element
  appears in Studio the moment it's in the registry — adoption of the actual
  wrapper can lag (the inspector shows "not yet wired" for unadopted ids and
  edits are stored but inert until the wrapper lands).
- **Registry ⇆ wrapper consistency is gated:** a source-scanning test (like
  `knowledge_protocol_test.dart`) asserts every `CfgText('x', …)` literal id in
  `lib/` exists in `kElementRegistry`, and (warn-level) flags registry ids with no
  wrapper. This keeps "everything is listable" honest.
- **Auto-extraction tooling (Phase E):** a `dart` script greps `Cfg*('id', …)`
  call-sites to scaffold registry rows — but the registry stays a committed file
  (reviewable, gate-friendly), not runtime reflection (Flutter has none).
- **Seam for Pillar-2:** `elementRegistryProvider` concatenates `kElementRegistry`
  with a runtime `domainElementsProvider` (domain-builder's generated ids), so a
  new trade's elements show up in Studio automatically.
- **Seam for Pillar-3:** analytics subscribes to the registry to label
  click/stuck events by `labelHe`+`screen` (human-readable funnels) and to the
  publish-event stream to annotate "what changed when."

---

## 5. The Studio screen (owner control-center)

New full screen `lib/screens/studio/studio_screen.dart`, reached **only** from the
manager dashboard's 🛠️ ניהול tab (`manager_dashboard_screen.dart`, the `_ManageTab`
accordion ~:2240) behind `kStudioFlag`. RTL `Directionality` + light scaffold +
white AppBar — the manager screen's own chrome (`manager_dashboard_screen.dart:79-90`).
Four panes (segmented toggle → `IndexedStack`, the established pattern):

### 5.1 Top bar — draft status + publish
- Live "טיוטה" badge (count of changed nodes), **"פרסם לכולם"** primary button,
  **"בטל טיוטה"** (discard), and the edit-mode toggle ("מצב עריכה").
- Publish opens an R9 inline note field ("מה שינית?") → `publish(note, ownerEmail)`.

### 5.2 Pane A — **Tree of screens → elements**
- Expandable tree built from `elementRegistryProvider`, grouped `screen → area →
  element` (`ExpansionTile`s). Each leaf shows `labelHe`, current resolved text,
  and badges (מוסתר / ערוך / per-persona). Tap → inspector (Pane B).
- A **persona selector** at the top ("עורך עבור: כולם / קבלן / חנות / שליח /
  עובד / מנהל") scopes edits to a persona layer (writes `persona[role][id]`).
- Search box filters the tree by `labelHe`/id/current-text.

### 5.3 Pane B — **Inspector** (R9 inline, no modals)
Per selected element, only the axes in `descriptor.axes`:
- **תוכן:** inline `TextField` for text + emoji (seeded with resolved value;
  empty ⇒ "use default"). RTL, `textScaler`-safe.
- **נראות:** show/hide switch (disabled + lock icon if `critical`).
- **עיצוב:** token pickers (color/bg chips from `BsTokens`, size step, weight,
  fontScale slider clamped 0.8–1.6, padding) — **live preview** in the same pane.
- **התנהגות:** (Pillar-4 panel mount-point) — v1 shows kind + args read-only
  unless an action-catalog is registered.
- Footer: **"אפס אלמנט"** (`resetDraftNode`) + "מצב נוכחי מול ברירת-מחדל" diff line.

### 5.4 Pane C — **Theme editor** (global design)
- Edits a `CfgTheme` override (brand color, surface, ink, radius scale, default
  font scale) consumed by an `AppTheme` `ThemeExtension` (the `BsSemanticColors`
  mechanism, `app_theme.dart:77-116`). Live whole-app preview. Color choices run a
  **contrast check** (reuse the logic behind `test/a11y_contrast_theme_test.dart`)
  and block AA-failing combos (safety).

### 5.5 Pane D — **Find & replace + Version history**
- **Global find-&-replace** over content: search a Hebrew substring across all
  resolved texts (registry-driven), preview every hit with its `labelHe`, replace
  into the **draft** (never straight to published) — review then publish.
- **Version history:** `history[]` list (note · time · byEmail), each row →
  "תצוגה מקדימה" (preview that snapshot) + **"שחזר"** one-tap `rollback(id)`
  (which itself creates a new version, so rollback is undoable). Diff view
  (added/changed/removed ids) computed on the fly.

All Studio writes hit the **draft** layer (except rollback, which is an explicit
published change). Nothing reaches real users until **פרסם**.

---

## 6. Edit-mode overlay (owner-only, app-wide)

```dart
// lib/state/studio/edit_mode.dart   (NEW)
class EditModeState { final bool isEditing; final bool previewDraft; final String? selectedId; }
final editModeProvider = StateNotifierProvider<EditModeController, EditModeState>(...);
```

- **Gate to even exist:** `editModeProvider` can flip to `isEditing` ONLY when
  `kStudioFlag` is on **and** `isOwnerEmail(session.email) && role==manager`
  (`board_accounts_local.dart:102`, `board_auth.dart`). For everyone else the
  controller is permanently inert (the `_AutoLogout`/connection-indicator overlay
  pattern of `main.dart:382-396` — an always-mounted overlay that is **read-only/inert**
  off its gate).
- **The overlay:** a thin `StudioOverlay` widget inserted **once** in
  `main.dart`'s `builder:` Stack (`main.dart:383-395`, beside `ConnectionIndicator`)
  — so it floats over **every** screen. When editing it renders: a top "מצב עריכה"
  banner (with "צא ממצב עריכה" + "פתח סטודיו"), and it's what `EditHandle` talks to.
  When not editing it is `SizedBox.shrink()` ⇒ **byte-identical** to today.
- **Tap-to-edit in place (WYSIWYG):** because every `Cfg*` wrapper already injected
  an `EditHandle`, turning on edit-mode makes those handles intercept taps → a tiny
  inline popover (text field for `CfgText`; show/hide + "ערוך עוד" → Studio
  inspector for others). Edits land in the draft and re-render live via
  `resolvedNodeProvider` (because `previewDraft` is on for the owner) — true live
  WYSIWYG. Unadopted areas aren't tappable in-place but are still editable from the
  Studio tree.
- **Toggle entry point:** a single owner-only FAB/menu item in the manager
  dashboard turns edit-mode on and drops the owner back onto the normal app with
  the overlay active (so they edit the *real* screens, not a mock).

---

## 7. Draft / publish / versioning (LOCAL mechanism — Pillar-5 makes it remote)

- **Draft layer** lives in the same persisted doc; survives app restart (owner can
  edit across sessions before publishing). Only the owner's device sees it
  (locally; Pillar-5 may later sync drafts per-owner).
- **Publish** = `draft → published`, prune empty nodes, push a `ConfigVersion`
  snapshot (cap 30, drop oldest), clear draft, persist, **emit a publish event**
  on `configSinkProvider` (Pillar-5 turns this into a Firestore write +
  FCM/topic push so all devices update live; Pillar-3 logs it).
- **Versioning + rollback:** every publish snapshots the full published layer;
  rollback restores a snapshot **as a new publish** (forward-only history → always
  undoable, never destructive).
- **Server-ready seam:** the `ConfigSink` interface is the ONLY thing Pillar-5
  replaces. Local: write JSON to `'bs.studio-config.v1'` (catalog_settings idiom).
  Remote: same `ConfigDoc.toJson()` → Firestore `/studio/{env}` doc; `watch()`
  streams remote changes back into the same `ConfigStore` (mirrors how
  `ordersRepositoryProvider` swaps `_local`↔`_firebase` behind `useFirebaseBackend`,
  `backend.dart:16-17`). **No wrapper or Studio code changes when the backend flips.**
- **Migration:** `schemaVersion` + a `migrate(json)` step in `fromJson` (handles
  future axis additions; old docs upgrade in place — the forward-compat append
  pattern of `home_content_order.dart:72-75`).

---

## 8. Safety guardrails

1. **Critical elements can't be hidden / un-routed.** `descriptor.critical == true`
   (and `CfgVisible(critical:true)`) hard-blocks `hidden` in both the model
   (`mergeNode` ignores `hidden` for critical ids) and the inspector (switch
   disabled + lock). Critical set seeded from: bottom-nav, login/auth
   (`welcome_screen.dart`), the manager-board entry, the edit-mode exit, and the
   logout control. **Defence in depth:** a publish-time validator rejects a doc
   that hides any critical id (can't be smuggled via find-&-replace/AI/Pillar-2).
2. **Style is token-bounded** (§2.2) + **theme changes contrast-checked** (§5.4) →
   can't produce illegible UI; protects `a11y_contrast_theme_test`.
3. **Behavior is whitelisted:** `navigate` only to existing, registered routes;
   no arbitrary code, no external URLs (gate 51). Unknown action kind ⇒ falls back
   to the widget's original handler.
4. **Validation on every write + publish:** text length caps, emoji-only-from-legacy
   (gate 64), no LTR injection (gate 65), required-axis checks. Invalid edits are
   refused inline (R9 error text), never persisted.
5. **Reset at three scopes:** per-element (`resetDraftNode`), discard whole draft
   (`discardDraft`), and **"אפס הכל לברירת-מחדל"** (publish an empty layer) — always
   recoverable to the code baseline.
6. **Owner-only, end-to-end:** edit-mode + Studio gated by `isOwnerEmail`+manager
   AND `kStudioFlag`; Pillar-5 adds the matching Firestore-rules `manager`-claim
   check (the RBAC the manager plan already mandates, `MANAGER-BUILD-PLAN.md:112`)
   so the server refuses non-owner config writes even if the client were bypassed.
7. **Audit:** every publish/rollback records `byEmail`+`at`+`note` in the version
   (the manager plan's audit-log requirement, `MANAGER-BUILD-PLAN.md:110,114`).

---

## 9. Adoption strategy for existing widgets (the 2,361-`Text` problem)

**Principle: opt-in, incremental, reversible, gate-clean at every step.** No
big-bang. The app works fully with **zero** wrappers adopted (engine OFF = today).

1. **Wrappers ship first, adoption follows.** Phase B delivers `Cfg*` + engine
   with the flag OFF and **only a handful** of pilot adoptions (the manager
   cockpit KPI titles + the cart CTA — ~10 ids) to prove the loop end-to-end.
2. **Mechanical, search-friendly migration.** `Text('שלח')` →
   `CfgText('cart.cta.send','שלח')`. The literal stays as the fallback, so:
   gate 61/64 (verbatim Hebrew/emoji) still pass, a string grep still finds it, and
   ripping the engine out is a pure `Cfg→Text` revert. Same for `Visibility`→
   `CfgVisible`, ordered `Column`→`CfgList`.
3. **High-value surfaces first** (owner cares most, smallest blast radius):
   manager dashboard texts → home shell CTAs → catalog section/category labels →
   per-persona dashboards. Mega-files (`catalog_screen.dart`,
   `manager_dashboard_screen.dart`) are adopted **section-by-section**, each its
   own commit + visual_log entry (gate 107/116).
4. **Registry-first for the long tail.** Add ids to `kElementRegistry` ahead of
   wrapper adoption so Studio can already *list* them; wire the wrapper later. The
   gap is visible (inspector "not yet wired") and measurable (the warn-level
   registry-vs-wrapper test).
5. **Codemod assist.** A `dart` script (Phase E) proposes `Text(<literal>)` →
   `CfgText(<suggested-id>, <literal>)` edits for a chosen file for human review —
   accelerates without runtime reflection (which Flutter lacks).
6. **Per-commit discipline.** Each adoption batch: `analyze 0` (31) + `test`
   green (32) + `build web` (33) + `knowledge_protocol_test` (94) + visual_log
   (116). Because OFF=identical, visual diffs are empty until the owner actually
   publishes an override — so adoption commits are visually inert and low-risk.

---

## 10. New files + key existing seams to touch (file:line)

### New files (all under `lib/.../studio/`, the engine is self-contained)
| File | Role |
|---|---|
| `lib/state/studio/config_node.dart` | `CfgNode`, `CfgStyle`, `CfgAction` value objects + JSON |
| `lib/state/studio/config_doc.dart` | `ConfigDoc`/`ConfigLayer`/`ConfigVersion` + JSON + migrate |
| `lib/state/studio/config_merge.dart` | **pure** `mergeNode(...)` (unit core) |
| `lib/state/studio/config_store.dart` | `ConfigStore` notifier + `ConfigSink`/`LocalPrefsSink` + providers |
| `lib/state/studio/edit_mode.dart` | `EditModeController` + gate logic |
| `lib/state/studio/element_registry.dart` | `ElementDescriptor` + `kElementRegistry` + providers |
| `lib/state/studio/studio_flags.dart` | `kStudioFlag` const + `kStudioFlagName` runtime flag |
| `lib/state/studio/config_theme.dart` | `CfgTheme` override + `AppTheme` extension glue |
| `lib/widgets/studio/cfg_text.dart` … `cfg_visible/cfg_list/cfg_box/cfg_action.dart` | wrappers |
| `lib/widgets/studio/edit_handle.dart` | `EditHandle.maybe` + in-place popover |
| `lib/widgets/studio/studio_overlay.dart` | app-wide edit-mode overlay |
| `lib/screens/studio/studio_screen.dart` (+ `panes/`) | tree · inspector · theme · history |
| `test/studio/*` | merge/store/registry/visibility/zero-regression suites (§12) |

### Existing seams to touch (small, additive, all flag-gated)
- `lib/main.dart:383-395` — insert `const StudioOverlay()` into the builder Stack
  beside `ConnectionIndicator` (inert unless owner+flag). **One line.**
- `lib/screens/manager_dashboard_screen.dart` `_ManageTab` (~:2240–2440) — add a
  "🎨 סטודיו" accordion row → `StudioScreen.route()` + the edit-mode toggle,
  gated `kStudioFlag` (mirrors existing role-assign/catalog rows).
- `lib/state/feature_flags.dart` — register `kStudioFlagName` (no behavior change;
  enables no-rebuild owner staging like `kKbLiveMirrorFlag` :23).
- `lib/data/board_accounts_local.dart:102` — **reuse** `isOwnerEmail` (no edit);
  edit_mode imports it.
- `lib/theme/app_theme.dart:62-67` — add the `CfgTheme`-driven values to the
  `extensions:` list (additive; defaults preserve current look).
- `knowledge/GATE_REGISTRY.md` — claim gate **118** "studio ids ⊆ registry +
  OFF=identical" and add it to `.githooks/pre-commit` (the registry's own
  protocol, GATE_REGISTRY "פרוטוקול הוספת שער").
- `WIRING.md` — document the engine + wrappers (gate 24/40).
- **Pilot adoptions** (Phase B, ~10 call-sites): a few `Text(` in
  `manager_dashboard_screen.dart` (KPI titles) + the cart CTA.

**Nothing existing is rewritten or deleted** (gates 38/39/89/90) — every touch is
additive and reverts to current behavior with the flag off.

---

## 11. How it scales to 10K–100K ids

- **Sparse storage.** A `CfgNode` serialises only non-null axes; an id with no
  override **costs nothing** (absent from the map). The doc size tracks *edits
  made*, not *ids that exist*. 100K registry ids with 2K actual overrides ≈ a few
  hundred KB JSON — fine for prefs/Firestore (and Pillar-5 can shard the doc by
  `screen` if ever needed; the `ConfigLayer.global` map is already partitionable).
- **O(1) reads.** `resolvedNodeProvider` is a `Provider.family` → per-id cached;
  `mergeNode` is a handful of `Map` lookups (global, persona) — no scan over all
  ids. Only the *changed* ids' providers recompute on a publish (Riverpod
  fine-grained invalidation), so a publish doesn't rebuild the world.
- **Registry as data, lazily presented.** `kElementRegistry` is a `const List` (no
  runtime cost beyond memory). The Studio tree is **virtualised** (lazy
  `ExpansionTile`/`ListView.builder` by screen→area) so 100K rows never all build;
  search filters before building. Grouping keys (`screen`/`area`) are the index.
- **Versions bounded** (ring buffer N≤30 snapshots of the *sparse* published
  layer) → history stays small regardless of id count.
- **Per-persona without blow-up:** persona overrides are a second sparse map keyed
  by role (≤6 roles) — additive, not multiplicative.
- **Pillar-5 path:** Firestore doc(s) + a single realtime listener feeding
  `ConfigStore`; the merge stays client-side and O(edits). If the global doc ever
  exceeds the 1 MB Firestore doc cap, shard by `screen` collection — the
  `ConfigSink` abstraction absorbs this with no client logic change.

---

## 12. Gate / test strategy (fits the 100-gate pre-commit)

Per the repo's **source-scanning + unit** house style (`knowledge_protocol_test.dart`,
404 test files), all under `test/studio/`:

- **`config_merge_test.dart`** — pure-function table tests: default-only,
  global override, persona override beats global, draft beats published in preview,
  critical-id `hidden` ignored, unknown-key round-trip preserved.
- **`config_store_test.dart`** — editDraft/publish/discard/rollback transitions;
  publish prunes empties + pushes a version; rollback is itself versioned; JSON
  round-trips (the `catalog_settings` toJson/fromJson convention) — injects a fake
  `ConfigSink` (the `serverCallables`/`uidScoped` fake-gateway testability pattern,
  `backend.dart:64-65`).
- **`cfg_wrappers_test.dart`** — `CfgText` returns fallback when doc empty;
  applies override; `CfgVisible` hides only when published+not-editing; `CfgList`
  reorders by `order`; `EditHandle` is a no-op off edit-mode (widget tests).
- **`zero_regression_test.dart`** — with `kStudioFlag` OFF + empty doc:
  `resolvedNodeProvider(anyId)` == identity, `StudioOverlay` builds to
  `SizedBox`, `editModeProvider` cannot flip for a non-owner/role — **the proof in
  §14, codified.**
- **`registry_contract_test.dart`** (a new **gate, #118**, source-scan like
  `knowledge_protocol_test.dart`): every `CfgText('…')`/`CfgVisible('…')` literal id
  in `lib/` exists in `kElementRegistry`; ids are unique; (warn) registry ids lack a
  wrapper. Plugs into `.githooks/pre-commit`.
- **Safety tests** — publish-validator rejects hiding a critical id; style tokens
  resolve within `BsTokens`; theme override passes the existing contrast check
  (`a11y_contrast_theme_test`).
- **Gate compliance per commit:** 31 (analyze 0), 32 (test 0 regress), 33 (build
  web), 62/63/65/95 (RTL/numbers-LTR — the overlay + inspector audited), 64 (emoji
  from legacy), 94 (knowledge_protocol_test), 107/116 (visual_log on any UI
  change). No new pub dep (gate 60) — hand-rolled JSON, millis-id (no `uuid`).

---

## 13. Seams the OTHER pillars plug into (coordinate, don't design)

| Pillar | Seam I expose | They own |
|---|---|---|
| **2 — Domain builder** | `ConfigLayer.structure` sub-doc (same `ConfigDoc`, same `ConfigSink`) + `domainElementsProvider` concatenated into `elementRegistryProvider`; new trades emit `CfgNode`s + descriptors into the tree | category/variant/product/accessory/connection-rule schema + the wizard |
| **3 — Live analytics** | `elementRegistryProvider` (human labels for funnels) + the publish-event stream on `configSinkProvider` (annotate "what changed when") + element-id click instrumentation hook in `EditHandle`/`Cfg*` | event capture, real-time customer view, stuck-detection |
| **4 — AI co-editor + palette** | writes proposed `CfgNode` diffs into the **draft** layer (never published) via `ConfigStore.editDraft`; owns `cfgActionRegistryProvider` (action-catalog) + the behavior/component-palette panel mounted in inspector Pane B/§5.3 | the Claude prompt/grounding, the action kinds, component templates |
| **5 — Scale/backend/publish-push** | the `ConfigSink` interface (`save`/`watch`) — swap `LocalPrefsSink`→`FirestoreSink`; the publish-event → FCM topic push; Firestore rules `manager`-claim enforcement; doc sharding | Firestore schema, push fan-out, offline-merge, rules |

The **invariant for all four:** they read/write the *same* `ConfigDoc` through the
*same* `ConfigSink` and the *same* `editDraft/publish` API — so the data model,
draft/publish, registry, and Studio shell (this pillar) are the single substrate.

---

## 14. Zero-regression proof

The non-negotiable: **with `kStudioFlag` OFF (default), the app is byte-identical
to today** — the documented invariant of `backend.dart:12-127` applied to Studio.

1. **Read path collapses to identity.** Every `Cfg*` wrapper resolves a `CfgNode`;
   with an empty published doc + edit-mode-off, `mergeNode` returns the all-null
   identity node ⇒ `CfgText` renders `fallback` (the original literal), `CfgVisible`
   renders `child`, `CfgList` keeps declaration order, `CfgAction` calls the
   original handler. **Same widget tree, same Hebrew, same emoji.** (Unit-proven by
   `zero_regression_test.dart`.)
2. **Overlay is inert.** `StudioOverlay` (the one `main.dart` insertion) builds to
   `SizedBox.shrink()` unless `kStudioFlag && isOwnerEmail && manager` — the exact
   inert-overlay pattern of `ConnectionIndicator` (`main.dart:383-395`), which is
   already always-mounted and read-only off its gate.
3. **Edit-mode can't engage for anyone else.** `editModeProvider` refuses to flip
   without owner-email + manager-role + flag (`board_accounts_local.dart:102`,
   `board_auth.dart:24/288`). Every non-owner persona (קבלן/חנות/שליח/עובד) gets
   the controller in a permanently-off state ⇒ no `EditHandle` ever activates ⇒
   **zero behavioral change to other personas** (the pillar constraint).
4. **No existing code rewritten.** §10's touches are additive (one overlay line,
   one gated manager-tab row, an additive theme-extension entry, a reused
   `isOwnerEmail`). Gates 38/39/89/90 (no deletions) hold.
5. **Adoption commits are visually inert.** Because OFF=identical, a `Text→CfgText`
   batch produces an empty visual diff until the owner publishes an override —
   so visual_log/gate-116 stays clean and rollback of the whole engine is a
   pure `Cfg*→Text` revert.
6. **CI proof, every commit:** `zero_regression_test` + `registry_contract_test`
   (gate 118) + analyze 0 (31) + test green (32) + build web (33) +
   knowledge_protocol_test (94).

---

## 15. Phased plan (numbered, dependency-ordered)

**Phase A — Data model + store (no UI).** `1.` `CfgNode/CfgStyle/CfgAction` + JSON.
`2.` `ConfigDoc/ConfigLayer/ConfigVersion` + migrate. `3.` pure `mergeNode` +
exhaustive unit tests. `4.` `ConfigStore` + `ConfigSink`/`LocalPrefsSink` (clone
`catalog_settings`) + `editDraft/publish/discard/rollback`. `5.` `kStudioFlag` +
runtime flag-name. `6.` `resolvedNodeProvider` family. **Gate: analyze 0 + new unit
tests green + OFF byte-identical.**

**Phase B — Wrappers + edit-mode + pilot.** `7.` `EditHandle.maybe` + `editModeProvider`
(owner gate). `8.` `CfgText` (+`CfgVisible`,`CfgList`,`CfgBox`,`CfgAction`). `9.`
`StudioOverlay` inserted in `main.dart`. `10.` Adopt ~10 pilot ids (manager KPI
titles + cart CTA) + their registry rows. `11.` `zero_regression_test` +
`cfg_wrappers_test`. **Gate: full 100-gate; OFF=identical; owner can flip edit-mode
and change a pilot text live (draft).**

**Phase C — Studio shell + draft/publish/versioning.** `12.` `studio_screen` +
segmented panes. `13.` Tree pane from registry (virtualised) + persona selector.
`14.` Inspector (R9 inline, per-axis, live preview). `15.` Publish/discard/version
history + one-tap rollback. `16.` Wire the manager-tab entry + edit-mode toggle.
`17.` `config_store_test` (publish/rollback) + `registry_contract_test` (claim gate
118). **Gate: owner edits → draft → publish → all-users; rollback restores.**

**Phase D — Theme editor + find&replace + safety.** `18.` `CfgTheme` + `AppTheme`
extension + theme pane (live preview + contrast block). `19.` Global find-&-replace
→ draft. `20.` Critical-id set + publish-validator + reset-all. `21.` Safety tests
(critical can't hide; tokens bounded; contrast). **Gate: safety suite green;
a11y_contrast still passes.**

**Phase E — Scale + adoption + seams.** `22.` Registry auto-extract `dart` script +
codemod assist. `23.` Roll adoption across high-value screens, section-by-section
(each its own gate-clean commit + visual_log). `24.` Finalise + document the four
pillar seams (§13) so 2/3/4/5 can start against a frozen interface. `25.` `WIRING.md`
+ `GATE_REGISTRY.md` + `manager-dashboard-MAP.md` updated. **Gate: 10K-id virtualised
tree perf check; all gates; owner sign-off per the manager-plan rollout (default OFF
until approved, `MANAGER-BUILD-PLAN.md:5,17`).**

---

## 16. Key risks + mitigations

| Risk | Mitigation |
|---|---|
| **Adoption scale** (2,361 `Text`) | Opt-in wrappers, OFF=identical, registry-first long tail, codemod assist, per-section commits — never big-bang (§9). |
| **Id churn orphaning overrides** | Append-only dotted ids + central registry + gate-118 id⊆registry test; renames go through an explicit `migrate` map, never silent. |
| **Owner footgun** (hides nav / breaks app) | Critical-id lock (model+UI+publish-validator), token-bounded style, contrast block, 3-scope reset, forward-only undoable rollback (§8). |
| **Perf at 100K ids** | Sparse storage (cost ∝ edits), `Provider.family` O(1) reads, virtualised tree, bounded versions (§11). |
| **Hidden regression to other personas** | Hard owner+manager+flag gate on edit-mode; non-owner controller permanently inert; `zero_regression_test` per commit (§14). |
| **Behavior editing unsafe** | v1 ships only `noop`+whitelisted-`navigate`; arbitrary kinds deferred to Pillar-4's reviewed action-catalog; no external URLs (gate 51). |
| **Backend coupling creep** | Single `ConfigSink` seam; local now, Firestore later, **zero** wrapper/Studio change at swap (mirrors `backend.dart` `_local↔_firebase`). |
| **Gate friction** (404 tests, strict lint) | Hand-rolled JSON (no new dep), source-scan tests in the house style, additive-only edits, claim exactly one new gate (118). |

---

### One-paragraph essence
A single layered, id-keyed `ConfigDoc` (content·visibility·order·design·behavior ×
per-persona, draft vs published, bounded versions) — a direct generalisation of the
repo's existing `hidden_catalog_sections` + `home_content_order` overrides, persisted
via the proven `catalog_settings` notifier, gated like `backend.dart` (default
**OFF = byte-identical**), keyed off `isOwnerEmail`+manager. Thin opt-in `Cfg*`
wrappers (fallback = today's literal) let existing widgets adopt config + WYSIWYG
edit-handles incrementally; a compile-time `ElementRegistry` makes the Studio list
"everything" before full adoption; the Studio shell (tree·inspector·theme·find&replace·
history·rollback) + an app-wide owner-only edit-mode overlay drive it; and a single
`ConfigSink` seam keeps the whole thing local-now / Firestore-when-on so Pillars
2–5 plug into one substrate.

---

## 🔧 תיקוני Red-Team R1 (מחייב — מחליף סעיפים סותרים)

> מקור-הסמכות: `studio-plan/RED-TEAM-R1.md` (2026-06-23, 9 עדשות). הסעיף הזה
> **גובר** על כל ניסוח קודם במסמך שסותר אותו. כל פריט אומר: **מה משתנה · איזה §
> נדרס · איזה שלב מושפע**. עקרון-על: התשתית של P1 (רישום-מורחב + מודל-פרסונה-יחיד
> + draft-op-API) **מוקפאת ב-Phase-0 לפני הקפאת-ה-seams (לפני שלב-30)**; כל
> over-claim על "byte-identical" יורד; חמישה שלבים-חסרים שחלים על P1 נוספים.

### R1-A1 · רישום מורחב — `ElementDescriptor` הופך לחוזה-האכיפה (נדרס §4 · §2.4-ConfigDoc.schemaVersion · שלבים A1–A2, gate-118)
**הבעיה (A.1):** P4 מקרקע `validateSafe` מול `editableProps`/`allowedActions`/
`allowedValues`/`kImmutable`/`kRoleFloor`/`ElementKind`, אבל §4 מצהיר רק
`axes`/`critical`/`personas` → כל ולידציה **ירוקה-ריקה (vacuous)**: אין מול מה
לאמת, והשרת (P5) לא יכול לאכוף role-floor/action-legality.

**מה משתנה — `ElementDescriptor` החדש (מחליף את הבלוק ב-§4 כולו):**
```dart
class ElementDescriptor {
  final String id;
  final String screen;
  final String area;
  final String labelHe;
  final ElementKind kind;          // ← חדש: button|text|list|image|container|nav|input…
  final Set<CfgAxis> axes;         // (נשאר)
  final Set<String> editableProps; // ← חדש: אילו props ניתנים-לעריכה ('text','colorToken','order'…)
  final Set<String> allowedActions;// ← חדש: אילו kinds מותרים על האלמנט הזה ('navigate','noop'…)
  final List<String> Function(String prop)? allowedValues; // ← חדש: סגירת-קבוצה לכל prop (closed-set)
  final bool kImmutable;           // ← חדש: אסור-לעריכה לחלוטין (גובר על axes)
  final String? kRoleFloor;        // ← חדש: רצפת-תפקיד מינ' לעריכה (roleProvider-string; null=כולם)
  final bool critical;             // (נשאר) נראות-נעולה
  final Set<String>? personas;     // ⚠️ סוג השתנה ל-Set<String>? — ראה R1-A2 (לא Set<BoardRole>)
}
```
**fail-closed כשחסר:** אם descriptor חסר `editableProps`/`allowedActions`/`kind`
— האלמנט נחשב **לא-ניתן-לעריכה** (deny), לא "פתוח כברירת-מחדל". `validateSafe`
דוחה כל op על prop שלא ב-`editableProps`, kind שלא ב-`allowedActions`, וערך שלא
ב-`allowedValues(prop)`. `kImmutable==true` דוחה כל op. `kRoleFloor` נאכף גם
client (advisory) וגם server (מקור-אמת — תיאום עם P5/§8.6).
**Phase-0 freeze:** החוזה הזה (כל ששת השדות) נכתב ונבדק **לפני שלב-30** (הקפאת-
ה-seam של P4), כי P4/P2/P3 כולם מקרקעים מולו. שלב A1 (`ElementDescriptor`+JSON)
ושלב A2 (`ConfigDoc.schemaVersion` + `migrate`) מורחבים בהתאם; gate-118 מאמת לא
רק `id ⊆ registry` אלא גם **שלמות-descriptor** (כל row מצהיר את ששת השדות, אחרת
fail). מבחן חדש ב-`registry_contract_test.dart` (§12).

### R1-A2 · מודל-פרסונה יחיד — `roleProvider` (String?) הוא מקור-האמת (נדרס §2.6 · §4.personas · §5.2 · §13-Pillar3/4 · שלבים A6, C13, C14)
**הבעיה (A.2):** שלושה מודלים סותרים — חי=`roleProvider` (String?, null=קבלן) ·
§2.6/§4 משתמשים ב-`BoardRole` enum (**אין בו קבלן** — זה role-הלוח, לא פרסונת-
לקוח) · P4=`BsRole`. עריכה פר-קבלן לא-ניתנת-למיפתוח → "נשמר, כלום לא קורה".

**מה משתנה:**
1. **מקור-אמת יחיד = `roleProvider` (`String?`, `null` = קבלן).** כל שכבת-פרסונה,
   כל מפתח ב-`ConfigLayer.persona`, כל `kRoleFloor`, וכל persona-selector — לפי
   המחרוזת הזו. **מחליף את §2.6** שבו `viewerRoleProvider` החזיר `BoardRole`:
   ```dart
   // §2.6 read-path — מתוקן:
   final resolvedNodeProvider = Provider.family<CfgNode, String>((ref, id) {
     final doc  = ref.watch(configStoreProvider);
     final role = ref.watch(roleProvider);    // String? — null=קבלן (מקור-אמת יחיד)
     final live = ref.watch(editModeProvider).previewDraft;
     return mergeNode(id, doc, role, includeDraft: live);
   });
   ```
2. **`ConfigLayer.persona` מ-key לפי String** (לא enum): `Map<String, Map<String,
   CfgNode>> persona` כאשר ה-key = ערך-`roleProvider` ('contractor'/'supplier'/
   'courier'/'worker'/'manager'…; קבלן יכול להיות מפתח מפורש 'contractor' או
   ה-fallback של `null`). **מחליף את §2.4 `ConfigLayer.persona` ואת §1 ("BoardRole"
   ב-merge-diagram).**
3. **`ElementDescriptor.personas` הופך ל-`Set<String>?`** (R1-A1) — מסונכרן.
4. **adapter יחיד ממפה enums→string:** `BoardRole`/`BsRole` **לעולם לא משמשים
   כ-key-פרסונה**; הם נכנסים דרך `roleKeyOf(BoardRole)` / `roleKeyOf(BsRole)`
   ב-`config_merge.dart` (או קובץ-adapter ייעודי). **מחליף כל מקום ש-§5.2/§13
   הניחו `BoardRole` כמפתח.**
**שלבים:** A6 (read-path) משתנה ל-`roleProvider`; C13 (persona-selector) מציג את
חמש המחרוזות (כולל קבלן-כ-null מפורש); C14 (inspector per-persona) כותב
`persona[roleKey][id]`. מבחן ב-`config_merge_test.dart`: persona-string מנצח
global, ו-`null`-role (קבלן) פותר נכון.

### R1-A3 · draft-op-API — `applyOps` + undo-stack ראשון-במעלה (נדרס §2.5 · §7 · §13-Pillar4 · שלבים A4, C15)
**הבעיה (A.3):** P4 מצפה `draft.apply(List<ConfigOp>)` + `revertLast()`/redo; §2.5
חושף רק `editDraft(id, CfgNode Fn)` — לא תואם, ואין undo-stack בכלל.

**מה משתנה — `ConfigStore` מרחיב את ה-API (מחליף את חתימת §2.5):**
```dart
// מודל-op חדש (lib/state/studio/config_op.dart):
sealed class ConfigOp {                  // diff אטומי על הטיוטה
  // SetProp(id, prop, value?) | ClearNode(id) | Reorder(parentId, ids) | SetPersona(id, roleKey, op)
}
class ConfigStore extends StateNotifier<ConfigDoc> {
  void applyOps(List<ConfigOp> ops);     // ← API ציבורי: P4 + find&replace + tree כותבים דרכו
  void revertLast();                     // ← undo (pop מ-undo-stack)
  void redo();                           // ← redo (re-push)
  CfgNode _editDraft(String id, CfgNode Function(CfgNode) f, {String? persona}); // ← primitive פנימי בלבד
}
```
- `applyOps` הוא **השער היחיד** לכתיבה-לטיוטה: כל op נדחף ל-`undoStack`, מאומת
  מול ה-descriptor (R1-A1) **לפני** החלה (fail-closed), ו-`_editDraft` יורד
  להיות מימוש-פנימי שלא נחשף ל-P4. **מחליף את §2.5 + §13-Pillar4** ("writes via
  `ConfigStore.editDraft`" → "writes via `ConfigStore.applyOps`").
- **undo-stack ראשון-במעלה** (גם תיאום עם R1-E-undo למטה): bounded (≥50 ops),
  נמחק ב-publish/discard, לא נשמר ל-prefs (in-session). חושף `canUndo`/`canRedo`.
**שלבים:** A4 (`ConfigStore`) מוסיף `applyOps`/`revertLast`/`redo` + `ConfigOp`;
C15 (publish/discard) מנקה את ה-stack. `config_store_test.dart` מאמת
applyOps→undo→redo round-trip + דחיית-op לא-חוקי.

### R1-B7 · `CfgText` עוטפן נאמן — מעביר את כל פרמטרי-ה-`Text` (נדרס §3.1 · שלב B8)
**הבעיה (B.7):** §3.1 בונה `Text(...)` עם `style`+`semanticsLabel` בלבד ומפיל
`maxLines`/`overflow`/`textAlign`/`softWrap`/`textDirection`/`textScaler`/
`maxLines` → רגרסיות-חיתוך/יישור/אליפסיס **גם כשהמנוע OFF** (כי ה-call-site
שהמיר `Text('x', maxLines:2, overflow:ellipsis)` ל-`CfgText` מאבד את הפרמטרים).

**מה משתנה — `CfgText` חייב לקבל ולהעביר את כל פרמטרי-ה-`Text` (מחליף §3.1):**
```dart
class CfgText extends ConsumerWidget {
  const CfgText(this.id, this.fallback, {
    this.style, this.semanticsLabel,
    this.maxLines, this.overflow, this.textAlign, this.softWrap,
    this.textDirection, this.textScaler, this.strutStyle, this.locale,
    this.textWidthBasis, this.selectionColor, super.key,
  });
  // …build: Text(effText, style: eff, semanticsLabel: …,
  //   maxLines: maxLines, overflow: overflow, textAlign: textAlign,
  //   softWrap: softWrap, textDirection: textDirection, textScaler: textScaler, …)
}
```
- **שימור composition:** היכן שהמקור היה `Text.rich`/`RichText`/`Text` עם
  `TextSpan` — `CfgText` **לא חל** (ראה R1-B6: out-of-v1); ההמרה המכנית מותרת
  רק על `Text('ליטרל', …)` פשוט, וכל פרמטר קיים מועתק 1:1.
- **gate חדש ב-`cfg_wrappers_test.dart`:** snapshot שמוודא `CfgText` עם
  `maxLines:1, overflow:ellipsis` מתנהג זהה ל-`Text` המקורי (OFF). **מחליף את
  טענת-§14.1** "same widget tree" — כעת מאומת פר-פרמטר, לא רק על-טקסט.
**שלב:** B8 (`CfgText`) מורחב; ה-codemod של §9.5/Phase-E חייב להעתיק את פרמטרי-
ה-`Text` הקיימים אל ה-`CfgText` המוצע (לא רק את הליטרל).

### R1-B6 · היקף-תוכן כן — ציר-תוכן-v1 = ~532 אתרי-`Text('ליטרל')` בלבד (נדרס §0-adoption-cost · §9 · §3.1 · שלבים B10, E22–E23)
**הבעיה (B.6):** §0 מצהיר "2,361 `Text(` call-sites" כאילו כולם ברי-המרה. בפועל:
~532 בלבד הם `Text('ליטרל-עברי')`; **721 הם `const Text(...)`** (המרה ל-`CfgText`
הורסת את ה-`const` → rebuilds מיותרים); השאר **מחושב/interpolated/`Text.rich`**
(אין fallback-ליטרל יציב, gate-61/64 לא תקף).

**מה משתנה:**
1. **ציר-תוכן-v1 מוגדר מחדש = ~532 הליטרלים הסטטיים בלבד.** **מחליף את §0
   ("2,361") ואת §9** ("the 2,361-`Text` problem" → "the ~532-literal content
   axis; 2,361 הוא ספירת-`Text(` גסה, לא היקף-ההמרה").
2. **const-loss מתועד + נמדד:** כל המרה של `const Text` → `CfgText` (לא-const)
   נרשמת, וב-Phase-E נמדד **מדד-ביצועים** (rebuild-count/frame-time על מסך-צפוף,
   ראה R1-E-perf) לפני/אחרי. אם מסך חוצה-סף — האלמנט נשאר `const Text` ולא מאומץ
   ב-v1. **מחליף את §9.6** ("adoption commits are visually inert" → "...וגם
   perf-neutral; const-loss נמדד פר-מסך-צפוף").
3. **מחושב/interpolated/`Text.rich` = templating נפרד, מחוץ-ל-v1.** `CfgText`
   לא חל עליהם (תיאום R1-B7). מנגנון-templating (placeholders ב-string מאומת)
   נדחה ל-vNext ומוצהר מפורשות כ-out-of-scope. **מחליף כל רמיזה ב-§3.1/§9 שכל
   `Text` ניתן-להמרה.**
**שלבים:** B10 (pilot) נשאר ~10 ליטרלים; E22 (auto-extract) סורק רק
`Text\('<ליטרל>'` (לא const, לא interpolation); E23 (roll adoption) מוגבל ל-~532
+ מדידת const-loss פר-section.

### R1-B4 · "byte-identical" יורד → "answer-equivalent מול fixtures + golden-render" (נדרס §0 · §1 · §6 · §10 · §11 · §12 · §14 · §16 · כל-המסמך)
**הבעיה (B.4):** "byte-identical" מופיע לאורך-המסמך כערובת-אפס-רגרסיה. אבל
מבנה-Widget אינו "בייטים", ו-golden/visual-diff הוא ההוכחה האמיתית. הטענה
over-claim ולא-מדידה.

**מה משתנה — מחק "byte-identical" מכל P1, החלף ב-"answer-equivalent":**
1. **ניסוח-תקני חדש (מחליף בכל מופע — §0/§1/§6/§10/§11/§12/§14/§16/essence):**
   > "עם `kStudioFlag` OFF + doc-ריק, האפליקציה **answer-equivalent** למצב-היום:
   > כל `Cfg*` מחזיר את ה-fallback, מאומת מול **fixtures** (אותו טקסט/נראות/סדר)
   > **ו-golden-render** (אותו פיקסל על מסכי-הפיילוט). לא 'byte-identical'."
2. **§14 (Zero-regression proof) משוכתב:** סעיף 14.1 ("Read path collapses to
   identity") + 14.5 ("Adoption commits are visually inert") מנוסחים מחדש כ-
   **golden-equivalent** (gate-116 visual_log = ההוכחה), לא "same bytes". הוכחת-ה-
   CI (14.6) מוסיפה golden-render לפיילוט.
3. **§12 מוסיף `golden_off_equivalence_test.dart`** (או מרחיב `zero_regression_
   test.dart`): מרנדר מסך-פיילוט עם flag-OFF ומשווה golden מול ה-baseline-לפני-
   המנוע. **מחליף את ההסתמכות על §14 הטקסטואלי.**
**שלבים:** A6/B11/C17 — כל gate-אפס-רגרסיה מתנסח answer-equivalent; Phase-B מוסיף
golden לפיילוט; Phase-E מרחיב golden ל-sections המאומצים.

### R1-E · שלבים-חסרים שחלים על P1 (חמישה — נוספים ל-§15 ול-§16)
פערי-השלמות מהעדשה-ה-8 שנופלים בתחום-P1. כל אחד הוא **שלב חדש** (ממוספר בהמשך
ל-Phase-D/E) עם gate משלו.

**R1-E-undo · undo first-class גם ל-tree/find-replace/theme (נדרס §5.4 · §5.5 · §7 · שלב חדש D-undo)**
היום undo קיים רק כ-rollback פר-publish (§7) ו-`resetDraftNode` פר-אלמנט (§2.5);
**אין undo לפעולות-טיוטה רב-אלמנטיות** (find&replace מחליף 80 hits — אין "בטל
הכל"; theme-edit אין "חזור"; reorder בעץ אין "בטל"). **מחליף §5.4/§5.5/§7**:
כל פעולת-Studio (tree-reorder · find&replace-batch · theme-edit) עוברת דרך
`applyOps` (R1-A3) → נכנסת ל-undo-stack → כפתור "בטל"/"חזור" גלובלי ב-top-bar
(§5.1). שלב D-undo: חיווט ה-undo-stack לכל שלוש הקונכיות + מבחן
`undo_stack_test.dart`.

**R1-E-a11y · a11y-gate לקונכיית-הסטודיו עצמה (panes/inspector/chat) (נדרס §5 · §12 · שלב חדש D-a11y)**
§5.4 בודק contrast רק על **פלט-המשתמש** (theme-editor); הקונכייה של הסטודיו
(tree/inspector/find&replace/theme-panes, וה-chat-panel של P4 המורכב ב-Pane-B)
**עצמה לא נבדקת** ל-a11y (טאץ'-טארגטים, contrast, semantics, focus-order, RTL).
שלב D-a11y חדש: `studio_shell_a11y_test.dart` מריץ את אותה לוגיקת-contrast
(`a11y_contrast_theme_test`) + בדיקת-semantics על מסכי-הסטודיו; gate פר-commit
על קונכיית-הסטודיו. **מרחיב §12** (מעבר ל-overlay/inspector שכבר נבדקים ל-RTL).

**R1-E-onboarding · onboarding/first-run לבעלים-הלא-מתכנת (נדרס §5 · §6 · שלב חדש D-onboarding)**
המסמך מניח בעלים שמבין "draft/publish/persona/critical-id"; אין מסך-first-run.
שלב D-onboarding חדש: בכניסה-ראשונה ל-Studio (flag-state נשמר ב-prefs כמו
`feature_flags`) — סבב-הסבר קצר (3–4 צעדים, RTL, עברית-verbatim) "זו טיוטה ·
ככה מפרסמים · ככה מבטלים · מה נעול". מוצג פעם-אחת, ניתן-לפתיחה-מחדש מ-top-bar.
**מרחיב §5/§6** (entry-point של edit-mode).

**R1-E-perf · edit-mode perf-gate על מסך-צפוף (catalog/manager) (נדרס §0-mega-screens · §11 · §16 · שלב חדש E-perf)**
§11 טוען "O(1) reads" אבל לא מודד edit-mode על המסכים-הצפופים (`catalog_screen.
dart` ~330KB, `manager_dashboard_screen.dart` 136KB) כש-`EditHandle` עוטף מאות
אלמנטים + const-loss (R1-B6). שלב E-perf חדש: מדידת frame-time/jank עם edit-mode
ON על catalog+manager (סף מוגדר), gate שחוסם אם חוצה-סף. **מחליף את §11
("O(1)/virtualised" כטענה-בלבד) ואת שורת-§16 "Perf at 100K ids"** — כעת מדוד,
לא מוצהר. תוצאת-המדידה מזינה את החלטת-ה-const-loss של R1-B6.

**R1-E-export · export/import JSON של הקונפיג (גיבוי) (נדרס §7 · §2.5 · §10 · שלב חדש E-export)**
היום כל-העסק ב-prefs/Firestore + ring-30 בלבד (§7) — **אין גיבוי חיצוני**; אובדן-
מכשיר/מחיקת-prefs = אובדן-קונפיג. שלב E-export חדש (תיאום עם R1-E15 הכללי):
`ConfigStore.exportJson()` → קובץ (כל `ConfigDoc.toJson` כולל history) +
`importJson(String)` → restore-from-file (עם validate מול schemaVersion+migrate,
fail-closed על doc פגום). UI ב-Pane-D (§5.5, ליד version-history). **מרחיב §7
ו-§2.5**; `config_store_test.dart` מוסיף export→import round-trip. (Pillar-5
מוסיף אחר-כך גיבוי-שרת; זה הגיבוי-הלוקאלי המיידי.)

### סיכום-דלתות לטבלת-השלבים (§15) ולסיכונים (§16)
- **§15 Phase-0 (חדש, לפני Phase-A-freeze):** הקפאת-חוזה-`ElementDescriptor`
  המורחב (R1-A1) + `roleProvider`-כמקור-יחיד (R1-A2) + `applyOps`-API (R1-A3)
  **לפני שלב-30**.
- **§15 שלבים-מורחבים:** A1/A2/A4/A6 (descriptor+op+role), B8/B10 (CfgText נאמן +
  היקף-532), C13–C15/C17 (persona-string + applyOps + golden-equivalence).
- **§15 שלבים-חדשים:** D-undo · D-a11y · D-onboarding · E-perf · E-export.
- **§16 סיכונים-מתוקנים:** "byte-identical" → "answer-equivalent + golden" ·
  "O(1)/100K" → "perf-gate מדוד על catalog/manager" · נוסף סיכון "אובדן-קונפיג →
  export/import" ו-"validateSafe ריק → descriptor fail-closed".
- **gate-118 מורחב:** `id ⊆ registry` **+ שלמות-descriptor (ששת השדות)** +
  golden-OFF-equivalence; 119=AI-grounded (ע4), 120=analytics-PII (ע3) — כבר
  שמורים ב-`GATE_REGISTRY.md`.
