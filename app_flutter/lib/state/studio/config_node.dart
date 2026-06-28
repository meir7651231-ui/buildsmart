// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 1 — the per-element override value-objects.
//
// Three immutable nodes the No-Code config tree is built from:
//   • [CfgNode]   — one element's override across ALL axes (content/visibility/
//                   order/design/behavior). Every field nullable = "inherit".
//   • [CfgStyle]  — token-bounded design (no raw hex → a11y + theme-consistent).
//   • [CfgAction] — the behavior seam (Pillar-4 owns the catalog of kinds).
//
// A node with all-null = the IDENTITY (no override); it serialises to `{}` and is
// pruned on publish, so the document carries only real edits (sparse → scales to
// tens-of-thousands of ids, §11).
//
// Hand-rolled JSON — NO new pub dependency (gate 60), NO `uuid`/`equatable`:
//   • `toJson` omits nulls (sparse maps → small docs).
//   • `fromJson` is TOLERANT — unknown keys round-trip intact in [CfgNode.extra]
//     (forward-compat), an unknown enum-name falls back (never throws), and a
//     numeric that arrives as `int` is coerced to `double`.
//   • manual `==`/`hashCode` so `resolvedNodeProvider` can skip rebuilds when a
//     resolved node is unchanged.
//
// Canonical design: knowledge/studio-plan/01-config-engine-studio.md §2.1–2.3
// (+ RED-TEAM-R1/R2 merged). Pure value-objects — the only import is
// `foundation` for `@immutable`/`mapEquals` (not a new dependency). Inert until a
// wrapper consumes it; with `kStudioFlag` default-OFF there is no consumer, so
// adding this file is answer-equivalent / zero-regression by construction.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart' show immutable, mapEquals;

/// Soft upper bound for owner-authored text. **NOT enforced here** (enforcement is
/// step 27) — a single source of truth so the inspector + Pillar-4 share one cap.
const int kTextMaxLen = 280;

/// Padding step → resolved to `BsTokens.spaceN` at read-time by the wrappers.
enum EdgeKey { none, sm, md, lg }

/// Tolerant enum-by-name: returns the matching value, or `null` for anything
/// unknown/non-string. Never throws (trouble (ג) in the step-1 spec).
T? _enumByName<T extends Enum>(List<T> values, Object? raw) {
  if (raw is! String) return null;
  for (final v in values) {
    if (v.name == raw) return v;
  }
  return null;
}

/// Coerce a JSON number to a clamped font-scale (trouble (ד): JSON `int`→`double`).
/// Defensive clamp 0.8..1.6 so a corrupt stored value can't break layout.
double? _clampScale(Object? raw) {
  final v = (raw as num?)?.toDouble();
  return v == null ? null : v.clamp(0.8, 1.6).toDouble();
}

// ─── CfgStyle — token-bounded design ─────────────────────────────────────────

@immutable
class CfgStyle {
  const CfgStyle({
    this.colorToken,
    this.bgToken,
    this.fontScale,
    this.weightToken,
    this.sizeToken,
    this.pad,
  });

  /// Enum-name of an allowed `BsTokens` color (brand/ink/muted/…) — NOT raw hex.
  final String? colorToken;

  /// Allowed surface token.
  final String? bgToken;

  /// Multiplier of the resolved base size, clamped 0.8..1.6 (on read + here).
  final double? fontScale;

  /// {regular, medium, bold} → FontWeight.
  final String? weightToken;

  /// Type-scale step (typeBody/typeSubhead/…).
  final String? sizeToken;

  /// {none, sm, md, lg} → BsTokens.spaceN.
  final EdgeKey? pad;

  /// The no-override style (shared instance).
  static const CfgStyle identity = CfgStyle();

  /// True when no axis is set (so the parent node can treat it as absent).
  bool get isEmpty =>
      colorToken == null &&
      bgToken == null &&
      fontScale == null &&
      weightToken == null &&
      sizeToken == null &&
      pad == null;

  CfgStyle copyWith({
    String? colorToken,
    String? bgToken,
    double? fontScale,
    String? weightToken,
    String? sizeToken,
    EdgeKey? pad,
  }) =>
      CfgStyle(
        colorToken: colorToken ?? this.colorToken,
        bgToken: bgToken ?? this.bgToken,
        fontScale: fontScale ?? this.fontScale,
        weightToken: weightToken ?? this.weightToken,
        sizeToken: sizeToken ?? this.sizeToken,
        pad: pad ?? this.pad,
      );

  Map<String, dynamic> toJson() {
    final j = <String, dynamic>{};
    if (colorToken != null) j['colorToken'] = colorToken;
    if (bgToken != null) j['bgToken'] = bgToken;
    if (fontScale != null) j['fontScale'] = fontScale;
    if (weightToken != null) j['weightToken'] = weightToken;
    if (sizeToken != null) j['sizeToken'] = sizeToken;
    if (pad != null) j['pad'] = pad!.name;
    return j;
  }

  factory CfgStyle.fromJson(Map<String, dynamic> j) => CfgStyle(
        colorToken: j['colorToken'] as String?,
        bgToken: j['bgToken'] as String?,
        fontScale: _clampScale(j['fontScale']),
        weightToken: j['weightToken'] as String?,
        sizeToken: j['sizeToken'] as String?,
        pad: _enumByName(EdgeKey.values, j['pad']),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CfgStyle &&
          other.colorToken == colorToken &&
          other.bgToken == bgToken &&
          other.fontScale == fontScale &&
          other.weightToken == weightToken &&
          other.sizeToken == sizeToken &&
          other.pad == pad;

  @override
  int get hashCode =>
      Object.hash(colorToken, bgToken, fontScale, weightToken, sizeToken, pad);
}

// ─── CfgAction — behavior seam (Pillar-4 owns the kinds) ─────────────────────

@immutable
class CfgAction {
  const CfgAction({required this.kind, this.args = const {}});

  /// e.g. 'navigate' | 'openSheet' | 'noop'. The engine ships only 'noop' + a
  /// guarded 'navigate'; Pillar-4 registers the rest via `cfgActionRegistryProvider`.
  final String kind;

  /// kind-specific payload, opaque to the engine.
  final Map<String, dynamic> args;

  CfgAction copyWith({String? kind, Map<String, dynamic>? args}) =>
      CfgAction(kind: kind ?? this.kind, args: args ?? this.args);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': kind,
        if (args.isNotEmpty) 'args': args,
      };

  factory CfgAction.fromJson(Map<String, dynamic> j) => CfgAction(
        kind: (j['kind'] as String?) ?? 'noop',
        args: _strKeyed(j['args']),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CfgAction && other.kind == kind && mapEquals(other.args, args);

  @override
  int get hashCode => Object.hash(kind, Object.hashAllUnordered(args.keys));
}

// ─── CfgNode — one element, all axes optional ────────────────────────────────

@immutable
class CfgNode {
  const CfgNode({
    this.text,
    this.emoji,
    this.hidden,
    this.order,
    this.style,
    this.action,
    this.extra = const {},
  });

  // ── CONTENT ──
  final String? text;
  final String? emoji;

  // ── VISIBILITY ──
  final bool? hidden; // true = hide (null = show)

  // ── ORDER ── (within a CfgList parent)
  final int? order;

  // ── DESIGN ──
  final CfgStyle? style;

  // ── BEHAVIOR ──
  final CfgAction? action;

  /// Forward-compat: any keys we don't recognise round-trip here intact.
  final Map<String, dynamic> extra;

  /// The no-override node (shared instance) — the merge identity.
  static const CfgNode identity = CfgNode();

  /// True when the node carries no override on any axis (the identity contract).
  /// Empty nodes are pruned on publish + short-circuit the merge.
  bool get isEmpty =>
      text == null &&
      emoji == null &&
      hidden == null &&
      order == null &&
      (style == null || style!.isEmpty) &&
      action == null &&
      extra.isEmpty;

  CfgNode copyWith({
    String? text,
    String? emoji,
    bool? hidden,
    int? order,
    CfgStyle? style,
    CfgAction? action,
    Map<String, dynamic>? extra,
  }) =>
      CfgNode(
        text: text ?? this.text,
        emoji: emoji ?? this.emoji,
        hidden: hidden ?? this.hidden,
        order: order ?? this.order,
        style: style ?? this.style,
        action: action ?? this.action,
        extra: extra ?? this.extra,
      );

  Map<String, dynamic> toJson() {
    // Forward-compat keys first; known axes never collide (fromJson strips them
    // out of `extra`), so a real unknown key is never clobbered.
    final j = <String, dynamic>{...extra};
    if (text != null) j['text'] = text;
    if (emoji != null) j['emoji'] = emoji;
    if (hidden != null) j['hidden'] = hidden;
    if (order != null) j['order'] = order;
    if (style != null && !style!.isEmpty) j['style'] = style!.toJson();
    if (action != null) j['action'] = action!.toJson();
    return j;
  }

  static const Set<String> _known = {
    'text',
    'emoji',
    'hidden',
    'order',
    'style',
    'action',
  };

  factory CfgNode.fromJson(Map<String, dynamic> j) {
    final styleJson = j['style'];
    final actionJson = j['action'];
    return CfgNode(
      text: j['text'] as String?,
      emoji: j['emoji'] as String?,
      hidden: j['hidden'] as bool?,
      order: (j['order'] as num?)?.toInt(),
      style: styleJson is Map ? CfgStyle.fromJson(_strKeyed(styleJson)) : null,
      action:
          actionJson is Map ? CfgAction.fromJson(_strKeyed(actionJson)) : null,
      // Everything we DON'T know survives here (unknown axes round-trip intact).
      extra: Map<String, dynamic>.from(j)
        ..removeWhere((k, _) => _known.contains(k)),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CfgNode &&
          other.text == text &&
          other.emoji == emoji &&
          other.hidden == hidden &&
          other.order == order &&
          other.style == style &&
          other.action == action &&
          mapEquals(other.extra, extra);

  @override
  int get hashCode => Object.hash(
        text,
        emoji,
        hidden,
        order,
        style,
        action,
        Object.hashAllUnordered(extra.keys),
      );
}

/// Tolerant string-keyed normalisation (the platform/JSON layer may hand back
/// `Map<Object?, Object?>`), mirroring the gateway repos' `_asMap`.
Map<String, dynamic> _strKeyed(Object? raw) {
  if (raw is Map) {
    return raw.map((k, v) => MapEntry(k.toString(), v));
  }
  return const <String, dynamic>{};
}
