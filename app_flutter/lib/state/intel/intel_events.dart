/// Pillar-3 STUDIO · step 87 — the customer-intelligence event taxonomy.
///
/// ONE source of truth for the LOCAL intel event names, so the call-sites
/// (steps 92-94), the pure funnel/segment logic (steps 95-96) and the manager
/// dashboard (step 98) all agree on the exact wire strings — zero drift between
/// call-site, test and dashboard (§4).
///
/// This is a SEPARATE registry from `TelemetryEvents`
/// (`lib/state/telemetry.dart`) on purpose (§4): the G4 GA/Crashlytics names
/// must not move, and this file must stay Firebase-free (telemetry.dart pulls in
/// Firebase), so the single shared real event — `order_placed` — is re-declared
/// here as an independent constant rather than imported.
///
/// PURE DATA. No Firebase, no widgets, no providers, zero imports. Dormant until
/// step 89 wires the bus. Every name AND every allowed prop key is validated by
/// `test/intel/intel_events_test.dart`: snake_case, `<= 40` chars, unique, and
/// free of any PII token (no `name` / `email` / `phone` / `uid` / ... in a key).
abstract final class IntelEvents {
  // ── Session & identity (steps 91, 97) ──────────────────────────────────
  static const String sessionStart = 'session_start';
  static const String sessionHeartbeat = 'session_heartbeat';
  static const String sessionEnd = 'session_end';
  static const String identify = 'identify';

  // ── Navigation (step 92) ────────────────────────────────────────────────
  static const String screenView = 'screen_view';

  // ── Catalog interaction (step 93) ───────────────────────────────────────
  static const String searchSubmit = 'search_submit';
  static const String searchNoResult = 'search_no_result';
  static const String productView = 'product_view';
  static const String addToCart = 'add_to_cart';

  // ── Store funnel (step 94) ──────────────────────────────────────────────
  static const String cartView = 'cart_view';
  static const String checkoutStart = 'checkout_start';
  static const String checkoutStep = 'checkout_step';

  /// Terminal conversion step of the funnel (step 95). Shares its wire string
  /// with `TelemetryEvents.orderPlaced` BY DESIGN — the same real-world event,
  /// two independent registries (§4). This is NOT a G4 move: `order_placed` is
  /// already wired via telemetry at `store_screen.dart` and is not re-emitted
  /// here; the intel funnel keys its conversion on this name.
  static const String orderPlaced = 'order_placed';

  /// Every intel event name, declared once. The registry test folds over this
  /// to enforce uniqueness + format + length.
  static const List<String> all = <String>[
    sessionStart,
    sessionHeartbeat,
    sessionEnd,
    identify,
    screenView,
    searchSubmit,
    searchNoResult,
    productView,
    addToCart,
    cartView,
    checkoutStart,
    checkoutStep,
    orderPlaced,
  ];

  /// Per-event ALLOWED prop keys (§9, addition-a) — a declarative allow-list the
  /// registry test reads to enforce the no-PII / scalar-only rule, and that the
  /// bus (step 89) can later assert against in debug. SCALAR keys ONLY: never a
  /// raw query (only `q_len` / `q_hash`), never `uid` / `name` / a contact
  /// field. `uid` travels as a top-level pseudonymous field on `IntelEvent`
  /// (step 90), never inside these free props (step 91.3).
  static const Map<String, Set<String>> allowedProps = <String, Set<String>>{
    sessionStart: <String>{'actor_kind'},
    sessionHeartbeat: <String>{'screen'},
    sessionEnd: <String>{'reason', 'dur_s'},
    identify: <String>{},
    screenView: <String>{'screen', 'prev'},
    searchSubmit: <String>{'q_len', 'q_hash', 'source'},
    searchNoResult: <String>{'q_len', 'q_hash'},
    productView: <String>{'sku', 'source'},
    addToCart: <String>{'sku', 'qty', 'acc_count'},
    cartView: <String>{'item_count'},
    checkoutStart: <String>{'item_count', 'sum'},
    checkoutStep: <String>{'step', 'value', 'dur_s'},
    orderPlaced: <String>{'order_id', 'items', 'sum'},
  };
}
