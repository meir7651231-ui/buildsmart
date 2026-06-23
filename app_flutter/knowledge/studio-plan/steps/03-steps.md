# Pillar 3 — Live Customer Intelligence · Steps 86–100 (phase 6, FINAL block)

> Decomposed from `knowledge/studio-plan/03-live-customer-intelligence.md`.
> Branch `claude/whats-happening-LyY9G` · `app_flutter/` (Flutter 3.29 · Riverpod).
> **EXACTLY 15 atomic, dependency-ordered steps.** Step 100 = platform-wide GA lock (the "100%, not 99" finish).
>
> Constraints baked into every step: instrumentation zero-regression + near-zero perf
> (fire-and-forget, batched) · gated **default OFF until privacy-policy text ships** · Hebrew/RTL/a11y ·
> 100-gate protocol (gates 31/32/33/46/94 + new **118**) · governance #84 (owner/manager-only reads).
> Each step is independently shippable and gate-passing. Format:
> `N. <action ≤14 words> · <file:seam> · <gate/test> · <zero-reg note>`

86. Update privacy-policy text to disclose gated live analytics · `lib/data/legal_texts.dart:4-13` (revise "no analytics SDK" + תיקון 13 §11/§13/§14 notice) · `legal_screen` widget test renders new text · text-only, no code path changes — gate to enabling forward.
87. Add `IntelEvents` registry + `IntelEvent` immutable record · new `lib/state/intel/intel_events.dart` + `lib/state/intel/intel_event.dart` (extends `TelemetryEvents` idea, `telemetry.dart:139-148`) · `test/intel/intel_events_test.dart` (unique/snake_case/≤40/no-PII-key) · pure data, no wiring yet.
88. Add `IntelLogNotifier` ring buffer (cap ~1000, newest-first) · new `lib/state/intel/intel_log.dart` (`analytics_log.dart:33-38` trim invariant) · unit test record/trim/recent · in-memory only, never persisted.
89. Add `IntelBus` one-line seam fanning local + telemetry + (inert) sink · new `lib/state/intel/intel_bus.dart` (`telemetry.dart:47`, `read` not `watch`) · bus no-op test `returnsNormally` w/o Firebase · never awaits/throws; demo = local append only.
90. Add consent-gated batched `IntelSink` (N/T/paused flush, requeue) · new `lib/state/intel/intel_sink.dart` gated `useFirebaseBackend && privAnalytics` (`app_settings.dart:82`, `backend.dart:12-17`) · sink fake test (sync enqueue/flush/requeue) · inert no-op off-backend (`connection_status.dart:82` idiom).
91. Add anon-but-stable `actorKey` (per-install uuid) + sign-in stitch · `lib/state/intel/intel_sink.dart` + SharedPreferences (`recently_viewed.dart` idiom) · unit test stitch anon→uid continuity · off-backend key generated, never written.
92. Adopt `screen_view` via RouteObserver + shell tab listener · `lib/main.dart:210-218` (navigatorObservers) + `lib/screens/home_shell.dart:90-97` one `ref.listen(mainTabProvider)` · widget test fires on tab/route change · `read`-only, no rebuilds; ~3 edits not 270.
93. Adopt catalog interaction events (search/no-result/view/cart) · `catalog_screen.dart:1614` `search_submit` · `:2229` `search_no_result` · `:4067` `product_view` · `:6374` `add_to_cart` · widget test each emits once · single statements, no constructor/control-flow change.
94. Adopt store funnel events (cart/checkout-start/step) · `store_screen.dart:1565` `_CartView` cart_view · `:2693` `checkout_start` · `~:2800-2825` `checkout_step` (order_placed `:2916` already wired) · widget test emits · additive single lines, demo byte-identical.
95. Add deterministic funnel + stuck/abandon/dead-end detectors · new `lib/logic/intel/funnels.dart` + `lib/logic/intel/intel_config.dart` thresholds (`manager_dashboard.dart:29-36` fold) · pure-logic tests on hand-built event lists · pure Dart, no Firebase/widgets.
96. Add pure segments + retention cohort derivations (join by name) · new `lib/logic/intel/segments.dart` (keyed `actorKey`/`displayName` → `managerCustomersProvider`, `orders_engine.dart:693-700`) · cohort/roll-up unit tests · pure fold, deterministic.
97. Add session tracker + heartbeat presence (connection_status clone) · new `lib/state/intel/session_tracker.dart` + `lib/state/intel/presence.dart`, root observer `main.dart:210-218`, liveness 2.5× rule · lifecycle/liveness tests w/ fake clock+source · inert ctor off-backend (`connection_status.dart:82`).
98. Add manager intel read providers + 5th tab `_IntelTab` (Hebrew/RTL) · new `lib/state/intel/intel_read.dart` + `lib/screens/intel/intel_tab.dart`; `manager_dashboard_screen.dart:65` 4→5, `:216-231`, `:3452-3463` (📡 מודיעין לקוחות) reusing `_MetricTile`/`_CreditBar`/`_StagePill` · widget test RTL + `Semantics` + demo data renders · existing 4 tabs untouched, demo folds local buffer.
99. Add per-customer journey timeline + privacy gate 118 + WIRING/docs · `manager_dashboard_screen.dart:2017-2018` `_CustomerDetailSheet` "מסע הלקוח" section (join by name, live `watch`); add Gate 118 (grep `lib/state/intel/` PII key) to `GATE_REGISTRY.md`+`.githooks/pre-commit`, bump next-free→119; update `WIRING.md` + README/ARCHITECTURE/DECISIONS · realtime-wiring test (`_FakeSource` both directions) + `knowledge_protocol_test` green (gate 94) · additive drill section, erasure-by-actorKey mechanical.
100. Platform-wide GA lock — flip forward ON, full gate + owner-approval · all pillars: `flutter analyze` 0 + full suite green + APK build flags-ON smoke + per-module owner-approval gate (governance #84) + every `WIRING.md`/knowledge doc synced · gates 31/32/33/46/94/118 ALL pass on device · default-OFF→ON only after step 86 policy shipped; the "100%, not 99" finish.
