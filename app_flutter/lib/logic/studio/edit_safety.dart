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
    show ElementDescriptor, findDescriptor, kElementRegistry;
import '../../theme/tokens.dart' show BsTokens;
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
/// `kImmutable` / `kind` / criticalBusiness from the concrete descriptor and grounds
/// value/action legality through [view] (defaulting to the SAME source as
/// [registry], so they never disagree). Pure, TOTAL, never throws.
///
/// ⚠️ ADVISORY (R1-1): a green verdict is NOT authorization — `publishConfig`
/// re-runs this server-side before anything goes live (see the file header).
SafetyVerdict validateSafe(
  List<ConfigOp> ops, {
  List<ElementDescriptor> registry = kElementRegistry,
  RegistryView? view,
}) {
  final grounding = view ?? ElementRegistryView(registry);
  final applied = <ConfigOp>[];
  final blocked = <BlockedEntry>[];
  for (final op in ops) {
    final reason = _reasonToBlock(op, registry, grounding);
    if (reason == null) {
      applied.add(op);
    } else {
      blocked.add(BlockedEntry(op, reason));
    }
  }
  return SafetyVerdict(applied: applied, blocked: blocked);
}

/// The single-op backstop — returns a non-empty Hebrew reason to BLOCK, or `null`
/// when [op] is safe. FAIL-CLOSED: a missing descriptor / an unresolvable token /
/// an empty legal-action set all BLOCK.
String? _reasonToBlock(
  ConfigOp op,
  List<ElementDescriptor> registry,
  RegistryView grounding,
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
    // axis is locked; the element stays otherwise editable).
    case SetHidden(:final hidden):
      if ((hidden ?? false) && crit == _CriticalKind.price) {
        return 'אי-אפשר להסתיר מחיר';
      }
      if ((hidden ?? false) && crit == _CriticalKind.confirmOrder) {
        return 'אי-אפשר להסתיר את פקד «אשר הזמנה»';
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
