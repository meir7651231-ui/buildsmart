// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 18 — Studio navigation state.
//
// The persona the owner is scoping edits to + the element selected for the
// inspector. Both default-inert; nothing outside the Studio screen reads them, so
// they add no behavior to the app.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The canonical owner-facing personas (roleKeys) for scoping edits + view-as.
/// 'contractor' is the base/default layer.
const kStudioPersonas = <String>[
  'contractor',
  'manager',
  'store',
  'courier',
  'worker',
];

/// Hebrew labels for [kStudioPersonas].
const kStudioPersonaHe = <String, String>{
  'contractor': 'קבלן',
  'manager': 'מנהל',
  'store': 'חנות',
  'courier': 'שליח',
  'worker': 'עובד',
};

/// The persona scope for the tree + inspector — which `persona[roleKey]` layer an
/// edit targets. Defaults to 'contractor' (the base layer).
final studioScopePersonaProvider = StateProvider<String>((_) => 'contractor');

/// The element id selected in the tree, opened by the inspector (s19). null = none.
final studioSelectedIdProvider = StateProvider<String?>((_) => null);
