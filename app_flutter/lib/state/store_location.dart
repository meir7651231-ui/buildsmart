// store_location — the SEALED "where am I on the חנות tab" snapshot that drives
// the LIVE-MIRROR floating keyboard, mirroring updates_location.dart EXACTLY.
//
// PRINCIPLE (owner SSOT): on the חנות tab the floating keyboard is a LIVE MIRROR
// — at every click it re-derives BOTH its tools AND its predictions from the
// current spot. The pure function that does the deriving ([deriveStoreContext],
// keyboard_store_deriver.dart) takes ONE location input: a [StoreLocation]. This
// file defines that input as a SEALED value type plus the derived
// [storeLocationProvider] that recomputes it from the live store section.
//
// WHY A SEALED VALUE TYPE (load-bearing — the single most important detail, same
// as UpdatesLocation): [storeLocationProvider] is a derived `Provider`, so
// Riverpod notifies its listeners (the keyboard) ONLY when the newly computed
// location is `!=` the previous one. If these subclasses lacked TRUE value
// equality the provider would emit a fresh instance every frame and the keyboard
// would re-derive its whole row at 60fps (churn). So every subclass is
// `@immutable`, overrides `==`/`hashCode` by VALUE, and (per the עדכונים
// precedent) carries NO list field — the store DATA (cart lines / orders /
// services) is NOT held here; the keyboard reads the live providers and passes
// the lists to the deriver as params, keeping this location cheap to compare.
// `equatable` is not a dependency of this app, so we use explicit operators (the
// SAME dependency-free idiom updates_location.dart / state/auth_state.dart use).
//
// WHY IT DOES NOT WATCH mainTabProvider: the tab is the OUTER guard, watched at
// the keyboard (the deriver is consulted ONLY when tab == 3). Watching it here
// too would couple this provider to cross-tab churn for no gain — leaving חנות
// already stops the keyboard from reading this provider at all. (Identical
// rationale to updates_location.dart, where tab == 2 is the outer guard.)

import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WHERE the user is on the חנות tab, as a SEALED value type — the single
/// location input to the pure [deriveStoreContext]. Exactly four locations mirror
/// the four [StoreSection] surfaces (the section axis):
///
///   • [StoreRoot]      — the 'all' hub (section == all): the deriver shows the
///                        three section chips (הסל שלי / ההזמנות שלי / שירותים) as
///                        REAL [KbDestination]s + store-level tools, reflecting
///                        the active section. The owner-order entry surface.
///   • [CartLocation]   — the 🛒 הסל section (section == cart): the deriver shows
///                        the real CART LINE chips (sourced by the keyboard from
///                        `smartCartProvider` and passed in) + cart tools
///                        (לקופה / רוקן). Empty cart ⇒ tools only (no crash).
///   • [OrdersLocation] — the 📦 הזמנות section (section == orders): the deriver
///                        shows the recent ORDER chips (sourced from the live
///                        orders list passed in) + order tools.
///   • [ServicesLocation]— the 🔧 שירותים section (section == services): the
///                        deriver shows the SERVICE chips + service tools.
///
/// EXHAUSTIVE: the deriver switches over this sealed type with no default, so a
/// future fifth location is a compile error at the deriver (very_good_analysis
/// enforces the exhaustive switch) rather than a silent fall-through — identical
/// to UpdatesLocation's exhaustive contract.
@immutable
sealed class StoreLocation {
  const StoreLocation();
}

/// The 'all' hub root (section == all): the three section chips + store tools.
/// Carries the active [section] so the equality re-fires when the section flips
/// (e.g. all → cart) and the deriver re-derives to the right surface. (Mirrors
/// [UpdatesRoot]'s `subTab`-carrying root.)
@immutable
final class StoreRoot extends StoreLocation {
  const StoreRoot({required this.section});

  /// The active store section (mirrors `storeSectionProvider`). Part of
  /// value-equality so re-selecting the section re-fires the location.
  final StoreSection section;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreRoot && other.section == section;

  @override
  int get hashCode => section.hashCode;
}

/// The 🛒 הסל section is showing (section == cart): the real cart-line chips +
/// cart tools. The cart DATA is NOT carried here (the keyboard reads
/// `smartCartProvider` and passes the list to the deriver as a param, keeping
/// this location cheap to compare) — exactly like [ChatsLocation] for threads.
@immutable
final class CartLocation extends StoreLocation {
  const CartLocation();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CartLocation;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The 📦 הזמנות section is showing (section == orders): the recent-order chips +
/// order tools. The orders DATA is NOT carried here (the keyboard reads the live
/// orders list and passes it to the deriver as a param), so this stays cheap to
/// compare. (Mirrors [ChatsLocation].)
@immutable
final class OrdersLocation extends StoreLocation {
  const OrdersLocation();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OrdersLocation;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The 🔧 שירותים section is showing (section == services): the service chips +
/// service tools. The service catalogue is static (mirrors the store's own
/// `_kServices`), so — like [NotifsLocation]'s static type chips — the deriver
/// emits it from a const list and this location carries no data.
@immutable
final class ServicesLocation extends StoreLocation {
  const ServicesLocation();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ServicesLocation;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The LIVE חנות location — the single derived location input to the keyboard's
/// pure deriver. Recomputes (and, thanks to the value-equality above, NOTIFIES)
/// only when its one watched source actually changes value:
///   • `storeSectionProvider` — the section axis (all / cart / orders / services).
///
/// It does NOT watch `mainTabProvider`: the tab is the keyboard's outer guard
/// (the keyboard reads this provider only at tab 3), so watching it here would
/// add cross-tab churn for nothing. (Identical to updates_location.dart.)
///
/// SHAPE OF THE SWITCH:
///   • section == cart     ⇒ [CartLocation]     (the cart-line chips).
///   • section == orders   ⇒ [OrdersLocation]   (the recent-order chips).
///   • section == services ⇒ [ServicesLocation] (the service chips).
///   • section == all      ⇒ [StoreRoot]        (the three section chips).
final storeLocationProvider = Provider<StoreLocation>((ref) {
  final section = ref.watch(storeSectionProvider);
  return switch (section) {
    StoreSection.cart => const CartLocation(),
    StoreSection.orders => const OrdersLocation(),
    StoreSection.services => const ServicesLocation(),
    StoreSection.all => StoreRoot(section: section),
  };
});
