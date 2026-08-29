// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 4 · Step 79 — `summarizeDiff`: the pure ops→Hebrew
// PREVIEW mapping. Turns a draft's [ConfigOp] list into human, RTL Hebrew display
// rows the owner reads BEFORE publishing — one row per op for a small diff, a
// collapsed count for a broadcast, and a blocked-count tail from a [SafetyVerdict].
//
// GOAL (step 79): "Preview is free" (§9) — a ZERO-model, ZERO-IO mapping. No
// gateway, no provider, no Firebase; re-previewing a diff costs nothing, so the UI
// may recompute it on every keystroke. The rows are grounded in the SAME Hebrew
// vocabulary the rest of the co-editor already owns: the step-72 action catalog
// (`actionHe`) and the step-69 `ConfigOp.kind` group getter.
//
// §6 — EACH [DiffLine] CARRIES ITS ORIGINAL [ConfigOp]. A per-op row keeps the exact
// op that produced it, so the step-82 manual builder can tap-to-edit / tap-to-remove
// WITHOUT re-parsing the Hebrew back into an op. A grouped/summary/blocked row is a
// roll-up of many (or of the verdict), so its [DiffLine.op] is `null` — the builder
// expands such a row rather than editing a single op.
//
// §4 broadcast grouping: a diff of [kDiffBroadcastThreshold]+ ops is COLLAPSED — a
// single-kind broadcast to one "N שינויים" row, a multi-kind broadcast to the §9
// grouped-by-kind summary ("🎨 12 צבעים · 🙈 3 הסתרות · ⚙️ 1 פעולה") — never N noisy
// rows. §4 blocked-count: when a [SafetyVerdict] is supplied and it refused K ops, a
// trailing "נחסמו K" row reports it (K>0); the count is read straight from
// `verdict.blocked.length`, never re-derived, so it can't drift from the backstop.
//
// §10 before→after: for a `SetStyle(color)` whose token the registry constrains
// (`allowedValues(id,'color')` contains it), the row renders the precise new color
// in Hebrew ("שינוי צבע: <id> ← ירוק") — a precise preview, not just "changed";
// best-effort, SKIPPED when the registry does not constrain the value.
//
// ADAPTATION (the plan §9 example "➕ 1 רכיב" is PRE-S3.K stale): P1's FROZEN
// `ConfigOp` family (config_store.dart) is the 6 Set-axis ops only — there is NO
// `AddComponent` variant, so the step-73 component palette `he` is not reachable
// FROM an op and is deliberately not imported here (the same reconciliation the
// sibling files document). The grouped summary maps the 6 REAL kinds.
//
// RTL discipline (§4/§8): the rows are PURE Hebrew strings — no forced left-
// alignment, no direction override, no LTR-injection. Embedded counts (the "N" in
// "N שינויים", the "K" in "נחסמו K") are bare digits so the bidi algorithm places
// them naturally within the RTL text — never fenced by directional marks.
//
// DORMANT: pure top-level functions over pure data — renders no widget, no gateway,
// no provider, Firebase-free, no raw color. Nothing in `lib/` imports it yet ⇒
// tree-shaken out ⇒ byte-identical under every flag.
// ─────────────────────────────────────────────────────────────────────────────

import '../../state/studio/config_node.dart' show CfgStyle;
import '../../state/studio/config_store.dart'
    show ConfigOp, SetAction, SetEmoji, SetHidden, SetOrder, SetStyle, SetText;
import 'action_catalog.dart' show actionHe;
import 'config_op.dart' show ConfigOpKind, ConfigOpKindX;
import 'edit_safety.dart' show SafetyVerdict;
import 'registry_view.dart' show RegistryView;

/// A diff exceeding this many ops is a BROADCAST — collapsed to a grouped summary
/// instead of one noisy row per op (§4). Below it, every op gets its own row.
const int kDiffBroadcastThreshold = 6;

/// ONE preview row: the Hebrew display [he] the owner reads, plus the ORIGINAL [op]
/// that produced it (§6) — carried so the step-82 builder can tap-to-edit /
/// tap-to-remove WITHOUT re-parsing the Hebrew. A grouped / summary / blocked-count
/// row rolls up many ops (or the verdict), so its [op] is `null`.
class DiffLine {
  const DiffLine(this.he, {this.op});

  /// The human Hebrew text shown to the owner — always non-empty for a real op.
  final String he;

  /// The single op this row previews, or `null` for a grouped / summary / blocked
  /// row (§6 — the tap-to-edit anchor for step 82).
  final ConfigOp? op;

  @override
  String toString() => 'DiffLine($he${op == null ? '' : ' · ${op!.id}'})';
}

/// Map a draft's [ops] to human Hebrew preview rows (§9 "Preview is free" — pure,
/// zero model, zero IO). A small diff yields one row per op (each carrying its op,
/// §6); a broadcast ([kDiffBroadcastThreshold]+ ops) collapses to a grouped summary
/// (§4/§9). When [verdict] is supplied and it refused K ops, a trailing "נחסמו K"
/// row reports the blocked count (K>0), read from `verdict.blocked.length`.
///
/// [registry] grounds the optional §10 before→after fragment (the precise new color
/// for a constrained `SetStyle`); best-effort, skipped when unconstrained. Pure,
/// TOTAL, never throws.
List<DiffLine> summarizeDiff(
  List<ConfigOp> ops,
  RegistryView registry, {
  SafetyVerdict? verdict,
}) {
  final rows = <DiffLine>[];
  if (ops.length >= kDiffBroadcastThreshold) {
    rows.add(_broadcastRow(ops)); // §4 — collapse, never N noisy rows
  } else {
    for (final op in ops) {
      rows.add(DiffLine(_heForOp(op, registry), op: op)); // §6 — carry the op
    }
  }
  // §4 blocked-count — read straight from the backstop's verdict, never re-derived.
  final blocked = verdict?.blocked.length ?? 0;
  if (blocked > 0) {
    rows.add(DiffLine('נחסמו $blocked')); // summary row → op: null
  }
  return rows;
}

// ─── broadcast grouping (§4 · §9 group-by-kind) ──────────────────────────────

/// Collapse a broadcast to ONE row: a single-kind broadcast to "N שינויים" (§4), a
/// multi-kind broadcast to the §9 grouped-by-kind summary. The op is a roll-up ⇒
/// [DiffLine.op] is `null`.
DiffLine _broadcastRow(List<ConfigOp> ops) {
  final counts = <ConfigOpKind, int>{};
  // Track whether EVERY SetStyle in the group is a color change, so the label can
  // sharpen "עיצובים" → "צבעים" (the §9 example) only when it is truly all colors.
  var styleAllColor = true;
  for (final op in ops) {
    final kind = op.kind;
    counts[kind] = (counts[kind] ?? 0) + 1;
    if (kind == ConfigOpKind.setStyle &&
        !(op is SetStyle && op.style?.colorToken != null)) {
      styleAllColor = false;
    }
  }
  // §4 — a same-kind broadcast collapses to the plain total.
  if (counts.length == 1) {
    return DiffLine('${ops.length} שינויים');
  }
  // §9 — grouped-by-kind, in the stable enum order for a deterministic string.
  final frags = <String>[
    for (final kind in ConfigOpKind.values)
      if (counts[kind] != null)
        '${_kindEmoji(kind)} ${counts[kind]} ${_kindPlural(kind, styleAllColor)}',
  ];
  return DiffLine(frags.join(' · '));
}

/// The scannable emoji for a kind's grouped summary (§9). Legacy-flavoured, matching
/// the app's emoji-heavy Hebrew UI.
String _kindEmoji(ConfigOpKind kind) => switch (kind) {
      ConfigOpKind.setText => '✏️',
      ConfigOpKind.setEmoji => '🙂',
      ConfigOpKind.setHidden => '🙈',
      ConfigOpKind.setOrder => '↕️',
      ConfigOpKind.setStyle => '🎨',
      ConfigOpKind.setAction => '⚙️',
    };

/// The Hebrew plural noun for a kind's grouped count (§9). A SetStyle group is
/// "צבעים" only when [styleAllColor] (every op is a color change), else "עיצובים".
String _kindPlural(ConfigOpKind kind, bool styleAllColor) => switch (kind) {
      ConfigOpKind.setText => 'טקסטים',
      ConfigOpKind.setEmoji => 'אמוג׳ים',
      ConfigOpKind.setHidden => 'הסתרות',
      ConfigOpKind.setOrder => 'שינויי סדר',
      ConfigOpKind.setStyle => styleAllColor ? 'צבעים' : 'עיצובים',
      ConfigOpKind.setAction => 'פעולות',
    };

// ─── per-op Hebrew rows (small diff) ─────────────────────────────────────────

/// The human Hebrew line for ONE op — the target id plus the axis it edits, using
/// the action catalog's `he` for a `SetAction` and the §10 before→after for a
/// constrained `SetStyle(color)`. Exhaustive over the sealed family; always non-empty.
String _heForOp(ConfigOp op, RegistryView registry) => switch (op) {
      SetText() => 'שינוי טקסט: ${op.id}',
      SetEmoji() => 'שינוי אמוג׳י: ${op.id}',
      SetHidden(:final hidden) => hidden == null
          ? 'שינוי נראות: ${op.id}'
          : (hidden ? 'הסתרה: ${op.id}' : 'הצגה: ${op.id}'),
      SetOrder(:final order) => order == null
          ? 'שינוי סדר: ${op.id}'
          : 'שינוי סדר: ${op.id} ← $order', // before→after: the new position
      SetStyle(:final style) => _styleHe(op.id, style, registry),
      SetAction(:final action) => action == null
          ? 'ניקוי פעולה: ${op.id}'
          : 'פעולה: ${actionHe(action.kind) ?? action.kind}',
    };

/// The Hebrew line for a `SetStyle`. A color change renders the precise new color
/// (§10 before→after) when the registry CONSTRAINS the token
/// (`allowedValues(id,'color')` contains it) — best-effort, skipped otherwise; a
/// non-color style change is the generic "שינוי עיצוב".
String _styleHe(String id, CfgStyle? style, RegistryView registry) {
  final token = style?.colorToken;
  if (token == null) return 'שינוי עיצוב: $id';
  // §10 — precise only when the registry vouches for the token (skip when unknown).
  if (registry.allowedValues(id, 'color').contains(token)) {
    return 'שינוי צבע: $id ← ${_colorHe(token)}';
  }
  return 'שינוי צבע: $id';
}

/// The Hebrew name for a `BsTokens` color token (§10 before→after). An unrecognised
/// token degrades to itself (never throws). Mirrors the owner-facing color vocabulary.
String _colorHe(String token) => switch (token) {
      'success' => 'ירוק',
      'danger' => 'אדום',
      'warn' => 'כתום',
      'muted' => 'אפור',
      'ink' => 'כהה',
      'brand' => 'מותג',
      'brandDark' => 'מותג כהה',
      _ => token,
    };
