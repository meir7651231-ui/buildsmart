// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · ORG-GATES — the giant-system V2's ONE wiring seam: every V2
// surface asks [modOn]/[featOn] (and ONLY these) whether an org module /
// feature is in force; nothing else reads [orgConfigProvider] for gating.
//
// The four rules every gated site honors:
//   · build() ONLY — gates WATCH ([WidgetRef.watch]), so when the V5 wizard
//     swaps [orgConfigProvider] live, every gated surface rebuilds with no
//     restart; never call a gate from an event handler or initState;
//   · popup itemBuilder closures (PopupMenuButton and kin) run OUTSIDE
//     build() — watching there is Riverpod misuse: compute the booleans in
//     build() and let the closure CAPTURE them;
//   · compile-floor consts always AND FIRST at co-gated sites
//     (`kProfileX && modOn(…)`): a false const tree-shakes the whole branch
//     out of the binary — runtime config can never resurrect what the
//     compile floor removed;
//   · default all-on ([kDefaultOrgConfig], absent=on) ⇒ every gate reads
//     true ⇒ the un-overridden (define-less) suite stays byte-identical.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/config/org_config.dart' show featureOn, moduleOn, termOf;
import 'package:buildsmart/state/org_config_store.dart' show orgConfigProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Is [module] on for the org in force? Reads LIVE (`watch`) — build() only.
/// Absent=on + core-never-off semantics ride in from [moduleOn].
bool modOn(WidgetRef ref, String module) =>
    moduleOn(ref.watch(orgConfigProvider), module);

/// Is [feature] of [module] on for the org in force? Reads LIVE (`watch`) —
/// build() only. Module-off cascades false, per [featureOn].
bool featOn(WidgetRef ref, String module, String feature) =>
    featureOn(ref.watch(orgConfigProvider), module, feature);

/// The org's wording for [key] — LIVE (`watch`), build() only: when the V5
/// wizard swaps [orgConfigProvider], every termed label re-renders. Absent /
/// empty override ⇒ [fallback] IDENTITY (the byte-identical default).
String orgTerm(WidgetRef ref, String key, String fallback) =>
    termOf(ref.watch(orgConfigProvider), key, fallback);

/// One-shot term read for strings composed OUTSIDE build() — sheet-open
/// paths and event handlers, where `watch` is Riverpod misuse and a live
/// swap cannot re-compose an already-shown string anyway. Never call this
/// in build(): it does not subscribe, so the label would go stale.
String orgTermNow(WidgetRef ref, String key, String fallback) =>
    termOf(ref.read(orgConfigProvider), key, fallback);
