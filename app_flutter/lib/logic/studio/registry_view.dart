// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 4 · Step 70 — the frozen `RegistryView` query seam
// + an in-memory `FakeRegistryView` (scaffolding) + the REAL Pillar-1 adapter.
//
// GOAL (step 70): a FROZEN query interface the whole AI co-editor grounds against,
// so steps 71-85 (matchers · parse · validateSafe · preview) can be built + tested
// BEFORE trusting the live registry — the same "hand-rolled fake" discipline as
// `ClaudeGateway`/`claudeGatewayProvider` (claude_functions.dart:56-67), applied to
// the registry. Every closed-set the model is confined to (element ids · prop keys ·
// allowed values · action ids · component types) is read ONLY through this seam.
//
// ADAPTATION — the step's detail is PRE-S3.K (stale). It imagined this file landing
// BEFORE Pillar 1, so it described a test-only fake plus a promised "real adapter of
// P1's frozen ElementDescriptor". Pillar 1 has since LANDED: the frozen 6-field
// `ElementDescriptor` + `kElementRegistry` (state/studio/element_registry.dart) IS
// the real grounding source (R1-2). So this file ships BOTH halves the step names:
//   • [RegistryView]        — the frozen abstract query interface (5 methods).
//   • [FakeRegistryView]    — an in-memory fake built from injected sets (§6 `.of`).
//   • [ElementRegistryView] — the REAL adapter over P1's `kElementRegistry`. This is
//                             the ONE place a concrete Pillar-1 registry type is
//                             imported; every OTHER studio file depends on
//                             `RegistryView` alone (DoD §8 — "if the shape moves,
//                             only the adapter changes").
//
// FAIL-CLOSED (R1-2 · R2-#15): a query on an unknown id / absent prop returns an
// EMPTY set — never throws, never pass-all. A "too generous" fake (that answered a
// made-up id) would FAIL `registryViewContract` (the shared contract both the fake
// AND this real adapter must pass), so the fake can't self-certify green — the exact
// vacuous-green trap R2-#15 closes. `componentTypes()` is empty until the palette
// lands (step 73): nothing is addable, fail-closed.
//
// DORMANT: pure data, no widget / gateway / provider. Nothing in `lib/` imports it
// yet ⇒ tree-shaken out ⇒ byte-identical under every flag.
// ─────────────────────────────────────────────────────────────────────────────

import '../../state/studio/element_registry.dart'
    show ElementDescriptor, findDescriptor, kElementRegistry;

/// The FROZEN query interface the AI co-editor grounds against. Every method
/// returns a CLOSED [Set] the model's output is confined to; an unknown id / prop
/// yields an EMPTY set (fail-closed — never throws, never pass-all). Implemented by
/// the in-memory [FakeRegistryView] (tests) and the real [ElementRegistryView]
/// (over Pillar-1's frozen registry) — both pinned by `registryViewContract`.
abstract class RegistryView {
  /// Every editable element id in the registry (the closed target set).
  Set<String> elementIds();

  /// The prop keys editable on [id] (P1's `editableProps` axis names), or empty
  /// when [id] is unknown / has none.
  Set<String> propKeysFor(String id);

  /// The closed set of legal values for [id].[propKey] (e.g. the color tokens a
  /// `SetProp(color)` may pick), or empty when unknown — so an invented value is
  /// dropped (fail-closed).
  Set<String> allowedValues(String id, String propKey);

  /// The closed set of action ids that may be wired onto [id], or empty when
  /// unknown / read-only.
  Set<String> actionIdsFor(String id);

  /// The closed set of component types that may be ADDED (step-73 palette). Empty
  /// until the palette lands ⇒ nothing addable (fail-closed).
  Set<String> componentTypes();

  /// Addition-a (§9): an IMMUTABLE in-memory snapshot of THIS view. A later step's
  /// race between prompt-build and parse then sees ONE stable registry image, even
  /// if the backing source (a provider / adapter) changes underneath. Materialises
  /// the whole queryable surface into a [FakeRegistryView] (unmodifiable sets).
  RegistryView frozen() {
    final ids = elementIds();
    final propKeys = <String, Set<String>>{};
    final allowed = <String, Map<String, Set<String>>>{};
    final actions = <String, Set<String>>{};
    for (final id in ids) {
      final pk = propKeysFor(id);
      if (pk.isNotEmpty) propKeys[id] = pk;
      final acts = actionIdsFor(id);
      if (acts.isNotEmpty) actions[id] = acts;
      final byProp = <String, Set<String>>{};
      for (final k in pk) {
        final vals = allowedValues(id, k);
        if (vals.isNotEmpty) byProp[k] = vals;
      }
      if (byProp.isNotEmpty) allowed[id] = byProp;
    }
    return FakeRegistryView.of(
      ids: ids,
      propKeys: propKeys,
      allowedValues: allowed,
      actionIds: actions,
      componentTypes: componentTypes(),
    );
  }
}

/// An in-memory [RegistryView] built from EXACTLY the sets injected — the fake that
/// lets every grounding test (steps 71+) stand up a minimal, isolated registry
/// (§6). Scaffolding only: the REAL grounding source is [ElementRegistryView]; a
/// fake can never self-certify green because it must pass the SAME
/// `registryViewContract` as the real adapter (R2-#15). All stored sets are
/// UNMODIFIABLE, so a returned set can't be mutated to widen the closed set.
class FakeRegistryView extends RegistryView {
  /// Build a fake from injected sets. [ids] is unioned with the keys of the other
  /// maps, so an id mentioned only in [propKeys]/[actionIds]/[allowedValues] is
  /// still a valid element (no half-registered ids).
  FakeRegistryView.of({
    Set<String> ids = const {},
    Map<String, Set<String>> propKeys = const {},
    Map<String, Map<String, Set<String>>> allowedValues = const {},
    Map<String, Set<String>> actionIds = const {},
    Set<String> componentTypes = const {},
  })  : _ids = Set<String>.unmodifiable(<String>{
          ...ids,
          ...propKeys.keys,
          ...allowedValues.keys,
          ...actionIds.keys,
        }),
        _propKeys = {
          for (final e in propKeys.entries)
            e.key: Set<String>.unmodifiable(e.value),
        },
        _allowedValues = {
          for (final e in allowedValues.entries)
            e.key: {
              for (final v in e.value.entries)
                v.key: Set<String>.unmodifiable(v.value),
            },
        },
        _actionIds = {
          for (final e in actionIds.entries)
            e.key: Set<String>.unmodifiable(e.value),
        },
        _componentTypes = Set<String>.unmodifiable(componentTypes);

  final Set<String> _ids;
  final Map<String, Set<String>> _propKeys;
  final Map<String, Map<String, Set<String>>> _allowedValues;
  final Map<String, Set<String>> _actionIds;
  final Set<String> _componentTypes;

  static const Set<String> _empty = <String>{};

  @override
  Set<String> elementIds() => _ids;

  @override
  Set<String> propKeysFor(String id) => _propKeys[id] ?? _empty;

  @override
  Set<String> allowedValues(String id, String propKey) =>
      _allowedValues[id]?[propKey] ?? _empty;

  @override
  Set<String> actionIdsFor(String id) => _actionIds[id] ?? _empty;

  @override
  Set<String> componentTypes() => _componentTypes;
}

/// The REAL grounding source (R1-2): a [RegistryView] over Pillar-1's FROZEN
/// [ElementDescriptor] registry. This class is the ONLY importer of a concrete
/// Pillar-1 registry type — every other studio file depends on [RegistryView]
/// alone, so a change to the descriptor shape touches only THIS adapter (DoD §8).
///
/// The mapping is faithful to the frozen 6-field contract: `propKeysFor` exposes
/// the `editableProps` axis NAMES, `allowedValues`/`actionIdsFor` the matching
/// descriptor fields, and every miss is fail-closed. `componentTypes` is empty
/// until the step-73 palette lands.
class ElementRegistryView extends RegistryView {
  /// Adapt an explicit descriptor list (a test set, or a provider-materialised
  /// `elementRegistryProvider` value including Pillar-2 domain rows).
  ElementRegistryView(this._descriptors);

  /// Adapt Pillar-1's built-in [kElementRegistry] — the frozen grounding source.
  ElementRegistryView.builtIn() : _descriptors = kElementRegistry;

  final List<ElementDescriptor> _descriptors;

  static const Set<String> _empty = <String>{};

  @override
  Set<String> elementIds() => {for (final d in _descriptors) d.id};

  @override
  Set<String> propKeysFor(String id) {
    final d = findDescriptor(_descriptors, id);
    if (d == null) return _empty; // fail-closed (R1-2)
    return {for (final a in d.editableProps) a.name};
  }

  @override
  Set<String> allowedValues(String id, String propKey) {
    final vals = findDescriptor(_descriptors, id)?.allowedValues[propKey];
    return vals == null ? _empty : Set<String>.of(vals);
  }

  @override
  Set<String> actionIdsFor(String id) {
    final acts = findDescriptor(_descriptors, id)?.allowedActions;
    return acts == null ? _empty : Set<String>.of(acts);
  }

  @override
  Set<String> componentTypes() => _empty; // palette lands in step 73 (fail-closed)
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 71 — the registry closed-set MATCHERS (exact → longest-contained, null-on-
// miss). These are the ONE path from a model-emitted string to a REAL registry key
// — the "code-currency" resolvers the whole co-editor grounds against (step 75
// `parseConfigEdit` calls them field-by-field; step 76 uses `matchAllElementIds`).
//
// COPIED 1:1 from the proven, audited `matchRecipe` (describe_to_cart_screen.dart:
// 50-67) + `matchAssistantRecipeKey` (assistant_intent.dart:80-95): `.trim()`, an
// early `isEmpty → null` guard, exact-equality first, then the LONGEST CONTAINED
// key (`k.length > best.length`) so a wrapped reply can't grab a short prefix.
//
// ADAPTATION (detail is PRE-S3.K): the source matchers close over a GLOBAL const set
// (`kSmartProducts`). Here the closed set is pulled from the injected [RegistryView],
// so the SAME resolver grounds against the in-memory `FakeRegistryView` (tests) AND
// the real, frozen Pillar-1 `ElementRegistryView` (gate-119) — exactly the fake↔real
// discipline `registryViewContract` pins (R2-#15). No global state, pure functions.
//
// FAIL-CLOSED / anti-hallucination: a blank reply, an empty closed set (unknown id /
// absent prop / palette-not-landed), or no contained key all yield `null` (degrade —
// the caller drops the op), NEVER a throw and NEVER an invented key. Per the gate-119
// property invariant (step 85): for every reply, each matcher returns `null` OR a real
// member of its closed set. DORMANT: pure top-level functions, imported by nothing in
// `lib/` yet ⇒ tree-shaken out ⇒ byte-identical under every flag.
// ─────────────────────────────────────────────────────────────────────────────

/// The pure core (copy of `matchRecipe`): resolve [reply] to a key from [closed] —
/// exact first, else the LONGEST key CONTAINED in the (trimmed) reply, else `null`.
/// A blank reply or empty [closed] set is fail-closed (`null`). Empty keys are
/// skipped so a stray `''` in a set can never spuriously "contain" — the return is
/// always `null` or a REAL, non-empty member. NEVER throws.
String? _matchClosed(Set<String> closed, String reply) {
  final r = reply.trim();
  if (r.isEmpty) return null; // early guard (assistant_intent.dart:60,82)
  // Exact wins outright — short-circuits before the contained scan, so an exact
  // short key isn't shadowed by a longer key that merely contains it.
  for (final k in closed) {
    if (r == k) return k;
  }
  // Longest-contained fallback (the model may wrap the key in quotes/prose). Many
  // keys are prefixes of others (faucet⊂kitchenFaucet, card⊂card.order); first-match
  // would grab the short prefix → the wrong key (the central collision defect).
  String? best;
  for (final k in closed) {
    if (k.isNotEmpty &&
        r.contains(k) &&
        (best == null || k.length > best.length)) {
      best = k;
    }
  }
  return best;
}

/// The pure core for addition-a: EVERY key from [closed] contained in [reply] (not
/// just the best). A blank reply → empty set; only real, non-empty keys. NEVER throws.
Set<String> _matchAllClosed(Set<String> closed, String reply) {
  final r = reply.trim();
  if (r.isEmpty) return const <String>{};
  return {
    for (final k in closed)
      if (k.isNotEmpty && r.contains(k)) k,
  };
}

/// Resolve [reply] to a REAL element id from `reg.elementIds()`, or `null` (degrade).
/// Exact then longest-contained; fail-closed on a blank reply / empty registry.
String? matchElementId(RegistryView reg, String reply) =>
    _matchClosed(reg.elementIds(), reply);

/// Resolve [reply] to a REAL editable prop key on [id] (`reg.propKeysFor(id)`), or
/// `null`. An unknown [id] has an empty prop set ⇒ any reply degrades (fail-closed).
String? matchPropKey(RegistryView reg, String id, String reply) =>
    _matchClosed(reg.propKeysFor(id), reply);

/// Resolve [reply] to a REAL allowed value for [id].[propKey]
/// (`reg.allowedValues(id, propKey)`), or `null`. An invented / out-of-set value
/// (e.g. a raw hex the model made up) degrades — the closed color/enum subset wins.
String? matchValue(RegistryView reg, String id, String propKey, String reply) =>
    _matchClosed(reg.allowedValues(id, propKey), reply);

/// Resolve [reply] to a REAL action id wireable onto [id] (`reg.actionIdsFor(id)`),
/// or `null`. A read-only / unknown [id] has an empty action set ⇒ fail-closed.
String? matchActionId(RegistryView reg, String id, String reply) =>
    _matchClosed(reg.actionIdsFor(id), reply);

/// Resolve [reply] to a REAL addable component type (`reg.componentTypes()`), or
/// `null`. Empty until the step-73 palette lands ⇒ nothing addable (fail-closed).
String? matchComponentType(RegistryView reg, String reply) =>
    _matchClosed(reg.componentTypes(), reply);

/// Addition-a (§9 · step 76 scope-expansion): EVERY real element id CONTAINED in
/// [reply], not just the best — so an utterance naming several targets resolves to
/// all of them, still only over REAL ids (never model-enumerated). Blank → empty.
Set<String> matchAllElementIds(RegistryView reg, String reply) =>
    _matchAllClosed(reg.elementIds(), reply);
