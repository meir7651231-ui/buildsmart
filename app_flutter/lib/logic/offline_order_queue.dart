// ─────────────────────────────────────────────────────────────────────────────
// OfflineOrderQueue — the S9.2 EXPLICIT offline queue for batch orders.
//
// HONESTY FIRST (read before extending): with S0.4 (`main.dart` sets
// `Settings(persistenceEnabled: true)` right after `Firebase.initializeApp`)
// Firestore's OWN offline queue already covers EVERY guarded write in the
// cache-pattern — a `placeOrder` fired while offline lands in the optimistic
// cache instantly, the background `set` is queued by the SDK (disk on
// Android/iOS, IndexedDB persistentLocalCache on web) and syncs on reconnect.
// This layer is therefore NOT the thing that makes offline orders work; it is
// the SSOT-MANDATED belt-and-braces for the batch-order flow specifically
// (`SPEC-server-connect-MICRO` §S9 row S9.2: "offline-queue ל-batch-order
// (נשלח בחזרת-רשת)"), adding what the native queue cannot:
//   • REPLAY-TIME id assignment — an intent carries NO order id; the id
//     (`BS-####`) is assigned by the repository at replay, over the cache as
//     it stands AFTER reconnect. The native queue replays the doc-id chosen
//     while offline, so two offline devices can both pick `BS-1043` and
//     silently overwrite each other (doc-id LWW). The explicit queue removes
//     that collision lane for queued batch orders.
//   • INSPECTABILITY — [pending] exposes the queued intents synchronously to
//     a future "ממתין לסנכרון" badge; the SDK queue is a black box.
//   • REPLAY THROUGH THE SEAM — [drainQueue] replays through
//     `ordersRepositoryProvider`, so a replayed order takes the SAME path a
//     live one does (verbatim `_nextId`/stage/prepend ports, future S8
//     server-side validation included).
//
// OFFLINE-SUSPECT (the pragmatic seam): there is NO connectivity_plus (no new
// deps, SSOT constraint). [connectivityProbeProvider] is a plain
// `bool Function()` provider DEFAULTING TO "assume online" — so in production
// today this layer is INERT (the native Firestore queue carries offline, which
// is the honest division of labour). Tests — and a later wave that wires a
// real probe (e.g. Firestore snapshot `isFromCache` metadata or a platform
// listener) — inject their own probe; nothing else changes.
//
// VOICE & RULES (the repositories' contract, kept verbatim):
//   1. NOTHING here ever throws into the UI — every prefs/replay touch is
//      guarded, caught + logged (`debugPrint`), exactly like `guardWrite`.
//   2. The interception decision ([maybeEnqueue]) is SYNCHRONOUS — the
//      checkout path is sync and must stay sync; the persist is a guarded
//      background write (the optimistic-write shape of the cache-pattern).
//   3. A corrupt persisted payload is dropped + logged, never crashes a drain
//      (the same "one bad doc can't blank the app" stance as the cache base).
//   4. The persist key is VERSIONED (`bs.offline-orders.v1`) like every other
//      store key (`bs.orders.v1`, `bs.offline-cache.v1`).
//
// CRASH-SAFETY / NO DOUBLE-PLACE / FIFO: [drainQueue] persists the SHRINKING
// remainder after EVERY replayed intent, so a crash mid-drain can never replay
// an already-placed intent on the next start. ALL queue operations are
// SERIALIZED through one internal future chain — two rapid enqueues (or an
// enqueue racing a drain) would otherwise interleave around the cold
// `SharedPreferences.getInstance()` await and reorder (or even drop) entries;
// serialization makes enqueue order == replay order and a concurrent drain a
// natural no-op (it runs after, finds the queue empty). A drain while still
// offline-suspect keeps the queue intact (it replays "בחזרת-רשת", per the
// SSOT row).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/data/repositories/orders_local.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A connectivity probe: `true` = the device is believed ONLINE.
typedef ConnectivityProbe = bool Function();

/// The offline-suspect seam (S9.2). Defaults to "assume online" — the queue is
/// INERT in production until a real probe is wired (no connectivity_plus — no
/// new deps; Firestore's native offline queue carries the offline case until
/// then). Tests override this provider to simulate offline.
final connectivityProbeProvider = Provider<ConnectivityProbe>(
  (_) => () => true,
);

/// SharedPreferences key for the queued batch-order intents. Versioned like
/// every other store key (`bs.orders.v1` / `bs.offline-cache.v1`).
const String kOfflineOrdersKey = 'bs.offline-orders.v1';

/// One queued "place this order" intent — the EXACT `placeOrder` parameter set
/// (who/site/items/sum/lines/shipTo/notes), captured at checkout time, plus
/// [queuedAt] (when the user actually placed it; replayed as the order's
/// `createdAt` so the order is honest about its placement time).
///
/// Deliberately NO `id` field: the `BS-####` id is assigned by the repository
/// AT REPLAY (over the post-reconnect cache) — see the header for why that
/// beats the native queue's offline-chosen doc-id.
@immutable
class OfflineOrderIntent {
  const OfflineOrderIntent({
    required this.who,
    required this.site,
    required this.items,
    required this.sum,
    required this.queuedAt,
    this.lines = const [],
    this.shipTo = '',
    this.notes = '',
  });

  /// THROWS on a structurally-bad entry — the queue catches per-payload and
  /// drops it (logged), exactly like the cache base skips a corrupt doc.
  factory OfflineOrderIntent.fromJson(Map<String, dynamic> j) =>
      OfflineOrderIntent(
        who: j['who'] as String,
        site: j['site'] as String,
        items: (j['items'] as num).toInt(),
        sum: (j['sum'] as num).toInt(),
        queuedAt: DateTime.parse(j['queuedAt'] as String),
        lines: j['lines'] == null
            ? const []
            : (j['lines'] as List<dynamic>)
                .map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
                .toList(),
        shipTo: (j['shipTo'] as String?) ?? '',
        notes: (j['notes'] as String?) ?? '',
      );

  /// The contractor placing the order (`Order.who`).
  final String who;

  /// The build site / checkout project (`Order.site`).
  final String site;

  /// Line-item count (`Order.items`).
  final int items;

  /// Order total in ₪ (`Order.sum`).
  final int sum;

  /// When the intent was queued — replayed as the order's `createdAt`.
  final DateTime queuedAt;

  /// Captured cart lines (`Order.lines`) so the order detail sheet renders
  /// real rows even though the cart was cleared at checkout.
  final List<OrderLineItem> lines;

  /// Optional "where to ship" captured at checkout (`Order.shipTo`).
  final String shipTo;

  /// Optional courier notes captured at checkout (`Order.notes`).
  final String notes;

  /// Mirrors `Order.toJson` field economy: optional fields are written only
  /// when non-empty so payloads stay small and round-trip tolerantly.
  Map<String, dynamic> toJson() => {
        'who': who,
        'site': site,
        'items': items,
        'sum': sum,
        'queuedAt': queuedAt.toIso8601String(),
        if (lines.isNotEmpty) 'lines': lines.map((l) => l.toJson()).toList(),
        if (shipTo.isNotEmpty) 'shipTo': shipTo,
        if (notes.isNotEmpty) 'notes': notes,
      };
}

/// The explicit batch-order offline queue (S9.2). One instance per container
/// via [offlineOrderQueueProvider]; holds the [Ref] so the drain replays
/// through the `ordersRepositoryProvider` SEAM (Firebase-backed or local —
/// the queue does not care, exactly like every other consumer of the seam).
class OfflineOrderQueue {
  OfflineOrderQueue(this._ref);

  final Ref _ref;

  /// The serialization chain every queue operation rides (FIFO). Without it,
  /// two enqueues racing the COLD `SharedPreferences.getInstance()` resume in
  /// INVERTED order (the later caller's listener registers on the instance
  /// completer first) and an enqueue interleaving a drain's read-modify-write
  /// could resurrect already-drained state. Ops are internally guarded (they
  /// never throw), so the chain never breaks.
  Future<void> _chain = Future<void>.value();

  /// Run [op] after every previously scheduled queue operation (FIFO).
  Future<T> _serialized<T>(Future<T> Function() op) {
    final run = _chain.then((_) => op());
    // Ops are self-guarded; the extra swallow keeps the chain alive even if
    // one ever threw (belt-and-braces, like everything else in this file).
    _chain = run.then((_) {}).catchError((Object _) {});
    return run;
  }

  /// `true` when the probe says the device is NOT believed online. With the
  /// default probe this is always `false` (assume online → queue inert).
  bool get offlineSuspect => !_ref.read(connectivityProbeProvider)();

  /// The checkout-side interception, SYNCHRONOUS like the checkout itself:
  /// when [offlineSuspect], capture the intent (guarded background persist —
  /// the optimistic-write shape) and return `true` ("queued — do NOT place");
  /// when online (the production default) return `false` and touch NOTHING —
  /// the caller proceeds with the normal `placeOrder`, whose background
  /// Firestore write the NATIVE offline queue already covers.
  bool maybeEnqueue({
    required String who,
    required String site,
    required int items,
    required int sum,
    List<OrderLineItem> lines = const [],
    String shipTo = '',
    String notes = '',
  }) {
    if (!offlineSuspect) return false; // inert when online — the common path
    unawaited(
      enqueue(
        OfflineOrderIntent(
          who: who,
          site: site,
          items: items,
          sum: sum,
          queuedAt: DateTime.now(),
          lines: lines,
          shipTo: shipTo,
          notes: notes,
        ),
      ),
    );
    return true;
  }

  /// Append [intent] to the persisted queue. Guarded — a prefs failure is
  /// logged, never thrown (rule #1). Rides the serialization chain, so rapid
  /// successive enqueues land in CALL order (enqueue order == replay order).
  Future<void> enqueue(OfflineOrderIntent intent) =>
      _serialized(() => _enqueueNow(intent));

  Future<void> _enqueueNow(OfflineOrderIntent intent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = _decode(prefs.getString(kOfflineOrdersKey))..add(intent);
      await prefs.setString(kOfflineOrdersKey, _encode(pending));
    } on Object catch (e) {
      debugPrint('OfflineOrderQueue: enqueue failed (ignored): $e');
    }
  }

  /// The currently queued intents, oldest first (FIFO — replay order). For
  /// tests and a future "ממתין לסנכרון" badge. Rides the chain so a read
  /// issued right after [maybeEnqueue] sees the intent it queued. Guarded:
  /// any failure → empty.
  Future<List<OfflineOrderIntent>> pending() => _serialized(() async {
        try {
          final prefs = await SharedPreferences.getInstance();
          return _decode(prefs.getString(kOfflineOrdersKey));
        } on Object catch (e) {
          debugPrint('OfflineOrderQueue: pending read failed (empty): $e');
          return const <OfflineOrderIntent>[];
        }
      });

  /// Replay every queued intent, FIFO, through `ordersRepositoryProvider` —
  /// called on app start (the orders-engine init path wires it) and by
  /// whoever observes connectivity returning. Returns the number replayed.
  ///
  ///   • EMPTY queue (the overwhelmingly common path) → returns 0 without
  ///     touching the repository at all.
  ///   • Still [offlineSuspect] → no-op, queue kept intact ("נשלח בחזרת-רשת").
  ///   • CRASH-SAFE / NO DOUBLE-PLACE: the shrinking remainder is persisted
  ///     after EVERY replayed intent, so an interrupted drain never replays a
  ///     placed intent again; a CONCURRENT drain is serialized behind this
  ///     one and finds the queue already empty (replays nothing).
  ///   • A replay failure keeps THAT intent (and the rest) queued for the
  ///     next drain; everything is caught + logged, nothing ever throws
  ///     (rule #1 — this runs fire-and-forget from a provider build).
  Future<int> drainQueue() => _serialized(_drainNow);

  Future<int> _drainNow() async {
    var replayed = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      var pending = _decode(prefs.getString(kOfflineOrdersKey));
      if (pending.isEmpty) return 0; // common path: never touches the repo
      if (offlineSuspect) return 0; // still offline — keep the queue
      final repo = _ref.read(ordersRepositoryProvider);
      while (pending.isNotEmpty) {
        final intent = pending.first;
        try {
          // NO id passed — the repository assigns the next BS-#### over the
          // post-reconnect cache (the whole point, see header). queuedAt is
          // replayed as createdAt so the order keeps its true placement time.
          repo.placeOrder(
            who: intent.who,
            site: intent.site,
            items: intent.items,
            sum: intent.sum,
            createdAt: intent.queuedAt,
            lines: intent.lines,
            shipTo: intent.shipTo,
            notes: intent.notes,
          );
        } on Object catch (e) {
          // Keep this intent (and the rest) for the next drain — losing a
          // customer's order is worse than replaying late.
          debugPrint('OfflineOrderQueue: replay failed (kept queued): $e');
          break;
        }
        pending = pending.sublist(1);
        replayed++;
        // Persist the remainder NOW — a crash here cannot double-place.
        await prefs.setString(kOfflineOrdersKey, _encode(pending));
      }
      return replayed;
    } on Object catch (e) {
      debugPrint('OfflineOrderQueue: drain failed (queue intact): $e');
      return replayed;
    }
  }

  // ── payload codec (versioned via the key, tolerant like the cache base) ────

  String _encode(List<OfflineOrderIntent> intents) =>
      jsonEncode(intents.map((i) => i.toJson()).toList());

  /// Decode the persisted payload. A corrupt/legacy payload is dropped +
  /// logged (it cannot be replayed) — never crashes a drain; a single corrupt
  /// ENTRY is skipped, the rest of the queue survives (per-doc tolerance,
  /// the cache-base stance).
  List<OfflineOrderIntent> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return <OfflineOrderIntent>[];
    try {
      final out = <OfflineOrderIntent>[];
      for (final e in jsonDecode(raw) as List<dynamic>) {
        try {
          out.add(OfflineOrderIntent.fromJson(e as Map<String, dynamic>));
        } on Object catch (err) {
          debugPrint('OfflineOrderQueue: skipped corrupt intent: $err');
        }
      }
      return out;
    } on Object catch (e) {
      debugPrint('OfflineOrderQueue: corrupt queue payload (dropped): $e');
      return <OfflineOrderIntent>[];
    }
  }
}

/// The queue provider — container-lifetime singleton, like every repository
/// provider. Read by the orders-engine init path (the drain wiring) and by
/// any future checkout interception / pending-badge consumer.
final offlineOrderQueueProvider = Provider<OfflineOrderQueue>(
  OfflineOrderQueue.new,
);
