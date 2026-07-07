// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 4 · Step 69 — ConfigOp JSON round-trip + grouping.
//
// GOAL (step 69): the shared "code-currency" of the AI co-editor — a CLOSED
// `ConfigOp` family with a lossless `toJson`/`fromJson` round-trip + a schema tag,
// so a draft of ops can be stored/re-read and a diff/undo can compare by value.
//
// ADAPTATION — the step's detail is PRE-S3.K (stale). It says NEW-file a parallel
// `ConfigOp` family (`SetProp`/`SetVisible{roleProvider}`/`AddComponent`/`AddRule`…).
// But Pillar-1 has since landed and ALREADY owns `sealed class ConfigOp`
// (`state/studio/config_store.dart`: SetText·SetEmoji·SetHidden·SetOrder·SetStyle·
// SetAction), and its `applyOps(List<ConfigOp>)` is the FROZEN SEAM-2 that R1-4
// requires Pillar-4 to write THROUGH. A `sealed` family is closed to its declaring
// library, and forking a second `ConfigOp` would break that seam. So this file does
// NOT redefine the family — it adds the residual capability the family lacks:
//   • `configOpFromJson`  — the tolerant inverse of `op.toJson()` (round-trip).
//   • schema envelope      — `kConfigOpSchema` inside the JSON (migration-safe).
//   • `ConfigOp.kind`      — an enum grouping getter (for `summarizeDiff`, step 79).
//   • `configOpEquals`     — value equality (the sealed classes use identity ==).
// Persona/visibility mapping (R1-3): the detail's `SetVisible{roleProvider}` is P1's
// `SetHidden(id, !visible)` applied via `applyOps(persona: roleKeyOf(roleProvider))`
// — the persona is the String roleKey (null=contractor), never a `BsRole` enum.
//
// ANTI-DRIFT: enums serialise by NAME (P1's `toJson` uses `.name`; `CfgStyle`/
// `CfgAction.fromJson` re-read by name) — never an `int` index that shifts when a
// variant is inserted. TOTAL / never-throws: an unknown/absent op-tag or any
// malformed field yields `null` (drop), mirroring `parseAssistantIntent`
// (assistant_intent.dart:172-173) + `_enumByName` (config_node.dart). PURE data —
// no widget, no gateway, no provider. Nothing imports it yet ⇒ tree-shaken out ⇒
// DORMANT / byte-identical under every flag.
// ─────────────────────────────────────────────────────────────────────────────

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

/// The op-JSON schema. Bumped on any shape change so a stored draft can migrate
/// (same idiom as `kSchemaVersion` in `config_doc.dart` / `'bs.feature-flags.v1'`).
const int kConfigOpSchema = 1;

/// The closed set of op kinds — a stable enum for grouping a diff by type
/// (step 79 `summarizeDiff`) without an `is`-ladder. Mirrors P1's `ConfigOp` family.
enum ConfigOpKind { setText, setEmoji, setHidden, setOrder, setStyle, setAction }

/// Group getter over the (P1-owned) sealed family — exhaustive, compile-checked.
extension ConfigOpKindX on ConfigOp {
  ConfigOpKind get kind => switch (this) {
        SetText() => ConfigOpKind.setText,
        SetEmoji() => ConfigOpKind.setEmoji,
        SetHidden() => ConfigOpKind.setHidden,
        SetOrder() => ConfigOpKind.setOrder,
        SetStyle() => ConfigOpKind.setStyle,
        SetAction() => ConfigOpKind.setAction,
      };
}

/// Serialise one op to JSON WITH the schema tag. P1's `op.toJson()` already emits
/// `{'op': <tag>, 'id': …, <field>}` with enum values by name; we only add the
/// `schemaVersion` envelope so a stored op is migration-safe.
Map<String, dynamic> configOpToJson(ConfigOp op) => <String, dynamic>{
      'schemaVersion': kConfigOpSchema,
      ...op.toJson(),
    };

/// The TOLERANT inverse — reconstruct a [ConfigOp] from [raw], or `null` when it
/// is not a recognised op. NEVER throws: a non-map input, a missing/blank `id`, an
/// unknown/absent `op` tag (incl. stale-family tags like `addComponent`/`addRule`
/// that P1 has no variant for), or a wrong-typed field all degrade to `null`. All
/// field reads are `is`-guarded (not `as`-cast) so hostile JSON can't blow up.
ConfigOp? configOpFromJson(Object? raw) {
  if (raw is! Map) return null;
  final j = raw.map((k, v) => MapEntry(k.toString(), v));

  final rawId = j['id'];
  if (rawId is! String || rawId.isEmpty) return null; // fail-closed on identity
  final id = rawId;

  switch (j['op']) {
    case 'setText':
      final t = j['text'];
      return SetText(id, t is String ? t : null);
    case 'setEmoji':
      final e = j['emoji'];
      return SetEmoji(id, e is String ? e : null);
    case 'setHidden':
      final h = j['hidden'];
      return SetHidden(id, h is bool ? h : null);
    case 'setOrder':
      final o = j['order'];
      return SetOrder(id, o is num ? o.toInt() : null);
    case 'setStyle':
      final s = j['style'];
      return SetStyle(id, s is Map ? CfgStyle.fromJson(_strMap(s)) : null);
    case 'setAction':
      final a = j['action'];
      return SetAction(id, a is Map ? CfgAction.fromJson(_strMap(a)) : null);
    default:
      return null; // unknown / missing tag → drop (degrade, never throw)
  }
}

/// Serialise a batch (a draft's op-list) — 1:1, order preserved.
List<Map<String, dynamic>> configOpsToJson(List<ConfigOp> ops) =>
    [for (final op in ops) configOpToJson(op)];

/// Deserialise a batch, DROPPING anything unrecognised (never throws, never a
/// half-built op) — mirrors the closed-set discipline: a stored draft with a
/// future/foreign op simply loses that entry instead of corrupting the load.
List<ConfigOp> configOpsFromJson(Object? raw) {
  if (raw is! List) return const [];
  final out = <ConfigOp>[];
  for (final e in raw) {
    final op = configOpFromJson(e);
    if (op != null) out.add(op);
  }
  return out;
}

/// VALUE equality for two ops (the sealed classes use identity `==`; this is the
/// step-69 "value-based compare" for undo/diff tests). Reuses `CfgStyle`/`CfgAction`
/// value `==` for the nested payloads.
bool configOpEquals(ConfigOp a, ConfigOp b) => switch ((a, b)) {
      (final SetText x, final SetText y) => x.id == y.id && x.text == y.text,
      (final SetEmoji x, final SetEmoji y) => x.id == y.id && x.emoji == y.emoji,
      (final SetHidden x, final SetHidden y) =>
        x.id == y.id && x.hidden == y.hidden,
      (final SetOrder x, final SetOrder y) => x.id == y.id && x.order == y.order,
      (final SetStyle x, final SetStyle y) => x.id == y.id && x.style == y.style,
      (final SetAction x, final SetAction y) =>
        x.id == y.id && x.action == y.action,
      _ => false, // mismatched variants
    };

/// String-keyed normalisation for a nested JSON map (the platform layer may hand
/// back `Map<Object?, Object?>`) — same tolerant cast as `config_doc._asStrMap`.
Map<String, dynamic> _strMap(Map<dynamic, dynamic> m) =>
    m.map((k, v) => MapEntry(k.toString(), v));
