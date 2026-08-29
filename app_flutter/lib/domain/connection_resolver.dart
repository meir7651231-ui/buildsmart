// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 39 — the pure
// trade-agnostic connection RESOLVER (no UI).
//
// Pure rule-evaluation resolver: the engine stops "knowing physics"
// (install_engine.dart's hand-coded `connectionMethodLabel` / `directMatesWith`
// branches) and starts evaluating AUTHORED rules (connection_schema.dart,
// seeded for plumbing at steps 37-38). NO live call-site until step 41
// (flag-gated delegation) — nothing outside this file's test imports it, so
// zero regression today. Plumbing's hard-coded branch is NEVER replaced (R1-2).
//
// Deterministic by construction: same input → same output. The end-pair
// iteration generalizes the legacy `connectionMethodLabel` order EXACTLY
// (a.ends outer, b.ends inner, FIRST match wins — install_engine.dart:90-109);
// rules are scanned in authored list order; end-pair results are memoized per
// `'$aTypeId|$aSize|$bTypeId|$bSize'` key (plan §6). Everything stays
// O(ends × rules). No randomness, no DateTime, no I/O, no print. All
// user-facing text flows from the AUTHORED data (methodLabelHe / whyHe /
// requiredInterposerWhyHe) — this file introduces no strings of its own.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/domain/connection_schema.dart';
import 'package:flutter/foundation.dart';

/// Normalizes a size string for comparison (plan §4): strips every inch mark
/// (`"`, U+0022 — trailing OR embedded) and trims surrounding whitespace, so
/// `'1/2'` == `'1/2"'` == `' 1/2" '`. Stripping happens before the trim so a
/// quote that leaves edge whitespace behind (`'1/2 "'`) still normalizes to
/// `'1/2'`. Used for ALL size comparisons ([SizeMatch.exactSame] and
/// [SizeMatch.tableLookup] cells alike).
String normalizeSize(String s) => s.replaceAll('"', '').trim();

/// The outcome of evaluating one product-pair (or end-pair) against the
/// authored [CompatibilityRule]s.
///
/// Decision table (exactly three shapes):
///
/// | case                                   | mates | methodLabelHe        | severity          | rule            |
/// |----------------------------------------|-------|----------------------|-------------------|-----------------|
/// | a rule matched (type-pair + size OK)   | true  | rule.methodLabelHe   | null              | the matched rule|
/// | a pair-rule existed but size failed    | false | ''                   | rule.onMismatch   | that rule       |
/// | NO rule matched the type-pair at all   | false | ''                   | null              | null            |
///
/// "No rule" is a documented "doesn't connect", not an exception. [rule] is
/// the matched/considered rule back-reference — the plan's `explain()`
/// (addition A): callers can surface WHY (`rule.methodLabelHe`,
/// `rule.onMismatch`, `rule.id`) without re-deriving anything.
@immutable
class ConnectResult {
  const ConnectResult({
    required this.mates,
    required this.methodLabelHe,
    this.severity,
    this.rule,
  });

  /// Whether the two specs (or ends) physically mate under some authored rule.
  final bool mates;

  /// The matched rule's authored joint label (Hebrew); `''` when [mates] is
  /// false.
  final String methodLabelHe;

  /// Null on success and on "no rule at all"; the considered rule's
  /// [CompatibilityRule.onMismatch] when a pair-rule existed but its size
  /// check failed.
  final RuleSeverity? severity;

  /// The matched rule (on success) or the first pair-matching rule whose size
  /// check failed (on a size-miss); null when no rule covers the type-pair.
  final CompatibilityRule? rule;

  @override
  bool operator ==(Object other) =>
      other is ConnectResult &&
      other.mates == mates &&
      other.methodLabelHe == methodLabelHe &&
      other.severity == severity &&
      other.rule == rule;

  @override
  int get hashCode => Object.hash(mates, methodLabelHe, severity, rule);
}

/// One completion finding: [rule] fired against the line, with the resolved
/// user-facing reason ([whyHe]), the rule's [severity], and the offending
/// skus in line order.
@immutable
class CompletionIssue {
  const CompletionIssue({
    required this.rule,
    required this.whyHe,
    required this.severity,
    required this.offendingSkus,
  });

  final CompletionRule rule;

  /// Authored reason — [CompletionRule.requiredInterposerWhyHe] (when the
  /// MATERIAL shape fired and it is non-null) falling back to
  /// [CompletionRule.whyHe].
  final String whyHe;

  final RuleSeverity severity;

  /// The skus that triggered the rule, in line order (deterministic).
  final List<String> offendingSkus;

  @override
  bool operator ==(Object other) =>
      other is CompletionIssue &&
      other.rule == rule &&
      other.whyHe == whyHe &&
      other.severity == severity &&
      listEquals(other.offendingSkus, offendingSkus);

  @override
  int get hashCode =>
      Object.hash(rule, whyHe, severity, Object.hashAll(offendingSkus));
}

/// Whether a line sticks to a single authored system (plan addition B) —
/// e.g. supply parts never mixed into a drainage line.
@immutable
class SystemCoherence {
  const SystemCoherence({
    required this.coherent,
    this.offendingSystem,
    this.offendingSku,
  });

  /// True when at most one distinct non-null systemId appears across the
  /// line's ends (unknown/system-less connector types are ignored).
  final bool coherent;

  /// The [SystemDef] of the differing systemId — null when [coherent], and
  /// ALSO null when the differing systemId has no [SystemDef] in the
  /// resolver's `systems` (the line is still incoherent).
  final SystemDef? offendingSystem;

  /// The FIRST sku (line order) carrying an end whose system differs from the
  /// first-seen system; null when [coherent].
  final String? offendingSku;

  @override
  bool operator ==(Object other) =>
      other is SystemCoherence &&
      other.coherent == coherent &&
      other.offendingSystem == offendingSystem &&
      other.offendingSku == offendingSku;

  @override
  int get hashCode => Object.hash(coherent, offendingSystem, offendingSku);
}

/// The pure, trade-agnostic rule evaluator. Constructed from authored data
/// only; holds no engine/physics knowledge and performs no I/O. The provided
/// lists are treated as frozen authored data (they are not copied) — mutating
/// them after construction would break the memo's determinism contract.
class ConnectionResolver {
  ConnectionResolver({
    required this.rules,
    this.connectorTypes = const [],
    this.systems = const [],
    this.completionRules = const [],
  });

  /// Authored pair rules, scanned in LIST ORDER (authored order is the
  /// tie-breaker — deterministic).
  final List<CompatibilityRule> rules;

  final List<ConnectorType> connectorTypes;

  final List<SystemDef> systems;

  final List<CompletionRule> completionRules;

  /// End-pair memo (plan §6), keyed `'$aTypeId|$aSize|$bTypeId|$bSize'` with
  /// the RAW (un-normalized) size values — normalization happens inside the
  /// evaluation, so identical raw inputs always hit the same entry. Populated
  /// lazily; pure evaluation makes the cached value indistinguishable from a
  /// fresh one.
  final Map<String, ConnectResult> _memo = <String, ConnectResult>{};

  /// connectorTypeId → systemId (nullable), from the authored
  /// [connectorTypes]. Built lazily once; on duplicate ids the LAST entry
  /// wins (map-literal semantics — still deterministic).
  late final Map<String, String?> _systemIdByTypeId = <String, String?>{
    for (final t in connectorTypes) t.id: t.systemId,
  };

  /// systemId → [SystemDef], from the authored [systems].
  late final Map<String, SystemDef> _systemById = <String, SystemDef>{
    for (final s in systems) s.id: s,
  };

  static const ConnectResult _noRule =
      ConnectResult(mates: false, methodLabelHe: '');

  /// Can product [a] connect to product [b]?
  ///
  /// Deterministic generalization of the legacy `connectionMethodLabel`
  /// iteration (install_engine.dart:90-109): for each `endA` in `a.ends` (in
  /// order), for each `endB` in `b.ends` (in order), evaluate the end-pair
  /// (memoized); the FIRST result with `mates == true` wins and returns.
  /// If none mates: the first size-miss (a pair-rule existed but its size
  /// check failed — non-null severity) is returned if any occurred, else the
  /// no-rule result (`mates:false, severity:null` — a documented "doesn't
  /// connect", never an exception). Products with no ends therefore simply
  /// don't connect.
  ConnectResult canConnect(ProductConnectorSpec a, ProductConnectorSpec b) {
    ConnectResult? firstMiss;
    for (final endA in a.ends) {
      for (final endB in b.ends) {
        final r = _endPairMemoized(endA, endB);
        if (r.mates) return r;
        if (firstMiss == null && r.severity != null) firstMiss = r;
      }
    }
    return firstMiss ?? _noRule;
  }

  ConnectResult _endPairMemoized(ProductEnd endA, ProductEnd endB) {
    final key = '${endA.connectorTypeId}|${endA.sizeValue}'
        '|${endB.connectorTypeId}|${endB.sizeValue}';
    return _memo.putIfAbsent(key, () => _endPair(endA, endB));
  }

  /// Evaluates one end-pair against [rules] in list order.
  ///
  /// A rule matches the pair in FORWARD orientation when
  /// `rule.aTypeId == endA.connectorTypeId && rule.bTypeId == endB.connectorTypeId`,
  /// or in REVERSE orientation when the ids match swapped. (A same-type rule
  /// matches as forward — the orientations coincide.) The first rule that
  /// matches the pair AND passes its size check wins. A rule that matches the
  /// pair but FAILS its size check does not stop the scan — a later rule may
  /// still mate the pair; if none does, the FIRST such size-miss rule shapes
  /// the returned miss (`severity: rule.onMismatch`).
  ConnectResult _endPair(ProductEnd endA, ProductEnd endB) {
    CompatibilityRule? firstSizeMiss;
    for (final rule in rules) {
      final forward = rule.aTypeId == endA.connectorTypeId &&
          rule.bTypeId == endB.connectorTypeId;
      final reverse = !forward &&
          rule.aTypeId == endB.connectorTypeId &&
          rule.bTypeId == endA.connectorTypeId;
      if (!forward && !reverse) continue;
      if (_sizeOk(rule, endA, endB, forward: forward)) {
        return ConnectResult(
          mates: true,
          methodLabelHe: rule.methodLabelHe,
          rule: rule,
        );
      }
      firstSizeMiss ??= rule;
    }
    if (firstSizeMiss != null) {
      return ConnectResult(
        mates: false,
        methodLabelHe: '',
        severity: firstSizeMiss.onMismatch,
        rule: firstSizeMiss,
      );
    }
    return _noRule;
  }

  /// Size check per `rule.sizeMatch`, all comparisons via [normalizeSize].
  ///
  /// ORIENTATION RULE for [SizeMatch.tableLookup]: `rule.sizeTable` rows are
  /// `[aSize, bSize]` pairs in the rule's STATED `(aTypeId, bTypeId)`
  /// orientation — whichever end plays `aTypeId` supplies column 0. So in
  /// forward orientation we look up `[endA.size, endB.size]`; when the rule
  /// matched in REVERSE orientation we look up `[endB.size, endA.size]`
  /// accordingly. Rows shorter than 2 cells (tolerant-decoder debris) are
  /// skipped; a null table under tableLookup never matches.
  bool _sizeOk(
    CompatibilityRule rule,
    ProductEnd endA,
    ProductEnd endB, {
    required bool forward,
  }) {
    switch (rule.sizeMatch) {
      case SizeMatch.exactSame:
        return normalizeSize(endA.sizeValue) == normalizeSize(endB.sizeValue);
      case SizeMatch.anyToAny:
        return true;
      case SizeMatch.tableLookup:
        final table = rule.sizeTable;
        if (table == null) return false;
        final aSide = normalizeSize(forward ? endA.sizeValue : endB.sizeValue);
        final bSide = normalizeSize(forward ? endB.sizeValue : endA.sizeValue);
        for (final row in table) {
          if (row.length < 2) continue;
          if (normalizeSize(row[0]) == aSide &&
              normalizeSize(row[1]) == bSide) {
            return true;
          }
        }
        return false;
    }
  }

  /// Evaluates every [CompletionRule] against the [line], in rule list order;
  /// offending skus are reported in line order. A rule carries one (or, in
  /// principle, both) of two shapes — each shape that fires appends its own
  /// issue, MATERIAL first, then TYPE (deterministic):
  ///
  /// 1. MATERIAL shape (`incompatibleMaterialGroups` non-null/non-empty —
  ///    the plumbing seed's galvanic rule, which has EMPTY type fields):
  ///    collect the line's non-null `materialGroupId` set; when ≥2 DISTINCT
  ///    groups of the rule's listed groups are present together, the rule
  ///    fires. `offendingSkus` = the skus carrying those present groups;
  ///    `whyHe` = `requiredInterposerWhyHe ?? whyHe`.
  /// 2. TYPE shape (`whenInLineHasTypeId` non-empty): when any end in the
  ///    line has the trigger type AND no end has `requireTypeId` (checked
  ///    literally — an authored empty `requireTypeId` matches no end, so the
  ///    trigger alone fires the rule), the rule fires. `offendingSkus` = the
  ///    skus carrying the trigger type; `whyHe` = `whyHe`.
  List<CompletionIssue> completion(List<ProductConnectorSpec> line) {
    final presentGroups = <String>{
      for (final spec in line)
        if (spec.materialGroupId != null) spec.materialGroupId!,
    };
    final issues = <CompletionIssue>[];
    for (final rule in completionRules) {
      // (1) MATERIAL shape.
      final groups = rule.incompatibleMaterialGroups;
      if (groups != null && groups.isNotEmpty) {
        final hit = <String>{
          for (final g in groups)
            if (presentGroups.contains(g)) g,
        };
        if (hit.length >= 2) {
          issues.add(
            CompletionIssue(
              rule: rule,
              whyHe: rule.requiredInterposerWhyHe ?? rule.whyHe,
              severity: rule.severity,
              offendingSkus: [
                for (final spec in line)
                  if (spec.materialGroupId != null &&
                      hit.contains(spec.materialGroupId))
                    spec.productSku,
              ],
            ),
          );
        }
      }
      // (2) TYPE shape.
      if (rule.whenInLineHasTypeId.isNotEmpty) {
        final triggerSkus = <String>[
          for (final spec in line)
            if (spec.ends.any(
              (e) => e.connectorTypeId == rule.whenInLineHasTypeId,
            ))
              spec.productSku,
        ];
        if (triggerSkus.isNotEmpty) {
          final hasRequired = line.any(
            (spec) => spec.ends.any(
              (e) => e.connectorTypeId == rule.requireTypeId,
            ),
          );
          if (!hasRequired) {
            issues.add(
              CompletionIssue(
                rule: rule,
                whyHe: rule.whyHe,
                severity: rule.severity,
                offendingSkus: triggerSkus,
              ),
            );
          }
        }
      }
    }
    return issues;
  }

  /// Does the [line] stay inside ONE authored system? (Plan addition B.)
  ///
  /// Each end's `connectorTypeId` maps to its [ConnectorType.systemId] via
  /// the constructor's [connectorTypes]; ends are visited in line order
  /// (specs in order, each spec's ends in order). Ends whose type is unknown
  /// or carries a null systemId are ignored. If more than one distinct
  /// non-null systemId appears, the line is incoherent: `offendingSku` is the
  /// FIRST sku (line order) carrying an end whose system differs from the
  /// first-seen system, and `offendingSystem` is that differing systemId's
  /// [SystemDef] (null when absent from [systems] — still incoherent).
  SystemCoherence systemCoherence(List<ProductConnectorSpec> line) {
    String? firstSystemId;
    for (final spec in line) {
      for (final end in spec.ends) {
        final sysId = _systemIdByTypeId[end.connectorTypeId];
        if (sysId == null) continue;
        if (firstSystemId == null) {
          firstSystemId = sysId;
        } else if (sysId != firstSystemId) {
          return SystemCoherence(
            coherent: false,
            offendingSystem: _systemById[sysId],
            offendingSku: spec.productSku,
          );
        }
      }
    }
    return const SystemCoherence(coherent: true);
  }
}
