// dept_location — the SEALED "where am I on the מחלקות tab" snapshot that drives
// the LIVE-MIRROR floating keyboard, mirroring updates_location.dart /
// store_location.dart EXACTLY (the proven, gate-green pattern).
//
// PRINCIPLE (owner SSOT): on the מחלקות tab the floating keyboard is a LIVE MIRROR
// — at every click it re-derives BOTH its tools AND its predictions from the
// current spot. The pure function that does the deriving ([deriveDeptContext],
// keyboard_dept_deriver.dart) takes ONE location input: a [DeptLocation]. This
// file defines that input as a SEALED value type plus the derived
// [deptLocationProvider] that recomputes it from the live department selection.
//
// WHY A SEALED VALUE TYPE (load-bearing — the single most important detail, same
// as UpdatesLocation / StoreLocation): [deptLocationProvider] is a derived
// `Provider`, so Riverpod notifies its listeners (the keyboard) ONLY when the
// newly computed location is `!=` the previous one. If these subclasses lacked
// TRUE value equality the provider would emit a fresh instance every frame and
// the keyboard would re-derive its whole row at 60fps (churn). So every subclass
// is `@immutable`, overrides `==`/`hashCode` by VALUE, and carries NO list field
// — the department surface is the four STATIC department chips (the deriver emits
// them from a const list), so this location holds no data to compare.
// `equatable` is not a dependency of this app, so we use explicit operators (the
// SAME dependency-free idiom updates_location.dart / store_location.dart /
// state/auth_state.dart use).
//
// WHY A SINGLE [DeptRoot] CASE (the THIN scope): the מחלקות surface is a STABLE
// NAV ROW — the four live departments are ALWAYS the surface, exactly like a
// fixed bottom-nav. Selecting a department (homeDepartmentProvider != null) opens
// that department's catalog UNDERNEATH but the keyboard still shows the same four
// chips so the user can switch between them (a stable nav row, never a dead end).
// So one root case is the whole thin scope. The provider still WATCHES
// homeDepartmentProvider, so it is reactive and ready to extend (a future
// per-department drill location is a new subclass + a new deriver arm, no
// signature break) — but the thin arm always returns the same [DeptRoot].
//
// WHY IT DOES NOT WATCH mainTabProvider: the tab is the OUTER guard, watched at
// the keyboard (the deriver is consulted ONLY when tab == 1). Watching it here
// too would couple this provider to cross-tab churn for no gain — leaving מחלקות
// already stops the keyboard from reading this provider at all. (Identical
// rationale to updates_location.dart (tab == 2) / store_location.dart (tab == 3).)

import 'package:buildsmart/screens/departments_screen.dart'
    show homeDepartmentProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WHERE the user is on the מחלקות tab, as a SEALED value type — the single
/// location input to the pure [deriveDeptContext]. In the THIN scope there is
/// exactly ONE location:
///
///   • [DeptRoot] — the departments surface: the deriver shows the four live
///                  department chips (אינסטלציה / ברזים וסניטריים / כלי עבודה
///                  ידני / כלי עבודה חשמלי) as REAL [KbDestination]s (reusing the
///                  registry's `_openDepartment` runs) + department-level tools.
///                  The four are ALWAYS the surface (a stable nav row), so a
///                  selected department still shows all four — you can switch
///                  between them — mirroring how a department tile keeps the shell
///                  chrome put.
///
/// EXHAUSTIVE: the deriver switches over this sealed type with no default, so a
/// future second location (e.g. a per-department drill) is a compile error at the
/// deriver (very_good_analysis enforces the exhaustive switch) rather than a
/// silent fall-through — identical to UpdatesLocation / StoreLocation.
@immutable
sealed class DeptLocation {
  const DeptLocation();
}

/// The departments surface: the four live department chips + department tools.
/// Carries NO field in the thin scope — the four departments are STATIC (the
/// deriver emits them from a const list, like StoreLocation's [ServicesLocation]
/// or UpdatesLocation's [NotifsLocation] type chips), so the location is a pure
/// singleton compared by [runtimeType]. (A future selected-department drill would
/// add a `department`-carrying subclass; the root stays the always-present nav
/// row.)
@immutable
final class DeptRoot extends DeptLocation {
  const DeptRoot();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DeptRoot;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The LIVE מחלקות location — the single derived location input to the keyboard's
/// pure deriver. Recomputes (and, thanks to the value-equality above, NOTIFIES)
/// only when its one watched source actually changes value:
///   • `homeDepartmentProvider` — the selected department (null = the grid).
///
/// In the THIN scope every value of `homeDepartmentProvider` maps to the SAME
/// [DeptRoot] (the four departments are always the surface), so the location is
/// effectively constant and the provider never churns — but the watch is kept so
/// this provider is reactive and ready to extend (a future per-department drill
/// is a new switch arm here + a new deriver arm, no signature break). The
/// value-equality on [DeptRoot] means re-deriving the same root is a structural
/// no-op (Riverpod skips the notify), so the keep-the-watch cost is zero churn.
///
/// It does NOT watch `mainTabProvider`: the tab is the keyboard's outer guard
/// (the keyboard reads this provider only at tab 1), so watching it here would
/// add cross-tab churn for nothing. (Identical to updates_location.dart /
/// store_location.dart.)
final deptLocationProvider = Provider<DeptLocation>((ref) {
  // Watched for reactivity + future extension; the thin arm collapses every
  // department (and the null grid) to the same stable [DeptRoot] nav row.
  ref.watch(homeDepartmentProvider);
  return const DeptRoot();
});
