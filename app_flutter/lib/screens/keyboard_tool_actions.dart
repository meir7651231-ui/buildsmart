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
// Tools with no single, unambiguous destination (workRoute / quickTools /
// recentOrders) and tools we cannot meaningfully drive from a fire-and-forget
// helper yet (voice needs a transcript sink; menu is a PopupMenuButton with no
// standalone opener) show a "בקרוב" SnackBar via [_comingSoon] instead of a
// guessed/broken navigation. Each is marked TODO(step-2).

import 'package:buildsmart/screens/ai_hub_screen.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/catalog_screen.dart' show catalogSectionProvider;
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/install_studio_screen.dart';
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

    // ── No clean single target yet → "בקרוב" (never a guessed nav) ───────────
    case KbTool.workRoute:
      // TODO(step-2): "מסלול" has no single nav target (display-only surface).
      _comingSoon(context, 'מסלול');

    case KbTool.quickTools:
      // TODO(step-2): "מהירים" is a 3-way-ambiguous quick-actions surface.
      _comingSoon(context, 'מהירים');

    case KbTool.recentOrders:
      // TODO(step-2): "הזמנות" has no single destination (orders is a pilot).
      _comingSoon(context, 'הזמנות');

    case KbTool.voice:
      // TODO(step-2): VoiceService.listen (voice.dart:57) requires an onFinal
      // transcript sink we have no field to route to from here — wiring it to a
      // no-op would silently drop the transcript, so defer rather than break.
      _comingSoon(context, 'קולי');

    case KbTool.menu:
      // The app's home/catalog overflow menu (the app-bar 3-dots) surfaced as a
      // sheet so the keyboard tool can reach it from anywhere.
      _openAppMenu(context);
  }
}

/// Brings the catalog tab (index 0) forward and selects [section] on it, so the
/// section change is actually visible. Pairs the tab + section exactly as the
/// catalog's own navigation does (catalog_screen.dart:2534 sets tab 0).
void _openCatalogSection(WidgetRef ref, String section) {
  ref.read(mainTabProvider.notifier).state = 0;
  ref.read(catalogSectionProvider.notifier).state = section;
}

/// Opens the home/catalog overflow menu (the app-bar 3-dots, `_CatalogMenuButton`
/// in home_shell.dart) as a bottom sheet, so the keyboard's תפריט tool can reach
/// it from anywhere. Mirrors that menu's two items: AI hub + settings.
void _openAppMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🤖', style: TextStyle(fontSize: 22)),
              title: const Text('בינה מלאכותית ואוטומציה'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                Navigator.of(context).push(AIHubScreen.route());
              },
            ),
            ListTile(
              leading: const Text('⚙️', style: TextStyle(fontSize: 22)),
              title: const Text('הגדרות'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                Navigator.of(context).push(CatalogSettingsScreen.route());
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shows a transient "בקרוב" SnackBar for a not-yet-wired tool [label]. Used in
/// place of any guessed/broken navigation.
void _comingSoon(BuildContext context, String label) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$label — בקרוב')));
}
