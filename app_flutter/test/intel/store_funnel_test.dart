// Studio Pillar-3 · step 94 — the store FUNNEL events (cart_view / checkout_start
// / checkout_step), each an additive single `track(...)` at its live call-site.
// This suite proves the §8 DoD on the REAL store widgets:
//   1. cart_view fires EXACTLY ONCE when _CartView mounts (from initState's
//      post-frame callback, NOT build) and does NOT re-fire on a rebuild;
//   2. checkout_start fires once when the checkout sheet opens, carrying only the
//      scalar item_count + sum;
//   3. checkout_step fires on a delivery/payment CHANGE (via ref.listen, NOT
//      build), carrying step + the bare scalar enum value;
//   4. NO payment-detail prop ever rides a funnel event — checkout_step's `value`
//      is only the delivery-type / payment-method NAME, never a card number;
//   5. order_placed is NOT duplicated: the store emits it once via the telemetry
//      seam (untouched at store_screen.dart) and ZERO times into the intel log.
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/intel_log.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/telemetry.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Iterable<IntelEvent> _events(ProviderContainer c, String name) =>
    c.read(intelLogProvider).where((e) => e.name == name);

/// A recording TelemetrySink — proves the EXISTING G4 order_placed emit at
/// store_screen.dart still fires exactly once (never duplicated by step 94).
/// Mirrors intel_bus_test.dart's _RecordingTelemetrySink.
class _RecordingTelemetrySink implements TelemetrySink {
  final List<String> names = <String>[];

  @override
  bool get enabled => true;

  @override
  void logEvent(String name, {Map<String, Object>? params}) => names.add(name);

  @override
  void recordError(Object error, StackTrace? stack, {String? reason}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  // Seed one real cart line (a contractor "added a product"). brandPrice*qty is
  // the line total; this drives the cart subtotal/total like the catalog does.
  void seedCartLine(
    ProviderContainer c, {
    int brandPrice = 500,
    int qty = 4,
  }) {
    c.read(smartCartProvider.notifier).add(
          SmartCartLine(
            productKey: 'test-prod',
            productName: 'מוצר בדיקה',
            productEmoji: '🧱',
            brandName: 'מותג בדיקה',
            brandPrice: brandPrice,
            productQty: qty,
            accessories: const [],
          ),
        );
  }

  /// Pump the real store on the CART section under [c]. Roomy surface so the
  /// cart's horizontal rows never trip a cosmetic overflow (this suite is about
  /// events, not pixels). Section is set BEFORE the first frame so _CartView
  /// mounts (and cart_view fires) exactly once.
  Future<void> pumpCart(WidgetTester t, ProviderContainer c) async {
    await t.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => t.binding.setSurfaceSize(null));
    c.read(storeSectionProvider.notifier).state = StoreSection.cart;
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          locale: Locale('he'),
          home: Scaffold(body: StoreScreen()),
        ),
      ),
    );
    await settle(t);
  }

  ProviderContainer newContainer() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  // ── cart_view ──────────────────────────────────────────────────────────────
  testWidgets(
    'cart_view fires EXACTLY ONCE on mount (post-frame, not build) and does NOT '
    're-fire on a rebuild',
    (t) async {
      final c = newContainer();
      seedCartLine(c, brandPrice: 100, qty: 3); // item_count = 3
      await pumpCart(t, c);

      final views = _events(c, IntelEvents.cartView).toList();
      expect(views, hasLength(1));
      // Scalar item_count only (§4 allow-set {item_count}) — the unit count.
      expect(views.single.props, <String, String>{'item_count': '3'});

      // Force a GENUINE rebuild WITHOUT a remount (build watches cartProjectProvider).
      c.read(cartProjectProvider.notifier).state = 'פרויקט אחר';
      await settle(t);
      // initState ran once → still exactly one cart_view (no per-rebuild spam).
      expect(_events(c, IntelEvents.cartView), hasLength(1));
    },
  );

  // ── checkout_start ───────────────────────────────────────────────────────────
  testWidgets(
    'checkout_start fires once when the checkout sheet opens, carrying only the '
    'scalar item_count + sum',
    (t) async {
      final c = newContainer();
      seedCartLine(c); // default 4 × ₪500 = ₪2000 < ₪5000 → no min/large gate trips
      await pumpCart(t, c);

      final orderNow = find.textContaining('הזמן עכשיו');
      await t.ensureVisible(orderNow.first);
      await settle(t);
      await t.tap(orderNow.first);
      await settle(t);

      // The summary sheet opened → we reached _showCheckoutSheet (the emit site).
      expect(find.text('אישור הזמנה'), findsOneWidget);

      final starts = _events(c, IntelEvents.checkoutStart).toList();
      expect(starts, hasLength(1));
      final props = starts.single.props;
      // Only the allow-set keys, both scalar — no payment detail.
      expect(props.keys.toSet(), <String>{'item_count', 'sum'});
      expect(props['item_count'], '4');
      expect(int.parse(props['sum']!), greaterThan(0));
    },
  );

  // ── checkout_step ─────────────────────────────────────────────────────────────
  testWidgets(
    'checkout_step fires on a delivery + payment CHANGE (ref.listen, not build), '
    'carrying step + the bare scalar enum value — never a payment detail',
    (t) async {
      final c = newContainer();
      // Empty cart is fine: the ref.listen is registered at the top of build,
      // ahead of the empty-state early return.
      await pumpCart(t, c);

      // Default delivery = standard; change it → one checkout_step {delivery, pickup}.
      c.read(cartDeliveryProvider.notifier).state = CartDelivery.pickup;
      await settle(t);
      // Default payment = card; change it → one checkout_step {payment, bit}.
      c.read(cartPaymentProvider.notifier).state = CartPaymentMethod.bit;
      await settle(t);

      final steps = _events(c, IntelEvents.checkoutStep).toList();
      expect(steps, hasLength(2));

      final delivery = steps.firstWhere((e) => e.props['step'] == 'delivery');
      final payment = steps.firstWhere((e) => e.props['step'] == 'payment');
      expect(
        delivery.props,
        <String, String>{'step': 'delivery', 'value': 'pickup'},
      );
      expect(
        payment.props,
        <String, String>{'step': 'payment', 'value': 'bit'},
      );

      // §4 privacy invariant — NO funnel event carries a payment detail. Every
      // checkout_step `value` is one of the known scalar enum names, and never a
      // card-number-like digit run.
      final cardLike = RegExp(r'\d{4,}');
      for (final e in steps) {
        final v = e.props['value']!;
        expect(
          const <String>{
            'express',
            'standard',
            'pickup',
            'card',
            'bit',
            'supplierCredit',
          }.contains(v),
          isTrue,
          reason: 'value must be a scalar enum name, got "$v"',
        );
        expect(
          cardLike.hasMatch(v),
          isFalse,
          reason: 'a funnel prop must never look like a card number',
        );
      }
    },
  );

  // ── order_placed stays single ─────────────────────────────────────────────────
  testWidgets(
    'order_placed stays SINGLE: the store emits it once via the telemetry seam '
    'and ZERO times into the intel log (step 94 added no order_placed emit)',
    (t) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final telemetry = _RecordingTelemetrySink();
      final c = ProviderContainer(
        overrides: <Override>[telemetryProvider.overrideWithValue(telemetry)],
      );
      addTearDown(c.dispose);

      c.read(userProfileProvider.notifier).register(
            name: 'אבי הקבלן',
            contact: '050-1111111',
          );
      seedCartLine(c);
      await pumpCart(t, c);

      // Drive the FULL order via the real UI: open the checkout sheet, then confirm.
      final orderNow = find.textContaining('הזמן עכשיו');
      await t.ensureVisible(orderNow.first);
      await settle(t);
      await t.tap(orderNow.first);
      await settle(t);
      expect(find.text('אישור הזמנה'), findsOneWidget);
      await t.tap(find.text('אישור הזמנה'));
      await settle(t);

      // The G4 order_placed telemetry (store_screen.dart:~2846, untouched) fired
      // EXACTLY once — step 94 did NOT duplicate it.
      expect(
        telemetry.names.where((n) => n == IntelEvents.orderPlaced),
        hasLength(1),
      );
      // And NO intel order_placed was ever emitted: the funnel keys its conversion
      // on the telemetry event; it must never be re-emitted into the intel log.
      expect(_events(c, IntelEvents.orderPlaced), isEmpty);

      // Sanity — the funnel events step 94 DID add all landed during the flow.
      expect(_events(c, IntelEvents.cartView), hasLength(1));
      expect(_events(c, IntelEvents.checkoutStart), hasLength(1));
    },
  );
}
