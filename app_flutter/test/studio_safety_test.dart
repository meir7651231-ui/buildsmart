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
}
