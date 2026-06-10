// SHARED ORDERS ENGINE — the keystone that makes the app's data live across all
// roles. This is the Flutter/Riverpod port of the legacy `SYS_ORDERS` (a
// localStorage-backed array that every role's screen read & wrote, kept in sync
// via the browser `storage` event — @index.html:11965-12039, :16939-17035).
//
// Legacy reality being ported:
//   • SYS_ORDERS_SEED  @index.html:11970-12001 — the four seed orders.
//   • ORDER_FLOW       @index.html:16943       — the 6 ordered stages.
//   • mgrAdvanceOrder  @index.html:17022-17032 — "next stage in the flow".
//   • the contractor "place order" path that pushes a `{stage:'new'}` order.
//   • the manager "god-step" that can set an order to ANY stage.
//
// DATA LAYER ONLY: no widget reads this engine yet — wiring the 4-tab UI to it
// is a LATER wave. The manager derivations (`ManagerAnalytics` / `mgrCustomerList`
// in `logic/manager_dashboard.dart`) now compute over THIS engine's live orders;
// because the engine is SEEDED with the SAME four orders the seed carries, every
// existing manager number stays byte-for-byte identical (🚚 open=4, the 4
// customers, …). See `test/orders_engine_test.dart`.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:buildsmart/data/repositories/customers_local.dart';
import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/data/repositories/orders_local.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';

/// A single persisted line item captured at checkout and stored inside [Order].
/// Populated from `smartCartProvider` at `placeOrder` time so the order detail
/// sheet can render real rows even after the cart is cleared.
@immutable
class OrderLineItem {
  const OrderLineItem({
    required this.name,
    required this.emoji,
    required this.qty,
    required this.price,
  });

  final String name;
  final String emoji;

  /// Quantity (units, not a string).
  final int qty;

  /// Line total in ₪.
  final int price;

  Map<String, dynamic> toJson() =>
      {'name': name, 'emoji': emoji, 'qty': qty, 'price': price};

  factory OrderLineItem.fromJson(Map<String, dynamic> j) => OrderLineItem(
        name: j['name'] as String,
        emoji: j['emoji'] as String,
        qty: (j['qty'] as num).toInt(),
        price: (j['price'] as num).toInt(),
      );
}

/// A single live order — the shared record every role sees. Mirrors the legacy
/// `SYS_ORDERS` element and the existing [ManagerOrder] (`who` = contractor,
/// `site`, `items`, `sum`, `stage`), with an optional [createdAt] timestamp the
/// legacy array did not carry (newly-placed orders stamp it; seed orders leave
/// it null so seeded numbers/IDs are unaffected).
///
/// Optional [lines], [shipTo], [notes] fields are populated at `placeOrder`
/// time for contractor-placed orders; seed orders carry none of these so
/// JSON round-trips stay backward-compatible.
@immutable
class Order {
  const Order({
    required this.id,
    required this.who,
    required this.site,
    required this.items,
    required this.sum,
    required this.stage,
    this.createdAt,
    this.lines = const [],
    this.shipTo = '',
    this.notes = '',
  });

  /// Order id, e.g. `BS-1042` (the legacy `o.id`).
  final String id;

  /// The contractor who placed it (the legacy `o.who`).
  final String who;

  /// The build site (the legacy `o.site`).
  final String site;

  /// Line-item count (the legacy `o.items`).
  final int items;

  /// Order total in ₪ (the legacy `o.sum`).
  final int sum;

  /// One of [kManagerOrderFlow] (the legacy `o.stage`).
  final String stage;

  /// When the order was placed. Null for the four seed orders (the legacy
  /// array had no timestamp) so the seed round-trips unchanged.
  final DateTime? createdAt;

  /// Captured line items from `smartCartProvider` at checkout. Empty for seed
  /// orders (they predate this field). Persisted so detail sheet survives restart.
  final List<OrderLineItem> lines;

  /// Optional "where to ship" address from `shipToProvider`. Empty if not set.
  final String shipTo;

  /// Optional courier notes from `cartNotesProvider`. Empty if not set.
  final String notes;

  /// Mirrors the legacy `o.stage!=='delivered'` "open order" predicate
  /// (@index.html:16951) — the same rule [ManagerOrder.isOpen] uses.
  bool get isOpen => stage != 'delivered';

  Order copyWith({
    String? stage,
    List<OrderLineItem>? lines,
    String? shipTo,
    String? notes,
  }) =>
      Order(
        id: id,
        who: who,
        site: site,
        items: items,
        sum: sum,
        stage: stage ?? this.stage,
        createdAt: createdAt,
        lines: lines ?? this.lines,
        shipTo: shipTo ?? this.shipTo,
        notes: notes ?? this.notes,
      );

  /// Project to the pure [ManagerOrder] the manager analytics fold over — lets
  /// `logic/manager_dashboard.dart` stay Flutter-free while the engine feeds it.
  ManagerOrder toManagerOrder() => ManagerOrder(
        id: id,
        who: who,
        site: site,
        items: items,
        sum: sum,
        stage: stage,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'who': who,
        'site': site,
        'items': items,
        'sum': sum,
        'stage': stage,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (lines.isNotEmpty) 'lines': lines.map((l) => l.toJson()).toList(),
        if (shipTo.isNotEmpty) 'shipTo': shipTo,
        if (notes.isNotEmpty) 'notes': notes,
      };

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        who: j['who'] as String,
        site: j['site'] as String,
        items: (j['items'] as num).toInt(),
        sum: (j['sum'] as num).toInt(),
        stage: j['stage'] as String,
        createdAt: j['createdAt'] == null
            ? null
            : DateTime.tryParse(j['createdAt'] as String),
        lines: j['lines'] == null
            ? const []
            : (j['lines'] as List<dynamic>)
                .map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
                .toList(),
        shipTo: (j['shipTo'] as String?) ?? '',
        notes: (j['notes'] as String?) ?? '',
      );

  /// Lift a seed [ManagerOrder] into a live [Order] (no timestamp — seed).
  factory Order.fromManagerOrder(ManagerOrder o) => Order(
        id: o.id,
        who: o.who,
        site: o.site,
        items: o.items,
        sum: o.sum,
        stage: o.stage,
      );
}

/// The engine's seed — the FOUR existing seed orders, lifted from
/// [kManagerOrderSeed] (which stays the single seed source of truth). Seeding
/// from it guarantees every current number stays identical.
final List<Order> kOrdersEngineSeed = List<Order>.unmodifiable(
  kManagerOrderSeed.map(Order.fromManagerOrder),
);

/// SharedPreferences key for the persisted orders (mirrors the cart/profile
/// key shape; the legacy localStorage key was `buildsmart:sharedOrders`).
const String kOrdersEngineKey = 'bs.orders.v1';

class OrdersEngineNotifier extends StateNotifier<List<Order>> {
  /// [seed] is the genesis order list the engine starts from (and `resetToSeed`
  /// restores). It defaults to [kOrdersEngineSeed] so direct construction stays
  /// byte-identical; the `ordersEngineProvider` injects it THROUGH the orders
  /// repository (T6.3) — same four seed orders, just sourced via the seam.
  OrdersEngineNotifier({this.persist = true, List<Order>? seed})
      : _seed = seed ?? kOrdersEngineSeed,
        super(seed ?? kOrdersEngineSeed) {
    if (persist) _load();
  }

  /// When false (tests), skip touching SharedPreferences entirely so the
  /// in-memory seed/flow behavior can be asserted in isolation.
  final bool persist;

  /// The seed list this engine resets to — the same list it was constructed
  /// with (the four seed orders). Held so `resetToSeed` is source-consistent
  /// with construction whether the seed came from the const or the repository.
  final List<Order> _seed;

  /// True once any mutation has been applied (or _load completes).
  /// Guards against _load clobbering a mutation that arrived before prefs.
  bool _loaded = false;

  /// S4.4 — the bound Firestore-backed orders repository, or null on the local
  /// path (no Firebase → the engine itself stays the store, byte-identical).
  FirebaseOrdersRepository? _remote;

  /// Bind the engine to the live Firestore-backed orders repository (called by
  /// [ordersEngineProvider] only when Firebase is initialised — the repo the
  /// `ordersRepositoryProvider` switch already constructs+attaches). The
  /// real-time loop both ways:
  ///   • DOWN — every cache change (a `snapshots()` event or an optimistic
  ///     write) `notifyListeners`s → [_refreshFromRemote] rebuilds the engine
  ///     state from the SYNC `all()` — so a store-side stage advance lands live
  ///     in this engine, and through it in `sysOrdersProvider` (the
  ///     store/courier projection) and the manager analytics, zero UI changes;
  ///   • UP — [placeOrder]/[advance]/[setStage]/[resetToSeed] delegate to the
  ///     repo's verbatim ports, whose optimistic upserts notify back
  ///     SYNCHRONOUSLY — the UI sees the mutation in the same frame, the
  ///     Firestore write fires in the background. Delegating (rather than
  ///     mutating engine state directly) is what keeps the cache ⇄ engine in
  ///     lockstep: a later snapshot can never clobber a local mutation, because
  ///     every local mutation lives IN the cache.
  /// The immediate refresh aligns engine ⇄ cache from t0; running through the
  /// `state` setter it also flips [_loaded], so the prefs overlay never
  /// clobbers server state — under Firebase, Firestore's own offline
  /// persistence is the continuity source and prefs stays a write-behind copy.
  void bindRemote(FirebaseOrdersRepository remote) {
    if (_remote != null) return; // bind once (provider-lifetime)
    _remote = remote;
    remote.addListener(_refreshFromRemote);
    _refreshFromRemote();
  }

  void _refreshFromRemote() {
    final r = _remote;
    if (r == null) return;
    state = r.all(); // public setter → _loaded + persist (write-behind)
  }

  @override
  void dispose() {
    _remote?.removeListener(_refreshFromRemote);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kOrdersEngineKey);
      if (raw == null || raw.isEmpty) {
        _loaded = true;
        return;
      }
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!_loaded) {
        super.state = list; // bypass re-persisting the value we just loaded
        _loaded = true;
      }
    } on Object catch (_) {
      // Corrupt/old payload — keep the seed.
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kOrdersEngineKey,
        jsonEncode(state.map((o) => o.toJson()).toList()),
      );
    } on Object catch (_) {}
  }

  // Persist on every state change (the cart pattern).
  @override
  set state(List<Order> value) {
    _loaded = true; // mutation happened — block any pending _load
    super.state = value;
    _persist();
  }

  /// Next `BS-####` id — one above the current max BS-number (the legacy ids
  /// run BS-1039…BS-1042; a new order continues the sequence). Falls back to a
  /// timestamp-based id if no order matches the pattern.
  String _nextId() {
    final re = RegExp(r'^BS-(\d+)$');
    var maxN = 0;
    for (final o in state) {
      final m = re.firstMatch(o.id);
      if (m != null) {
        final n = int.tryParse(m.group(1)!) ?? 0;
        if (n > maxN) maxN = n;
      }
    }
    return maxN > 0 ? 'BS-${maxN + 1}' : 'BS-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Contractor places a new order — it enters the flow at stage `new`
  /// (the first of [kManagerOrderFlow]). Returns the created order. If [id] is
  /// omitted it is auto-assigned the next `BS-####`. Mirrors the legacy
  /// "push a `{stage:'new'}` order onto SYS_ORDERS" path.
  ///
  /// Optional [lines] captures the cart line items for the order detail view.
  /// Optional [shipTo] and [notes] are persisted alongside the order so they
  /// are not dropped on restart.
  Order placeOrder({
    required String who,
    required String site,
    required int items,
    required int sum,
    String? id,
    DateTime? createdAt,
    List<OrderLineItem> lines = const [],
    String shipTo = '',
    String notes = '',
  }) {
    // S4.4 — bound to Firestore: the repo's verbatim port places the order
    // (same _nextId/stage/prepend), its optimistic cache notifies back
    // synchronously → the engine state already carries it on return.
    final r = _remote;
    if (r != null) {
      return r.placeOrder(
        who: who,
        site: site,
        items: items,
        sum: sum,
        id: id,
        createdAt: createdAt,
        lines: lines,
        shipTo: shipTo,
        notes: notes,
      );
    }
    final order = Order(
      id: id ?? _nextId(),
      who: who,
      site: site,
      items: items,
      sum: sum,
      stage: kManagerOrderFlow.first, // 'new'
      createdAt: createdAt ?? DateTime.now(),
      lines: lines,
      shipTo: shipTo,
      notes: notes,
    );
    state = [order, ...state];
    return order;
  }

  /// Advance the order with [orderId] to the NEXT stage in [kManagerOrderFlow]
  /// — a no-op once it is `delivered` (the last stage). Verbatim port of
  /// `mgrAdvanceOrder` (@index.html:17022-17032): `cur=ORDER_FLOW.indexOf(stage)`;
  /// if `cur<0 || cur>=len-1` do nothing, else `stage=ORDER_FLOW[cur+1]`.
  void advance(String orderId) {
    // S4.4 — bound: delegate to the repo's verbatim port (same flow walk +
    // guards); the optimistic cache mirrors back synchronously.
    final r = _remote;
    if (r != null) {
      r.advance(orderId);
      return;
    }
    final idx = state.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;
    final cur = kManagerOrderFlow.indexOf(state[idx].stage);
    if (cur < 0 || cur >= kManagerOrderFlow.length - 1) return;
    setStage(orderId, kManagerOrderFlow[cur + 1]);
  }

  /// Manager "god-step": set the order with [orderId] to ANY [stage] in the
  /// flow. Ignores an unknown stage (not in [kManagerOrderFlow]) or unknown id.
  void setStage(String orderId, String stage) {
    // S4.4 — bound: delegate to the repo's verbatim port (same guards).
    final r = _remote;
    if (r != null) {
      r.setStage(orderId, stage);
      return;
    }
    if (!kManagerOrderFlow.contains(stage)) return;
    final idx = state.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;
    if (state[idx].stage == stage) return;
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == idx) state[i].copyWith(stage: stage) else state[i],
    ];
  }

  /// Reset to the four seed orders (used by tests / a future "demo reset").
  /// Restores the [_seed] the engine was constructed with — identical to
  /// [kOrdersEngineSeed] (the const) and to the repository-sourced seed.
  /// Bound to Firestore this resets the remote-backed cache (and re-writes the
  /// seed); its notify mirrors the seed back into the engine state.
  void resetToSeed() {
    final r = _remote;
    if (r != null) {
      r.resetToSeed();
      return;
    }
    state = _seed;
  }
}

/// The shared orders provider — the single live list every role will read.
/// Seeded with the four existing seed orders (obtained THROUGH the orders
/// repository — T6.3 — instead of referencing the const directly) so every
/// current number is preserved until real orders are placed. The repository's
/// `seed()` is const-backed and never reads this provider, so the wiring is
/// acyclic; a future remote impl supplies the seed via the same seam.
final ordersEngineProvider =
    StateNotifierProvider<OrdersEngineNotifier, List<Order>>(
  (ref) {
    final repo = ref.read(ordersRepositoryProvider);
    // Source the seed through the repository (the local impl exposes it). Any
    // non-local impl falls back to the const seed — identical orders either way.
    final seed = repo is LocalOrdersRepository ? repo.seed() : kOrdersEngineSeed;
    final engine = OrdersEngineNotifier(seed: seed);
    // S4.4 — Firebase initialised → the switch above returned the attached
    // Firestore-backed repo: bind the engine to it so `orders.snapshots()` →
    // cache → THIS engine → `sysOrdersProvider`/manager analytics is one live
    // chain (a store-side advance shows up at the courier/contractor), and
    // every engine mutation rides the repo's optimistic-write path out. On the
    // Firebase-free path (the whole test suite) nothing is bound — the engine
    // behaves byte-identically to today.
    if (repo is FirebaseOrdersRepository) engine.bindRemote(repo);
    return engine;
  },
);

/// Live manager analytics over the engine's orders — the same five tile numbers
/// the dashboard reads, now derived from the LIVE list instead of the static
/// seed. Identical to `managerAnalytics` while the engine holds the seed.
final managerAnalyticsProvider = Provider<ManagerAnalytics>((ref) {
  final orders = ref.watch(ordersEngineProvider);
  return ManagerAnalytics(
    orders: orders.map((o) => o.toManagerOrder()).toList(growable: false),
    stores: kManagerStores,
    catalogCategories: kManagerCatalogCategories,
  );
});

/// Live customer aggregates over the engine's orders — the same group-by-buyer
/// list the 👥 לקוחות leaves read, derived from the LIVE orders. The fold now
/// flows THROUGH the customers repository (T6.3): this provider keeps `watch`ing
/// the engine so the list stays live (re-runs on every order change), and
/// delegates the actual group-by-buyer derivation to the repo's `all()` — the
/// identical `mgrCustomerList` aggregation, just behind the server-ready seam.
final managerCustomersProvider = Provider<List<ManagerCustomer>>((ref) {
  final orders = ref.watch(ordersEngineProvider); // live → re-runs on change
  final repo = ref.read(customersRepositoryProvider);
  // Delegate the group-by-buyer fold to the repository. The local impl exposes
  // `aggregate(orders)` so the watched live list drives it directly; any other
  // impl folds the engine's current orders via `all()` — identical result.
  return repo is LocalCustomersRepository ? repo.aggregate(orders) : repo.all();
});
