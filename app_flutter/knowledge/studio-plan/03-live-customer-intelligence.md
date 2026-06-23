# Pillar 3 — Live Customer Intelligence / Analytics

> **Build-plan · branch `claude/whats-happening-LyY9G` · `app_flutter/` (Flutter 3.29 · Riverpod).**
> Owner-facing goal (Hebrew, manager screen): for **every customer, in real time** — what they
> click, where they get stuck, where they are **now**, plus a per-customer journey, segments,
> funnels, retention. This pillar OWNS: the **event taxonomy**, the **instrumentation seam**, the
> **funnel/stuck logic**, the **presence model**, and the **manager analytics UX**. It COORDINATES
> (does not design): Pillar 1 (config-engine), Pillar 5 (backend/Firestore/real-time-infra/cost/
> security-rules).
>
> **Non-negotiables carried from the codebase:** ZERO regression on the demo / Firebase-free path
> (the whole 356-test suite stays green and Firebase-free); fire-and-forget + batched events (near-
> zero perf cost); gated → **OFF in demo, ON only when the live backend is up**; scales to 1000s of
> customers + high event volume. Every claim below cites real code (`file:line`).

---

## 0. Ground truth — what telemetry exists TODAY (cited)

The repo already has a clean, **2-layer** telemetry design that this pillar EXTENDS rather than
replaces. Reusing it is the whole zero-regression story.

| Layer | File | What it is | Reuse |
|---|---|---|---|
| **External seam (port)** | `lib/state/telemetry.dart:40-52` `TelemetrySink` (`logEvent`/`recordError`) | Injectable port; `NoopTelemetrySink` (`:71-82`) is the DEFAULT; `FirebaseTelemetrySink` (`:90-125`) resolves `FirebaseAnalytics`/`Crashlytics` **lazily**, fire-and-forget (`:110-116` `.catchError`). | This is the **batching/forward seam** model. Our event bus follows the SAME port+gate+lazy+swallow shape. |
| **Gate** | `lib/state/telemetry.dart:132-135` `telemetryProvider` → `FirebaseTelemetrySink` only `if (useFirebaseBackend)`, else `const NoopTelemetrySink()` | `useFirebaseBackend` = `kUseFirebaseBackendFlag && Firebase.apps.isNotEmpty` (`lib/data/repositories/backend.dart:12-17`). | The **single master gate** every analytics provider in this pillar respects. |
| **Event names** | `lib/state/telemetry.dart:139-148` `TelemetryEvents` (`order_placed`, `role_assigned`, `app_error`) | One source of truth so call-sites + tests + dashboard agree (no drifting strings). | Our taxonomy (§1) **extends this exact class** — one canonical name registry. |
| **In-memory event log** | `lib/state/analytics_log.dart` `AnalyticsLogNotifier` (`record`/`countByName`/`recent`, cap 500, newest-first) | In-memory only, never persisted (payloads may be sensitive — `:4-7`). | The **local sink** for the demo path + the live-feed buffer (§4, §5). |
| **Last-action log** | `lib/state/last_action.dart` `LastActionNotifier` (cap 50) | `{kind,label,at}`, newest-first, `countByKind`. | Shape template for our per-session ring buffer. |
| **Crash log** | `lib/state/crash_log.dart` (cap 200) | In-memory diagnostics. | Friction/error-event mirror (§3). |
| **Live connection truth** | `lib/state/connection_status.dart:73-219` `ConnectionStatusNotifier` | INERT on demo (`:82` `if (!_active) return`); on live it fuses connectivity + auth + a per-uid Firestore `snapshots(includeMetadataChanges:true)` probe on `diag/{uid}` (`:160-189`); guarded, never throws. | The **canonical real-time-presence engineering pattern** — our presence notifier is a near-clone (§4). |

**Existing call-sites (the adoption pattern to copy verbatim):**
- Checkout success — `lib/screens/store_screen.dart:2915-2922`:
  `ref.read(telemetryProvider).logEvent(TelemetryEvents.orderPlaced, params: {'order_id': placed.id, 'items': itemCount, 'sum': widget.total})` — fired right after `placeOrder` (`:2901-2911`).
- Role assigned — `lib/screens/manager_role_assign_sheet.dart:173-176` (PII rule: uid NOT logged, only role).
- Generic handled error — `manager_role_assign_sheet.dart:197` `logError(e, st, where: 'role_assign')` via the `TelemetryErrorLogging` extension (`telemetry.dart:61-66`).
- Usage-tracking precedents (persisted, `_userTouched` late-load guard, capped): `lib/state/recently_viewed.dart`, `lib/state/smart_input_usage.dart`, `lib/state/recent_searches.dart` (added at `catalog_screen.dart:1619, 2417`).

**Customer identity (load-bearing).** The manager surfaces key a customer by the order's **`who`
display-name**, NOT by uid: `managerCustomersProvider` groups by `Order.who` (`lib/state/orders_engine.dart:693-700`, `lib/logic/manager_dashboard.dart:272-296`), and `_CustomerDetailSheet` filters `ordersEngineProvider.where((o)=>o.who==c.name)` (`manager_dashboard_screen.dart:2017-2018`). The real auth uid is `currentUidProvider` (`auth_state.dart:641-643`, null off-backend). **Our events therefore carry BOTH a stable `actorKey` (uid when signed-in, else an anonymous device id) AND a `displayName`**, so the journey timeline can join to the existing customer rows by name while the backend keys by uid (§1, §6).

**Backend reality this pillar must fit (coordinate with Pillar 5):**
- Firestore schema (`knowledge/firestore-schema.md`) lists **9 collections** (`users/orders/customers/projects/tasks/stock/siteNodes/chatThreads/chatMessages`). Our pipeline ADDS new collections (`events/`, `sessions/`, `presence/`) — **proposed here, owned/cost-tuned by Pillar 5.**
- The cache pattern is `FirestoreCachedRepo<T>` over a neutral `RemoteCollectionSource` (id+map `RemoteDoc`, lazy Firebase) — `lib/data/repositories/firestore_cached_repo.dart:1-60`; template repo `orders_firebase.dart`; the engine binds via `bindRemote` (`orders_engine.dart:649-661`). Its surface: sync `cached()`, `attach()` (live `snapshots()` listener), optimistic `upsert`/`replaceAll`/`removeById`, **`upsertLocalOnly` (cache-only, when the persist happens elsewhere — perfect for events written via a batch/Function)**, and the `onFirstSnapshotEmpty()`+`pushCacheToRemote()` fresh-backend hook (gated `useFirebaseBackend && !kSeedFreshBackend` so it never pollutes prod). `RemoteCollectionSource` also takes an optional uid `scope` (`kUidScopedQueries`) for per-uid queries. **We reuse this base for the manager READ side; the WRITE side is a dedicated batched sink (events are append-only, high-volume — NOT a cached list).**
- The catalog (1,877 products) is **deliberately NOT in Firestore** (`firestore-schema.md:126-133`). Event payloads must reference products by `sku`/`key` only — never embed product docs.

---

## 1. Event taxonomy & schema (Phase A)

### 1.1 The canonical event registry
Extend the existing one-source-of-truth class. **New file `lib/state/intel/intel_events.dart`** adds
`IntelEvents` (kept SEPARATE from `TelemetryEvents` so the G4 funnel names stay untouched, but both
flow through the same sink). GA-style snake_case, ≤40 chars, flat scalar params (the
`TelemetrySink.logEvent` contract, `telemetry.dart:47`).

```
// Navigation / presence
screen_view            {screen, prev, tab_index}          // every route/tab change
session_start          {entry}                            // first event of a session
session_end            {reason: 'idle'|'background'|'logout', dur_s}
heartbeat              {screen, dur_s}                     // presence keep-alive (live only)

// Catalog / search
search_submit          {q_len, scope, result_count}       // q HASHED, never raw text by default
search_no_result       {q_len, scope}                     // STUCK signal
product_view           {sku, source: 'catalog'|'search'|'history'}
filter_change          {kind: 'sort'|'lens'|'system', value}

// Cart / checkout funnel
add_to_cart            {sku, brand, qty, acc_count}
cart_view              {items, total}
checkout_start         {items, total}
checkout_step          {step: 'ship_to'|'payment'|'delivery', value}
checkout_abandon       {last_step, items, total}          // STUCK signal (derived, §3)
order_placed           {order_id, items, sum}             // ALREADY EXISTS (TelemetryEvents)

// Friction
app_error              {where}                            // ALREADY EXISTS (G4 breadcrumb)
dead_end               {screen, hint}                     // repeated no-op / back-loop (§3)
```

### 1.2 The event record (in-memory + wire)
**New file `lib/state/intel/intel_event.dart`** — `@immutable class IntelEvent` (mirrors
`AnalyticsEvent`, `analytics_log.dart:8-19`):

| field | type | note |
|---|---|---|
| `name` | `String` | from `IntelEvents` / `TelemetryEvents`. |
| `at` | `DateTime` | client clock; server stamps `serverTs` on write (Pillar 5). |
| `actorKey` | `String` | `currentUidProvider` when signed-in, else a per-install anon id (see §6.2). |
| `displayName` | `String` | for the manager join-by-name; '' when unknown. |
| `sessionId` | `String` | uuid minted at `session_start` (§4.1). |
| `screen` | `String` | current screen key (route name). |
| `props` | `Map<String,Object>` | flat scalars, ≤ ~8 keys. |

**Wire doc (`events/{autoId}`) — proposed to Pillar 5** (NOT designed here; cost/TTL/sharding are theirs):
`{name, ts, actorKey, displayName, sessionId, screen, props, ownerId}`. Reuses the schema's `ownerId`
convention (`firestore-schema.md:69`) so manager reads are rules-scoped exactly like `customers/`.

### 1.3 Privacy at the schema level (detail in §7)
- **Search text is HASHED, not stored**, by default — `search_submit` carries `q_len` + a salted hash, never the raw query. (Raw-text capture is a Pillar-1 config toggle, default OFF.)
- No free-text, no contact info, no payment numbers in `props` — same rule as the existing PII-safe call-sites (`manager_role_assign_sheet.dart:172` "uid is NOT logged").
- Every field is a scalar; the registry test (§8) asserts no event declares a disallowed key.

---

## 2. The instrumentation seam — how screens adopt it (Phase A→B)

**Design goal: a screen emits an event in ONE line, with zero new imports beyond one provider, and
the call is a guaranteed no-op on the demo path.**

### 2.1 The bus (`lib/state/intel/intel_bus.dart`)
A thin `IntelBus` provider that is the SINGLE thing screens touch. It fans one `track()` call to
three places, each independently safe:

```
final intelBusProvider = Provider<IntelBus>((ref) => IntelBus(ref));

class IntelBus {
  IntelBus(this._ref);
  final Ref _ref;

  void track(String name, {Map<String, Object> props = const {}}) {
    // 1. LOCAL ring buffer — ALWAYS (powers the demo + the live-feed UI). Cheap, in-memory.
    _ref.read(intelLogProvider.notifier).record(name, props, _context());
    // 2. EXTERNAL forward — the existing sink (no-op unless Firebase up). Fire-and-forget.
    _ref.read(telemetryProvider).logEvent(name, params: props);   // telemetry.dart:47
    // 3. BATCHED pipeline — enqueue for Firestore (live only; §6). Returns instantly.
    _ref.read(intelSinkProvider).enqueue(name, props, _context());
  }
}
```

- `_context()` stamps `actorKey`/`displayName`/`sessionId`/`screen` from providers so call-sites pass only `name` + a tiny `props` map.
- **It NEVER awaits, NEVER throws** — same discipline as `FirebaseTelemetrySink` (`telemetry.dart:110-123`) and `guardWrite` (`firestore_cached_repo.dart` HARD RULE #2). A bug in analytics can never crash a screen.
- On demo: step 2 is the `NoopTelemetrySink` and step 3's `intelSinkProvider` returns an inert no-op sink (gated on `useFirebaseBackend`, exactly like `connectionStatusProvider` is inert at `connection_status.dart:82`). Only step 1 (cheap in-memory append) runs → **byte-identical user-visible behavior**, and the local ring buffer makes the manager UI demoable with synthetic data.

### 2.2 Two adoption styles (both minimal-coupling)
1. **Imperative (interaction events)** — one line at the action site:
   `ref.read(intelBusProvider).track(IntelEvents.addToCart, props: {'sku': key, 'qty': 1});`
2. **Automatic (screen_view / presence)** — a `RouteObserver<ModalRoute>` + a tiny mixin so NO
   screen has to remember to fire `screen_view`. The observer is installed once in `BuildSmartApp`
   (the `ProviderScope` root, `lib/main.dart:210-218`) and reads `intelBusProvider`. For the
   `IndexedStack` tab shell (`home_shell.dart:90-97`, driven by `mainTabProvider` in `dial_state.dart:9`)
   we add ONE `ref.listen(mainTabProvider, …)` in the shell that maps tab-index→screen key and calls
   `track(screen_view)`. **One listener replaces N per-screen calls** → adoption is ~3 edits, not 270.

### 2.3 Exact instrumentation points (grounded, from the nav/funnel trace)
| Event | File:line | Site |
|---|---|---|
| `screen_view` (tabs) | `home_shell.dart:90-97` IndexedStack + `dial_state.dart:9` `mainTabProvider` | one `ref.listen` in the shell |
| `screen_view` (pushed routes) | `lib/main.dart:210-218` root `ProviderScope` | `RouteObserver` on `MaterialApp.navigatorObservers` |
| `search_submit` | `catalog_screen.dart:1619` (`_submit` → `recentSearchesProvider.add`) | one line after `.add(q)` |
| `search_no_result` | `catalog_screen.dart:2229` (`filtered.isEmpty && products.isEmpty`) | one line at the empty-state branch |
| `product_view` | `catalog_screen.dart:4067` `openSmartProductSheet(...)` | one line at sheet open |
| `add_to_cart` | `catalog_screen.dart:6374` (`smartCartProvider.notifier.add`) | one line after `.add` |
| `cart_view` | `store_screen.dart:1591` `_CartView.build` | one line on first build |
| `checkout_start` | `store_screen.dart:2693` `_showCheckoutSheet` | one line |
| `checkout_step` | `store_screen.dart` payment/delivery selectors (~`2800-2825`) | on `cartPayment/cartDelivery` change |
| `order_placed` | `store_screen.dart:2915` | **already wired** (no change) |
| `app_error` | existing `logError` sites | **already wired** |

> **Coupling audit:** each interaction edit is a single statement; no screen gains a constructor
> arg, no widget rebuilds because of tracking (we `read`, never `watch`, the bus). This is the
> "clean instrumentation seam, minimal coupling" the brief asks for.

---

## 3. Funnel & stuck-detection — deterministic algorithms (Phase C)

All logic is **pure Dart** over the in-memory `IntelEvent` list (and, on live, the manager's read of
`events/`), so it is unit-testable with hand-built event lists and produces no magic numbers — the
same "pure logic, fully tested" discipline as `manager_dashboard.dart` and `install_engine.dart`.

**New file `lib/logic/intel/funnels.dart`** (pure) + thresholds in **`lib/logic/intel/intel_config.dart`**
(so Pillar 1 can later make them owner-tunable; defaults below are deterministic constants).

### 3.1 Funnel definition (ordered stages)
A funnel = an ordered `List<String>` of event names; conversion = the standard monotonic
step-retention fold (mirrors the `kManagerOrderFlow` ordered-stage idea, `manager_dashboard.dart:29-36`):

```
const kCheckoutFunnel = [product_view, add_to_cart, cart_view, checkout_start, order_placed];

FunnelResult computeFunnel(List<String> stages, Iterable<SessionEvents> sessions) {
  // For each session: the furthest stage reached (stages are monotonic within a session).
  // count[i] = sessions that reached stage i. dropOff[i] = count[i-1]-count[i].
}
```
Output per stage: `reached`, `dropOffFromPrev`, `pct`. The biggest `dropOff` is the headline
"where they get stuck" tile.

### 3.2 Stuck / friction detectors (deterministic, session-scoped)
| Signal | Rule (deterministic) | Threshold (default const) |
|---|---|---|
| **Abandoned cart** | session has `add_to_cart` or `checkout_start` AND no `order_placed` AND session ended (idle/background) | end = idle ≥ `kIdleEnd` (180 s) |
| **Repeated dead-end search** | ≥ `kRepeatNoResult` `search_no_result` with the same `q` hash in one session | 3 |
| **Checkout drop-off** | reached `checkout_start`/`checkout_step` but `session_end` before `order_placed` | — |
| **Dead-end loop** | ≥ `kBackLoop` consecutive `screen_view` toggling between the same two screens with no interaction between | 4 |
| **Error friction** | any `app_error` within a session, attributed to the screen at the time | — |

`checkout_abandon` and `dead_end` are **derived** (emitted by the detector when a session closes, or
computed at manager-read time) — they are not raw client events, so a flaky client can't fake them.

### 3.3 Segments, funnels, retention (manager derivations)
**`lib/logic/intel/segments.dart`** (pure): group sessions by `actorKey`; per-customer roll-up
`{sessions, lastSeen, screensTouched, stuckCount, converted}`. **Retention** = cohort-by-first-seen-day
→ % returning on day N (deterministic date-bucket fold, like `mgrCustomerList`'s group-by,
`manager_dashboard.dart:272-296`). All keyed by `actorKey`/`displayName` so they **join to the
existing `managerCustomersProvider` rows by name**.

---

## 4. Real-time presence — "where they are NOW" (Phase D)

**Model: a `presence/{actorKey}` doc with a heartbeat, read live by the manager.** This is a
near-clone of the already-shipped `ConnectionStatusNotifier` engineering (`connection_status.dart`),
which already does "live per-uid Firestore `snapshots()` probe, inert on demo, guarded".

### 4.1 Session lifecycle (client)
**`lib/state/intel/session_tracker.dart`** — a `StateNotifier` + a `WidgetsBindingObserver`
(installed at the `BuildSmartApp` root, `main.dart:210-218` — note: **no app-lifecycle observer
exists today**, so this is the one new global hook, gated):
- `session_start` (mint `sessionId` uuid) on first foreground/first event;
- a **heartbeat timer** (`kHeartbeat`, default 20 s) writes `presence/{actorKey}` `{screen, sessionId, lastBeat: serverTs, displayName}` while foregrounded;
- `didChangeAppLifecycleState(paused)` → stop heartbeat + emit `session_end{reason:'background'}`;
- idle ≥ `kIdleEnd` (180 s, no events) → `session_end{reason:'idle'}`;
- logout (`currentUidProvider`→null via `ref.listen`) → `session_end{reason:'logout'}` + clear presence doc.

### 4.2 Liveness rule (manager side, deterministic)
`presence` doc is **LIVE** iff `now - lastBeat < kHeartbeat * 2.5` (≈ 50 s — tolerates one missed
beat). Else **idle/offline**. The manager's "דוד נמצא במסך התשלום, 3 דק׳" string = `displayName` +
Hebrew screen label + `now - sessionStart`.

### 4.3 Gate & inertness
The whole tracker is constructed inert on demo (`if (!useFirebaseBackend) return;` in the ctor —
the EXACT `connection_status.dart:82` idiom): no timer, no observer-driven writes, no Firestore
touched → zero cost, suite stays Firebase-free. **Pillar 5 owns** the presence collection's write
cost (heartbeat = 1 small write/20 s/active user) and the security rule (`read: role==manager`,
`write: actorKey==uid`).

---

## 5. Manager analytics UI — Hebrew, live (Phase E)

The owner sees this on the manager screen. We ADD a **5th tab** to the existing
`ManagerDashboardScreen` (`manager_dashboard_screen.dart`) — the cheapest, most consistent surface.

### 5.1 Add the tab (exact edits — grounded by the dashboard trace)
1. `_kManagerTabs` (`:3452-3457`) → add `_ManagerTab(emoji:'📡', label:'מודיעין לקוחות')`.
2. `tabCount` (`:65`) 4→5; `_kManagerTabHelp` (`:3463`) add a tuple.
3. `IndexedStack.children` (`:216-231`) → add `const _IntelTab()`.
4. The toggle (`_ManagerToggle :295-378`) auto-renders from `_kManagerTabs.length` — no edit.

### 5.2 `_IntelTab` composition (reuse the EXISTING widgets — no chart lib)
The dashboard is deliberately chart-library-free; we reuse its hand-composed widgets + tokens
(`BsTokens.bgLight/cardLight/inkLight/mutedLight/brand`, `Directionality(rtl)`, `EdgeInsetsDirectional`):

| Section (Hebrew) | Reused widget / pattern | Source |
|---|---|---|
| **חי עכשיו** (Live feed) | top strip of `_LivePill`-style chips + a streaming list (newest-first) of the in-memory ring buffer | `_LivePill :241-288`, `analytics_log.dart:52` `recent()` |
| **מי מחובר כעת** (Who's live now) | list of presence rows: 👤 `displayName` · screen · "לפני X דק׳", LIVE green dot | `_Dot :274`, presence (§4) |
| **מדדים** (KPI tiles) | `_MetricTile` grid (Σ sessions today, active now, conversion %, stuck count) | `_MetricGrid/_MetricTile :493-595` |
| **משפך רכישה** (Checkout funnel) | per-stage rows with `LinearProgressIndicator` bars (the `_CreditBar`/`_PipelineRow` pattern, a11y `Semantics` label) | `_CreditBar :1966-1986`, `_PipelineRow :677-731` |
| **תקיעות** (Stuck list) | `_StagePill`-tinted rows: "🛒 עגלה ננטשה" / "🔁 חיפוש ללא תוצאה" + count | `_StagePill :1166-1189` |
| **פילוח ושימור** (Segments/retention) | simple bar rows + a cohort grid | `_PipelineRow` bars |

### 5.3 Per-customer drill-down (the JOURNEY timeline)
Attach to the EXISTING customer drill: `_CustomerDetailSheet` (`:1998`), already keyed by customer
`name` and already `ref.watch(ordersEngineProvider)` live (`:2017-2018`). We add **one section**:
**"מסע הלקוח"** — a vertical timeline of that customer's `IntelEvent`s (join by `displayName`/`actorKey`),
each row = emoji + Hebrew label + relative time, with stuck rows highlighted via `_StagePill` colors.
Live (`ref.watch`) so it updates while open. Opening a row from "מי מחובר כעת" deep-links to the same
sheet → a single drill-down surface.

### 5.4 Manager read providers (live, gated)
**`lib/state/intel/intel_read.dart`**:
- `intelLogProvider` — `StateNotifierProvider<IntelLogNotifier, List<IntelEvent>>` (the ring buffer; cap ~1000, newest-first — the `analytics_log.dart` shape). Powers the demo + live feed.
- `presenceProvider` — live `presence/` read; on demo a const empty list (inert).
- `funnelProvider` / `segmentsProvider` / `retentionProvider` — `Provider`s that fold §3 logic over the read source. **On demo they fold the local ring buffer** (so the UI is fully demoable); **on live they fold the manager's `events/` read** (via a `FirestoreCachedRepo`-backed source, coordinated with Pillar 5). Same "pure fold over a live-watched list" shape as `managerCustomersProvider` (`orders_engine.dart:693-700`).

> a11y/RTL: every bar carries a `Semantics(label:'…')` like `_CreditBar :1974`; all Hebrew strings
> verbatim-style; tap targets ≥ 48 — matches the dashboard's existing idioms.

---

## 6. Data pipeline, volume, retention, sampling at scale (Phase B/F — coordinate w/ Pillar 5)

> We OWN the client batching/sampling policy + the collection shapes (proposed). Pillar 5 OWNS the
> Firestore cost model, TTL/retention enforcement, sharding, and security rules.

### 6.1 Client batching (the perf proof)
**`lib/state/intel/intel_sink.dart`** — `IntelSink` (live only; no-op on demo):
- `enqueue()` appends to an in-memory `List<IntelEvent>` and **returns instantly** (no await — same as `FirebaseTelemetrySink.logEvent`).
- A flush fires on the FIRST of: **N events** (`kBatchSize`, default 25), **T seconds** (`kFlushInterval`, default 10 s), or **app-paused** (`WidgetsBindingObserver.paused`). One Firestore `WriteBatch` per flush → **≤ ~6 writes/min/active user worst case**, not one-per-tap.
- Flush is `guardWrite`-style: failure is logged + the batch is RE-QUEUED (capped) — never thrown, never lost on a transient blip. Firestore offline persistence (`main.dart:133-134`) already buffers writes when offline, so the sink rides the same offline-first guarantee as orders.

### 6.2 Anonymous-but-stable actor id
When signed-out (or pre-login), `actorKey` = a per-install uuid persisted in SharedPreferences
(the `recently_viewed.dart`/`smart_input_usage.dart` persistence idiom). On sign-in we emit an
`identify`-style stitch event mapping anon→uid so the journey is continuous. Off-backend the key is
generated but never written anywhere.

### 6.3 Volume & retention (PROPOSED to Pillar 5)
- **Sampling:** `heartbeat` and high-frequency `screen_view` are **rate-limited client-side** (min `kMinInterval` 5 s between identical-screen views) so we don't write noise. Interaction/funnel events are NOT sampled (they're the signal). A `kSampleRate` config (Pillar 1, default 1.0) can down-sample for huge fleets.
- **Retention windows:** raw `events/` kept ~30–90 d (Firestore TTL policy — Pillar 5); the manager UI reads **rolling windows** (today / 7d / 30d) so a query never scans all history. Long-term trends come from a **daily rollup** (`events_daily/{yyyy-mm-dd}` — a Cloud Function aggregation, Pillar 5) so the dashboard reads O(days) docs, not O(events). This keeps cost flat as the fleet grows to 1000s.
- **Indexes:** manager reads filter `ownerId` + `ts`-window (+ `actorKey` for the drill) — composite-index needs handed to Pillar 5.

---

## 7. Privacy & consent (Phase A — blocks live capture)

The repo's legal posture is explicit and HONEST today: `lib/data/legal_texts.dart:4-13` states
"data lives on-device only … no analytics SDK … future Firebase sync is PLANNED and gated on a
policy update + user notice", and references **חוק הגנת הפרטיות תיקון 13 (14.8.2025)**. Turning on
live customer tracking **changes that fact**, so consent is a hard gate, not an afterthought.

1. **Consent gate.** Add `privAnalytics`-driven enforcement: `AppSettings` already has
   `privAnalytics` / `privCrashReports` (`lib/state/app_settings.dart:82-85`). The `IntelSink` (live
   forward, step 3) and `presence` writes are gated on `privAnalytics == true` AND `useFirebaseBackend`.
   The **local ring buffer (step 1) stays on-device** regardless (no transmission → no consent issue),
   so the demo UI works without consent.
2. **Default OFF until policy updated.** Until the privacy policy text is revised (a Pillar-0/legal
   task), ship `privAnalytics` default such that the **forward is OFF** — local-only, matching
   today's stated reality. Flip is a one-line policy decision, not code surgery.
3. **Data minimization (enforced).** No raw search text (hash + length), no contact/payment/free-text
   in `props`, uid never in user-visible logs (the `manager_role_assign_sheet.dart:172` rule). A
   registry test (§8) fails the build if an event declares a banned field.
4. **Subject rights (תיקון 13 §13/§14).** Because every wire event carries `actorKey`, deletion-by-
   subject is a single `where('actorKey',==).delete()` sweep (Pillar 5 Cloud Function) — the schema
   makes "right to erasure" mechanical.
5. **Manager-only visibility.** Reads scoped by `ownerId`/`role==manager` (the `customers/` rule
   model, `firestore-schema.md:69`) — Pillar 5 owns the rule.

---

## 8. New files & touched seams (map)

**New (this pillar owns):**
```
lib/state/intel/intel_events.dart      // IntelEvents registry (extends the TelemetryEvents idea)
lib/state/intel/intel_event.dart       // IntelEvent immutable record
lib/state/intel/intel_bus.dart         // IntelBus + intelBusProvider (the one-line seam)
lib/state/intel/intel_log.dart         // IntelLogNotifier ring buffer (analytics_log shape)
lib/state/intel/intel_sink.dart        // batched live forward (gated, no-op on demo)
lib/state/intel/session_tracker.dart   // session lifecycle + heartbeat (WidgetsBindingObserver)
lib/state/intel/presence.dart          // presenceProvider (connection_status clone)
lib/state/intel/intel_read.dart        // manager read providers (funnel/segments/retention)
lib/logic/intel/intel_config.dart      // deterministic thresholds (Pillar-1-tunable later)
lib/logic/intel/funnels.dart           // pure funnel + stuck detectors
lib/logic/intel/segments.dart          // pure segments + retention
lib/screens/intel/intel_tab.dart       // _IntelTab + sections (reuses dashboard widgets)
```
**Touched (additive, one-line each unless noted):**
```
lib/main.dart:210-218                  // install RouteObserver + (live-gated) session observer at root
lib/screens/home_shell.dart:90-97      // one ref.listen(mainTabProvider) → screen_view
lib/screens/manager_dashboard_screen.dart  // 5th tab (:65,:216-231,:3452-3463) + journey section in _CustomerDetailSheet (:1998)
lib/screens/catalog_screen.dart        // :1619 search_submit · :2229 search_no_result · :4067 product_view · :6374 add_to_cart
lib/screens/store_screen.dart          // :1591 cart_view · :2693 checkout_start · ~:2800-2825 checkout_step (order_placed :2915 already done)
WIRING.md                              // document each new wired event (knowledge_protocol_test requires sync)
knowledge/{README,ARCHITECTURE,DECISIONS}.md  // note the new intel layer
```
**Coordinate (do NOT design here):** `events/`, `sessions/`, `presence/`, `events_daily/` collections + their rules/indexes/TTL/rollup Functions (Pillar 5); threshold/sample-rate config surfacing in Studio (Pillar 1).

---

## 9. Phasing (each phase is independently green & shippable)

| Phase | Deliverable | Gate |
|---|---|---|
| **A** | Taxonomy + `IntelEvent` + `IntelBus` + local ring buffer + consent gate. Demo-only (no wire). | analyze 0 · tests green · suite Firebase-free |
| **B** | Batched `IntelSink` + anon-id + sampling/rate-limit. Inert on demo. | + sink fake test (batch/flush/requeue) |
| **C** | Pure funnel + stuck + segments + retention logic. | + pure-logic tests (hand-built event lists) |
| **D** | Session tracker + presence (live-gated clone of connection_status). | + lifecycle/liveness tests w/ fakes |
| **E** | `_IntelTab` UI + per-customer journey in `_CustomerDetailSheet`. | + widget tests (RTL, a11y, demo data renders) |
| **F** | Manager live reads over `events/`/`presence/` (with Pillar 5) + daily rollup read. | + realtime-wiring test (fake source, both directions) |

---

## 10. Risks & mitigations

1. **Perf / jank from tracking** → mitigated: bus `read`s (never `watch`s) so no rebuilds; all writes fire-and-forget + batched; rate-limited high-freq events. *Proof in §11.*
2. **Regression on demo path** → mitigated: every live component is constructed INERT off-backend (the `connection_status.dart:82` idiom); the local ring buffer is the only always-on piece and is a cheap in-memory append. The 356-test suite stays Firebase-free.
3. **Event cost explosion at 1000s of customers** → batching + sampling + rolling windows + daily rollup (§6.3); Pillar 5 owns TTL/sharding. Catalog stays out of Firestore (`firestore-schema.md:126`).
4. **Privacy / legal exposure** → consent gate + data minimization + erasure-by-actorKey (§7); forward default-OFF until policy text updated.
5. **Identity mismatch (uid vs display-name)** → events carry BOTH; manager joins by name (matching the existing `Order.who` keying) while backend keys by uid; anon→uid stitch on sign-in (§6.2).
6. **Tracking-call drift / stringly-typed names** → one `IntelEvents` registry + a registry test (§8) + WIRING.md sync (enforced by `knowledge_protocol_test.dart:91-103`).
7. **Presence false-positives** (a hung tab looks "live") → liveness = `lastBeat` freshness with a 2.5× tolerance, not mere doc-existence (§4.2).
8. **Local ring buffer memory** → capped (cap ~1000, trim-on-record — the `analytics_log.dart:33-38` invariant).

---

## 11. Gate / test strategy + zero-regression & perf proof

**The 100-gate protocol** is the `.githooks/pre-commit` registry in `knowledge/GATE_REGISTRY.md`
(groups A/B/C/D, **next free gate = 118**, audited functional by `scripts/audit_gates.sh`). The
load-bearing gates for this pillar: **31** (`flutter analyze` 0 errors), **32** (`flutter test` 0
regressions vs `test/known_failing.txt`), **33** (`flutter build web` clean), **46** (no dark
surface in screens), **94** (`knowledge_protocol_test` green). **We add one new gate (118)** that
greps `lib/state/intel/` for any raw-text/PII prop key (the §7.3 minimization rule) so the privacy
contract has teeth. Add the row to `GATE_REGISTRY.md`, bump "next free" → 119, add the condition to
`.githooks/pre-commit` (`# Gate 118: …`), and `cp` the hook into `.git/hooks/` (the registry's own
add-a-gate procedure).

```bash
export PATH="/home/user/flutter/bin:$PATH"
cd app_flutter
flutter analyze                 # Gate 31 — 0 errors (mandatory)
flutter test                    # Gate 32 — all 356+ green, INCLUDING knowledge_protocol_test
flutter build web --release     # Gate 33 — builds clean
```

**Tests to add (mirroring the repo's idioms):**
- **Registry test** (`test/intel/intel_events_test.dart`) — asserts names are unique, snake_case, ≤40 chars, and that no event declares a banned (PII/free-text) prop key. (Like `telemetry_test.dart`'s name assertions.)
- **Bus / no-op test** — with no Firebase, `intelBusProvider.track` records locally, calls the `NoopTelemetrySink`, and the `intelSinkProvider` is inert; `returnsNormally` (the `telemetry_test.dart:65-78` pattern). **This is the zero-regression proof** for the demo path.
- **Sink batch test** — a recording fake source (the `realtime_wiring_test.dart:32-50` `_FakeSource` shape, `RemoteCollectionSource` with `sets`/`deletes`) proves: enqueue is sync, flush fires at N / T / paused, a failed flush re-queues and never throws.
- **Pure-logic tests** — `funnels`/`segments`/`retention` over hand-built `IntelEvent` lists: deterministic conversion %, abandoned-cart detection, repeated-no-result, retention cohorts. No Firebase, no widgets.
- **Presence/lifecycle test** — drive `session_tracker` with a fake clock + fake source: heartbeat cadence, idle/background/logout `session_end`, liveness 2.5× rule.
- **Realtime-wiring test** — `_FakeSource` snapshot → manager `funnelProvider`/`presenceProvider` reflect it via a SYNCHRONOUS read (the `realtime_wiring_test.dart` DOWN/UP pattern); unbound (demo) path byte-identical.
- **Widget test** — `_IntelTab` + the journey section render under `Directionality(rtl)` with seeded local events; a11y `Semantics` labels present; demo data shows (no Firebase).
- **Protocol sync** — update `WIRING.md` with every new wired event and any new enforced helper so `knowledge_protocol_test.dart:91-103` stays green; the new knowledge note keeps `knowledge_protocol_test.dart:74-90` (docs-exist) green.

**Zero-regression proof (concrete):**
1. `useFirebaseBackend` is false in tests + demo (`telemetry.dart:132-135`, `backend.dart:12-17`) → `intelSinkProvider`/`presence`/`session_tracker` are all INERT (the `connection_status.dart:82` pattern) → no platform channel, no Firebase, no timer.
2. The only always-on path is `intelLogProvider.record` — an in-memory list prepend + trim (proven cheap by `analytics_log.dart`).
3. Existing call-sites (`store_screen.dart:2915`, `manager_role_assign_sheet.dart:173`) are UNCHANGED; new `track` calls are additive single statements that cannot alter control flow.
4. The whole new surface is behind a 5th tab + an optional drill section — existing 4 tabs untouched.

**Perf proof (concrete):**
- Per tap: 1 list prepend (O(1) amortized w/ trim) + 1 no-op (demo) / 1 enqueue-append (live). No `await`, no rebuild (bus uses `read`).
- Live write amplification: batched to ≤ `kBatchSize` per `WriteBatch`, flush ≤ every `kFlushInterval` or on pause → bounded ~6 writes/min/active user; heartbeat 1 write/20 s. Sampling caps the rest.
- No `watch` on the bus → tracking causes **zero widget rebuilds**; the live feed UI rebuilds only on the manager screen (which is already watching its providers).

---

## 🔧 תיקוני Red-Team R1 (מחייב — מחליף סעיפים סותרים)

> מקור: `knowledge/studio-plan/RED-TEAM-R1.md` (תמה C פריטים 11–12 · תמה E פריט 18 · תיקוני-gate · אכיפת-#84).
> כל פריט להלן **גובר** על הניסוח המקורי בגוף-המסמך כשהם סותרים. הסעיף נכתב לפני תחילת-הבנייה
> ומחליף את התיאורים הרכים ("💡", "flip של שורה אחת", "default OFF עד שתעודכן המדיניות") בדלתאות
> קונקרטיות הניתנות-לבנייה. עברית מקורקעת מול קוד (`file:line`).

### R1-1 · פרטיות default-DENY — `privAnalytics=false` + opt-in + gate לפי גרסת-מדיניות (C11)

**הבעיה (R1 #11):** היום `privAnalytics` ברירת-מחדל **`true`** (`app_settings.dart:105`), והפענוח מ-persist
הוא `priv['analytics'] != false` (`:236`) → **absent = true**. כלומר ה-forward נדלק כברירת-מחדל וגם
לכל משתמש ישן שמעולם לא ראה מסך-הסכמה. זה סותר את העמדה-החוקית המוצהרת (`legal_texts.dart:4-13`,
תיקון 13). gate-bool צף לא מבחין בין "הסכים למדיניות v1" ל-"מדיניות עודכנה ל-v2 ועוד לא הסכים מחדש".

**מה משתנה:**
1. **ברירת-מחדל הפוכה ל-DENY.** `AppSettings.defaults.privAnalytics` → **`false`** (היה `true`,
   `app_settings.dart:105`). הפענוח `fromJson` → `priv['analytics'] == true` (absent / null / כל-דבר-אחר
   = **false**) במקום `!= false` (`:236`). אין forward עד opt-in **מפורש** במסך-ההסכמה.
2. **gate לפי גרסת-מדיניות, לא bool צף.** מוסיפים שדה `consentedPolicyVersion` (`int`, default `0`)
   ל-`AppSettings` (לצד `privAnalytics`, `app_settings.dart:82-85` + `copyWith :129` + `toJson :189` +
   `fromJson :236`). קבוע `kCurrentPolicyVersion` (`int`) מנוהל ליד-טקסט-המדיניות (`legal_texts.dart`).
   ה-forward-gate ב-`IntelSink`/`presence` (step 3, §2.1) הופך מ-`privAnalytics == true` ל:
   **`consentedPolicyVersion >= kCurrentPolicyVersion && useFirebaseBackend`**.
   העלאת `kCurrentPolicyVersion` (שינוי-מדיניות עתידי) **מאפסת הסכמה דה-פקטו** עד re-opt-in — בדיוק
   הדרישה של תיקון 13 ל-"הסכמה מדעת ומעודכנת". `privAnalytics` נשאר ה-toggle הגלוי; ההסכמה-בתוקף =
   צמד (toggle ON **וגם** גרסה-מעודכנת).
3. **שלב-86 = build-step אמיתי, לא "💡".** מה שתואר ב-§7.2 כ-"flip של שורה אחת" הופך ל**שלב-בנייה
   מלא**: (א) מסך/דיאלוג-הסכמה שמציג את טקסט-המדיניות (`legal_texts.dart`), (ב) על "אני מסכים"
   כותב `privAnalytics=true` **וגם** `consentedPolicyVersion=kCurrentPolicyVersion` בטרנזקציה אחת,
   (ג) טסט שמוודא: ללא-מעבר-במסך → forward inert; אחרי-הסכמה → forward enabled; אחרי-bump-גרסה →
   forward inert-שוב. ה-local ring buffer (step 1) נשאר on-device תמיד ללא תלות בהסכמה (אין שידור).

**§-מוחלף:** §7.1 ("gated on `privAnalytics == true`") · §7.2 ("Default OFF … Flip is a one-line policy
decision") · §10 risk #4 · טבלת-§9 Phase-A "consent gate".
**שלב מושפע:** שלב-86 (privacy-gate; היום מתואר כקיים ב-RED-TEAM §"מה מחזיק" — מתחזק ל-build-step) ·
Phase A (§9).

### R1-2 · presence consent נפרד — `privPresence` default-OFF + TTL קצר + בסיס-חוקי (C11)

**הבעיה (R1 #11):** presence ("איפה הלקוח עכשיו") הוא **מעקב-מיקום-בהקשר** חודרני בהרבה מ-funnel-אנליטיקה,
ובמסמך-המקורי הוא חוסה תחת אותו `privAnalytics` (§4.3 → "`write: actorKey==uid`" בלי הסכמה-נפרדת). הסכמה
אחת-לכל אינה מידתית.

**מה משתנה:**
1. **toggle נפרד `privPresence`.** שדה `bool` חדש ב-`AppSettings` (לצד `privAnalytics`,
   `app_settings.dart:82-85` + כל-ארבעת-המקומות כמו R1-1), **default `false`**. כתיבת `presence/{...}`
   ב-`session_tracker` (§4.1) נשמרת מאחורי gate **עצמאי**:
   `privPresence == true && consentedPolicyVersion >= kCurrentPolicyVersion && useFirebaseBackend`.
   כיבוי-presence **לא** מכבה funnel-אנליטיקה ולהפך — שני הסכמות מתועדות בנפרד.
2. **TTL קצר על presence.** doc-ה-`presence/{actorKey}` נושא `expireAt = serverTs + kPresenceTtl`
   (`kPresenceTtl` קצר, סדר-גודל **דקות** — לא 30–90 יום של `events/`); Firestore-TTL מוחק אוטומטית
   (אכיפה ב-Pillar 5). presence הוא חי-בלבד, לא היסטוריית-תנועה. `session_end` (background/idle/logout,
   §4.1) **מוחק** את ה-doc מיידית, לא מסתמך רק על TTL.
3. **בסיס-חוקי + מידתיות מתועד.** ליד `legal_texts.dart` נוסף נימוק קצר: מטרה (תמיכת-לקוח בזמן-אמת),
   מינימיזציה (רק `screen`+`lastBeat`, ללא קואורדינטות-GPS — `privLocation` נשאר נפרד ו-DEAD,
   `app_settings.dart:83`), TTL-דקות, ו-opt-in-נפרד. זהו ה"בסיס-חוקי/מידתיות" שתיקון 13 דורש.
4. **presence-read = לקוחות בלבד.** ראה R1-5 — presence נכתב/נקרא **רק** עבור actors-לקוחות, לא צוות.

**§-מוחלף:** §4 (מודל presence — מוסיף toggle+TTL) · §4.1 (heartbeat write) · §4.3 ("Gate & inertness" —
gate מתפצל מ-`privAnalytics` ל-`privPresence`) · §7.1.
**שלב מושפע:** Phase D (§9 — session tracker + presence) · שלב-86.

### R1-3 · erasure שלם — `actorKey` + `uid` + `presence/{uid}` + שורות-displayName (C12)

**הבעיה (R1 #12):** §7.4 מתאר מחיקה כ-"single `where('actorKey',==).delete()` sweep" — אבל זה **מפספס**:
(א) doc-ה-`presence/{uid}` (אם מפתח-presence הוא uid ולא actorKey), (ב) אירועים שנכתבו עם `actorKey`=anon
**לפני** ה-stitch ל-uid (§6.2 — anon→uid), (ג) שורות שנשאו `displayName` בלבד (מצטרפות-בשם ב-§5.3).

**מה משתנה:** "מחיקת-נושא" (תיקון 13 §13/§14) = **טאטוא רב-מפתחי** ב-Cloud-Function (Pillar 5),
שמוחק את **כל** הבאים עבור נושא-נתון:
- `events/` ב-`where('actorKey', whereIn: [uid, ...allKnownAnonKeysForUid])` — כולל מפתחות-anon
  שקדמו ל-stitch (ה-stitch של §6.2 חייב לכן **לתעד את מיפוי anon→uid בצד-השרת** כדי שהמחיקה תוכל
  לאחות אותם; בלי זה אירועי-pre-login הם יתומים בלתי-נמחקים).
- `presence/{uid}` **וגם** `presence/{actorKey}` לכל מפתח רלוונטי.
- `sessions/` (אם קיים, §8) באותו תנאי-`whereIn`.
- **שורות displayName-only** — מנוקות/מאופסות (`displayName → ''`) גם כשאין `actorKey` תואם, כי
  הן עדיין PII מצטרף-בשם (§5.3, `Order.who` join).
- **טסט-שלמות-מחיקה** (חובה): seed אירועי-anon + אירועי-uid + presence + שורת-displayName → הרצת
  ה-sweep → assert **אפס** שאריות בכל הקולקציות עבור הנושא (כולל presence ו-pre-stitch-anon).
  זהו טסט חדש מעל הטסטים של §11.

**§-מוחלף:** §7.4 ("single `where('actorKey',==).delete()`") · §6.2 (stitch חייב לתעד מיפוי שרת-צד) ·
§10 risk #4 · §11 (מוסיף טסט-שלמות-מחיקה).
**שלב מושפע:** Phase F (§9 — manager reads/backend) · שלב-86 · תיאום Pillar 5.

### R1-4 · צמצום displayName על-החוט — key by `actorKey`, resolve-name owner-side (PII)

**הבעיה:** §1.2 / wire-doc (§1.2 line 99) שולח `displayName` **בכל אירוע** על-החוט ובכל doc ב-`events/`,
מה שמשכפל PII (שם-לקוח) באלפי-רשומות ומרחיב משטח-החשיפה + נטל-המחיקה (R1-3).

**מה משתנה:**
1. **על-החוט: `actorKey` בלבד.** doc-ה-`events/{autoId}` (§1.2) **משמיט** את `displayName` כברירת-מחדל;
   המפתח-היחיד הוא `actorKey`. השדה `displayName` ב-`IntelEvent` (§1.2 טבלה) נשאר **in-memory-בלבד**
   (ל-local ring buffer + live-feed דמו), ולא נכתב ל-Firestore.
2. **resolve-name בצד-הבעלים בלבד.** ה-join-בשם ל-`managerCustomersProvider` (§3.3, §5.3) נעשה
   **owner-side**: ה-UI של המנהל מתרגם `actorKey → displayName` דרך מקור-שמות שכבר-מורשה-למנהל
   (שורות-`orders`/`customers` הקיימות, `orders_engine.dart:693-700`), ולא דרך שם-מוטבע-באירוע.
   כך השם לעולם לא נוסע בערוץ-האנליטיקה; הוא נפתר רק היכן שכבר מותר (מסך-המנהל).
3. אם join-בשם בלתי-אפשרי ל-actor מסוים (anon ללא הזמנה) — מוצג `actorKey`-מקוצר/אנונימי, לא שם.

**§-מוחלף:** §1.2 (טבלת-`IntelEvent` + wire-doc line 99 — `displayName` יורד מהחוט) · §3.3 · §5.3 ·
§6.2 · §10 risk #5 (זהות עדיין דו-ערכית, אך ההצטרפות owner-side).
**שלב מושפע:** Phase A (סכמת-אירוע) · Phase E/F (resolve owner-side).

### R1-5 · אכיפת-#84 — read = `isManager()`, אך ללא הרחבת-פיקוח על צוות; presence = לקוחות בלבד

**הבעיה:** §4.3 / §5.4 / §7.5 ממסגרים את ה-read כ-`role==manager` גנרי. אך #84 (גבול-הפיקוח) דורש
ש-presence/analytics **לא** יהפכו לכלי-מעקב-התנהגותי על צוות (worker/courier). presence-read במסמך
אינו מבחין בין actor-לקוח ל-actor-צוות.

**מה משתנה:**
1. **read-gate = `isManager()`** (לא bool-תפקיד גולמי) — מתואם לאכיפה ב-#84; הכלל ב-rules
   (`read: isManager()`) ב-Pillar 5.
2. **presence = actors-לקוחות בלבד.** כתיבת `presence/{...}` (§4.1) מותנית ב-actor שהוא **לקוח**
   (לא `worker`/`courier`). מודל-הפרסונה הוא `roleProvider` (String?, null=קבלן/לקוח — מקור-האמת
   היחיד שנקבע ב-RED-TEAM תמה A #2). actor-צוות **לא** כותב presence ולא נקרא ב-"מי מחובר כעת" (§5.2).
   הרחבת-פיקוח-על-צוות = **מעבר ל-#84**, מחוץ-לתחום-Pillar-3.
3. **תיעוד-גבול מפורש.** במסמך-זה ובכללי-Pillar-5: "read=`isManager()` נועד לראות **לקוחות** בזמן-אמת;
   הוא **אינו** מרחיב פיקוח-התנהגותי על צוות-העובדים". זהו תנאי-עיצוב, לא רק הערה.

**§-מוחלף:** §4.3 ("`read: role==manager`") · §5.2 ("מי מחובר כעת") · §5.4 (`presenceProvider`) ·
§7.5 ("Manager-only visibility").
**שלב מושפע:** Phase D/E/F · תיאום #84 + Pillar 5 rules.

### R1-6 · gate-מספר — P3 = **120** (לא 118), analytics-PII

**הבעיה (R1 תיקוני-gate):** §11 (line 404) ו-§8 (line 360 דרך §11) תופסים gate **118** ל-P3.
התנגשות-gate-118: P1/P3/P4 כולם תפסו 118. ההכרעה-האחידה: **118 = P1 config-registry** ·
**119 = P4 AI-grounded-config** · **120 = P3 analytics-PII**.

**מה משתנה:** הגייט שגורף `lib/state/intel/` לאיתור prop-key של PII/raw-text (§7.3) נרשם כ-**gate 120**
(לא 118). לרשום מראש ב-`GATE_REGISTRY.md` את 3-השורות (118/119/120) לפני בנייה; "next free" →
121 אחרי הקצאת-השלישייה. עדכון §11 (line 404: "We add one new gate (118)" → "gate 120") ו-§8.

**§-מוחלף:** §11 (line 404, מספר-הגייט 118→120) · §8 (אזכור-עקיף).
**שלב מושפע:** כל-הקומיטים (pre-commit hook) · `GATE_REGISTRY.md`.

### R1-7 · שלב-חסר (תמה E #18) — אובזרבביליות לשימוש-בסטודיו עצמו (רפלקסיבי)

**הבעיה (R1 #18):** התוכנית מודדת את **הלקוח** אך לא את **השימוש-בסטודיו עצמו** (קונכיית-הניהול/העריכה).
"אובזרבביליות לשימוש-בסטודיו" נרשם כ-MED חסר. עדשת-המודיעין צריכה להיות **רפלקסיבית** — לחול גם על
מי-שמפעיל את הסטודיו.

**מה משתנה:** שלב חדש (Phase E-bis / סמוך ל-Phase E) — instrumentation של אירועי-סטודיו-פנימיים דרך
**אותו `IntelBus`** (§2.1), תחת אותם-מעקות (consent/minimization/erasure של R1-1..4):
- `studio_edit_session` `{dur_s, ops}` — אורך וגודל-סשן-עריכה (open→publish/discard).
- `studio_ai_op_blocked` `{reason}` — פעולת-AI שנחסמה ע"י anti-hallucination / role-floor /
   validateSafe (RED-TEAM §"מה מחזיק" closed-set-drop) — אות לשיפור-UX/grounding.
- `studio_draft_abandon` `{age_s, dirty_ops}` — draft שננטש ללא publish (מקביל ל-cart-abandon, §3.2).

actors-אלה הם **בעלים/מנהלים** (לא לקוחות), ולכן presence-עליהם **אינו** נכתב (R1-5 — presence=לקוחות);
זו אובזרבביליות-מוצר על תהליך-העריכה, לא פיקוח-נוכחות. הדטקטורים (§3) חלים זהה (abandon/blocked-loop).

**§-חדש:** מרחיב §1.1 (taxonomy — בלוק "Studio-self" חדש) · §3.2 (detector ל-draft-abandon) · §9
(Phase E-bis) · §10 (אין risk חדש — חוסה תחת אותם-מעקות).
**שלב מושפע:** Phase E (§9) + שלב-חדש בתוך טקסונומיית-100-השלבים (RED-TEAM תמה E).

> **סיכום-מחייב:** ברירות-המחדל לפרטיות הן **DENY** (`privAnalytics=false`, `privPresence=false`),
> ההסכמה-בתוקף נקבעת לפי **`consentedPolicyVersion >= kCurrentPolicyVersion`** (לא bool צף),
> presence הוא opt-in-נפרד · TTL-דקות · **לקוחות-בלבד**, מחיקה-שלמה מטאטאת `uid`+anon+presence+שם
> (עם טסט-שלמות), `displayName` **לא** נוסע על-החוט (resolve owner-side), gate-PII = **120**,
> ועדשת-המודיעין חלה גם **רפלקסיבית** על השימוש-בסטודיו. כל אלה גוברים על הניסוח-הרך בגוף-המסמך.
