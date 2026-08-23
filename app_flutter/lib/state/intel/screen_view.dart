// ─────────────────────────────────────────────────────────────────────────────
// screen_view — Pillar-3 STUDIO · step 92 — automatic `screen_view` on every
// route / tab transition, in ~3 edits instead of 270.
//
// Two READ-ONLY seams feed ONE event ([IntelEvents.screenView]) into the bus:
//
//   (1) [IntelRouteObserver] — a single NavigatorObserver installed once in
//       `MaterialApp.navigatorObservers` (main.dart). It fires screen_view on
//       didPush / didPopNext of any *named* route, so NO screen has to remember
//       to emit — the "~3 edits, not 270" adoption. It holds the bus by
//       reference and READS it (never subscribes) → it can never rebuild.
//   (2) [listenTabScreenView] — the ONE `ref.listen` the shell registers on the
//       provider that actually drives the bottom-nav (`mainTabProvider`). A tab
//       switch maps index→key and emits screen_view. `ref.listen` (never
//       `ref.watch`) → the tab tracking adds ZERO rebuild on top of the shell's
//       existing tab-UI watch (`home_shell.dart:69`).
//
// SINGLE SOURCE OF TRUTH (§6): [screenKeyForTab] / [screenKeyForRoute] are the
// only place a screen key is derived, so the step-98/99 journey timeline reuses
// them — zero duplicated strings.
//
// DEDUPE (§3/§4) — "exactly once per real navigation": the observer drops a
// consecutive same-key push, AND the bus's own §9 min-interval throttle collapses
// a screen_view that repeats inside 1s. Together they prevent every double-fire
// (a rebuild never re-fires — a NavigatorObserver hook runs once per navigation,
// and `ref.listen` only fires on a CHANGE, not on rebuild).
//
// RECONCILIATION (§3): the plan feared the shell held a LOCAL `tabIndex`. The
// LIVE shell instead reads `ref.watch(mainTabProvider)` (home_shell.dart:69/:563)
// and writes `ref.read(mainTabProvider.notifier).state` (:171), so the listener
// binds to `mainTabProvider` — the REAL source — NOT a local field.
//
// DEMO-PATH INERTNESS: every app route today is an unnamed `MaterialPageRoute`
// (`route.settings.name == null`), so [screenKeyForRoute] returns null for all of
// them and the observer emits NOTHING for a real push — zero user-visible change,
// the 4 tabs stay byte-identical. The observer activates the moment a route opts
// in with `RouteSettings(name: …)`; the tab listener is the workhorse today.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/intel/intel_bus.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The four bottom-nav tabs → their stable screen keys, in the shell's tab order
/// (בית · מחלקות · עדכונים · חנות — `home_shell.dart` `_BottomNav`). The ONE place
/// a tab key is spelled (§6). Out-of-range indices fall back to a safe `tab_N`.
String screenKeyForTab(int index) => switch (index) {
      0 => 'home',
      1 => 'departments',
      2 => 'updates',
      3 => 'store',
      _ => 'tab_$index',
    };

/// A pushed route's name → its screen key, or null when the route is unnamed or
/// is the app root (`'/'`). App routes are unnamed `MaterialPageRoute`s today, so
/// this is null for them (the observer then emits nothing — zero demo-path
/// change); a route that opts in with `RouteSettings(name: …)` gets its name as
/// the key. A leading `'/'` is stripped and the bare root (`'/'`) folds to null.
String? screenKeyForRoute(String? name) {
  if (name == null) return null;
  final key = name.startsWith('/') ? name.substring(1) : name;
  return key.isEmpty ? null : key;
}

/// The ONE NavigatorObserver (installed in main.dart's
/// `MaterialApp.navigatorObservers`) that turns every *named* route push/pop into
/// a `screen_view` — so no individual screen has to emit (§2, the ~3-edits win).
///
/// It IS-A `RouteObserver<ModalRoute<dynamic>>` (the exact type the plan names, so
/// `RouteAware` widgets can still subscribe for the step-98/99 journey) but ALSO
/// overrides the [NavigatorObserver] hooks to emit CENTRALLY — a plain
/// RouteObserver only notifies RouteAware subscribers and could not identify
/// WHICH screen was pushed without every screen opting in (the 270-edit trap §2
/// exists to avoid).
///
/// READ-ONLY (§4/§8): it holds the bus by reference ([bind], idempotent) and
/// calls fire-and-forget [IntelBus.track]; it never subscribes to a provider, so
/// it can never trigger a rebuild. There is NO `ref.watch` / `.watch(` here (the
/// screen_view test grep-guards it, mirroring intel_bus.dart).
class IntelRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  IntelBus? _bus;

  /// The last screen key we emitted — used BOTH for the `prev` prop and for the
  /// consecutive-duplicate dedupe (§3). Reset to null when we return to an
  /// unmapped host (the shell), so a later re-push of the same screen re-emits.
  String? _lastScreen;

  /// Give the observer its bus, ONCE (idempotent `??=`). Called read-only from
  /// the app root's build (main.dart) — a stable-singleton hand-off, never a
  /// rebuild dependency. Tests inject a container's bus directly.
  void bind(IntelBus bus) => _bus ??= bus;

  /// Emit `screen_view` for [screen], carrying the previous key as `prev` (§9,
  /// addition-a). Drops a null (unmapped) route and a consecutive duplicate (§3);
  /// the bus additionally throttles repeats inside 1s. Fire-and-forget — a screen
  /// never crashes from tracking (the bus swallows any failure).
  void _track(String? screen) {
    final bus = _bus;
    if (bus == null || screen == null) return;
    if (screen == _lastScreen) return; // consecutive same-route dedupe (§3)
    final prev = _lastScreen;
    _lastScreen = screen;
    bus.track(
      IntelEvents.screenView,
      props: <String, String>{
        'screen': screen,
        if (prev != null) 'prev': prev,
      },
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(screenKeyForRoute(route.settings.name));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // didPopNext semantics: the revealed [previousRoute] becomes current again.
    // Returning to an unmapped host (the shell → null) just clears the tracker so
    // a later re-push re-emits; returning to a mapped route re-emits it (+ prev).
    final screen = screenKeyForRoute(previousRoute?.settings.name);
    if (screen == null) {
      _lastScreen = null;
      return;
    }
    _track(screen);
  }
}

/// The ONE read-only `screen_view` seam the shell registers (in `home_shell.dart`
/// build). It LISTENS — never watches — [mainTabProvider] (the RECONCILED real
/// tab source, §3), so a tab switch emits exactly one `screen_view` mapping
/// index→key (with the previous tab as `prev`), and the tracking adds ZERO
/// rebuild on top of the shell's existing tab-UI watch. Idempotent per element:
/// `ref.listen` in build re-registers the same single subscription across
/// rebuilds and fires only on an actual change — a rebuild never re-fires.
void listenTabScreenView(WidgetRef ref) {
  ref.listen<int>(mainTabProvider, (prev, next) {
    if (prev == next) return;
    ref.read(intelBusProvider).track(
      IntelEvents.screenView,
      props: <String, String>{
        'screen': screenKeyForTab(next),
        if (prev != null) 'prev': screenKeyForTab(prev),
      },
    );
  });
}
