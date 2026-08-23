// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 4 · Step 73 — the static COMPONENT PALETTE: the
// closed set of ADDABLE components (button / textBlock / badge / divider /
// infoCard / linkRow), each with a TYPED required-prop schema. This is the
// component twin of the step-72 action catalog — where that file is the closed
// "what a button DOES" set, this is the closed "what you may ADD, and with which
// props" set.
//
// GOAL (step 73): a CLOSED palette the AI co-editor (and the manual builder,
// step 82) grounds an `AddComponent` op against — the model may only NAME a type
// from this set; Dart deterministically checks the target container is legal and
// every required prop is supplied, else the op is DROPPED (no half-built
// AddComponent, §3). The RENDERING of a placed component stays Pillar-1's wrapper
// job (§2/§8) — this file constructs no widgets, it is pure schema + pure
// validators (the anti-hallucination spine: closed set → verified add).
//
// ADAPTATION — "auth-kind" vs the REAL `ElementKind` (the plan §4 predates the
// frozen enum, exactly as step 72 adapted its stale "11 typed-arg" to the live
// 17). The plan §4 says "auth-kind must NOT be in any template's allowedContainers".
// But Pillar-1's FROZEN `ElementKind` (element_registry.dart:26) is CLOSED to
// `{ text, container, list, action, theme }` — there is NO `auth` value. Auth /
// immutable surfaces are flagged by `ElementDescriptor.kImmutable` / `kRoleFloor`
// (auth.login.cta · auth.logout · nav.bottombar · manager.entry · studio.exit are
// all `kImmutable:true`), NOT by a kind. The closest "control" kind is
// `ElementKind.action` (an element that PERFORMS an action). So the plan's clause
// is honoured, reconciled to the real enum, as: a component may be dropped ONLY
// into a CONTENT container — `{ container, list }` — and NEVER onto `action`
// (a control), `text` (a leaf label) or `theme` (a styling surface). No template
// lists `action` (or any non-content kind) in [allowedContainers]; the palette
// test asserts this absence mechanically (the §4 "button into auth" guard,
// reconciled). `validateSafe` (step 77) is the SECOND gate — it additionally
// refuses any op targeting a `kImmutable` id, so even a content-KIND immutable
// element (`nav.bottombar` is `container`) is still protected there. This file
// (like the matcher) grounds; authorization is `validateSafe`'s job.
//
// TYPED SCHEMAS (§1 · §5): each [ComponentTemplate] carries the [requiredProps]
// that MUST be supplied for a well-formed component — button/linkRow need
// `label`+`actionId`, textBlock/badge need `text`, infoCard needs `title`+`body`,
// divider needs none. [validateAddComponent] DROPS an op missing any required prop
// (§4/§5) — the anti-hallucination spine applied to component-add, exactly as step
// 75 drops an op with an invented field.
//
// §6 injection-lever safety: free-text props (`label`/`title` single-line ·
// `text`/`body` multi-line) run through `promptSafeText` (prompt_sanitize.dart) —
// a single-line label is COLLAPSED (newlines → space) + hard-capped, a multi-line
// body is length-capped in place — so an owner-authored label that later echoes
// into an NL edit prompt cannot smuggle a newline-injection payload. The verdict
// returns the DEFANGED props for the caller to store.
//
// §9 attached-action grounding: only `button`/`linkRow` are `optionalAction:true`
// (they SUPPORT an attached action). Any attached action id is grounded against
// the step-72 catalog closed set via `matchCatalogActionId` — a new component
// CANNOT receive an action illegal for its context; a divider / textBlock that
// carries an action id at all is rejected. (Reconciliation: the plan named
// `actionIdsFor(container)`, but the frozen seed registry populates NO
// `allowedActions`, so the POPULATED closed set to ground against is the step-72
// catalog — the SAME set the manual builder offers via `catalogActionIdsFor`.)
//
// §10 flood ceiling: `divider` carries [ComponentTemplate.maxPerContainer] so a
// broadcast can't carpet a container with separators; the verdict rejects an add
// that would exceed it.
//
// REUSE (step 71): grounding a model-emitted component-type STRING reuses the
// FROZEN `matchComponentType` (exact → longest-contained → null) over a
// [FakeRegistryView] seeded with the closed type-name set — the SAME single
// matching path as the registry / the action catalog, no second algorithm.
//
// DORMANT: pure static data + pure functions — renders nothing (no widgets, no
// `build`), no gateway, no provider, Firebase-free. Nothing in `lib/` imports it
// yet ⇒ tree-shaken out ⇒ byte-identical under every flag (the wrapper that
// RENDERS a placed component is Pillar-1's job, not this file's — DoD §8).
// ─────────────────────────────────────────────────────────────────────────────

import '../../state/studio/element_registry.dart' show ElementKind;
import '../prompt_sanitize.dart' show promptSafeText;
import 'action_catalog.dart' show matchCatalogActionId;
import 'registry_view.dart'
    show FakeRegistryView, RegistryView, matchComponentType;

/// The CLOSED set of component types that may be ADDED (§1). Extend DELIBERATELY —
/// the golden-list test forces an explicit edit on any add/remove (a gate against
/// silent palette growth, mirroring the step-72 action-catalog golden).
enum ComponentType {
  /// A tappable button — carries a `label` + a MANDATORY attached `actionId` (§9).
  button,

  /// A read-only block of body text — carries `text`.
  textBlock,

  /// A small status / label chip — carries `text`.
  badge,

  /// A horizontal separator — carries NO props; capped per container (§10).
  divider,

  /// A titled information card — carries `title` + `body`.
  infoCard,

  /// A tappable row that links somewhere — carries a `label` + an `actionId` (§9).
  linkRow,
}

/// One palette entry: a closed [type] the model may NAME, its Hebrew human [he]
/// label (so step-79 preview / step-82 builder need NO separate translation table),
/// the CONTENT-container kinds it may be dropped INTO ([allowedContainers], §4/§5),
/// the [requiredProps] that MUST be supplied for a well-formed component (§5), the
/// recognised-but-optional [optionalProps] the Pillar-1 wrapper MAY honour, whether
/// it supports an [optionalAction] (§9), and an optional [maxPerContainer] flood
/// ceiling (§10). Pure data — no widget.
class ComponentTemplate {
  const ComponentTemplate({
    required this.type,
    required this.he,
    required this.allowedContainers,
    required this.requiredProps,
    this.optionalProps,
    this.optionalAction = false,
    this.maxPerContainer,
  });

  /// The CLOSED component type — the only value the model may emit for the TYPE of
  /// an `AddComponent` (grounded via [matchComponentTypeName]).
  final ComponentType type;

  /// The Hebrew label shown beside the type in preview / the manual builder.
  final String he;

  /// The CONTENT-container kinds this component may be dropped INTO (§4/§5). Only
  /// `{ container, list }` ever appear — NEVER `action` (a control), `text` (a leaf)
  /// or `theme` (a styling surface); the palette test pins this absence (the
  /// reconciled "no component into an auth/control kind" guard, §4).
  final Set<ElementKind> allowedContainers;

  /// The typed props that MUST be supplied for a well-formed component (§5). A
  /// missing one DROPS the `AddComponent` op ([validateAddComponent]) — no
  /// half-built component. The special key `'actionId'` means an attached action is
  /// MANDATORY (satisfied by [AddComponentRequest.actionId], not the props map).
  final List<String> requiredProps;

  /// Recognised-but-OPTIONAL prop keys the Pillar-1 wrapper MAY honour (e.g. a
  /// `style` token) — NOT enforced by [validateAddComponent]; disjoint from
  /// [requiredProps]. `null` when the component takes no optional props.
  final List<String>? optionalProps;

  /// True when this template SUPPORTS an attached action id (`button`/`linkRow`
  /// only, §9). When true, an attached action is grounded against the step-72
  /// catalog closed set; when false, carrying an action id at all is REJECTED.
  final bool optionalAction;

  /// The max number of THIS component allowed in ONE container (§10) — a flood
  /// ceiling against a broadcast carpeting a container (e.g. `divider`). `null`
  /// ⇒ unbounded.
  final int? maxPerContainer;
}

/// The CLOSED component palette — the 6 templates of §1. Extend DELIBERATELY (the
/// golden-list test forces an explicit edit here on any add/remove, gating silent
/// palette growth — the same discipline as the step-72 action-catalog golden).
///
/// Every `allowedContainers` is `{ container, list }` (the only CONTENT-container
/// kinds, §4 reconciliation); `optionalAction:true` is set ONLY on the two action-
/// bearing types; `divider` carries the §10 flood ceiling.
const List<ComponentTemplate> kComponentPalette = <ComponentTemplate>[
  ComponentTemplate(
    type: ComponentType.button,
    he: 'כפתור',
    allowedContainers: {ElementKind.container, ElementKind.list},
    requiredProps: ['label', 'actionId'],
    optionalProps: ['style'],
    optionalAction: true,
  ),
  ComponentTemplate(
    type: ComponentType.textBlock,
    he: 'בלוק טקסט',
    allowedContainers: {ElementKind.container, ElementKind.list},
    requiredProps: ['text'],
    optionalProps: ['style'],
  ),
  ComponentTemplate(
    type: ComponentType.badge,
    he: 'תג',
    allowedContainers: {ElementKind.container, ElementKind.list},
    requiredProps: ['text'],
    optionalProps: ['tone'],
  ),
  ComponentTemplate(
    type: ComponentType.divider,
    he: 'קו מפריד',
    allowedContainers: {ElementKind.container, ElementKind.list},
    requiredProps: [],
    maxPerContainer: 4,
  ),
  ComponentTemplate(
    type: ComponentType.infoCard,
    he: 'כרטיס מידע',
    allowedContainers: {ElementKind.container, ElementKind.list},
    requiredProps: ['title', 'body'],
    optionalProps: ['icon'],
  ),
  ComponentTemplate(
    type: ComponentType.linkRow,
    he: 'שורת קישור',
    allowedContainers: {ElementKind.container, ElementKind.list},
    requiredProps: ['label', 'actionId'],
    optionalProps: ['icon'],
    optionalAction: true,
  ),
];

/// The ONLY container kinds a component may be dropped into (§4/§5, reconciled to
/// the frozen `ElementKind`). `action` / `text` / `theme` are DELIBERATELY excluded
/// (control / leaf / styling surface); every template's
/// [ComponentTemplate.allowedContainers] is a subset of this — asserted by the
/// palette test (the §4 "no component into an auth/control kind" guard).
const Set<ElementKind> kContentContainerKinds = <ElementKind>{
  ElementKind.container,
  ElementKind.list,
};

/// §6 — SINGLE-LINE free-text prop keys (a `label`/`title` has no line structure):
/// COLLAPSED (newlines → space) + hard-capped via `promptSafeText(collapseWhitespace:
/// true)` — the injection-lever defense for values that may echo into a prompt.
const Set<String> kLabelProps = <String>{'label', 'title'};

/// §6 — MULTI-LINE free-text prop keys (a `text`/`body` legitimately spans lines):
/// length-capped IN PLACE via `promptSafeText(collapseWhitespace: false)`, so the
/// paragraph structure survives while an over-long payload is still bounded.
const Set<String> kBodyProps = <String>{'text', 'body'};

/// Every component type NAME in the palette (the closed set the model is confined
/// to, mirroring `actionCatalogIds()`). Seeds [matchComponentTypeName].
Set<String> componentTypeNames() =>
    {for (final t in kComponentPalette) t.type.name};

/// A closed [RegistryView] over the palette type names — the vehicle that lets the
/// component-type grounding REUSE the frozen step-71 [matchComponentType] (exact →
/// longest-contained → null) instead of forking a second matching algorithm, the
/// SAME reuse the action catalog does for its action ids.
final RegistryView _paletteTypeView =
    FakeRegistryView.of(componentTypes: componentTypeNames());

/// The template for [type], or `null` if the palette somehow omits it (fail-closed;
/// a golden test asserts every [ComponentType] has exactly one template). Exact
/// lookup.
ComponentTemplate? templateFor(ComponentType type) {
  for (final t in kComponentPalette) {
    if (t.type == type) return t;
  }
  return null;
}

/// The template whose type NAME is [name] (exact), or `null` when [name] is not a
/// palette type (fail-closed — an invented / blank type resolves to NO template).
ComponentTemplate? templateForName(String name) {
  final n = name.trim();
  if (n.isEmpty) return null;
  for (final t in kComponentPalette) {
    if (t.type.name == n) return t;
  }
  return null;
}

/// The Hebrew label for [type] (step-79 preview / step-82 builder), or `null` when
/// the palette omits it. Sugar over [templateFor].
String? componentHe(ComponentType type) => templateFor(type)?.he;

/// Ground a model-emitted string to a REAL palette type NAME, or `null` (degrade —
/// the caller drops the `AddComponent`). Reuses the frozen step-71 matcher over the
/// closed type-name set: exact → longest-contained → null; a blank / invented type
/// fails-closed to `null`. NEVER throws, NEVER invents a type.
String? matchComponentTypeName(String reply) =>
    matchComponentType(_paletteTypeView, reply);

/// §4 — true only when a component of [type] may be dropped INTO a container of
/// kind [container] (`container ∈ allowedContainers`). Fail-closed for an unknown
/// type. Pure.
bool canPlace(ComponentType type, ElementKind container) {
  final t = templateFor(type);
  return t != null && t.allowedContainers.contains(container);
}

/// §6 — defang ONE prop value: collapse+cap a single-line label, length-cap a
/// multi-line body, trim anything else (ids / tokens). Pure.
String _safeProp(String key, String value) {
  if (kLabelProps.contains(key)) {
    return promptSafeText(value, maxLen: 200, collapseWhitespace: true);
  }
  if (kBodyProps.contains(key)) {
    // Length-cap IN PLACE (promptSafeText default: 600 chars, no collapse) — a
    // multi-line body keeps its line structure while an over-long payload is
    // still bounded (§6).
    return promptSafeText(value);
  }
  return value.trim();
}

/// A proposed component-add — mirrors the future `AddComponent` ConfigOp (step 69):
/// a [type], its [props] map, and an optional attached [actionId] (§9). Pure data.
class AddComponentRequest {
  const AddComponentRequest({
    required this.type,
    this.props = const {},
    this.actionId,
  });

  /// The component type to add (typically already grounded via
  /// [matchComponentTypeName] before an [AddComponentRequest] is built).
  final ComponentType type;

  /// The proposed props (free-text values are DEFANGED in the verdict, §6).
  final Map<String, String> props;

  /// The attached action id, grounded against the step-72 catalog when the template
  /// is `optionalAction:true` (§9); `null` when none is attached.
  final String? actionId;
}

/// The verdict of [validateAddComponent]: either ACCEPTED (carrying the resolved
/// [template] + the DEFANGED [safeProps] / [safeActionId] the caller should store,
/// §6) or REJECTED (carrying a non-empty Hebrew [reasonHe] — never a silent drop).
/// Mirrors the `SafetyVerdict{applied, blocked:(op, reasonHe)}` idiom (step 77).
class AddComponentVerdict {
  /// An ACCEPT — the add is legal and well-formed; [safeProps] are the defanged
  /// values to store, [safeActionId] the grounded attached action (or `null`).
  const AddComponentVerdict.accepted(
    this.template, {
    required this.safeProps,
    this.safeActionId,
  })  : ok = true,
        reasonHe = null;

  /// A REJECT — [reasonHe] is a non-empty Hebrew reason shown to the owner.
  const AddComponentVerdict.rejected(this.reasonHe)
      : ok = false,
        template = null,
        safeProps = const {},
        safeActionId = null;

  /// True ⇔ the add is legal and well-formed.
  final bool ok;

  /// The Hebrew rejection reason — non-null ⇔ `!ok`, never empty on reject.
  final String? reasonHe;

  /// The resolved template — non-null ⇔ `ok`.
  final ComponentTemplate? template;

  /// The DEFANGED props (free-text run through `promptSafeText`, §6) the caller
  /// should store — empty on reject.
  final Map<String, String> safeProps;

  /// The grounded attached action id (or `null`) — always `null` on reject.
  final String? safeActionId;
}

/// Validate a proposed [req] dropped into a container of kind [container], given
/// [existingOfType] instances of the SAME component already present there. Returns
/// an ACCEPT (with defanged props) or a REJECT with a Hebrew reason. Pure, TOTAL,
/// NEVER throws. The four rejection axes are exactly:
///   §4  — an illegal / non-content container ([canPlace] false);
///   §5  — any required prop missing (after §6 defanging — no half-built add);
///   §9  — an attached action that is unsupported by the type, or not in the
///         step-72 catalog closed set;
///   §10 — an add that would exceed the [ComponentTemplate.maxPerContainer] ceiling.
/// Grounding matches the step-72 idiom (closed set → deterministic verify).
AddComponentVerdict validateAddComponent(
  AddComponentRequest req, {
  required ElementKind container,
  int existingOfType = 0,
}) {
  final t = templateFor(req.type);
  // Fail-closed — unreachable while the palette covers every enum value (pinned by
  // a golden test), but a dangling type resolves to NO template (never a guess).
  if (t == null) {
    return const AddComponentVerdict.rejected('רכיב לא מוכר');
  }

  // §4 — the target must be a legal CONTENT container for this type. `action` /
  // `text` / `theme` are never in `allowedContainers`, so a "button into a
  // control / auth surface" is rejected HERE (`validateSafe` step-77 is the second
  // gate, on `kImmutable` ids).
  if (!t.allowedContainers.contains(container)) {
    return AddComponentVerdict.rejected(
      'לא ניתן להוסיף ${t.he} לתוך מיכל מסוג «${container.name}» — '
      'רכיבים נוספים רק לתוך מיכל תוכן (container / list)',
    );
  }

  // §6 — defang free-text props up front, so the §5 presence check tests the
  // SANITISED value (a label that is only whitespace / newlines is "missing").
  final safe = <String, String>{
    for (final e in req.props.entries) e.key: _safeProp(e.key, e.value),
  };

  // §5 — every required prop must be supplied non-empty (after defanging). The
  // special key `'actionId'` is satisfied by the dedicated [req.actionId] field
  // (an attached action), not the props map. A miss DROPS the op.
  for (final key in t.requiredProps) {
    final value =
        key == 'actionId' ? (req.actionId ?? '').trim() : (safe[key] ?? '');
    if (value.isEmpty) {
      return AddComponentVerdict.rejected('חסר שדה חובה «$key» עבור ${t.he}');
    }
  }

  // §9 — an attached action is legal ONLY on an `optionalAction` template, and only
  // when it grounds to the step-72 catalog closed set (a new component cannot
  // receive an action illegal for its context).
  final attached = (req.actionId ?? '').trim();
  String? groundedAction;
  if (attached.isNotEmpty) {
    if (!t.optionalAction) {
      return AddComponentVerdict.rejected('${t.he} אינו תומך בפעולה מוצמדת');
    }
    groundedAction = matchCatalogActionId(attached);
    if (groundedAction == null) {
      return AddComponentVerdict.rejected(
        'פעולה לא-חוקית «$attached» — אינה בקטלוג הפעולות',
      );
    }
  }

  // §10 — a per-container flood ceiling (e.g. divider): adding one more must not
  // exceed [maxPerContainer].
  final cap = t.maxPerContainer;
  if (cap != null && existingOfType >= cap) {
    return AddComponentVerdict.rejected(
      'לא ניתן להוסיף עוד ${t.he} — מוגבל ל-$cap במיכל אחד',
    );
  }

  return AddComponentVerdict.accepted(
    t,
    safeProps: Map<String, String>.unmodifiable(safe),
    safeActionId: groundedAction,
  );
}
