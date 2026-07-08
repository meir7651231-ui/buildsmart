// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 4 · Step 77 — `validateSafe`: the explicit SAFETY
// BACKSTOP that sits ABOVE the step-71..76 grounding. Where the matchers/parse
// only guarantee "this string is a REAL registry key", THIS layer answers the
// harder question — "is it SAFE to let the owner do this at all?" — for the four
// harm classes the plan (§4/§7) enumerates: nav/auth immutability · the
// criticalBusiness floor (hide-price / relabel-or-hide "אשר הזמנה") · a WCAG-AA
// contrast collapse via a legitimate-but-wrong token · per-element value/action
// legality (no arbitrary hex, no action illegal for the element's context).
//
// ⚠️ ADVISORY ONLY — NOT A GUARANTEE (R1-1 · §1). This CLIENT `validateSafe` is a
// courtesy pre-check so the owner sees a Hebrew reason IMMEDIATELY; it is NOT the
// enforcement boundary. The IDENTICAL logic RE-RUNS SERVER-SIDE inside
// `publishConfig` before anything goes live — a config that passed here can still
// be rejected there (a stale client, a tampered request, a registry that moved).
// Treat a green verdict as "probably fine to preview", never as "authorised".
//
// ── ARCHITECTURE RECONCILIATION (documented per §2 · R1-2) ───────────────────
// The plan's signature is `validateSafe(List<ConfigOp>, RegistryView)`, but the
// FROZEN `RegistryView` seam (registry_view.dart) deliberately exposes only the
// grounding surface (`elementIds` / `propKeysFor` / `allowedValues` /
// `actionIdsFor` / `componentTypes`) — it does NOT surface `kImmutable`,
// `kRoleFloor` or `kind`. A safety backstop cannot be built on a view that hides
// the very governance flags it must enforce. Per §2 (R1-2 — "derived from the
// frozen P1 `ElementDescriptor`, fail-closed when missing"), this SAFETY layer is
// the ONE legitimate place that reads the CONCRETE descriptor: it imports
// `findDescriptor` + `kElementRegistry` and reads `kImmutable` / `kind` /
// `labelHe` directly, while KEEPING `RegistryView` as the seam for value/action
// grounding (`allowedValues(id,'color')` · `actionIdsFor(id)`). The two default to
// the SAME source (`ElementRegistryView(registry)`), so they can never disagree.
//   • FAIL-CLOSED: a target with NO descriptor is BLOCKED (never waved through) —
//     the vacuous-green trap R2-#15 closes, applied to authorization.
//
// ── criticalBusiness derivation (R1-6 · documented, fail-closed) ─────────────
// There is NO `kCriticalBusiness` field on the frozen descriptor, so the critical
// set is DERIVED (and the derivation is the contract): an element is critical iff
//   (a) `kImmutable` (nav/auth — the 5 seeded ids), OR
//   (b) it is a PRICE control        — `id` contains "price" or `labelHe` "מחיר", OR
//   (c) it is an ORDER-CONFIRM control — `labelHe` contains "אשר הזמנה"
//       (or an `id` like `confirmOrder`/`approveOrder`).
// The seed `kElementRegistry` contains NONE of (b)/(c), so the real registry stays
// clean; the floor only ever fires for a descriptor whose own metadata marks it —
// no hard-coded id list to drift. A missing/unclassifiable descriptor fails closed.
//
// ── the block rules (§4/§7) ──────────────────────────────────────────────────
//   • kImmutable target → BLOCK EVERY op (§7.2, whole-element freeze). The 5 seeded
//     ids (auth.login.cta · auth.logout · nav.bottombar · manager.entry ·
//     studio.exit) reject SetText/SetEmoji/SetHidden/SetOrder/SetStyle/SetAction
//     alike. Rationale is a live PRODUCT rule: "המנהל לא מתנתק / חשבון הבעלים —
//     אין התנתקות" (manager_dashboard_screen.dart:200-209) and the board-isolation
//     invariant (state/sys_chat.dart §2.5 — a shared store, but access is not).
//   • criticalBusiness PROP-LEVEL freeze (§9 תוספת-א — finer than all-or-nothing):
//     a price/confirm element stays editable in general, but its `visible`(hidden)
//     axis is LOCKED (SetHidden(true) → BLOCK "אי-אפשר להסתיר מחיר" / "…אשר הזמנה")
//     and a confirm control's `text` axis is LOCKED (relabel → BLOCK).
//   • CONTRAST (WCAG-AA) — a `SetStyle(color)` on a critical element whose token
//     drops the contrast ratio below 4.5:1 → BLOCK. Ratio = (Lₗᵢ+0.05)/(Lₗₒ+0.05)
//     over `Color.computeLuminance()` (dart:ui), foreground token vs the light
//     reference surface (BsTokens.cardLight `0xFFFFFFFF`, the same readability
//     contract test/studio/safety_test.dart pins). Computed HERE — never leaning on
//     the CI lint (#61/#64). (e.g. `brand`-on-white ≈ 2.6:1 is deliberately below
//     AA — the theme editor already warns; the backstop refuses it on a critical.)
//   • VALUE legality (R1-9) — a `SetStyle(color)` token is accepted ONLY if it is
//     in `allowedValues(id,'color')` (the per-element-kind subset of BsTokens); an
//     out-of-subset token / an arbitrary hex from the model → BLOCK. No hex ever.
//   • ACTION legality (§7.5) — a `SetAction` is accepted only if its identifier is
//     in `actionIdsFor(id)` ∪ the descriptor's `allowedActions`; a read-only /
//     unknown context (empty set) fails closed → BLOCK.
//
// Nothing is ever silently swallowed (§6/§7.8): every BLOCK carries a non-empty
// Hebrew `reasonHe` in [SafetyVerdict.blocked], SHOWN to the owner; and
// [renderAuditTrail] dumps the blocked list to a plain-text audit line for a future
// `visual_log` (§10 תוספת-ב) — a decision trail, no IO.
//
// DORMANT: pure functions over pure data — `dart:ui`'s `Color` is the ONLY heavy
// type (imported directly, NOT via material, to stay Widget-free); renders no widget
// tree, no gateway, no provider, Firebase-free. Nothing in `lib/` imports it yet ⇒
// tree-shaken out ⇒ byte-identical under every flag.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:ui' show Color;

import '../../state/studio/config_store.dart'
    show ConfigOp, SetAction, SetEmoji, SetHidden, SetOrder, SetStyle, SetText;
import '../../state/studio/element_registry.dart'
    show ElementDescriptor, ElementKind, findDescriptor, kElementRegistry;
import '../../theme/tokens.dart' show BsTokens;
import 'edit_intent.dart' show kStudioMaxBatch;
import 'registry_view.dart' show ElementRegistryView, RegistryView;

// ─── SafetyVerdict / BlockedEntry (§6) ───────────────────────────────────────

/// ONE blocked op + the non-empty Hebrew reason the owner is SHOWN (never a silent
/// drop — §6/§7.8). Also the unit of the pure audit trail (§10 תוספת-ב).
class BlockedEntry {
  const BlockedEntry(this.op, this.reasonHe);

  /// The op that was refused.
  final ConfigOp op;

  /// The human Hebrew reason — GUARANTEED non-empty by [validateSafe] (every path
  /// that appends a [BlockedEntry] passes a literal reason).
  final String reasonHe;
}

/// The partition [validateSafe] returns: the [applied] ops (safe to stage) and the
/// [blocked] ones (each with its [BlockedEntry.reasonHe]). The caller stages
/// `applied` and RENDERS `blocked` to the owner — nothing is dropped in silence.
class SafetyVerdict {
  const SafetyVerdict({required this.applied, required this.blocked});

  /// The ops that passed every backstop check (advisory — see the file header).
  final List<ConfigOp> applied;

  /// The refused ops, each carrying a non-empty Hebrew reason.
  final List<BlockedEntry> blocked;

  /// True ⇔ nothing was blocked.
  bool get allApplied => blocked.isEmpty;
}

// ─── constants ───────────────────────────────────────────────────────────────

/// The WCAG-AA minimum contrast ratio for normal text (§4). A critical element's
/// foreground must clear this against the reference surface.
const double kStudioMinContrast = 4.5;

/// The reference background the contrast check measures a critical element's
/// foreground token AGAINST — the app's light surface `BsTokens.cardLight`
/// (`0xFFFFFFFF`, the readability contract in test/studio/safety_test.dart), read
/// from the SSOT token so this file never re-hard-codes a hex (the color-ratchet).
const Color _kRefSurface = BsTokens.cardLight;

// ─── Step 78 · role-visibility floor + batch/session/registry ceilings ───────
// The step-77 backstop above answers "is this ONE op safe?"; step 78 adds the two
// BREADTH questions the plan (§4) names: "safe for WHOM?" (the role-visibility
// floor) and "safe at what SCALE?" (the batch / session / registry ceilings).
//
// ── ceiling reconciliation (§2/§10 prose is STALE — the committed value wins) ──
// Step 76 (edit_intent.dart) COMMITTED `kStudioMaxBatch = 25` as the PER-UTTERANCE
// broadcast ceiling, and its tests PIN the 25/26 boundary. The plan's prose still
// says "~80 · soft-40 · hard-80" — that predates the committed 25 and is NOT
// re-opened here. So this step:
//   • REUSES the committed `kStudioMaxBatch` (imported, never redefined) as the
//     hard per-utterance ceiling — the 25/26 boundary stays byte-identical;
//   • ADDS `kStudioSessionBudget` — the CUMULATIVE op budget across successive
//     utterances in ONE draft (per-utterance stays 25, but a long conversation
//     that keeps issuing near-ceiling batches is still bounded);
//   • ADDS `kStudioMaxRegistryFraction` — a breadth guard: a diff touching more
//     than this FRACTION of the whole registry is a "rewrite half the app"
//     broadcast (R1-8), refused regardless of the raw op count;
//   • keeps the §10 "soft-warning" as a SEPARATE, purely-advisory const
//     (`kStudioSoftBatchWarn`) that NEVER enters the block path — it cannot
//     disturb the committed hard 25.
// A ceiling breach fails CLOSED and WHOLE (mirrors step-76 `dryCountScope`): the
// entire batch is refused — every op returned in `blocked` with a Hebrew reason,
// none silently dropped — so the owner reduces the scope and retries. Advisory
// only: the server re-runs the IDENTICAL ceilings in `publishConfig` (R1-1).

/// CUMULATIVE op budget across utterances in ONE draft session — ADDITIVE to the
/// per-utterance [kStudioMaxBatch] (=25, unchanged). A draft whose prior ops + this
/// batch would exceed this is refused whole. Sane default; re-run server-side (R1-1).
const int kStudioSessionBudget = 60;

/// The breadth ceiling (R1-8): a diff touching MORE than this fraction of
/// `registry.elementIds().length` DISTINCT targets is a "rewrite half the app"
/// broadcast — refused whole. 0.25 = a quarter of the registry.
const double kStudioMaxRegistryFraction = 0.25;

/// §10 תוספת-א — a PURELY ADVISORY soft threshold (a UX "you're editing a lot"
/// nudge) that sits BELOW the hard per-utterance [kStudioMaxBatch]. It is NOT a
/// block and is NEVER read by [validateSafe]; [softBatchWarnHe] is its only reader,
/// kept separate precisely so it can never disturb the committed hard 25.
const int kStudioSoftBatchWarn = 15;

/// The canonical `roleProvider` base key: `null`/'' (the main app / contractor) maps
/// here. The `BsRole` enum OMITS contractor, so the role-visibility floor is computed
/// over the `roleProvider` STRING space (R1-3) — never that enum; `null` = contractor.
const String _kRoleContractor = 'contractor';

// ─── criticalBusiness classification (R1-6 · derived, fail-closed) ───────────

/// The two derived criticalBusiness kinds (beyond `kImmutable`) that carry a
/// prop-level floor. See the file header for the full derivation contract.
enum _CriticalKind { price, confirmOrder }

/// Classify [d] into a criticalBusiness kind, or `null` when it carries no floor.
/// Pure metadata read — `id` / `labelHe` only (no side-channel, no hard-coded list).
_CriticalKind? _criticalBusinessKind(ElementDescriptor d) {
  final id = d.id.toLowerCase();
  final label = d.labelHe;
  // (c) order-confirmation control — the plan's exact "אשר הזמנה" surface.
  if (label.contains('אשר הזמנה') ||
      id.contains('confirmorder') ||
      id.contains('approveorder')) {
    return _CriticalKind.confirmOrder;
  }
  // (b) price control.
  if (id.contains('price') || label.contains('מחיר')) {
    return _CriticalKind.price;
  }
  return null;
}

// ─── role-visibility floor (R1-6 · §4 · derived from the registry, §9 addition-a) ─
// The floor is read from the FROZEN descriptor (`kRoleFloor` in the `roleProvider`
// string space + the structural `area`/`kind` signal) — NOT a hard-coded persona
// list, so it tracks the registry as the model grows (§9 addition-a).

/// True when [d] is a NAVIGATION / structural surface (a nav bar / tab container)
/// whose GLOBAL hide would orphan the app for EVERY persona. Derived from the
/// registry (`area == 'nav'` or a container kind), never an id list.
bool _isNavStructural(ElementDescriptor d) =>
    d.area == 'nav' || d.kind == ElementKind.container;

/// The role-visibility floor for a `SetHidden(hidden:true)` on [d] applied to the
/// [persona] layer (`roleProvider` dialect — `null`/'' = the GLOBAL/contractor base
/// that EVERY persona inherits; a non-empty string = ONE persona's layer). Returns a
/// non-empty Hebrew reason to BLOCK, or `null` when the hide is legal. Two harms (§4):
///   • a GLOBAL hide (null persona) strips the element from EVERYONE incl contractor
///     — refused for a nav/tab surface, or for any element floored ABOVE contractor
///     (a role that MUST keep it would lose it);
///   • a SINGLE-persona hide is legal UNLESS it hides the element from the exact role
///     it is FLOORED to (a manager-critical surface hidden from `manager`). Hiding
///     from ONE persona while others keep it (§7.3) is the legal escape hatch.
String? _roleFloorBlock(ElementDescriptor d, String? persona) {
  final floor = d.kRoleFloor;
  final isGlobal = persona == null || persona.isEmpty; // null = every persona
  if (isGlobal) {
    if (_isNavStructural(d)) {
      return 'אי-אפשר להסתיר «${d.labelHe}» מכל הפרסונות (כולל קבלן) — '
          'רכיב ניווט חייב להישאר גלוי';
    }
    if (floor != _kRoleContractor) {
      return 'אי-אפשר להסתיר «${d.labelHe}» מכל הפרסונות — '
          'הרכיב חייב להישאר גלוי לתפקיד «$floor»';
    }
    return null; // a mundane, non-structural element MAY be hidden app-wide.
  }
  // SINGLE persona: legal unless we hide it from the very role it is critical for.
  if (persona == floor && floor != _kRoleContractor) {
    return 'אי-אפשר להסתיר «${d.labelHe}» מהתפקיד «$floor» — קריטי לתפקיד זה';
  }
  return null;
}

// ─── color / contrast helpers (§4 — no existing helper, per the plan) ────────

/// Resolve an owner-facing color TOKEN to its concrete [Color], or `null` for an
/// unknown token (e.g. a raw hex the model invented — which never resolves). Reads
/// the concrete colors straight from the `BsTokens` SSOT (mirrors the wrappers'
/// `cfgColorFromToken` vocabulary, widgets/studio/cfg_text.dart:21) — never a raw
/// hex here, so the safety layer stays widget-free AND clears the color-ratchet.
Color? _colorForToken(String? token) {
  switch (token) {
    case 'brand':
      return BsTokens.brand;
    case 'brandDark':
      return BsTokens.brandDark;
    case 'success':
      return BsTokens.success;
    case 'danger':
      return BsTokens.danger;
    case 'warn':
      return BsTokens.warnText;
    case 'ink':
      return BsTokens.inkLight;
    case 'muted':
      return BsTokens.mutedLight;
    default:
      return null;
  }
}

/// The WCAG contrast ratio between two colors: (L_lighter+0.05)/(L_darker+0.05),
/// each luminance from `dart:ui`'s `Color.computeLuminance()` (relative sRGB
/// luminance). Symmetric; ≥ 1.0. Pure.
double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

// ─── validateSafe — the backstop (§4) ────────────────────────────────────────

/// Partition [ops] into safe-to-stage vs blocked, checking EACH against the REAL
/// frozen descriptor metadata (see the file header for the reconciliation). Reads
/// `kImmutable` / `kind` / criticalBusiness / `kRoleFloor` from the concrete
/// descriptor and grounds value/action legality through [view] (defaulting to the
/// SAME source as [registry], so they never disagree). Pure, TOTAL, never throws.
///
/// [persona] is the `roleProvider`-dialect layer a `SetHidden` would apply to
/// (`null`/'' = the GLOBAL/contractor base every persona inherits; a non-empty
/// string = ONE persona's layer) — it drives the step-78 role-visibility floor.
/// [priorSessionOps] is the count of ops ALREADY staged in this draft session, so
/// the cumulative [kStudioSessionBudget] can be enforced across utterances. The
/// batch/session/registry ceilings are BATCH-LEVEL: a breach refuses the WHOLE
/// batch (every op → blocked) BEFORE the per-op backstop — nothing partial (§4).
///
/// ⚠️ ADVISORY (R1-1): a green verdict is NOT authorization — `publishConfig`
/// re-runs this server-side before anything goes live (see the file header).
SafetyVerdict validateSafe(
  List<ConfigOp> ops, {
  List<ElementDescriptor> registry = kElementRegistry,
  RegistryView? view,
  String? persona,
  int priorSessionOps = 0,
}) {
  final grounding = view ?? ElementRegistryView(registry);
  // ── Step 78 · BATCH-LEVEL ceilings FIRST — a breach fails CLOSED and WHOLE: the
  // entire batch is refused (every op → blocked with the Hebrew reason), so the
  // owner reduces the scope. Runs before the per-op backstop (nothing partial).
  final ceiling = _batchCeilingReason(ops, grounding, priorSessionOps);
  if (ceiling != null) {
    return SafetyVerdict(
      applied: const [],
      blocked: [for (final op in ops) BlockedEntry(op, ceiling)],
    );
  }
  final applied = <ConfigOp>[];
  final blocked = <BlockedEntry>[];
  for (final op in ops) {
    final reason = _reasonToBlock(op, registry, grounding, persona);
    if (reason == null) {
      applied.add(op);
    } else {
      blocked.add(BlockedEntry(op, reason));
    }
  }
  return SafetyVerdict(applied: applied, blocked: blocked);
}

/// The BATCH-LEVEL ceiling check (§4 · step 78) — a non-empty Hebrew reason when the
/// whole [ops] batch must be refused, or `null` when it is within every ceiling.
/// Order: per-utterance (the committed [kStudioMaxBatch]=25, REUSED not redefined) →
/// cumulative session budget → registry-breadth fraction. Fail-closed and WHOLE
/// (mirrors step-76 `dryCountScope`); an empty batch is vacuously fine.
String? _batchCeilingReason(
  List<ConfigOp> ops,
  RegistryView grounding,
  int priorSessionOps,
) {
  if (ops.isEmpty) return null;
  // 1 — PER-UTTERANCE ceiling: REUSE the step-76 committed value (never redefined),
  // so the 25/26 boundary its tests pin stays byte-identical.
  if (ops.length > kStudioMaxBatch) {
    return 'השינוי נרחב מדי — ${ops.length} פעולות (מעל התקרה '
        '$kStudioMaxBatch). צמצם את הטווח.';
  }
  // 2 — CUMULATIVE session budget across utterances in one draft.
  final cumulative = priorSessionOps + ops.length;
  if (cumulative > kStudioSessionBudget) {
    return 'השינוי נרחב מדי לסשן — $cumulative פעולות מצטברות '
        '(מעל $kStudioSessionBudget). צמצם.';
  }
  // 3 — REGISTRY-breadth fraction (R1-8): distinct targets vs the whole registry.
  final size = grounding.elementIds().length;
  final distinct = <String>{for (final op in ops) op.id}.length;
  if (size > 0 && distinct > size * kStudioMaxRegistryFraction) {
    final pct = (kStudioMaxRegistryFraction * 100).round();
    return 'השינוי נרחב מדי לסשן — נוגע ב-$distinct רכיבים '
        '(מעל $pct% מהמרשם). צמצם.';
  }
  return null;
}

/// §10 תוספת-א — a pure, ADVISORY Hebrew soft-warning for a batch that is large but
/// still UNDER the hard per-utterance ceiling ([kStudioSoftBatchWarn] ≤ n ≤
/// [kStudioMaxBatch]); `null` otherwise. NOT a block — a UX nudge only; [validateSafe]
/// never calls it, so it can never disturb the committed hard 25.
String? softBatchWarnHe(int opCount) =>
    (opCount >= kStudioSoftBatchWarn && opCount <= kStudioMaxBatch)
        ? 'שים לב — $opCount פעולות בבת אחת. אפשר להמשיך, או לצמצם.'
        : null;

/// The single-op backstop — returns a non-empty Hebrew reason to BLOCK, or `null`
/// when [op] is safe. FAIL-CLOSED: a missing descriptor / an unresolvable token /
/// an empty legal-action set all BLOCK.
String? _reasonToBlock(
  ConfigOp op,
  List<ElementDescriptor> registry,
  RegistryView grounding,
  String? persona,
) {
  // 0 — FAIL-CLOSED on a target the frozen registry doesn't know (R1-2).
  final d = findDescriptor(registry, op.id);
  if (d == null) {
    return 'רכיב לא מוכר במרשם — חסום מטעמי בטיחות (fail-closed)';
  }

  // 1 — kImmutable: the whole element is frozen; EVERY op is refused (§7.2). The
  // product rule is "המנהל לא מתנתק" (manager_dashboard_screen.dart:200-209) +
  // board-isolation (sys_chat.dart §2.5).
  if (d.kImmutable) {
    return 'רכיב נעול (ניווט/הזדהות) — «${d.labelHe}» אינו ניתן לעריכה';
  }

  final crit = _criticalBusinessKind(d);

  switch (op) {
    // 2 — criticalBusiness VISIBILITY freeze (§4 · §9 prop-level: only the `hidden`
    // axis is locked; the element stays otherwise editable) + the step-78 role-
    // visibility floor. The criticalBusiness reasons stay FIRST so their exact
    // strings (pinned by step-77 tests) are unchanged; the role floor layers after.
    case SetHidden(:final hidden):
      if (hidden ?? false) {
        if (crit == _CriticalKind.price) {
          return 'אי-אפשר להסתיר מחיר';
        }
        if (crit == _CriticalKind.confirmOrder) {
          return 'אי-אפשר להסתיר את פקד «אשר הזמנה»';
        }
        final floorReason = _roleFloorBlock(d, persona);
        if (floorReason != null) return floorReason;
      }
      return null;

    // 3 — a confirm control's LABEL is frozen too (§4 — no relabel of "אשר הזמנה").
    case SetText():
      if (crit == _CriticalKind.confirmOrder) {
        return 'אי-אפשר לשנות את התווית של «אשר הזמנה»';
      }
      return null;

    // 4 — SetStyle: value legality (R1-9, EVERY element) + contrast (critical only).
    case SetStyle(:final style):
      final token = style?.colorToken;
      if (token == null) return null; // non-color style axes carry no floor
      // R1-9 — the token MUST be in the per-element-kind color subset; an
      // out-of-subset token or an arbitrary hex from the model fails closed.
      if (!grounding.allowedValues(op.id, 'color').contains(token)) {
        return 'צבע «$token» אינו בתת-הקבוצה החוקית לרכיב מסוג ${d.kind.name}';
      }
      // WCAG-AA contrast on a critical element (a legitimate token can still be
      // unreadable in context — the exact "legal-but-harmful" trap §3 names).
      if (crit != null) {
        final c = _colorForToken(token);
        if (c == null) {
          return 'לא ניתן לאמת ניגודיות עבור צבע «$token» — חסום (fail-closed)';
        }
        final ratio = _contrastRatio(c, _kRefSurface);
        if (ratio < kStudioMinContrast) {
          return 'ניגודיות נמוכה מדי (${ratio.toStringAsFixed(1)}:1) על רכיב '
              'קריטי — מתחת ל-WCAG-AA ($kStudioMinContrast:1)';
        }
      }
      return null;

    // 5 — SetAction legality (§7.5): the identifier must be wireable onto this
    // element; a read-only / unknown context (empty set) fails closed.
    case SetAction(:final action):
      if (action == null) return null; // clearing the action axis is safe
      final legal = <String>{...grounding.actionIdsFor(op.id), ...d.allowedActions};
      if (legal.isEmpty) {
        return 'רכיב זה אינו מקבל פעולות (קריאה-בלבד) — הפעולה נחסמה';
      }
      if (!legal.contains(action.kind)) {
        return 'פעולה «${action.kind}» אינה חוקית לרכיב זה';
      }
      return null;

    // 6 — axes with no criticalBusiness floor beyond kImmutable (handled above).
    case SetEmoji():
    case SetOrder():
      return null;
  }
}

// ─── §10 תוספת-ב — pure audit trail (dumpable to a future visual_log) ────────

/// The op-tag for an audit line (mirrors P1's `toJson` `'op'` tag, no allocation).
String _opTag(ConfigOp op) => switch (op) {
      SetText() => 'setText',
      SetEmoji() => 'setEmoji',
      SetHidden() => 'setHidden',
      SetOrder() => 'setOrder',
      SetStyle() => 'setStyle',
      SetAction() => 'setAction',
    };

/// Render ONE blocked entry to a plain-text audit line — a decision trace, no IO.
String auditLine(BlockedEntry e) =>
    '⛔ ${_opTag(e.op)} · ${e.op.id} · ${e.reasonHe}';

/// The whole blocked list as audit lines (§10 תוספת-ב) — pure, dumpable to a future
/// `visual_log` (#107/#116). Empty when nothing was blocked.
List<String> auditTrail(SafetyVerdict verdict) =>
    [for (final e in verdict.blocked) auditLine(e)];

/// The audit trail joined into one newline-delimited block (convenience over
/// [auditTrail]). Pure — the caller decides where/whether to persist it.
String renderAuditTrail(SafetyVerdict verdict) => auditTrail(verdict).join('\n');
