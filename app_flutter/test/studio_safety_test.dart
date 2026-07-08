// Step 77 — `validateSafe`, the explicit SAFETY BACKSTOP above the grounding.
//
// This suite pins `logic/studio/edit_safety.dart` against the plan's DoD (§5/§8):
//   • a kImmutable element rejects EVERY op kind (§7.2);
//   • the criticalBusiness floor (R1-6): hide-price → blocked, relabel/hide the
//     "אשר הזמנה" control → blocked, a contrast-failing SetStyle on a critical
//     element → blocked;
//   • value legality (R1-9): a SetStyle(color) out-of-subset-for-kind → blocked,
//     an arbitrary hex (outside the palette) → blocked;
//   • action legality (§7.5): an action illegal for the element's context (and a
//     read-only element) → blocked;
//   • fail-closed: a missing descriptor → blocked;
//   • EVERY blocked entry carries a non-empty Hebrew reasonHe (§6);
//   • ANTI-VACUOUS: a legal op on a mutable element IS applied (the validator is
//     not just blocking everything).
//
// The seed `kElementRegistry` carries NO price / "אשר הזמנה" element, so those
// cases are exercised against test descriptors APPENDED to the frozen seed — the
// documented, fail-closed criticalBusiness derivation (id/labelHe), not a hard-
// coded id list. The default-registry path (no `registry:` arg) is covered too.
import 'package:buildsmart/logic/studio/edit_intent.dart' show kStudioMaxBatch;
import 'package:buildsmart/logic/studio/edit_safety.dart';
import 'package:buildsmart/state/studio/config_node.dart'
    show CfgAction, CfgStyle;
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/state/studio/element_registry.dart'
    show ElementDescriptor, ElementKind, kElementRegistry;
import 'package:flutter_test/flutter_test.dart';

// ── Test descriptors APPENDED to the frozen seed (the criticalBusiness set the
//    real registry deliberately lacks). Their criticalBusiness kind is DERIVED
//    from id/labelHe exactly as edit_safety.dart documents. ────────────────────
const _price = ElementDescriptor(
  id: 'shop.price.total',
  screen: 'cart',
  area: 'checkout',
  labelHe: 'מחיר כולל',
  kind: ElementKind.text,
  allowedValues: {
    'color': ['brand', 'ink'], // brand ≈ 2.6:1 on white (fails AA); ink ≈ 17:1
  },
);

const _confirm = ElementDescriptor(
  id: 'checkout.confirm',
  screen: 'cart',
  area: 'checkout',
  labelHe: 'אשר הזמנה',
  kind: ElementKind.action,
  allowedActions: ['cart.open'],
);

const _promoBtn = ElementDescriptor(
  id: 'promo.btn',
  screen: 'home',
  area: 'hero',
  labelHe: 'כפתור מבצע',
  kind: ElementKind.action,
  allowedActions: ['nav.cart'],
);

const List<ElementDescriptor> _reg = [
  ...kElementRegistry,
  _price,
  _confirm,
  _promoBtn,
];

SafetyVerdict _check(List<ConfigOp> ops) => validateSafe(ops, registry: _reg);

// ── Step-78 descriptors — the role-visibility floor set the seed lacks. Their floor
//    is DERIVED from `kRoleFloor` / `area` / `kind` exactly as edit_safety documents
//    (§9 addition-a — no hard-coded persona list). ────────────────────────────────
const _managerPanel = ElementDescriptor(
  id: 'manager.panel.revenue',
  screen: 'manager',
  area: 'cockpit',
  labelHe: 'פאנל הכנסות (מנהל)',
  kind: ElementKind.action, // NOT a container → not "structural"; floored to manager
  kRoleFloor: 'manager',
);

const _navTab = ElementDescriptor(
  id: 'shell.tabbar.home',
  screen: 'app',
  area: 'nav', // navigation surface — a GLOBAL hide orphans every persona
  labelHe: 'טאב בית',
  kind: ElementKind.container,
);

const List<ElementDescriptor> _reg78 = [
  ...kElementRegistry,
  _managerPanel,
  _navTab,
];

/// A tiny registry to isolate the registry-FRACTION ceiling: 0.25 × 4 = 1.0, so any
/// diff touching ≥ 2 distinct of these 4 ids is over the breadth ceiling.
const List<ElementDescriptor> _smallReg = [
  ElementDescriptor(
      id: 'a.one', screen: 's', area: 'x', labelHe: 'א', kind: ElementKind.text),
  ElementDescriptor(
      id: 'a.two', screen: 's', area: 'x', labelHe: 'ב', kind: ElementKind.text),
  ElementDescriptor(
      id: 'a.three', screen: 's', area: 'x', labelHe: 'ג', kind: ElementKind.text),
  ElementDescriptor(
      id: 'a.four', screen: 's', area: 'x', labelHe: 'ד', kind: ElementKind.text),
];

SafetyVerdict _check78(
  List<ConfigOp> ops, {
  String? persona,
  int priorSessionOps = 0,
}) =>
    validateSafe(
      ops,
      registry: _reg78,
      persona: persona,
      priorSessionOps: priorSessionOps,
    );

void main() {
  // ── §7.2 — a kImmutable element rejects EVERY op kind ───────────────────────
  group('kImmutable rejects all ops (§7.2)', () {
    const immutable = 'nav.bottombar'; // seeded kImmutable:true

    test('all six op kinds on an immutable id are blocked, none applied', () {
      final v = _check([
        const SetText(immutable, 'x'),
        const SetEmoji(immutable, '🔥'),
        const SetHidden(immutable, true),
        const SetOrder(immutable, 2),
        const SetStyle(immutable, CfgStyle(colorToken: 'ink')),
        const SetAction(immutable, CfgAction(kind: 'noop')),
      ]);
      expect(v.applied, isEmpty);
      expect(v.blocked, hasLength(6));
      for (final b in v.blocked) {
        expect(b.reasonHe, isNotEmpty);
      }
    });

    test('every one of the 5 seeded immutable ids rejects a benign op', () {
      for (final id in const [
        'auth.login.cta',
        'auth.logout',
        'nav.bottombar',
        'manager.entry',
        'studio.exit',
      ]) {
        final v = _check([SetText(id, 'שלום')]);
        expect(v.applied, isEmpty, reason: '$id should reject');
        expect(v.blocked.single.reasonHe, isNotEmpty);
      }
    });

    test('default-registry path also freezes a seeded immutable id', () {
      final v = validateSafe(const [SetHidden('nav.bottombar', true)]);
      expect(v.blocked, hasLength(1));
      expect(v.applied, isEmpty);
    });
  });

  // ── R1-6 — the criticalBusiness floor ───────────────────────────────────────
  group('criticalBusiness floor (R1-6)', () {
    test('hide-price → blocked ("אי-אפשר להסתיר מחיר")', () {
      final v = _check(const [SetHidden('shop.price.total', true)]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe, contains('מחיר'));
    });

    test('relabel "אשר הזמנה" → blocked', () {
      final v = _check(const [SetText('checkout.confirm', 'בטל')]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe, contains('אשר הזמנה'));
    });

    test('hide "אשר הזמנה" → blocked', () {
      final v = _check(const [SetHidden('checkout.confirm', true)]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe, contains('אשר הזמנה'));
    });

    test('contrast-failing SetStyle on a critical element → blocked', () {
      // `brand` is in the subset (passes R1-9) but ≈ 2.6:1 on white → below AA.
      final v = _check(const [
        SetStyle('shop.price.total', CfgStyle(colorToken: 'brand')),
      ]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe, contains('ניגודיות'));
    });
  });

  // ── R1-9 — SetStyle(color) value legality (per-element-kind subset) ─────────
  group('value legality (R1-9)', () {
    test("a real token OUT of this element's subset → blocked", () {
      // `danger` is a real BsTokens token but NOT in shop.price.total's subset.
      final v = _check(const [
        SetStyle('shop.price.total', CfgStyle(colorToken: 'danger')),
      ]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe, isNotEmpty);
    });

    test('an arbitrary hex (outside the palette) → blocked (no hex from model)', () {
      final v = _check(const [
        SetStyle('shop.price.total', CfgStyle(colorToken: '#ff00ff')),
      ]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe, isNotEmpty);
    });

    test('a color token on an element with NO subset → fail-closed blocked', () {
      // cart.cta populates no allowedValues['color'] in the seed → fail-closed.
      final v = _check(const [
        SetStyle('cart.cta', CfgStyle(colorToken: 'brand')),
      ]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe, isNotEmpty);
    });
  });

  // ── §7.5 — SetAction legality ───────────────────────────────────────────────
  group('action legality (§7.5)', () {
    test("an action illegal for the element's context → blocked", () {
      final v = _check(const [
        SetAction('promo.btn', CfgAction(kind: 'drop.database')),
      ]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe, contains('פעולה'));
    });

    test('any action on a read-only element (empty set) → fail-closed blocked', () {
      final v = _check(const [SetAction('cart.cta', CfgAction(kind: 'noop'))]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe, isNotEmpty);
    });
  });

  // ── fail-closed on a missing descriptor ─────────────────────────────────────
  test('a missing descriptor → fail-closed (blocked)', () {
    final v = _check(const [SetText('no.such.id.zzz', 'x')]);
    expect(v.applied, isEmpty);
    expect(v.blocked.single.reasonHe, isNotEmpty);
    // default registry too.
    final v2 = validateSafe(const [SetText('totally.invented', 'x')]);
    expect(v2.blocked, hasLength(1));
  });

  // ── §6 — every blocked entry carries a non-empty reasonHe ───────────────────
  test('EVERY blocked entry across mixed ops carries a non-empty reasonHe', () {
    final v = _check(const [
      SetHidden('nav.bottombar', true), // immutable
      SetHidden('shop.price.total', true), // hide-price
      SetText('checkout.confirm', 'x'), // relabel confirm
      SetStyle('shop.price.total', CfgStyle(colorToken: 'brand')), // contrast
      SetStyle('shop.price.total', CfgStyle(colorToken: 'danger')), // out-of-subset
      SetAction('promo.btn', CfgAction(kind: 'evil')), // illegal action
      SetText('no.such.id', 'x'), // missing descriptor
    ]);
    expect(v.applied, isEmpty);
    expect(v.blocked, hasLength(7));
    for (final b in v.blocked) {
      expect(b.reasonHe.trim(), isNotEmpty);
    }
  });

  // ── ANTI-VACUOUS — a legal op on a mutable element IS applied ───────────────
  group('anti-vacuous: legal ops are applied', () {
    test('a legal SetText on a mutable, non-critical element passes through', () {
      final v = _check(const [SetText('cart.cta', 'קנה עכשיו')]);
      expect(v.blocked, isEmpty);
      expect(v.applied, hasLength(1));
      expect(v.applied.single, isA<SetText>());
    });

    test('an in-subset, contrast-PASSING SetStyle on the price element applies', () {
      // `ink` is in the subset AND ≈ 17:1 on white → clears AA.
      final v = _check(const [
        SetStyle('shop.price.total', CfgStyle(colorToken: 'ink')),
      ]);
      expect(v.blocked, isEmpty);
      expect(v.applied, hasLength(1));
    });

    test("a legal action for the element's context applies", () {
      final v = _check(const [SetAction('promo.btn', CfgAction(kind: 'nav.cart'))]);
      expect(v.blocked, isEmpty);
      expect(v.applied, hasLength(1));
    });

    test('a mixed batch partitions correctly (some applied, some blocked)', () {
      final v = _check(const [
        SetText('cart.cta', 'קנה'), // applied
        SetHidden('shop.price.total', true), // blocked
        SetStyle('shop.price.total', CfgStyle(colorToken: 'ink')), // applied
      ]);
      expect(v.applied, hasLength(2));
      expect(v.blocked, hasLength(1));
      expect(v.allApplied, isFalse);
    });
  });

  // ── §10 תוספת-ב — the pure audit trail ──────────────────────────────────────
  group('audit trail (§10)', () {
    test('renders one dumpable line per blocked entry, carrying id + reason', () {
      final v = _check(const [SetHidden('shop.price.total', true)]);
      final trail = auditTrail(v);
      expect(trail, hasLength(1));
      expect(trail.single, contains('shop.price.total'));
      expect(trail.single, contains('setHidden'));
      expect(trail.single, contains('מחיר'));
      expect(renderAuditTrail(v), equals(trail.single));
    });

    test('an all-applied verdict has an empty audit trail', () {
      final v = _check(const [SetText('cart.cta', 'קנה')]);
      expect(v.allApplied, isTrue);
      expect(auditTrail(v), isEmpty);
      expect(renderAuditTrail(v), isEmpty);
    });
  });

  // ── Step 78 — role-visibility floor (R1-6 · §4 · §7.3) ──────────────────────
  group('role-visibility floor (step 78)', () {
    test("can't hide a manager-critical surface from `manager`", () {
      final v = _check78(
        const [SetHidden('manager.panel.revenue', true)],
        persona: 'manager', // hiding from the exact role it is floored to
      );
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe.trim(), isNotEmpty);
      expect(v.blocked.single.reasonHe, contains('manager'));
    });

    test('a manager-floored surface can\'t be hidden GLOBALLY either', () {
      // persona:null = the global layer → strips it from manager too → blocked.
      final v = _check78(const [SetHidden('manager.panel.revenue', true)]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe.trim(), isNotEmpty);
    });

    test("can't hide a nav/tab element from EVERY persona (incl contractor=null)",
        () {
      // persona defaults to null = the GLOBAL/contractor base every persona inherits.
      final v = _check78(const [SetHidden('shell.tabbar.home', true)]);
      expect(v.applied, isEmpty);
      expect(v.blocked.single.reasonHe, contains('ניווט'));
    });

    test('hiding a nav/tab from a SINGLE persona (others still see it) is LEGAL',
        () {
      final v = _check78(
        const [SetHidden('shell.tabbar.home', true)],
        persona: 'manager',
      );
      expect(v.blocked, isEmpty);
      expect(v.applied, hasLength(1));
      expect(v.applied.single, isA<SetHidden>());
    });

    test('ANTI-VACUOUS — a legal role-scoped hide IS applied', () {
      // cart.cta: default floor (contractor), non-structural → a single-persona hide
      // leaves it visible to others → applied (the floor is not just blocking all).
      final v = _check78(
        const [SetHidden('cart.cta', true)],
        persona: 'supplier',
      );
      expect(v.blocked, isEmpty);
      expect(v.applied, hasLength(1));
    });

    test('a GLOBAL hide of a mundane, non-structural element is legal', () {
      // productBadge: default floor, area "card", kind text → may be hidden app-wide.
      final v = _check78(const [SetHidden('catalog.card.productBadge', true)]);
      expect(v.blocked, isEmpty);
      expect(v.applied, hasLength(1));
    });
  });

  // ── Step 78 — batch / session / registry ceilings (§4 · R1-8) ───────────────
  group('scale ceilings (step 78)', () {
    test('over the per-utterance ceiling (kStudioMaxBatch) → whole batch blocked',
        () {
      // kStudioMaxBatch+1 ops on ONE id: distinct=1 (fraction can't preempt), so the
      // per-utterance ceiling is the trigger — reused from step 76, boundary intact.
      final ops = [
        for (var i = 0; i <= kStudioMaxBatch; i++) const SetText('cart.cta', 'x'),
      ];
      final v = _check78(ops);
      expect(v.applied, isEmpty);
      expect(v.blocked, hasLength(ops.length)); // nothing orphaned
      for (final b in v.blocked) {
        expect(b.reasonHe.trim(), isNotEmpty);
      }
      expect(v.blocked.first.reasonHe, contains('$kStudioMaxBatch'));
    });

    test('exactly kStudioMaxBatch ops on one id is UNDER the per-utterance ceiling',
        () {
      final ops = [
        for (var i = 0; i < kStudioMaxBatch; i++) const SetText('cart.cta', 'x'),
      ];
      final v = _check78(ops); // 25 == ceiling, not over; distinct=1, session ok
      expect(v.blocked, isEmpty);
      expect(v.applied, hasLength(kStudioMaxBatch));
    });

    test('over the cumulative session budget → whole batch blocked ("…לסשן")', () {
      final ops = [for (var i = 0; i < 5; i++) const SetText('cart.cta', 'x')];
      // prior 58 + 5 = 63 > 60; 5 ≤ 25 (per-utterance ok); distinct=1 (fraction ok).
      final v = _check78(ops, priorSessionOps: kStudioSessionBudget - 2);
      expect(v.applied, isEmpty);
      expect(v.blocked, hasLength(5));
      expect(v.blocked.first.reasonHe, contains('לסשן'));
    });

    test('under the session budget, a legal batch still applies', () {
      final ops = [for (var i = 0; i < 5; i++) const SetText('cart.cta', 'קנה')];
      final v = _check78(ops, priorSessionOps: 40); // 45 ≤ 60
      expect(v.blocked, isEmpty);
      expect(v.applied, hasLength(5));
    });

    test('a diff touching > kStudioMaxRegistryFraction of the registry → blocked',
        () {
      // 3 distinct of a 4-id registry → 3 > 0.25×4 → over the breadth ceiling. Only
      // 3 ops (per-utterance ok) and priorSessionOps=0 (session ok) → fraction fires.
      final v = validateSafe(
        const [
          SetText('a.one', 'x'),
          SetText('a.two', 'y'),
          SetText('a.three', 'z'),
        ],
        registry: _smallReg,
      );
      expect(v.applied, isEmpty);
      expect(v.blocked, hasLength(3));
      expect(v.blocked.first.reasonHe, contains('לסשן'));
    });

    test('EVERY blocked entry across a ceiling breach carries a non-empty reasonHe',
        () {
      final ops = [
        for (var i = 0; i <= kStudioMaxBatch; i++) const SetHidden('cart.cta', true),
      ];
      final v = _check78(ops);
      expect(v.applied, isEmpty);
      for (final b in v.blocked) {
        expect(b.reasonHe.trim(), isNotEmpty);
      }
    });
  });

  // ── Step 78 — §10 תוספת-א soft-warning (advisory, does NOT disturb the hard 25) ─
  group('soft-batch warning (§10, advisory only)', () {
    test('warns in [kStudioSoftBatchWarn, kStudioMaxBatch], null outside', () {
      expect(softBatchWarnHe(kStudioSoftBatchWarn - 1), isNull); // below → no nudge
      expect(softBatchWarnHe(kStudioSoftBatchWarn), isNotNull); // soft zone
      expect(softBatchWarnHe(kStudioMaxBatch), isNotNull); // still under hard block
      expect(softBatchWarnHe(kStudioMaxBatch + 1), isNull); // above = a hard BLOCK
    });

    test('the soft threshold sits strictly BELOW the committed hard ceiling', () {
      expect(kStudioSoftBatchWarn, lessThan(kStudioMaxBatch));
    });
  });
}
