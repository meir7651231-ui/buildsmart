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
//   • departments     → tab 1 + homeDepartmentProvider = the EXACT name from
//                       DepartmentsScreen.departments (departments_screen.dart:
//                       105-110, `live == true` only), mirroring a department
//                       tile's onTap. One destination per live department.
//   • catalog sections→ tab 0 + catalogSectionProvider (catalog_screen.dart:
//                       2292-2303 maps each label to its section widget).
//   • store sections  → tab 3 + storeSectionProvider (store_screen.dart:38-41).
//   • updates sub-tabs→ tab 2 + updatesSubTabProvider (updates_screen.dart:8).
//   • pushed screens  → the screen's own `static route()` (ai_hub / settings /
//                       profile / stock / chats-archive / notif-settings /
//                       home-arrangement / rewards / budget / legal) or a
//                       MaterialPageRoute (install-studio + audit — no route()).
//   • no-arg openers  → the exact opener fn the app uses for a sheet/hub:
//                       openSiteHub / openProjects / openFinanceHub /
//                       openScanPlanSheet / openCheaperAlternativesSheet /
//                       openPriceCompareSheet (all `(context)` only — no arg).
//   • global actions  → openCameraSheet (camera_sheet.dart:18), helpModeProvider
//                       (help_mode.dart:12), showRolePicker (role_picker_sheet).
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

import 'package:buildsmart/logic/system_division.dart'
    show catalogSystemFilterProvider;
import 'package:buildsmart/screens/ai_hub_screen.dart' show AIHubScreen;
import 'package:buildsmart/screens/audit_screen.dart' show AuditScreen;
import 'package:buildsmart/screens/budget_screen.dart' show BudgetScreen;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogSectionProvider, catalogTreePathProvider;
import 'package:buildsmart/screens/catalog_settings_screen.dart'
    show CatalogSettingsScreen;
import 'package:buildsmart/screens/chats_screen.dart' show ChatsArchiveScreen;
import 'package:buildsmart/screens/contractor_tools_sheets.dart'
    show
        openCheaperAlternativesSheet,
        openPriceCompareSheet,
        openScanPlanSheet;
import 'package:buildsmart/screens/departments_screen.dart'
    show deptFlatProductsProvider, homeDepartmentProvider;
import 'package:buildsmart/screens/finance_hub_sheets.dart' show openFinanceHub;
import 'package:buildsmart/screens/home_content_reorder.dart'
    show HomeContentReorder;
import 'package:buildsmart/screens/install_studio_screen.dart'
    show InstallStudioScreen;
import 'package:buildsmart/screens/keyboard_tool_actions.dart'
    show runKeyboardTool;
import 'package:buildsmart/screens/legal_screen.dart'
    show LegalScreen, LegalTab;
import 'package:buildsmart/screens/notif_settings_screen.dart'
    show NotifSettingsScreen;
import 'package:buildsmart/screens/profile_screen.dart' show ProfileScreen;
import 'package:buildsmart/screens/projects_screen.dart' show openProjects;
import 'package:buildsmart/screens/rewards_hub_screen.dart'
    show RewardsHubScreen;
import 'package:buildsmart/screens/role_picker_sheet.dart' show showRolePicker;
import 'package:buildsmart/screens/site_hub_screen.dart' show openSiteHub;
import 'package:buildsmart/screens/smart_project_screen.dart'
    show openSmartProject;
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

/// Opens a single live department [name] inside the departments tab — the SAME
/// state a department tile sets. Mirrors smart_home_screen.dart `_Departments`
/// onTap (~264-268: homeDepartmentProvider = name + mainTabProvider = 1) and the
/// common reset in departments_screen.dart `_DeptTile` onTap (~231-235:
/// catalogTreePathProvider = const [] + deptFlatProductsProvider = false +
/// catalogSystemFilterProvider = null), so a typed department always lands on its
/// TOP view (`_DeptCatGroups` for a catalog dept, the catalog finder for a tool
/// dept — departments_screen.dart:137-140) rather than a stale drill path.
///
/// [name] MUST be one of `DepartmentsScreen.departments` where `live == true`
/// (verified at the call sites below); a non-live name would just toast 'בקרוב'.
void _openDepartment(WidgetRef ref, String name) {
  ref.read(catalogSystemFilterProvider.notifier).state = null;
  ref.read(catalogTreePathProvider.notifier).state = const [];
  ref.read(deptFlatProductsProvider.notifier).state = false;
  ref.read(homeDepartmentProvider.notifier).state = name;
  ref.read(mainTabProvider.notifier).state = 1;
}

/// The MAIN navigable destinations of the app, for the type-to-navigate
/// keyboard. Ordered roughly by how central each is (tabs → catalog sections →
/// store → updates → global actions → settings/AI/finder → boards). Every `run`
/// is verified against real code (see file header); ambiguous or not-cleanly-
/// reachable targets are intentionally LEFT OUT (deferred) rather than wired to
/// a broken nav.
/// Memoized label→destination map backing `kbDestinationByLabel` — built once
/// from `kbDestinations`, read-only thereafter (owner button-spec #2).
Map<String, KbDestination>? _byLabelCache;

/// Look up a destination by its exact `label` (memoized). Lets the keyboard tool
/// tree reuse a destination's verified opener instead of re-implementing it;
/// returns null for an unknown label (the caller skips it).
KbDestination? kbDestinationByLabel(String label) =>
    (_byLabelCache ??= <String, KbDestination>{
      for (final d in kbDestinations()) d.label: d,
    })[label];

List<KbDestination>? _kbDestinationsCache;
/// Memoized: the registry is built ONCE then reused — avoids re-allocating the
/// full list + every `run` closure on each keystroke (matchDestinations and the
/// floating keyboard both call this per text/tab/drill change). All call sites
/// read it, never mutate it, so a single shared instance is safe.
List<KbDestination> kbDestinations() => _kbDestinationsCache ??= <KbDestination>[
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

      // ── PER-DEPARTMENT (the 4 LIVE departments) ──────────────────────────────
      // Labels are the EXACT names in DepartmentsScreen.departments where
      // `live == true` (departments_screen.dart:105-110). Each `run` opens that
      // one department via [_openDepartment] (homeDepartmentProvider = name +
      // tab 1), exactly as a department tile does — so TYPING a department name
      // lands directly on it, no extra tap. Non-live departments (חשמל / חומרי
      // בניין / צבע / גבס / אספקה) are intentionally absent: their tiles only
      // toast 'בקרוב', so they are not real destinations (see stillDeferred).
      KbDestination(
        label: 'אינסטלציה',
        keywords: const [
          'אינסטלציה',
          'מחלקת אינסטלציה',
          'צנרת',
          'צינורות',
          'שפכים',
          'ניקוז',
          'אינסטלטור',
          'plumbing',
        ],
        run: (ref, context) => _openDepartment(ref, 'אינסטלציה'),
      ),
      KbDestination(
        label: 'ברזים וסניטריים',
        keywords: const [
          'ברזים וסניטריים',
          'ברזים',
          'סניטריים',
          'כלים סניטריים',
          'אסלות',
          'כיורים',
          'מקלחות',
          'אמבטיה',
          'faucets',
          'sanitary',
        ],
        run: (ref, context) => _openDepartment(ref, 'ברזים וסניטריים'),
      ),
      KbDestination(
        label: 'כלי עבודה ידני',
        keywords: const [
          'כלי עבודה ידני',
          'כלים ידניים',
          'כלי יד',
          'חותך צינורות',
          'hand tools',
        ],
        run: (ref, context) => _openDepartment(ref, 'כלי עבודה ידני'),
      ),
      KbDestination(
        label: 'כלי עבודה חשמלי',
        keywords: const [
          'כלי עבודה חשמלי',
          'כלים חשמליים',
          'כלי ריתוך',
          'ריתוך PPR',
          'מכונת ריתוך',
          'power tools',
        ],
        run: (ref, context) => _openDepartment(ref, 'כלי עבודה חשמלי'),
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
        label: 'מאתר חכם',
        keywords: const [
          'מאתר חכם',
          'מאתר-חכם',
          'חיפוש חכם',
          'מוצא חכם',
          'מקלדת מילים',
          'smart finder',
        ],
        // → WordFinderHome, the flag-gated word-finder section. The catalog body
        // branch is inert + WordFinderHome self-gates when kWordFinder is off (see
        // _CatalogBody), so activating the section is safe UNCONDITIONALLY: flag ON
        // (the live demo) opens the finder, OFF lands on the gated host — never a
        // crash. Replaces the deleted 'מאתר חכם' section pill (keyboard-reachable).
        run: (ref, context) => _openCatalogSection(ref, 'מאתר חכם'),
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
      KbDestination(
        label: 'סידור מסך הבית',
        keywords: const [
          'סידור מסך הבית',
          'סידור הבית',
          'סדר הבית',
          'ארגון מסך',
          'סידור מסכים',
          'home arrangement',
          'reorder',
        ],
        // HomeContentReorder.route() (home_content_reorder.dart:21) — the same
        // route catalog settings' 'סידור מסך הבית' row pushes (settings:240).
        run: (ref, context) =>
            Navigator.of(context).push(HomeContentReorder.route()),
      ),
      KbDestination(
        label: 'מועדון BuildSmart',
        keywords: const [
          'מועדון',
          'מועדון BuildSmart',
          'נקודות',
          'הטבות',
          'תגמולים',
          'פרסים',
          'rewards',
          'club',
        ],
        // RewardsHubScreen.route() (rewards_hub_screen.dart:24) — the same route
        // profile's '🎮 מועדון BuildSmart' row pushes (profile_screen.dart:288).
        run: (ref, context) =>
            Navigator.of(context).push(RewardsHubScreen.route()),
      ),
      KbDestination(
        label: 'פרויקטים',
        keywords: const [
          'פרויקטים',
          'פרויקט',
          'הפרויקטים שלי',
          'אתרים',
          'projects',
        ],
        // openProjects(context) (projects_screen.dart:28) pushes
        // ProjectsScreen.route() — the projects dial/menu leaf. The budget +
        // smart-project tiles live one tap inside it.
        run: (ref, context) => openProjects(context),
      ),
      KbDestination(
        label: 'פרויקט חכם',
        keywords: const [
          'פרויקט חכם',
          'מאפס עד מסירה',
          'שלבי פרויקט',
          'התקדמות פרויקט',
          'smart project',
        ],
        // openSmartProject(context) (smart_project_screen.dart:20) pushes
        // SmartProjectScreen.route() — the same opener the projects screen's
        // smart-project tile uses (projects_screen.dart:90).
        run: (ref, context) => openSmartProject(context),
      ),
      KbDestination(
        label: 'תקציב',
        keywords: const [
          'תקציב',
          'תקציבים',
          'הוצאות',
          'עלויות',
          'כסף',
          'budget',
        ],
        // BudgetScreen.route() (budget_screen.dart:138) — the same route the
        // projects screen's '💰 תקציב' tile pushes (projects_screen.dart:79).
        run: (ref, context) =>
            Navigator.of(context).push(BudgetScreen.route()),
      ),
      KbDestination(
        label: 'כספים',
        keywords: const [
          'כספים',
          'מרכז פיננסים',
          'פיננסים',
          'חשבוניות',
          'תשלומים',
          'הכנסות',
          'finance',
        ],
        // openFinanceHub(context) (finance_hub_sheets.dart:60) — the same opener
        // the store hub's 'כספים' quick action uses (store_screen.dart:811).
        run: (ref, context) => openFinanceHub(context),
      ),
      KbDestination(
        label: 'אודיט',
        keywords: const [
          'אודיט',
          'ביקורת',
          'בדיקת איכות',
          'תאימות',
          'audit',
        ],
        // AuditScreen has NO route() — push via MaterialPageRoute exactly as the
        // install studio's '🧪 אודיט' button does (install_studio_screen.dart:
        // 799-801). The screen is self-contained (const ctor, no required args).
        run: (ref, context) => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AuditScreen()),
        ),
      ),
      KbDestination(
        label: 'חלופות זולות',
        keywords: const [
          'חלופות זולות',
          'חלופות',
          'זול יותר',
          'חיסכון',
          'מוצר זול',
          'cheaper',
        ],
        // openCheaperAlternativesSheet(context) (contractor_tools_sheets.dart:34)
        // — the same sheet the AI hub's '💡 חלופות זולות' row opens
        // (ai_hub_screen.dart:164).
        run: (ref, context) => openCheaperAlternativesSheet(context),
      ),
      KbDestination(
        label: 'השוואת מחירים',
        keywords: const [
          'השוואת מחירים',
          'השוואה',
          'מחירים',
          'השוואת ספקים',
          'price compare',
        ],
        // openPriceCompareSheet(context) (contractor_tools_sheets.dart:47) — the
        // same sheet the store services grid's price-comparison tile opens
        // (store_screen.dart:3277).
        run: (ref, context) => openPriceCompareSheet(context),
      ),
      KbDestination(
        label: 'סריקת תוכנית',
        keywords: const [
          'סריקת תוכנית',
          'סרוק תוכנית',
          'תוכנית עבודה',
          'סריקת תוכניות',
          'scan plan',
        ],
        // openScanPlanSheet(context) (contractor_tools_sheets.dart:21) — the same
        // sheet the smart home 'כלים מהירים → 📐 סרוק תוכנית עבודה' row and the
        // keyboard 'מהירים → סריקת תוכנית' leaf open (keyboard_tool_tree.dart:138).
        run: (ref, context) => openScanPlanSheet(context),
      ),
      KbDestination(
        label: 'תנאי שימוש',
        keywords: const [
          'תנאי שימוש',
          'תנאים',
          'תקנון',
          'terms',
        ],
        // LegalScreen.route() defaults to the terms tab (legal_screen.dart:27) —
        // the same route catalog settings' 'תנאי שימוש' row pushes (settings:650).
        run: (ref, context) =>
            Navigator.of(context).push(LegalScreen.route()),
      ),
      KbDestination(
        label: 'מדיניות פרטיות',
        keywords: const [
          'מדיניות פרטיות',
          'פרטיות',
          'privacy',
        ],
        // LegalScreen.route(initialTab: LegalTab.privacy) (legal_screen.dart:27)
        // — the same route catalog settings' 'מדיניות פרטיות' row pushes
        // (settings:660). Distinct tab from 'תנאי שימוש' above.
        run: (ref, context) => Navigator.of(context)
            .push(LegalScreen.route(initialTab: LegalTab.privacy)),
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
