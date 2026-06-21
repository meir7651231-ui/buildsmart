// updates_location — the SEALED "where am I on the עדכונים tab" snapshot that
// drives the LIVE-MIRROR floating keyboard (phases 0-2 of the plan).
//
// PRINCIPLE (owner SSOT): on the עדכונים tab the floating keyboard is a LIVE
// MIRROR — at every click it re-derives BOTH its tools AND its predictions from
// the current spot. The pure function that does the deriving
// ([deriveUpdatesContext], keyboard_updates_deriver.dart) takes ONE input: an
// [UpdatesLocation]. This file defines that input as a SEALED value type plus
// the derived [updatesLocationProvider] that recomputes it from the live state.
//
// WHY A SEALED VALUE TYPE (load-bearing — plan risk #1, the single most
// important detail): [updatesLocationProvider] is a derived `Provider`, so
// Riverpod notifies its listeners (the keyboard) ONLY when the newly computed
// location is `!=` the previous one. If these subclasses lacked TRUE value
// equality the provider would emit a fresh instance every frame and the keyboard
// would re-derive its whole row at 60fps (churn). So every subclass is
// `@immutable`, overrides `==`/`hashCode` by VALUE, and stores any list field as
// an unmodifiable copy compared with `listEquals`. (The plan names "Equatable OR
// explicit ==/hashCode"; `equatable` is not a dependency of this app, so we use
// explicit operators built on `package:flutter/foundation.dart`'s `listEquals` +
// `Object.hash` — the same dependency-free idiom `state/auth_state.dart` uses.)
//
// WHY IT DOES NOT WATCH mainTabProvider: the tab is the OUTER guard, watched at
// the keyboard (the deriver is consulted ONLY when tab == 2). Watching it here
// too would couple this provider to cross-tab churn for no gain — leaving
// עדכונים already stops the keyboard from reading this provider at all.

import 'package:buildsmart/screens/chats_screen.dart'
    show updatesChatOpenProvider;
import 'package:buildsmart/screens/notifications_screen.dart'
    show NotifSection, notifSectionProvider;
import 'package:buildsmart/screens/updates_screen.dart'
    show updatesSubTabProvider;
import 'package:buildsmart/state/board_auth.dart' show boardAuthProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WHERE the user is on the עדכונים tab, as a SEALED value type — the single
/// input to the pure [deriveUpdatesContext]. Exactly three locations mirror the
/// three live surfaces (the sub-tab axis + the open-chat hand-off):
///
///   • [UpdatesRoot]   — entry / the field is empty and no conversation is open:
///                       the deriver shows the two section chips (שיחות/התראות)
///                       + updates-level tools, reflecting the active sub-tab.
///   • [NotifsLocation]— the התראות sub-tab is showing (sub == 0): the deriver
///                       shows the 6 notification TYPE chips (always-safe, works
///                       even when the live feed is empty) + notif tools.
///   • [ChatsLocation] — the שיחות sub-tab is showing (sub == 1) and no chat is
///                       open: the deriver shows the real CONVERSATION chips
///                       (sourced by the keyboard from `visibleThreadsProvider`)
///                       + chat tools.
///
/// The [persona]/[audience] scope rides on every location so the deriver and the
/// equality both see the home-shell resolution (contractor,'contractor') — see
/// [updatesLocationProvider].
///
/// EXHAUSTIVE: the deriver switches over this sealed type with no default, so a
/// future fourth location is a compile error at the deriver (very_good_analysis
/// enforces the exhaustive switch) rather than a silent fall-through.
@immutable
sealed class UpdatesLocation {
  const UpdatesLocation({
    required this.persona,
    required this.audience,
  });

  /// The persona viewing the עדכונים surfaces — the home-shell scope
  /// 'contractor' (plan Q6). Carried as a plain string (the role's `name`) so
  /// this state file does not depend on the chat role enum; the deriver consumes
  /// only `ThreadLite`/`NotifSection`, never this field's type.
  final String persona;

  /// Which board's thread list the chats surface mirrors — 'contractor' for the
  /// home shell (plan Q6). Pairs with [persona]; both feed value-equality so a
  /// scope change re-fires the location.
  final String audience;
}

/// Entry / empty-field root: the two section chips + updates tools. The
/// [subTab] (0 = התראות, 1 = שיחות) decides which sub-tab's tools the deriver
/// surfaces at the root, so flipping the toggle re-derives.
@immutable
final class UpdatesRoot extends UpdatesLocation {
  const UpdatesRoot({
    required super.persona,
    required super.audience,
    required this.subTab,
  });

  /// The active עדכונים sub-tab (mirrors `updatesSubTabProvider`): 0 = התראות,
  /// 1 = שיחות. Drives which tool set the root surfaces (התראות tools vs chat
  /// tools) — the predictions at the root are always the two section chips.
  final int subTab;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatesRoot &&
          other.persona == persona &&
          other.audience == audience &&
          other.subTab == subTab;

  @override
  int get hashCode => Object.hash(persona, audience, subTab);
}

/// The התראות sub-tab is showing: the 6 type chips (each sets
/// `notifSectionProvider`) + mark-all-read / notif-settings tools. [section] is
/// the currently-selected type so the deriver can mark the active chip.
@immutable
final class NotifsLocation extends UpdatesLocation {
  const NotifsLocation({
    required super.persona,
    required super.audience,
    required this.section,
  });

  /// The selected notification type filter (mirrors `notifSectionProvider`).
  /// Part of value-equality so re-selecting a type re-fires the location and the
  /// deriver re-derives to that section.
  final NotifSection section;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotifsLocation &&
          other.persona == persona &&
          other.audience == audience &&
          other.section == section;

  @override
  int get hashCode => Object.hash(persona, audience, section);
}

/// The שיחות sub-tab is showing and no conversation is open: the real
/// conversation chips + chat tools. The thread DATA is NOT carried here (the
/// keyboard reads `visibleThreadsProvider` and passes the list to the deriver as
/// a param, keeping this location cheap to compare); only the scope rides along.
@immutable
final class ChatsLocation extends UpdatesLocation {
  const ChatsLocation({
    required super.persona,
    required super.audience,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatsLocation &&
          other.persona == persona &&
          other.audience == audience;

  @override
  int get hashCode => Object.hash(persona, audience);
}

/// The home-shell persona/audience scope for the floating keyboard — resolved
/// the SAME way `ChatsScreen`/`visibleThreadsProvider` resolve it (plan Q6):
/// the contractor home shell builds `_ThreadList(persona: contractor,
/// audience: 'contractor')`, and the bucket user falls back to 'contractor' when
/// there is no board session. We mirror that exact fallback so the keyboard's
/// scope can never diverge from the list it mirrors.
String _resolvePersona(Ref ref) =>
    ref.watch(boardAuthProvider.select((s) => s?.username ?? 'contractor'));

/// The LIVE עדכונים location — the single derived input to the keyboard's pure
/// deriver. Recomputes (and, thanks to the value-equality above, NOTIFIES) only
/// when one of its watched sources actually changes value:
///   • `updatesSubTabProvider` — the primary axis (0 = התראות, 1 = שיחות),
///   • `notifSectionProvider`  — the notification type filter (for NotifsLocation),
///   • `updatesChatOpenProvider` — the open-chat hand-off (null ⇒ list surface),
///   • the resolved persona     — the home-shell scope (plan Q6).
///
/// It does NOT watch `mainTabProvider`: the tab is the keyboard's outer guard
/// (the keyboard reads this provider only at tab 2), so watching it here would
/// add cross-tab churn for nothing.
///
/// SHAPE OF THE SWITCH (phases 0-2):
///   • a conversation is open (`updatesChatOpenProvider != null`) ⇒ the list
///     surface is covered by the chat route, which owns its OWN keyboard (plan
///     Q5); we still report a stable [UpdatesRoot] so the keyboard folds back to
///     the section chips the instant the route pops and the id nulls.
///   • sub == 1 (שיחות), no chat open ⇒ [ChatsLocation] (conversation chips).
///   • sub == 0 (התראות) ⇒ [NotifsLocation] (the 6 type chips).
///   • anything else ⇒ [UpdatesRoot].
final updatesLocationProvider = Provider<UpdatesLocation>((ref) {
  final sub = ref.watch(updatesSubTabProvider);
  final section = ref.watch(notifSectionProvider);
  final openChatId = ref.watch(updatesChatOpenProvider);
  final persona = _resolvePersona(ref);
  const audience = 'contractor';

  // A chat is being opened / is open: the list surface is hidden behind the
  // _ChatPage route (its own composer keyboard takes over — plan Q5). Report the
  // root so the floating keyboard shows the stable section chips underneath and
  // returns to the chats list the moment the route pops (the screen nulls the
  // provider on pop).
  if (openChatId != null) {
    return UpdatesRoot(persona: persona, audience: audience, subTab: sub);
  }

  return switch (sub) {
    1 => ChatsLocation(persona: persona, audience: audience),
    0 => NotifsLocation(persona: persona, audience: audience, section: section),
    _ => UpdatesRoot(persona: persona, audience: audience, subTab: sub),
  };
});
