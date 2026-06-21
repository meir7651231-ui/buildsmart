// keyboard_destinations — the UNIVERSAL DESTINATION REGISTRY behind the
// type-to-navigate keyboard (owner goal: "the floating keyboard is the OS
// navigator for the WHOLE app — not one button less").
//
// A [KbDestination] is one navigable target anywhere in the app — a bottom-nav
// tab, a catalog section, a store section, an updates sub-tab, a pushed
// route/screen, a global action (camera / help mode / role picker). Each carries
// a Hebrew [label], a list of [keywords] (search terms + synonyms a user might
// type), and a [run] callback that performs the REAL navigation (set the right
// provider / push the right route / open the right sheet).
//
// VERIFIED, NOT GUESSED — every [run] mirrors how the app itself reaches that
// destination, checked against the real code:
//   • tabs            → mainTabProvider (home_shell.dart:90-96 IndexedStack:
//                       0 בית · 1 מחלקות · 2 עדכונים · 3 חנות).
//   • catalog sections→ tab 0 + catalogSectionProvider (catalog_screen.dart:
//                       2292-2303 maps each label to its section widget).
//   • store sections  → tab 3 + storeSectionProvider (store_screen.dart:38-41).
//   • updates sub-tabs→ tab 2 + updatesSubTabProvider (updates_screen.dart:8).
//   • pushed screens  → the screen's own `static route()` (ai_hub / settings /
//                       profile / stock / chats-archive / notif-settings) or a
//                       MaterialPageRoute (install-studio — it has no route()).
//   • global actions  → openCameraSheet (camera_sheet.dart:18), helpModeProvider
//                       (help_mode.dart:12), showRolePicker (role_picker_sheet),
//                       openSiteHub (site_hub_screen.dart:60).
//   • the 5 BOARDS    → showRolePicker(context): the SAME gate-respecting dialog
//                       the app-bar logo opens. We do NOT push the dashboard
//                       route()s directly — those bypass `_BoardGateRoute`
//                       (role_picker_sheet.dart:250), which shows WelcomeScreen
//                       when there is no BoardSession. The picker is the only
//                       clean, verified board entry, so all 5 board terms route
//                       there (the user then taps the role).
//
// Where a destination already maps to a keyboard [KbTool], we REUSE
// [runKeyboardTool] verbatim (departments / smartTree / finder / favorites /
// connect / camera / intro) so its behaviour stays identical to the tool tiles.
//
// LAYERING — this is a `screens`-layer file (like keyboard_tool_tree.dart): it
// MAY import screens + state, but it must NOT import bs_keyboard_host.dart (that
// would create a cycle via the host). The floating keyboard imports THIS; this
// imports nothing from the host. The pure keyboard ([bs_keyboard.dart]) still
// only ever sees a plain `List<String>` — the destination-vs-word mapping lives
// in the floating keyboard, never here and never in the pure widget.

import 'package:buildsmart/screens/ai_hub_screen.dart' show AIHubScreen;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogSectionProvider;
import 'package:buildsmart/screens/catalog_settings_screen.dart'
    show CatalogSettingsScreen;
import 'package:buildsmart/screens/chats_screen.dart' show ChatsArchiveScreen;
import 'package:buildsmart/screens/install_studio_screen.dart'
    show InstallStudioScreen;
import 'package:buildsmart/screens/keyboard_tool_actions.dart'
    show runKeyboardTool;
import 'package:buildsmart/screens/notif_settings_screen.dart'
    show NotifSettingsScreen;
import 'package:buildsmart/screens/profile_screen.dart' show ProfileScreen;
import 'package:buildsmart/screens/role_picker_sheet.dart' show showRolePicker;
import 'package:buildsmart/screens/site_hub_screen.dart' show openSiteHub;
import 'package:buildsmart/screens/stock_screen.dart' show StockScreen;
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
import 'package:buildsmart/screens/updates_screen.dart'
    show updatesSubTabProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show KbTool;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One navigable destination in the universal registry: a Hebrew [label], the
/// [keywords] a user might type to reach it (search terms + synonyms), and the
/// [run] action that performs the REAL navigation.
///
/// [run] receives the floating keyboard's own `ref`/`context` (the home stays
/// mounted under the overlay, so both stay valid). A destination that changes a
/// tab/section swaps the screen UNDERNEATH while the keyboard keeps floating; a
/// destination that pushes a route pushes over everything (the keyboard
/// reappears when that route pops). Neither closes the overlay — the floating
/// keyboard owns that decision.
@immutable
class KbDestination {
  const KbDestination({
    required this.label,
    required this.keywords,
    required this.run,
  });

  /// The Hebrew display label (also matched by [matchDestinations]).
  final String label;

  /// Hebrew search terms + synonyms a user might type to reach this. Matched
  /// (prefix/contains, case-insensitive) alongside [label].
  final List<String> keywords;

  /// Performs the real navigation for this destination. Pure side-effect: set a
  /// provider, push a route, or open a sheet — exactly as the app itself does.
  final void Function(WidgetRef ref, BuildContext context) run;
}

/// Brings the catalog tab (index 0) forward and selects [section] on it — the
/// SAME pairing the catalog's own pills do (catalog_screen.dart sets tab 0 +
/// the section), so the section change is actually visible.
void _openCatalogSection(WidgetRef ref, String section) {
  ref.read(mainTabProvider.notifier).state = 0;
  ref.read(catalogSectionProvider.notifier).state = section;
}

/// Brings the store tab (index 3) forward and selects [section] on it — mirrors
/// the store's own section pills (store_screen.dart) and the cart-FAB jump.
void _openStoreSection(WidgetRef ref, StoreSection section) {
  ref.read(mainTabProvider.notifier).state = 3;
  ref.read(storeSectionProvider.notifier).state = section;
}

/// Brings the updates tab (index 2) forward and selects sub-tab [sub] on it
/// (0 = התראות, 1 = שיחות) — mirrors updates_screen.dart's toggle.
void _openUpdatesSub(WidgetRef ref, int sub) {
  ref.read(mainTabProvider.notifier).state = 2;
  ref.read(updatesSubTabProvider.notifier).state = sub;
}

/// The MAIN navigable destinations of the app, for the type-to-navigate
/// keyboard. Ordered roughly by how central each is (tabs → catalog sections →
/// store → updates → global actions → settings/AI/finder → boards). Every `run`
/// is verified against real code (see file header); ambiguous or not-cleanly-
/// reachable targets are intentionally LEFT OUT (deferred) rather than wired to
/// a broken nav.
List<KbDestination> kbDestinations() => <KbDestination>[
      // ── The 4 bottom-nav tabs ───────────────────────────────────────────────
      KbDestination(
        label: 'בית',
        keywords: const ['בית', 'דף הבית', 'קטלוג', 'ראשי', 'מסך הבית', 'home'],
        // Tab 0 + reset the catalog to its 'בית' (smart-home) section so the tab
        // shows its landing, not whatever section was last open.
        run: (ref, context) => _openCatalogSection(ref, 'בית'),
      ),
      KbDestination(
        label: 'מחלקות',
        keywords: const [
          'מחלקות',
          'מחלקה',
          'קטגוריות ראשיות',
          'אינסטלציה',
          'ברזים',
          'כלי עבודה',
          'departments',
        ],
        // index 1 == DepartmentsScreen (home_shell.dart:94). Reuse the tool seam.
        run: (ref, context) =>
            runKeyboardTool(ref, context, KbTool.departments),
      ),
      KbDestination(
        label: 'עדכונים',
        keywords: const ['עדכונים', 'updates'],
        // Tab 2; leave the sub-tab as-is (התראות/שיחות have their own entries).
        run: (ref, context) => ref.read(mainTabProvider.notifier).state = 2,
      ),
      KbDestination(
        label: 'חנות',
        keywords: const ['חנות', 'הזמנות וקנייה', 'store', 'shop'],
        // Tab 3; default to the 'all' hub (store_screen.dart:40 default).
        run: (ref, context) => _openStoreSection(ref, StoreSection.all),
      ),

      // ── עדכונים sub-tabs (tab 2 + updatesSubTabProvider) ─────────────────────
      KbDestination(
        label: 'התראות',
        keywords: const ['התראות', 'נוטיפיקציות', 'הודעות מערכת', 'notifications'],
        run: (ref, context) => _openUpdatesSub(ref, 0),
      ),
      KbDestination(
        label: 'שיחות',
        keywords: const ['שיחות', 'צאט', "צ'אט", 'הודעות', 'chat', 'chats'],
        run: (ref, context) => _openUpdatesSub(ref, 1),
      ),

      // ── חנות sections (tab 3 + storeSectionProvider) ─────────────────────────
      KbDestination(
        label: 'הסל שלי',
        keywords: const ['סל', 'הסל שלי', 'עגלה', 'עגלת קניות', 'cart'],
        run: (ref, context) => _openStoreSection(ref, StoreSection.cart),
      ),
      KbDestination(
        label: 'ההזמנות שלי',
        keywords: const [
          'הזמנות',
          'ההזמנות שלי',
          'מעקב הזמנה',
          'מעקב משלוח',
          'orders',
        ],
        run: (ref, context) => _openStoreSection(ref, StoreSection.orders),
      ),
      KbDestination(
        label: 'שירותים',
        keywords: const ['שירותים', 'השכרת כלים', 'services'],
        run: (ref, context) => _openStoreSection(ref, StoreSection.services),
      ),

      // ── קטלוג sections (tab 0 + catalogSectionProvider) ──────────────────────
      // Labels are the EXACT section strings catalog_screen.dart switches on
      // (lines 2292-2303); a wrong string would land on the empty-section view.
      KbDestination(
        label: 'מאתר',
        keywords: const [
          'מאתר',
          'מוצא מוצרים',
          'חיפוש מוצר',
          'מצא מוצר',
          'finder',
        ],
        // → FinderScreen (catalog_screen.dart:2292). Reuse the tool seam.
        run: (ref, context) => runKeyboardTool(ref, context, KbTool.finder),
      ),
      KbDestination(
        label: 'עץ חכם',
        keywords: const ['עץ חכם', 'עץ', 'דפדוף חכם', 'smart tree'],
        // → _SmartTreeSection (catalog_screen.dart:2298). Reuse the tool seam.
        run: (ref, context) => runKeyboardTool(ref, context, KbTool.smartTree),
      ),
      KbDestination(
        label: 'מועדפים',
        keywords: const ['מועדפים', 'אהובים', 'שמורים', 'favorites'],
        // → _FavoritesSection (catalog_screen.dart:2300). Reuse the tool seam.
        run: (ref, context) => runKeyboardTool(ref, context, KbTool.favorites),
      ),
      KbDestination(
        label: 'קטגוריות',
        keywords: const ['קטגוריות', 'קטגוריה', 'דפדוף לפי קטגוריה', 'categories'],
        run: (ref, context) => _openCatalogSection(ref, 'קטגוריות'),
      ),
      KbDestination(
        label: 'וריאנטים',
        keywords: const ['וריאנטים', 'גרסאות', 'מידות', 'גדלים', 'variants'],
        run: (ref, context) => _openCatalogSection(ref, 'וריאנטים'),
      ),
      KbDestination(
        label: 'תכנון חיבור',
        keywords: const [
          'תכנון חיבור',
          'חיבור',
          'התקנה',
          'אינסטלציה',
          'install studio',
        ],
        // The catalog section 'תכנון חיבור' renders InstallStudioScreen inline
        // (catalog_screen.dart:2302); the connect tool pushes it as a route.
        // Use the section so the keyboard keeps floating over the catalog tab,
        // matching the other section destinations.
        run: (ref, context) => _openCatalogSection(ref, 'תכנון חיבור'),
      ),
      KbDestination(
        label: 'חיפושים אחרונים',
        keywords: const ['חיפושים אחרונים', 'היסטוריית חיפוש', 'recent searches'],
        run: (ref, context) => _openCatalogSection(ref, 'חיפושים אחרונים'),
      ),

      // ── Global actions ──────────────────────────────────────────────────────
      KbDestination(
        label: 'מצלמה',
        keywords: const ['מצלמה', 'סריקה', 'ברקוד', 'סרוק', 'camera', 'scan'],
        // openCameraSheet (camera_sheet.dart:18) — same opener the tool uses.
        run: (ref, context) => runKeyboardTool(ref, context, KbTool.camera),
      ),
      KbDestination(
        label: 'מצב היכרות',
        keywords: const ['מצב היכרות', 'היכרות', 'עזרה', 'הסבר', 'help'],
        // helpModeProvider = true (help_mode.dart:12) — same as the intro tool.
        run: (ref, context) => runKeyboardTool(ref, context, KbTool.intro),
      ),
      KbDestination(
        label: 'פרופיל',
        keywords: const [
          'פרופיל',
          'הפרופיל שלי',
          'חשבון',
          'פרטים אישיים',
          'profile',
        ],
        // Push the full editor (ProfileScreen.route() — profile_screen.dart:30),
        // the same target catalog settings' profile row uses (settings:131).
        run: (ref, context) =>
            Navigator.of(context).push(ProfileScreen.route()),
      ),
      KbDestination(
        label: 'בורר תפקידים',
        keywords: const [
          'תפקיד',
          'תפקידים',
          'החלפת תפקיד',
          'בורר תפקידים',
          'מי אתה',
          'role',
        ],
        // showRolePicker(context) — the SAME dialog the app-bar logo opens
        // (role_picker_sheet.dart:28). Gate-respecting (locked to one server
        // role becomes a no-op there). Async opener; fire-and-forget is fine.
        run: (ref, context) => showRolePicker(context),
      ),

      // ── Pushed app screens (each has its own verified route()) ───────────────
      KbDestination(
        label: 'הגדרות',
        keywords: const ['הגדרות', 'הגדרה', 'העדפות', 'settings'],
        // CatalogSettingsScreen.route() (catalog_settings_screen.dart:20) — the
        // same route the kbd תפריט → הגדרות branch and the catalog menu push.
        run: (ref, context) =>
            Navigator.of(context).push(CatalogSettingsScreen.route()),
      ),
      KbDestination(
        label: 'בינה',
        keywords: const [
          'בינה',
          'בינה מלאכותית',
          'AI',
          'מרכז בינה',
          'חיזוי',
          'ai hub',
        ],
        // AIHubScreen.route() (ai_hub_screen.dart:44) — same route the kbd
        // תפריט → בינה branch and the catalog menu push.
        run: (ref, context) => Navigator.of(context).push(AIHubScreen.route()),
      ),
      KbDestination(
        label: 'מלאי',
        keywords: const [
          'מלאי',
          'המלאי שלי',
          'מחסן',
          'אתר',
          'stock',
          'inventory',
        ],
        // StockScreen.route() (stock_screen.dart:139) — the same route the smart
        // home 'כלים מהירים → 📦 המלאי שלי' row pushes.
        run: (ref, context) => Navigator.of(context).push(StockScreen.route()),
      ),
      KbDestination(
        label: 'משימות',
        keywords: const [
          'משימות',
          'משימות העבודה',
          'אתר',
          'גאנט',
          'ליקויים',
          'יומן עבודה',
          'tasks',
          'site',
        ],
        // openSiteHub(context) (site_hub_screen.dart:60) — the site/tasks hub the
        // smart home 'כלים מהירים → 📋 משימות העבודה' row opens. The hub is the
        // verified single entry (the team-tasks board sits one tap inside it).
        run: (ref, context) => openSiteHub(context),
      ),
      KbDestination(
        label: 'תכנון התקנה',
        keywords: const [
          'תכנון התקנה',
          'אולפן התקנה',
          'install',
          'בנה רשימה',
          'BOM',
        ],
        // InstallStudioScreen has NO route() — push via MaterialPageRoute exactly
        // as keyboard_tool_actions.dart:67 and smart_home_screen.dart:563 do.
        // (Distinct from the inline 'תכנון חיבור' catalog section above: this is
        // the full-screen studio pushed over everything.)
        run: (ref, context) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const InstallStudioScreen(),
          ),
        ),
      ),
      KbDestination(
        label: 'ארכיון שיחות',
        keywords: const ['ארכיון שיחות', 'ארכיון', 'שיחות שמורות', 'archive'],
        // ChatsArchiveScreen.route() (chats_screen.dart:2326) — the same route
        // the chats 3-dot menu 'ארכיון שיחות' pushes.
        run: (ref, context) =>
            Navigator.of(context).push(ChatsArchiveScreen.route()),
      ),
      KbDestination(
        label: 'הגדרות התראות',
        keywords: const [
          'הגדרות התראות',
          'התראות הגדרות',
          'שעות שקט',
          'נא תפריע',
          'notif settings',
        ],
        // NotifSettingsScreen.route() (notif_settings_screen.dart:14) — the same
        // route the notifications 3-dot menu 'הגדרות התראות' pushes.
        run: (ref, context) =>
            Navigator.of(context).push(NotifSettingsScreen.route()),
      ),

      // ── The 5 ROLE BOARDS ───────────────────────────────────────────────────
      // All route to showRolePicker(context): the gate-respecting dialog (see
      // file header). The label/keywords let the user TYPE a board name and land
      // on the picker, where one tap enters that board behind its auth gate.
      KbDestination(
        label: 'קבלן',
        keywords: const ['קבלן', 'לוח קבלן', 'מסך קבלן', 'contractor'],
        run: (ref, context) => showRolePicker(context),
      ),
      KbDestination(
        label: 'מנהל',
        keywords: const [
          'מנהל',
          'לוח מנהל',
          'לוח בקרה',
          'ניהול',
          'manager',
          'admin',
        ],
        run: (ref, context) => showRolePicker(context),
      ),
      KbDestination(
        label: 'חנות ספק',
        keywords: const ['חנות ספק', 'ספק', 'לוח חנות', 'store board', 'supplier'],
        run: (ref, context) => showRolePicker(context),
      ),
      KbDestination(
        label: 'שליח',
        keywords: const ['שליח', 'לוח שליח', 'משלוחים', 'courier', 'delivery'],
        run: (ref, context) => showRolePicker(context),
      ),
      KbDestination(
        label: 'עובד',
        keywords: const ['עובד', 'לוח עובד', 'אפליקציית עובד', 'worker', 'employee'],
        run: (ref, context) => showRolePicker(context),
      ),
    ];

/// PURE matcher: the [query] (case-insensitive, trimmed) against each
/// destination's `label` + `keywords`, by prefix OR contains. Returns up to
/// [max] destinations, de-duplicated (a destination matched on several of its
/// terms appears once), preserving the [kbDestinations] order. An empty query
/// returns an empty list (the floating keyboard shows product opening-words
/// then, unchanged).
///
/// DETERMINISTIC + widget-free: same (query, max) in ⇒ identical list out. The
/// floating keyboard maps each returned destination back to its `run` action;
/// the pure keyboard only ever sees the resulting `List<String>` of labels.
List<KbDestination> matchDestinations(String query, {int max = 4}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const <KbDestination>[];

  final out = <KbDestination>[];
  for (final d in kbDestinations()) {
    if (out.length >= max) break;
    // Build the haystack: the label + every keyword, lower-cased.
    final terms = <String>[d.label, ...d.keywords];
    final hit = terms.any((t) {
      final lt = t.toLowerCase();
      return lt.startsWith(q) || lt.contains(q);
    });
    if (hit) out.add(d);
  }
  return out;
}
