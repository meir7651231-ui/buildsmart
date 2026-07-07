// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 4 · Step 75 — the TOTAL anti-hallucination parser:
// `parseConfigEdit(raw, registry) → ConfigEditResult`. This is the LOAD-BEARING
// seam of the whole pillar — the ONLY thing standing between a model's free-text
// reply and a real config mutation. It validates EVERY field of EVERY op against
// the frozen [RegistryView] (step 71 matchers) + the action catalog (step 72),
// DROPS any op that names an invented id / prop / value / action / component, and
// NEVER throws — any malformed / non-JSON / partial / `{}` / prose-wrapped reply
// degrades to a clean empty result (the same guarantee as `matchRecipe`).
//
// STRUCTURAL COPY of the battle-tested `parseAssistantIntent`
// (assistant_intent.dart:168-210): the brace-extraction idiom (indexOf/lastIndexOf),
// `jsonDecode` inside a `try`, field-by-field CLOSED-SET validation where each field
// runs through a `match*` that returns null-on-miss (a null → the op is dropped,
// mirroring the `matchAssistantCategory==null → fallback` idiom at :189-204), and the
// terminal `catch (_) { return <empty> }` (:207-208). Extended for the ops grammar:
// the reply is an ARRAY of ops (step 74 `_kOpsGrammar`), so extraction spans the
// outermost `{`/`[` … `}`/`]`, and each op is validated INDEPENDENTLY (§9 per-op
// resilience — one bad op never drops the others).
//
// TRUNCATION-GUARD FIRST (§4 · R1-10): a `finishReason` that is NOT `stop`/`end_turn`
// (the model was cut by maxTokens) OR an unbalanced / unclosed JSON structure ⇒ the
// whole reply is failed AS A UNIT ([ConfigEditResult.truncated]) — a syntactically
// valid-but-truncated JSON must NEVER be parsed into a wrong partial preview. The
// caller shows "לא הצלחתי לבנות את השינוי, נסה שוב", distinct from a clean empty
// (which is an honest "no change matched").
//
// FIELD VALIDATION (each op, all-or-nothing):
//   • target  — `matchElementId` (must be a REAL registry id, else drop);
//   • prop    — `matchPropKey(target, <kind's axis>)` (the kind must be an EDITABLE
//               axis of that element, else drop — the seed registry exposes only
//               text/emoji/style, so a `setHidden`/`setOrder`/`setAction` on it is
//               fail-closed);
//   • value   — `matchValue(target, prop, value)` WHERE the registry constrains it
//               (a non-empty `allowedValues` closed set, e.g. a style color token);
//               a free-content axis (owner text / emoji / order / hidden) has an
//               empty closed set ⇒ unconstrained, passes;
//   • action  — a `setAction` id is grounded against BOTH the element's allowed
//               action set (`matchActionId`) AND the global catalog closed set
//               (`matchCatalogActionId`) — it must be legal on the element AND real.
// Every surviving op is rebuilt with the RESOLVED (registry-real) values, so the
// step-85 property invariant holds by construction: ∀op every registry-bound field
// ∈ registry. An `addComponent`/`addRule` op has NO Pillar-1 `ConfigOp` variant, so
// `configOpFromJson` drops it (an "invented component" degrades for free).
//
// PURE / DORMANT: pure Dart — no view, no rendering, no gateway round-trip, no
// provider, Firebase-free. Reuses the SHAPE parser `configOpFromJson` (step 69) +
// the frozen matchers (step 71) + `matchCatalogActionId` (step 72). Nothing in `lib/`
// imports it yet ⇒ tree-shaken out ⇒ byte-identical under every flag.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import '../../state/studio/config_node.dart' show CfgAction, CfgStyle;
import '../../state/studio/config_store.dart'
    show
        ConfigOp,
        SetAction,
        SetEmoji,
        SetHidden,
        SetOrder,
        SetStyle,
        SetText;
import 'action_catalog.dart' show matchCatalogActionId;
import 'config_op.dart' show configOpFromJson;
import 'edit_prompt.dart'
    show kScopeAll, kScopeScreenPrefix, kScopeSinglePrefix, scopeElementIds;
import 'registry_view.dart'
    show RegistryView, matchActionId, matchElementId, matchPropKey, matchValue;

/// The result of parsing a co-editor reply — the THREE outcomes §4/§6 demand:
///   • [ops]        — the surviving, fully registry-validated ops (may be empty).
///   • [dropped]    — how many op-shaped entries were DROPPED as invented/illegal,
///                    so the preview can surface "X לא הובנו" (§6 — transparency,
///                    never silent swallowing).
///   • [truncated]  — the reply was CUT (a non-terminal finishReason or an
///                    unbalanced/unclosed JSON), so it was failed AS A UNIT (R1-10);
///                    DISTINCT from a clean empty (`ops` empty, `truncated` false),
///                    which is an honest "nothing matched". The caller shows
///                    "לא הצלחתי לבנות את השינוי, נסה שוב" only when [truncated].
class ConfigEditResult {
  const ConfigEditResult({
    required this.ops,
    required this.dropped,
    required this.truncated,
  });

  /// A clean empty result — no ops, nothing dropped, NOT truncated (an honest
  /// "no change matched" / non-JSON prose / `{}`).
  const ConfigEditResult.empty()
      : ops = const <ConfigOp>[],
        dropped = 0,
        truncated = false;

  /// The fail-as-unit result (R1-10): the reply was truncated, so NO partial ops
  /// are surfaced — the caller must ask the user to try again.
  const ConfigEditResult.truncated()
      : ops = const <ConfigOp>[],
        dropped = 0,
        truncated = true;

  final List<ConfigOp> ops;
  final int dropped;
  final bool truncated;
}

/// The finishReason values that mean the model completed NORMALLY (not cut). Any
/// other non-null value (`length` / `max_tokens` / `content_filter` / …) means the
/// reply was truncated ⇒ fail-as-unit (§4 · R1-10).
const Set<String> _kCleanFinishReasons = {'stop', 'end_turn'};

/// Parse + VALIDATE a co-editor reply into a trusted [ConfigEditResult]. TOTAL:
/// any failure (truncated / not-JSON / malformed / an invented id·prop·value·action·
/// component) yields an empty-or-truncated result — NEVER a throw, NEVER an
/// un-validated op. [finishReason] (when the caller has it) triggers the
/// truncation-guard; omit it (null) for a reply with no known finish signal.
ConfigEditResult parseConfigEdit(
  String raw,
  RegistryView registry, {
  String? finishReason,
}) {
  final text = raw.trim();

  // ── TRUNCATION-GUARD FIRST (§4 · R1-10) — fail-as-unit, never a partial preview.
  // (a) A non-terminal finishReason = the model was CUT (maxTokens/length/filter);
  //     even syntactically-valid JSON may be a fragment, so refuse the whole reply.
  if (finishReason != null && !_kCleanFinishReasons.contains(finishReason)) {
    return const ConfigEditResult.truncated();
  }
  // (b) Brace/bracket balance. Extract the outermost JSON span (the `{`/`[`…`}`/`]`
  //     idiom, generalised from assistant_intent.dart:170-171 to accept an array).
  final start = _firstOpen(text);
  if (start < 0) {
    return const ConfigEditResult.empty(); // no JSON at all → plain prose.
  }
  final end = _lastClose(text);
  if (end <= start) {
    return const ConfigEditResult.truncated(); // opened, never closed → cut off.
  }
  final candidate = text.substring(start, end + 1);
  if (_looksTruncated(candidate)) {
    return const ConfigEditResult.truncated(); // unclosed structure / mid-string.
  }

  // ── Decode + validate EVERY field of EVERY op (independently — §9). ──
  try {
    final decoded = jsonDecode(candidate);
    final rawOps = _rawOps(decoded);
    final ops = <ConfigOp>[];
    var dropped = 0;
    for (final entry in rawOps) {
      final op = _validateOp(entry, registry);
      if (op == null) {
        dropped++; // an invented / illegal op — surfaced as "X לא הובנו" (§6).
      } else {
        ops.add(op); // enters ONLY when every field validated.
      }
    }
    return ConfigEditResult(ops: ops, dropped: dropped, truncated: false);
  } catch (_) {
    // Malformed / non-JSON / partial-syntax → clean empty, NEVER throw
    // (assistant_intent.dart:207-208).
    return const ConfigEditResult.empty();
  }
}

/// Validate ONE op-shaped entry against [reg], returning the RESOLVED op or `null`
/// (drop). All-or-nothing: a miss on ANY field drops the whole op (§4). The shape is
/// parsed by the step-69 `configOpFromJson` (unknown tag / bad shape / missing id →
/// null); the registry grounding is layered on top.
ConfigOp? _validateOp(Object? entry, RegistryView reg) {
  if (entry is! Map) return null; // a stray non-object array element.
  final m = entry.map((k, v) => MapEntry(k.toString(), v));

  // SHAPE (step 69): a real ConfigOp tag with a non-empty id, or null. An
  // `addComponent`/`addRule` (no P1 variant) drops here → invented component gone.
  final shape = configOpFromJson(m);
  if (shape == null) return null;

  // FIELD 1 — target must be a REAL registry id (else drop). The RESOLVED id (exact
  // or longest-contained) is carried through, mirroring assistant_intent.dart:195.
  final target = matchElementId(reg, shape.id);
  if (target == null) return null;

  // FIELD 2 — the op-kind's axis must be an EDITABLE prop of that element (else drop).
  if (matchPropKey(reg, target, _axisOf(shape)) == null) return null;

  // FIELD 3/4 — value / action per kind, grounded where the registry constrains it.
  switch (shape) {
    case SetText(:final text):
      if (!_freeValueOk(reg, target, 'text', text)) return null;
      return SetText(target, text);
    case SetEmoji(:final emoji):
      if (!_freeValueOk(reg, target, 'emoji', emoji)) return null;
      return SetEmoji(target, emoji);
    case SetHidden(:final hidden):
      return SetHidden(target, hidden); // bool — no closed set (editability gated it).
    case SetOrder(:final order):
      return SetOrder(target, order); // int — no closed set.
    case SetStyle(:final style):
      final resolved = _resolveStyle(reg, target, style);
      if (!resolved.ok) return null; // an invented style token → drop.
      return SetStyle(target, resolved.style);
    case SetAction():
      // The action id is a bare string per the grammar (edit_prompt.dart:113), which
      // `configOpFromJson` leaves as a null CfgAction — so read it from the raw map.
      final id = _actionIdOf(m);
      if (id == null) return null;
      final onElement = matchActionId(reg, target, id); // legal ON this element?
      final inCatalog = matchCatalogActionId(id); // a REAL catalog action?
      if (onElement == null || inCatalog == null) return null;
      return SetAction(target, CfgAction(kind: onElement));
  }
}

/// The registry axis name for [op]'s kind — the prop key its editability is checked
/// against (`matchPropKey`). Mirrors P1's `EditAxis` names (element_registry.dart:23).
String _axisOf(ConfigOp op) => switch (op) {
      SetText() => 'text',
      SetEmoji() => 'emoji',
      SetHidden() => 'hidden',
      SetOrder() => 'order',
      SetStyle() => 'style',
      SetAction() => 'action',
    };

/// True when a free-content [value] for [prop] is acceptable: `null` (a clear) or an
/// UNCONSTRAINED axis (empty `allowedValues` — owner text/emoji), else it must ground
/// to a real member of the closed set (`matchValue`). "Where the registry constrains
/// it" = a non-empty `allowedValues(target, prop)`.
bool _freeValueOk(RegistryView reg, String target, String prop, String? value) {
  if (value == null) return true;
  if (reg.allowedValues(target, prop).isEmpty) return true; // free content.
  return matchValue(reg, target, prop, value) != null;
}

/// Resolve every string token of a [style] against its per-element closed set (where
/// the registry constrains it), returning the rebuilt style with REGISTRY-REAL tokens
/// — or `ok:false` when any CONSTRAINED token is invented (drop the whole op). A null
/// style (a "clear") is passed through unchanged.
({bool ok, CfgStyle? style}) _resolveStyle(
  RegistryView reg,
  String target,
  CfgStyle? style,
) {
  if (style == null) return (ok: true, style: null);
  final color = _resolveToken(reg, target, 'color', style.colorToken);
  if (!color.ok) return (ok: false, style: null);
  final bg = _resolveToken(reg, target, 'bg', style.bgToken);
  if (!bg.ok) return (ok: false, style: null);
  final weight = _resolveToken(reg, target, 'weight', style.weightToken);
  if (!weight.ok) return (ok: false, style: null);
  final size = _resolveToken(reg, target, 'size', style.sizeToken);
  if (!size.ok) return (ok: false, style: null);
  return (
    ok: true,
    style: CfgStyle(
      colorToken: color.value,
      bgToken: bg.value,
      weightToken: weight.value,
      sizeToken: size.value,
      fontScale: style.fontScale, // clamped by CfgStyle itself (no closed set).
      pad: style.pad, // an EdgeKey enum — validated by CfgStyle.fromJson.
    ),
  );
}

/// Ground ONE style token: `null` passes (absent); an UNCONSTRAINED prop (empty
/// closed set) keeps the raw token; a CONSTRAINED prop must resolve via `matchValue`
/// (else `ok:false` → drop), and the RESOLVED value is returned.
({bool ok, String? value}) _resolveToken(
  RegistryView reg,
  String target,
  String prop,
  String? token,
) {
  if (token == null) return (ok: true, value: null);
  if (reg.allowedValues(target, prop).isEmpty) {
    return (ok: true, value: token); // unconstrained axis — free.
  }
  final resolved = matchValue(reg, target, prop, token);
  return resolved == null ? (ok: false, value: null) : (ok: true, value: resolved);
}

/// The candidate action id from a `setAction` op: the bare string per the grammar
/// (edit_prompt.dart:113), or a nested `{kind}` (the CfgAction shape). Blank → null.
String? _actionIdOf(Map<String, dynamic> m) {
  final a = m['action'];
  if (a is String) {
    final t = a.trim();
    return t.isEmpty ? null : t;
  }
  if (a is Map) {
    final k = a['kind'];
    if (k is String && k.trim().isNotEmpty) return k.trim();
  }
  return null;
}

/// The list of raw op entries from a decoded reply: a top-level JSON array (the
/// grammar), an `{"ops":[…]}` envelope, or a single op object. Anything else → empty
/// (so a `{}` / `{"key":"x"}` / a bare scalar yields no ops — a clean empty).
List<Object?> _rawOps(Object? decoded) {
  if (decoded is List) return decoded;
  if (decoded is Map) {
    final ops = decoded['ops'];
    if (ops is List) return ops;
    if (decoded['op'] != null) return <Object?>[decoded]; // a lone op object.
  }
  return const <Object?>[];
}

/// The earliest opening `{` or `[` in [s], or -1 (no JSON structure at all).
int _firstOpen(String s) {
  final brace = s.indexOf('{');
  final bracket = s.indexOf('[');
  if (brace < 0) return bracket;
  if (bracket < 0) return brace;
  return brace < bracket ? brace : bracket;
}

/// The latest closing `}` or `]` in [s], or -1 (nothing closed).
int _lastClose(String s) {
  final brace = s.lastIndexOf('}');
  final bracket = s.lastIndexOf(']');
  return brace > bracket ? brace : bracket;
}

/// True when [candidate] was CUT OFF: an unterminated string literal, or a net
/// unclosed `{`/`[` depth (more opens than closes outside strings). String-aware so a
/// brace inside a "text" value can't confuse the count. A NEGATIVE depth (a stray
/// close) is left to `jsonDecode` to reject as malformed (→ clean empty, not
/// truncated) — this predicate only flags the "opened, never finished" shape.
bool _looksTruncated(String candidate) {
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (final rune in candidate.runes) {
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (rune == 0x5C /* \ */) {
        escaped = true;
      } else if (rune == 0x22 /* " */) {
        inString = false;
      }
      continue;
    }
    if (rune == 0x22 /* " */) {
      inString = true;
    } else if (rune == 0x7B /* { */ || rune == 0x5B /* [ */) {
      depth++;
    } else if (rune == 0x7D /* } */ || rune == 0x5D /* ] */) {
      depth--;
    }
  }
  return inString || depth > 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 4 · Step 76 — CLOSED scope-token EXPANSION to concrete
// registry ids (the broadcast path). A broadcast utterance ("כל הכפתורים" / "בכל מסך
// העגלה") is NEVER trusted to the model as a LIST of ids — the model only NAMES a
// closed SCOPE TOKEN, and THIS Dart code deterministically EXPANDS that token over the
// REAL `registry.elementIds()`. Every id that leaves [expandScope] satisfies
// `registry.elementIds().contains(id)` by construction (§4 · DoD §8): no id is ever
// read from a model-emitted array. Builds directly on step 74's token shapes
// (`scope:all` / `scope:screen:<ns>` / `scope:single:<id>` from `classifyScope`).
//
// RECONCILIATION — the plan (§2/§9) PREDATES the FROZEN [RegistryView] seam. It said
// `elementIds().where(kind == button)` and `every:<kind>`, but the seam exposes NO
// per-id `ElementKind` (step 70 froze exactly five query methods; there is deliberately
// NO kind accessor and one may NOT be added). So, exactly as steps 72/74 reconciled the
// same pre-seam text against the id-namespace stand-in:
//   • `every:<ns>`  → `elementIds().where((id) => id == ns || id.startsWith('$ns.'))`.
//                     The id-NAMESPACE subtree IS the screen/area grouping the frozen
//                     seam affords (the same stand-in step 74 uses for "screen id").
//   • "all buttons" → the seam has NO kind, so the seam-legal PROXY for "the
//                     interactive/button-like elements" is "the elements that CARRY
//                     actions": `elementIds().where((id) => actionIdsFor(id).isNotEmpty)`.
//                     Named HONESTLY [kScopeActionable] (NOT "buttons") precisely because
//                     it is an actionable-proxy, not a kind query — the honest name
//                     documents the seam limit (WHY: no `ElementKind` on the frozen seam).
//   • `scope:single:<id>` → the ONE id, RE-GROUNDED through the frozen `matchElementId`
//                     (exact → longest-contained → null); a missing id drops to empty
//                     (fail-closed). `scope:all` / `scope:screen:<ns>` delegate to step
//                     74's proven `scopeElementIds` so the namespace semantics never
//                     drift from Stage-B slicing.
// INVARIANT: the model names a CLOSED token; Dart expands over REAL `elementIds()`; NO
// id is read from a model list.
//
// DoS/FOOT-GUN GUARD (§3 · §10): a broadcast that would rewrite half the app is a real
// hazard, so an early DRY-COUNT ([dryCountScope]) compares the expanded target COUNT to
// [kStudioMaxBatch] BEFORE any op is built — an over-ceiling scope is refused with a
// Hebrew reason, saving the wasted per-op construction. The broadcast builder
// ([buildScopeEdit]) then stamps ONE desired edit onto every real target and runs the
// WHOLE array through the step-75 [parseConfigEdit] pipeline — so each op is
// independently registry-validated and an element that rejects a field drops ONLY its
// own op (§4/§9), never bypassing the anti-hallucination pipeline.
//
// DORMANT: pure functions + consts — no view, no gateway, no provider, Firebase-free.
// `parseConfigEdit` above stays byte-identical (this only APPENDS below it). Nothing in
// `lib/` imports it yet ⇒ tree-shaken out ⇒ byte-identical under every flag.
// ─────────────────────────────────────────────────────────────────────────────

/// The "all buttons" broadcast token. NAMED HONESTLY: the frozen [RegistryView] has no
/// per-id kind, so this expands to every element that CARRIES actions (the seam-legal
/// proxy for "interactive/button-like"), NOT a real kind query (see the header).
const String kScopeActionable = 'scope:actionable';

/// The `every:<ns>` scope prefix (§9) — expands to every id in the namespace SUBTREE
/// (`id == ns || id.startsWith('$ns.')`). The id-namespace is the seam's area grouping.
const String kScopeEveryPrefix = 'every:';

/// The per-utterance broadcast CEILING (§3/§7.6 · aligned with step 78). A scope that
/// expands past this many REAL targets is rejected early ([dryCountScope]) as a
/// DoS/foot-gun guard — a broadcast must not silently rewrite half the app.
const int kStudioMaxBatch = 25;

/// Deterministically EXPAND a closed [token] to the concrete, deduped, SORTED list of
/// REAL registry ids it covers — the anti-hallucination core of the broadcast path
/// (§4). Every returned id satisfies `registry.elementIds().contains(id)`; a
/// non-existent namespace / missing single / unknown token yields an EMPTY list
/// (fail-closed). NO id is ever taken from a model list — Dart enumerates the registry.
List<String> expandScope(String token, RegistryView registry) {
  final ids = registry.elementIds();
  final Iterable<String> matched;
  if (token == kScopeActionable) {
    // "all buttons" proxy — an element CARRYING actions is the button-like one (there
    // is no `ElementKind` on the frozen seam; see the header reconciliation).
    matched = ids.where((id) => registry.actionIdsFor(id).isNotEmpty);
  } else if (token.startsWith(kScopeEveryPrefix)) {
    // §9 `every:<ns>` — the id-namespace subtree IS the area grouping.
    final ns = token.substring(kScopeEveryPrefix.length).trim();
    matched = ns.isEmpty
        ? const <String>[]
        : ids.where((id) => id == ns || id.startsWith('$ns.'));
  } else if (token.startsWith(kScopeSinglePrefix)) {
    // Re-ground the single id through the frozen matcher — drop to empty if missing.
    final one =
        matchElementId(registry, token.substring(kScopeSinglePrefix.length));
    matched = one == null ? const <String>[] : <String>[one];
  } else if (token == kScopeAll || token.startsWith(kScopeScreenPrefix)) {
    // The model-emittable tokens (step 74 `classifyScope`) — reuse the proven
    // `scopeElementIds` so the namespace semantics never drift from Stage-B slicing.
    matched = scopeElementIds(token, registry);
  } else {
    return const <String>[]; // unknown token → fail-closed (empty).
  }
  // DoD §8: deduped, SORTED, and — via the `ids.contains` filter — every id is REAL.
  final out = matched.where(ids.contains).toSet().toList()..sort();
  return out;
}

/// The Hebrew reason for an over-ceiling broadcast (§3 · surfaced in the preview).
String _batchRejectHe(int count) =>
    'השינוי נרחב מדי — $count יעדים (מעל התקרה $kStudioMaxBatch). צמצם את הטווח.';

/// The early DRY-COUNT verdict (§10): the real targets to build, the pre-ceiling
/// [requested] count, and a Hebrew [rejectedReasonHe] that is non-null EXACTLY when the
/// scope is over [kStudioMaxBatch] (then [ids] is empty — nothing is built).
class ScopeCount {
  const ScopeCount._(this.ids, this.requested, this.rejectedReasonHe);

  /// The real targets to build (empty when [rejected]).
  final List<String> ids;

  /// How many ids the scope expanded to — the pre-ceiling count, shown even when
  /// rejected so the preview can say "42 יעדים, מעל התקרה".
  final int requested;

  /// The Hebrew rejection reason, or null when under the ceiling.
  final String? rejectedReasonHe;

  bool get ok => rejectedReasonHe == null;
  bool get rejected => rejectedReasonHe != null;
  int get count => ids.length;
}

/// Run the §10 early DRY-COUNT for [token] over [registry]: [expandScope] once and
/// compare the target COUNT to [kStudioMaxBatch] BEFORE building any ops. An
/// over-ceiling scope is refused here (empty ids + a Hebrew reason), so the caller
/// never wastes per-op construction on a "rewrite half the app" broadcast (§3).
ScopeCount dryCountScope(String token, RegistryView registry) {
  final expanded = expandScope(token, registry);
  if (expanded.length > kStudioMaxBatch) {
    return ScopeCount._(
      const <String>[],
      expanded.length,
      _batchRejectHe(expanded.length),
    );
  }
  return ScopeCount._(expanded, expanded.length, null);
}

/// The outcome of a BROADCAST build ([buildScopeEdit]). Carries the step-75 [result]
/// (its `ops` survived per-field validation; `dropped` counts the ones an element
/// rejected) plus the early-ceiling verdict: when [rejectedReasonHe] is non-null the
/// broadcast was refused BEFORE building (over [kStudioMaxBatch]) and [result] is empty.
class ScopeEditResult {
  const ScopeEditResult({
    required this.token,
    required this.requested,
    required this.result,
    required this.rejectedReasonHe,
  });

  final String token;

  /// How many real ids the scope expanded to (pre-ceiling / pre-validation).
  final int requested;

  /// The step-75 parse outcome (registry-validated ops + dropped count).
  final ConfigEditResult result;

  /// Non-null ⇒ refused early over the batch ceiling (then [result] is empty).
  final String? rejectedReasonHe;

  bool get rejected => rejectedReasonHe != null;

  /// The surviving, registry-validated broadcast ops (empty when [rejected]).
  List<ConfigOp> get ops => result.ops;
}

/// Build a BROADCAST edit: stamp ONE desired [editTemplate] (an op map WITHOUT an
/// `id` — e.g. `{'op': 'setStyle', 'style': {'colorToken': 'brand'}}`) onto every REAL
/// id the [token] expands to, then run the whole array through the step-75
/// [parseConfigEdit] pipeline so EACH op is independently registry-validated and an
/// element that rejects a field drops ONLY its own op (§4/§9 — the pipeline is never
/// bypassed). The §10 dry-count guards FIRST: an over-[kStudioMaxBatch] scope is refused
/// before any op is built. NO id comes from a model list — [expandScope] enumerates the
/// registry.
ScopeEditResult buildScopeEdit(
  String token,
  Map<String, Object?> editTemplate,
  RegistryView registry,
) {
  final counted = dryCountScope(token, registry);
  if (counted.rejected) {
    return ScopeEditResult(
      token: token,
      requested: counted.requested,
      result: const ConfigEditResult.empty(),
      rejectedReasonHe: counted.rejectedReasonHe,
    );
  }
  // Stamp the edit onto each REAL target (the per-target `id` is applied LAST so a stray
  // `id` in the template can never override it), then VALIDATE through the existing
  // pipeline — the SAME JSON path a model reply takes (never a bypass).
  final opsJson = <Map<String, Object?>>[
    for (final id in counted.ids) {...editTemplate, 'id': id},
  ];
  return ScopeEditResult(
    token: token,
    requested: counted.requested,
    result: parseConfigEdit(jsonEncode(opsJson), registry),
    rejectedReasonHe: null,
  );
}

/// The Hebrew scope LABEL for a token (§6) — the human phrase step-79's preview shows
/// beside the broadcast count ("כל הכפתורים: 12 שינויים" / "מסך «cart»"). Distinct from
/// step 74's `scopeLabel` (which prefixes "מתוך: " for the Stage-B target line); this is
/// the bare phrase for a count row.
String scopeHe(String token) {
  if (token == kScopeAll) return 'כל האלמנטים';
  if (token == kScopeActionable) return 'כל הכפתורים';
  if (token.startsWith(kScopeEveryPrefix)) {
    return 'כל «${token.substring(kScopeEveryPrefix.length)}»';
  }
  if (token.startsWith(kScopeScreenPrefix)) {
    return 'מסך «${token.substring(kScopeScreenPrefix.length)}»';
  }
  if (token.startsWith(kScopeSinglePrefix)) {
    return 'האלמנט «${token.substring(kScopeSinglePrefix.length)}»';
  }
  return '(טווח לא מזוהה)';
}
