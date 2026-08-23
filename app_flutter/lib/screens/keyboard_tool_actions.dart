// keyboard_tool_actions — the ONE place the pure keyboard couples to the app.
//
// [BsKeyboard] (lib/widgets/smart_input/keyboard/bs_keyboard.dart) stays
// presentation-only: it knows nothing about screens, providers, or navigation —
// a tapped tool tile just emits a typed [KbTool]. This file is the single seam
// that turns that enum into a real action (set a bottom-nav tab / catalog
// section, push a screen, toggle help mode). The keyboard host calls
// [runKeyboardTool] from its onTool callback.
//
// Import direction is strictly one-way: host → this file → (keyboard enum +
// real app symbols). This file must NEVER import bs_keyboard_host.dart, so no
// import cycle is created.
//
// STEP D — most of the legacy "בקרוב" tools are now wired in the MORPH keyboard
// tree ([keyboard_tool_tree.dart]): מהירים became a 3-child branch, הזמנות jumps
// to the store orders section, and קולי runs voice-to-text into the field (the
// floating keyboard intercepts it). This seam is only reached from a LEGACY
// non-morph mount, so it still carries those cases:
//   • recentOrders → the same store-orders jump (cheap, single destination), so
//     even a legacy mount routes correctly;
//   • workRoute → still "בקרוב" (no nav target exists — display-only hero);
//   • quickTools → "בקרוב" here (it is a BRANCH, not a single destination — a
//     legacy flat mount has nowhere to drill);
//   • voice → "בקרוב" here (no field controller in a fire-and-forget helper; the
//     real mic→field path lives in the floating keyboard).

import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/catalog_screen.dart' show catalogSectionProvider;
import 'package:buildsmart/screens/install_studio_screen.dart';
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/help_mode.dart' show helpModeProvider;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show KbTool;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runs the real app action for a tapped keyboard tool tile.
///
/// [ref] drives the state-provider tools (tab / section / help mode); [context]
/// drives the Navigator pushes and the "בקרוב" SnackBar. The `home` tools that
/// land inside the catalog tab set the bottom-nav tab to 0 (catalog) AND the
/// catalog section, mirroring how the catalog's own pills route
/// (catalog_screen.dart) — otherwise the section change would be invisible while
/// another tab is showing.
void runKeyboardTool(WidgetRef ref, BuildContext context, KbTool tool) {
  switch (tool) {
    // ── State-provider tools ────────────────────────────────────────────────
    case KbTool.departments:
      // index 1 == DepartmentsScreen in HomeShell's IndexedStack
      // (home_shell.dart:90).
      ref.read(mainTabProvider.notifier).state = 1;

    case KbTool.finder:
      _openCatalogSection(ref, 'מאתר'); // → FinderScreen (catalog_screen.dart:2292)

    case KbTool.search:
      // No distinct search surface exists — the finder section IS the search
      // entry point (catalog_screen.dart:2292), so search routes there too.
      _openCatalogSection(ref, 'מאתר');

    case KbTool.smartTree:
      _openCatalogSection(ref, 'עץ חכם'); // → _SmartTreeSection (catalog_screen.dart:2298)

    case KbTool.favorites:
      _openCatalogSection(ref, 'מועדפים'); // → _FavoritesSection (catalog_screen.dart:2300)

    case KbTool.intro:
      // Turn discovery / help mode ON (help_mode.dart:12).
      ref.read(helpModeProvider.notifier).state = true;

    // ── Navigator pushes ────────────────────────────────────────────────────
    case KbTool.connect:
      // Mirrors smart_home_screen.dart:563 — the install-studio hero's push.
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const InstallStudioScreen()),
      );

    case KbTool.camera:
      // BarcodeScanner takes no required args (barcode_scanner.dart:9); it pops
      // with the scanned code. We don't consume the result here yet — opening
      // the scanner is the step-2 action.
      Navigator.of(context).push(
        MaterialPageRoute<String>(builder: (_) => const BarcodeScanner()),
      );

    // ── STEP D wired-or-deferred (legacy non-morph mount only) ───────────────
    case KbTool.recentOrders:
      // "הזמנות" → the store's ORDERS section (tab 3 + storeSectionProvider),
      // mirroring the store's own pills (store_screen.dart:38-41,676). The morph
      // keyboard wires this in the tree; this case keeps a legacy mount correct.
      ref.read(mainTabProvider.notifier).state = 3;
      ref.read(storeSectionProvider.notifier).state = StoreSection.orders;

    case KbTool.workRoute:
      // "מסלול" still has no single nav target — the only surface
      // (smart_home_screen.dart `_WorkPath`) is a display-only hero with no
      // onTap. Deferred (both here AND in the morph tree) until one exists.
      _comingSoon(context, 'מסלול');

    case KbTool.quickTools:
      // "מהירים" is a BRANCH in the morph tree (3 quick-action children). A
      // legacy FLAT mount has nowhere to drill, so it surfaces "בקרוב" here.
      _comingSoon(context, 'מהירים');

    case KbTool.voice:
      // "קולי" runs voice-to-text into the field — but that needs the field
      // controller, which this fire-and-forget helper does not own. The real
      // mic→insertAtCaret path lives in the FLOATING keyboard (it intercepts the
      // voice-marked node); a legacy mount has no field, so "בקרוב" here.
      _comingSoon(context, 'קולי');

    case KbTool.menu:
      // STEP B: תפריט is no longer a single destination — it is a BRANCH in the
      // morph keyboard ([keyboard_tool_tree.dart]) whose children are the AI hub
      // + settings (replacing the old `_openAppMenu` sheet). The morph keyboard
      // never routes KbTool.menu here (it drills the branch instead); this case
      // only fires from a legacy non-morph mount, where the menu has no single
      // target, so we surface "בקרוב" rather than a guessed/half nav.
      _comingSoon(context, 'תפריט');
  }
}

/// Brings the catalog tab (index 0) forward and selects [section] on it, so the
/// section change is actually visible. Pairs the tab + section exactly as the
/// catalog's own navigation does (catalog_screen.dart:2534 sets tab 0).
void _openCatalogSection(WidgetRef ref, String section) {
  ref.read(mainTabProvider.notifier).state = 0;
  ref.read(catalogSectionProvider.notifier).state = section;
}

/// Shows a transient "בקרוב" SnackBar for a not-yet-wired tool [label]. Used in
/// place of any guessed/broken navigation.
void _comingSoon(BuildContext context, String label) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$label — בקרוב')));
}
