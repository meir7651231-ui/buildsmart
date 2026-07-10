// keyboard_tool_tree — the SCREEN-AWARE tool tree behind the morph keyboard.
//
// The pure keyboard ([bs_keyboard.dart]) renders a flat list of pure [KbTile]s
// and bubbles a tapped tile back as an opaque int. The NAVIGATION meaning of
// each tile lives HERE, in the screens layer, as a tree of [KbToolNode]s:
//
//   • a LEAF node carries an [action] (`void Function(WidgetRef, BuildContext)`)
//     — run it and (for the morph keyboard) KEEP the overlay floating;
//   • a BRANCH node carries [children] — tapping it MORPHS the keyboard tool
//     view in place to those children (no navigation, no close).
//
// Two top node-lists mirror the two strip toggles:
//   • [kbHomeNodes] — the 8 HOME tools (grid toggle). Each leaf's action is the
//     SAME as today's [runKeyboardTool] for that [KbTool], reused verbatim.
//   • [kbKbdNodes]  — the KBD tools (gear toggle): קולי/חיפוש/מצלמה/היכרות as
//     leaves (again via [runKeyboardTool]) plus תפריט as a BRANCH whose children
//     are the AI hub + settings pushes — replacing the old `_openAppMenu` sheet.
//
// Import direction stays one-way: this file may import the keyboard enum, the
// existing seam ([runKeyboardTool]), and real screens — but [bs_keyboard.dart]
// imports NOTHING from here (it only knows pure [KbTile]s), so the keyboard
// widget stays screen-agnostic.

import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart'
    show kPlainDive;
import 'package:buildsmart/features/word_finder/word_finder_flag.dart'
    show kWordFinderFlag;
import 'package:buildsmart/screens/ai_hub_screen.dart';
import 'package:buildsmart/screens/budget_screen.dart' show BudgetScreen;
import 'package:buildsmart/screens/catalog_screen.dart'
    show
        catalogSectionProvider,
        catalogSectionsListProvider,
        openManageLists;
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart'
    show
        ChatsArchiveScreen,
        ChatsScreen,
        allChatsMuted,
        toggleMuteAllChats,
        updatesChatSearchProvider;
import 'package:buildsmart/screens/contractor_material_requests_sheet.dart'
    show showContractorMaterialRequestsSheet;
import 'package:buildsmart/screens/contractor_tools_sheets.dart'
    show openCheaperAlternativesSheet, openPriceCompareSheet, openScanPlanSheet;
import 'package:buildsmart/screens/courier_attendance_screen.dart'
    show CourierAttendanceScreen;
import 'package:buildsmart/screens/courier_certs_screen.dart'
    show CourierCertsScreen;
import 'package:buildsmart/screens/courier_dashboard_screen.dart'
    show showCourierNotifsSheet;
import 'package:buildsmart/screens/courier_forms_screen.dart'
    show CourierFormsScreen;
import 'package:buildsmart/screens/courier_profile_screen.dart'
    show CourierProfileScreen;
import 'package:buildsmart/screens/courier_settings_screen.dart'
    show CourierSettingsScreen;
import 'package:buildsmart/screens/defects_sheet.dart' show showDefectsSheet;
import 'package:buildsmart/screens/finance_hub_sheets.dart' show openFinanceHub;
import 'package:buildsmart/screens/home_shell.dart' show openNewChatSheet;
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show kbDestinationByLabel;
import 'package:buildsmart/screens/keyboard_tool_actions.dart'
    show runKeyboardTool;
import 'package:buildsmart/screens/legal_screen.dart'
    show LegalScreen, LegalTab;
import 'package:buildsmart/screens/lipskey_brand_screen.dart'
    show LipskeyBrandScreen;
import 'package:buildsmart/screens/manager_copilot_screen.dart';
import 'package:buildsmart/screens/manager_profile_screen.dart';
import 'package:buildsmart/screens/manager_screens_sheet.dart'
    show showManagerScreensSheet;
import 'package:buildsmart/screens/notif_settings_screen.dart'
    show NotifSettingsScreen;
import 'package:buildsmart/screens/notifications_screen.dart'
    show NotifSection, dismissAllNotifs, markAllNotifsRead, notifSectionProvider;
import 'package:buildsmart/screens/order_notif_sheet.dart'
    show showOrderNotifSheet;
import 'package:buildsmart/screens/rewards_hub_screen.dart'
    show RewardsHubScreen;
import 'package:buildsmart/screens/role_picker_sheet.dart' show showRolePicker;
import 'package:buildsmart/screens/role_request_sheet.dart'
    show showRoleRequestSheet;
import 'package:buildsmart/screens/site_hub_screen.dart' show openSiteHub;
import 'package:buildsmart/screens/smart_project_screen.dart'
    show SmartProjectScreen;
import 'package:buildsmart/screens/stock_screen.dart' show StockScreen;
import 'package:buildsmart/screens/store_dashboard_screen.dart'
    show SupplierSettingsScreen;
import 'package:buildsmart/screens/store_documents_sheet.dart'
    show showStoreDocumentsSheet;
import 'package:buildsmart/screens/store_profile_screen.dart'
    show StoreCertsScreen, StoreProfileScreen;
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
import 'package:buildsmart/screens/store_settings_screen.dart'
    show StoreSettingsScreen;
import 'package:buildsmart/screens/tasks_gantt_sheet.dart'
    show showTasksGanttSheet;
import 'package:buildsmart/screens/tasks_screen.dart' show TasksScreen;
import 'package:buildsmart/screens/updates_screen.dart'
    show updatesSubTabProvider;
import 'package:buildsmart/screens/worker_attendance_screen.dart';
import 'package:buildsmart/screens/worker_forms_screen.dart';
import 'package:buildsmart/screens/worker_payslips_sheet.dart'
    show showWorkerPayslipsSheet;
import 'package:buildsmart/screens/worker_safety_screen.dart';
import 'package:buildsmart/screens/worker_settings_screen.dart'
    show WorkerSettingsScreen;
import 'package:buildsmart/screens/worker_task_board_screen.dart'
    show WorkerTaskBoardScreen;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/feature_flags.dart'
    show featureFlagsProvider;
import 'package:buildsmart/state/hidden_catalog_sections.dart'
    show hiddenCatalogSectionsProvider;
import 'package:buildsmart/state/sys_chat.dart' show BsRole;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:buildsmart/widgets/confirm_dialog.dart' show confirmDestructive;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show KbTile, KbTool;
import 'package:buildsmart/widgets/toast.dart' show showToast;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One node of the keyboard tool tree: an [icon] + Hebrew [label] that is EITHER
/// a LEAF (non-null [action], null/empty [children]) or a BRANCH (non-null,
/// non-empty [children]). Exactly one of the two roles applies; [isBranch]
/// reports which.
@immutable
class KbToolNode {
  const KbToolNode.leaf({
    required this.icon,
    required this.label,
    required this.action,
    this.isVoiceInput = false,
  }) : children = const <KbToolNode>[];

  const KbToolNode.branch({
    required this.icon,
    required this.label,
    required this.children,
  })  : action = null,
        isVoiceInput = false;

  /// The Material icon shown on the tile.
  final IconData icon;

  /// The Hebrew label shown under the icon (and used as the Semantics label).
  final String label;

  /// LEAF action — run on tap (and keep the floating overlay open). Null for a
  /// branch. Receives the floating keyboard's own `ref`/`context`.
  final void Function(WidgetRef ref, BuildContext context)? action;

  /// BRANCH children — the node-list the keyboard morphs to on tap. Empty for a
  /// leaf.
  final List<KbToolNode> children;

  /// STEP D — VOICE-INPUT marker. `true` ONLY on the קולי leaf: voice-to-text
  /// needs the field controller (`_controller`), which the `(ref, context)`
  /// [action] signature cannot reach, so the FLOATING keyboard intercepts a tap
  /// on a voice-marked node (in `_onTile`) and runs the mic→`insertAtCaret`
  /// path itself instead of the (no-op) [action]. Every other node is `false`.
  final bool isVoiceInput;

  /// True when this node drills into [children] (morph) rather than running an
  /// action (navigate/keep-floating).
  bool get isBranch => children.isNotEmpty;
}

/// Projects a node-list to the PURE [KbTile]s the keyboard renders. The tile
/// `id` is just the node's INDEX in [nodes]; the floating keyboard maps that
/// index back to the node when `BsKeyboard.onTile` fires. (Index is a safe,
/// stable id because the keyboard is always handed the SAME list it tapped in.)
List<KbTile> kbTilesFor(List<KbToolNode> nodes) => <KbTile>[
      for (var i = 0; i < nodes.length; i++)
        KbTile(icon: nodes[i].icon, label: nodes[i].label, id: i),
    ];

/// The 8 HOME tool nodes (grid toggle). Most are leaves whose action delegates
/// to the existing [runKeyboardTool] for the matching [KbTool], so the per-tool
/// destination stays IDENTICAL to today (departments → tab 1, finder → catalog
/// 'מאתר', …). STEP D rewired three: מהירים is now a BRANCH (its 3 _QuickTools
/// children), הזמנות jumps to the store orders section directly, and מסלול stays
/// a deferred "בקרוב" leaf (no nav target exists). Order matches the legacy home
/// layer.
List<KbToolNode> kbHomeNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.grid_view,
        label: 'מחלקות',
        action: (ref, context) =>
            runKeyboardTool(ref, context, KbTool.departments),
      ),
      KbToolNode.leaf(
        icon: Icons.account_tree,
        label: 'עץ חכם',
        action: (ref, context) =>
            runKeyboardTool(ref, context, KbTool.smartTree),
      ),
      // STEP D — "מסלול" stays DEFERRED. The only מסלול surface
      // (smart_home_screen.dart `_WorkPath`, ~414-476) is a display-only hero
      // with NO onTap / no nav target, so wiring a leaf would be a guessed/broken
      // destination. It remains a "בקרוב" leaf (via [runKeyboardTool]) until a
      // real work-route/project screen exists. Recorded in deferred[].
      KbToolNode.leaf(
        icon: Icons.route,
        label: 'מסלול',
        action: (ref, context) =>
            runKeyboardTool(ref, context, KbTool.workRoute),
      ),
      // STEP D — "מהירים" is now a BRANCH whose 3 children mirror
      // smart_home_screen.dart `_QuickTools` (~485-503) EXACTLY: scan-plan sheet,
      // my-stock screen, tasks hub. Tapping it MORPHS the tool view in place to
      // these three (no nav); each child is a keep-floating LEAF.
      KbToolNode.branch(
        icon: Icons.bolt,
        label: 'מהירים',
        children: <KbToolNode>[
          KbToolNode.leaf(
            icon: Icons.description_outlined,
            label: 'סריקת תוכנית',
            // smart_home_screen.dart:490 — openScanPlanSheet(context).
            action: (ref, context) => openScanPlanSheet(context),
          ),
          KbToolNode.leaf(
            icon: Icons.inventory_2_outlined,
            label: 'המלאי שלי',
            // smart_home_screen.dart:496 — push StockScreen.route().
            action: (ref, context) =>
                Navigator.of(context).push(StockScreen.route()),
          ),
          KbToolNode.leaf(
            icon: Icons.checklist_rtl,
            label: 'משימות',
            // smart_home_screen.dart:502 — openSiteHub(context).
            action: (ref, context) => openSiteHub(context),
          ),
        ],
      ),
      // STEP D — "הזמנות" is a REAL leaf now: jump to the store's ORDERS section,
      // mirroring the store's own section pills (store_screen.dart:38-41,676 +
      // keyboard_destinations.dart:111-114): tab 3 (חנות) + storeSectionProvider
      // = orders. Keep-floating (a section swap under the overlay).
      KbToolNode.leaf(
        icon: Icons.receipt_long,
        label: 'הזמנות',
        action: (ref, context) {
          ref.read(mainTabProvider.notifier).state = 3;
          ref.read(storeSectionProvider.notifier).state = StoreSection.orders;
        },
      ),
      KbToolNode.leaf(
        icon: Icons.gps_fixed,
        label: 'מאתר',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.finder),
      ),
      KbToolNode.leaf(
        icon: Icons.cable,
        label: 'חיבור',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.connect),
      ),
      KbToolNode.leaf(
        icon: Icons.star_border,
        label: 'מועדפים',
        action: (ref, context) =>
            runKeyboardTool(ref, context, KbTool.favorites),
      ),
    ];

/// The KBD tool nodes (gear toggle): קולי / חיפוש / מצלמה / היכרות leaves (via
/// [runKeyboardTool]) + תפריט as a BRANCH. The branch children are the two app
/// destinations the old `_openAppMenu` sheet offered — the AI hub and settings —
/// each a LEAF that pushes the real route (full screen over everything; the
/// floating keyboard reappears when that route pops). Order matches the legacy
/// kbd layer (with תפריט now opening children instead of a sheet).
List<KbToolNode> kbKbdNodes() => <KbToolNode>[
      // STEP D — "קולי" is voice-to-text INTO the keyboard field. The mic needs
      // the field controller, which the (ref, context) action can't reach, so it
      // is MARKED [isVoiceInput]: the FLOATING keyboard intercepts a tap on it
      // (floating_card_keyboard.dart `_onTile`) and runs VoiceService.listen →
      // insertAtCaret(_controller, …) itself. The [action] here is only the
      // legacy non-morph fallback (a "בקרוב" SnackBar via [runKeyboardTool]).
      KbToolNode.leaf(
        icon: Icons.mic,
        label: 'קולי',
        isVoiceInput: true,
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.voice),
      ),
      KbToolNode.leaf(
        icon: Icons.search,
        label: 'חיפוש',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.search),
      ),
      KbToolNode.branch(
        icon: Icons.more_vert,
        label: 'תפריט',
        children: <KbToolNode>[
          KbToolNode.leaf(
            icon: Icons.smart_toy,
            label: 'בינה',
            action: (ref, context) =>
                Navigator.of(context).push(AIHubScreen.route()),
          ),
          KbToolNode.leaf(
            icon: Icons.settings,
            label: 'הגדרות',
            action: (ref, context) =>
                Navigator.of(context).push(CatalogSettingsScreen.route()),
          ),
        ],
      ),
      KbToolNode.leaf(
        icon: Icons.camera_alt,
        label: 'מצלמה',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.camera),
      ),
      KbToolNode.leaf(
        icon: Icons.lightbulb_outline,
        label: 'היכרות',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.intro),
      ),
    ];

// ─── עדכונים live-mirror tool node-lists (plan seam 11) ───────────────────────
//
// The עדכונים deriver ([keyboard_updates_deriver.dart]) supplies a THIRD
// stack-base node-list (alongside [kbHomeNodes]/[kbKbdNodes]) reflecting WHERE
// the floating keyboard is on the עדכונים tab. These two factories build those
// node-lists with the SAME [KbToolNode.leaf]/[.branch] shape every other tool
// view uses, so the floating keyboard renders + dispatches them through the
// unchanged `kbTilesFor → tiles:` + `_onTile` path. Each is a `()` factory (not
// a const) because the leaf actions are non-const closures, mirroring
// [kbHomeNodes]/[kbKbdNodes].

/// Shows the honest "<label> — בקרוב" SnackBar for ANY not-yet-wired tool leaf in
/// this file — the SINGLE deferral helper shared by the עדכונים / חנות / מחלקות
/// live-mirror node-lists (the SAME idiom `keyboard_tool_actions.dart`'s private
/// `_comingSoon` uses for מסלול/מהירים, reproduced here because that helper is
/// private to its file). Used wherever a tool's real opener is not exposed yet and
/// shipping "בקרוב" is the honest deferral rather than a broken nav:
///   • שיחות   — new-chat / search-chats / attach (real openers wired plan phase 6);
///   • חנות    — cart לקופה / רוקן סל (handlers live in private store widgets);
///   • מחלקות  — מסלול עבודה (no real work-route screen exists yet).
void _toolSoon(BuildContext context, String label) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$label — בקרוב')));
}

/// התראות tools (owner steps 1 + 4): 🔕 סמן הכל כנקרא + ⚙️ הגדרות התראות. Both
/// reuse EXISTING public actions verbatim:
///   • mark-all-read → [markAllNotifsRead] (notifications_screen.dart) — the same
///     action the AppBar 3-dot 'סמן הכל כנקרא' runs (it honours the empty live
///     feed, marking the active set);
///   • notif-settings → push [NotifSettingsScreen.route()] — the same route the
///     notifications 3-dot 'הגדרות התראות' and `keyboard_destinations.dart` push.
/// Keep-floating: mark-all-read mutates a provider (overlay stays); settings
/// pushes a full route over everything (the keyboard reappears when it pops).
List<KbToolNode> kbUpdatesNotifNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.done_all,
        label: 'סמן הכל כנקרא',
        action: (ref, context) => markAllNotifsRead(ref),
      ),
      KbToolNode.leaf(
        icon: Icons.settings,
        label: 'הגדרות התראות',
        action: (ref, context) =>
            Navigator.of(context).push(NotifSettingsScreen.route()),
      ),
    ];

/// שיחות tools (owner steps 2 + 3): ➕ שיחה חדשה · 🔍 חיפוש שיחות · 📎 צרף ·
/// 🎤 קולי. ➕ שיחה חדשה is WIRED to [openNewChatSheet] (the SAME _NewChatSheet
/// contact-picker the chats ⋮ menu shows); 🔍 חיפוש שיחות RESETS the chat filter
/// ([updatesChatSearchProvider]) for a fresh search (the LIVE search is typing on
/// the שיחות sub-tab — the floating keyboard routes it to that same provider);
/// 📎 צרף stays HONEST "בקרוב" (attach means something only inside a chat's
/// compose bar, where it already works — not the list). The conversation PREDICTIONS (the real-data surface) stay wired in the
/// deriver meanwhile.
/// 🎤 קולי REUSES the existing voice leaf verbatim ([KbToolNode.leaf] with
/// `isVoiceInput: true`): the FLOATING keyboard already intercepts a voice-marked
/// node in `_onTile` and runs mic→`insertAtCaret` itself, so the same leaf works
/// here with no new plumbing (its non-morph `action` is the legacy "בקרוב"
/// fallback only, exactly as in [kbKbdNodes]).
List<KbToolNode> kbUpdatesChatsNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.add_comment_outlined,
        label: 'שיחה חדשה',
        action: (ref, context) => openNewChatSheet(context),
      ),
      KbToolNode.leaf(
        icon: Icons.search,
        label: 'חיפוש שיחות',
        // Live search on the שיחות sub-tab is TYPING (the floating keyboard routes
        // it to [updatesChatSearchProvider]); this chip RESETS that filter so a tap
        // starts a fresh search (shows every thread again).
        action: (ref, context) {
          ref.read(updatesChatSearchProvider.notifier).state = '';
        },
      ),
      KbToolNode.leaf(
        icon: Icons.attach_file,
        label: 'צרף',
        action: (ref, context) => _toolSoon(context, 'צרף'),
      ),
      KbToolNode.leaf(
        icon: Icons.mic,
        label: 'קולי',
        isVoiceInput: true,
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.voice),
      ),
    ];

// ─── חנות live-mirror tool node-lists ─────────────────────────────────────────
//
// The חנות deriver ([keyboard_store_deriver.dart]) supplies a THIRD stack-base
// node-list (alongside [kbHomeNodes]/[kbKbdNodes], exactly like the עדכונים
// node-lists above) reflecting WHICH store section the floating keyboard is on
// (mainTabProvider == 3). [kbStoreNodes] returns the per-section node-list with
// the SAME [KbToolNode.leaf]/[.branch] shape every other tool view uses, so the
// floating keyboard renders + dispatches them through the unchanged
// `kbTilesFor → tiles:` + `_onTile` path. It is a `(StoreSection)` factory (not a
// const) because the leaf actions are non-const closures, mirroring
// [kbHomeNodes]/[kbUpdatesNotifNodes].

/// The per-section store tool node-list ([mainTabProvider] == 3). Each section
/// surfaces the actions that are REAL + verified for that surface; where the real
/// handler is private (cart checkout/clear) it ships an honest "בקרוב" leaf (the
/// established deferral), never a broken nav.
///
///   • [StoreSection.cart]  — 🛒: לקופה / רוקן סל are private store handlers ⇒
///     honest "בקרוב" leaves; 💰 כספים reuses [openFinanceHub] (the SAME opener
///     the store hub's 'כספים' quick action uses, store_screen.dart:811).
///   • [StoreSection.orders]— 📦: 🔔 התראות הזמנות reuses [showOrderNotifSheet]
///     (the SAME sheet the orders section's 🔔 button opens,
///     store_screen.dart:700); 📊 השוואת מחירים reuses [openPriceCompareSheet].
///   • [StoreSection.services]— 🔧: 📊 השוואת מחירים ([openPriceCompareSheet]) +
///     💡 חלופות זולות ([openCheaperAlternativesSheet]) — both real service
///     sheets the store already opens.
///   • [StoreSection.all]   — the hub root: 📦 הזמנות jumps to the orders section
///     (the SAME pairing keyboard_destinations.dart's `_openStoreSection` does:
///     tab 3 + storeSectionProvider = orders) + 💰 כספים ([openFinanceHub]).
/// Keep-floating throughout: a section-jump swaps the screen underneath; a sheet
/// opener pushes over everything (the keyboard reappears when it pops).
List<KbToolNode> kbStoreNodes(StoreSection section) => switch (section) {
      StoreSection.cart => <KbToolNode>[
          KbToolNode.leaf(
            icon: Icons.point_of_sale,
            label: 'לקופה',
            action: (ref, context) => _toolSoon(context, 'לקופה'),
          ),
          KbToolNode.leaf(
            icon: Icons.delete_outline,
            label: 'רוקן סל',
            action: (ref, context) => _toolSoon(context, 'רוקן סל'),
          ),
          KbToolNode.leaf(
            icon: Icons.account_balance_wallet_outlined,
            label: 'כספים',
            action: (ref, context) => openFinanceHub(context),
          ),
        ],
      StoreSection.orders => <KbToolNode>[
          KbToolNode.leaf(
            icon: Icons.notifications_outlined,
            label: 'התראות הזמנות',
            action: (ref, context) => showOrderNotifSheet(context),
          ),
          KbToolNode.leaf(
            icon: Icons.compare_arrows,
            label: 'השוואת מחירים',
            action: (ref, context) => openPriceCompareSheet(context),
          ),
        ],
      StoreSection.services => <KbToolNode>[
          KbToolNode.leaf(
            icon: Icons.compare_arrows,
            label: 'השוואת מחירים',
            action: (ref, context) => openPriceCompareSheet(context),
          ),
          KbToolNode.leaf(
            icon: Icons.lightbulb_outline,
            label: 'חלופות זולות',
            action: (ref, context) => openCheaperAlternativesSheet(context),
          ),
        ],
      StoreSection.all => <KbToolNode>[
          KbToolNode.leaf(
            icon: Icons.receipt_long,
            label: 'הזמנות',
            action: (ref, context) {
              ref.read(mainTabProvider.notifier).state = 3;
              ref.read(storeSectionProvider.notifier).state =
                  StoreSection.orders;
            },
          ),
          KbToolNode.leaf(
            icon: Icons.account_balance_wallet_outlined,
            label: 'כספים',
            action: (ref, context) => openFinanceHub(context),
          ),
        ],
    };

// ─── מחלקות live-mirror tool node-list ────────────────────────────────────────
//
// The מחלקות deriver ([keyboard_dept_deriver.dart]) supplies a THIRD stack-base
// node-list (alongside [kbHomeNodes]/[kbKbdNodes], exactly like the
// עדכונים/חנות node-lists above) reflecting the departments surface
// (mainTabProvider == 1). [kbDeptNodes] returns the department-level node-list
// with the SAME [KbToolNode.leaf]/[.branch] shape every other tool view uses, so
// the floating keyboard renders + dispatches them through the unchanged
// `kbTilesFor → tiles:` + `_onTile` path. It is a `()` factory (not a const)
// because the leaf actions are non-const closures, mirroring
// [kbHomeNodes]/[kbStoreNodes].

/// The department-level tool node-list ([mainTabProvider] == 1). These are the
/// catalog-navigation tools that make sense ACROSS the departments surface,
/// REUSING existing public openers verbatim (the SAME [runKeyboardTool] seam
/// [kbHomeNodes] uses, so the destination stays identical to the home tiles):
///   • עץ חכם → [runKeyboardTool] with [KbTool.smartTree] (catalog smart-tree
///     section — the SAME target kbHomeNodes' 'עץ חכם' leaf and the
///     keyboard_destinations.dart 'עץ חכם' destination open);
///   • מאתר  → [runKeyboardTool] with [KbTool.finder] (the catalog FinderScreen —
///     the SAME target kbHomeNodes' 'מאתר' leaf opens).
/// DEFERRED: מסלול עבודה has no real work-route/project screen yet (the only
/// current surface is a display-only hero in smart_home_screen.dart — `_WorkPath`,
/// ~414-476 — with NO onTap / no nav target), so wiring it would be a
/// guessed/broken nav. It ships HONEST via the [_toolSoon] "בקרוב" SnackBar until
/// a real opener exists (plan phase 7+). Mirrors the deferred 'מסלול' in
/// [kbHomeNodes] (keyboard_tool_tree.dart:122-132) exactly. Keep-floating
/// throughout: a tool that swaps the catalog section swaps the screen underneath;
/// a route push pushes over everything (the keyboard reappears when it pops); the
/// "בקרוב" leaf only shows a SnackBar.
List<KbToolNode> kbDeptNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.account_tree,
        label: 'עץ חכם',
        action: (ref, context) =>
            runKeyboardTool(ref, context, KbTool.smartTree),
      ),
      KbToolNode.leaf(
        icon: Icons.gps_fixed,
        label: 'מאתר',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.finder),
      ),
      // DEFERRED like kbHomeNodes' 'מסלול' (no real work-route surface exists);
      // honest "בקרוב" leaf, never a broken nav.
      KbToolNode.leaf(
        icon: Icons.route,
        label: 'מסלול עבודה',
        action: (ref, context) => _toolSoon(context, 'מסלול עבודה'),
      ),
    ];

/// Wrap a navigable destination [label] ([kbDestinationByLabel]) as a tool leaf
/// with [icon] — reusing that destination's verified opener. Null when the label
/// is not a known destination, so the caller can skip it (defensive).
KbToolNode? _destNode(String label, IconData icon) {
  final d = kbDestinationByLabel(label);
  if (d == null) return null;
  return KbToolNode.leaf(icon: icon, label: label, action: d.run);
}

/// Owner button-spec v2 (#2): the CURRENT tab's tool node-list — the FULL set of
/// the screen's navigable items (not a curated subset), each wired to the SAME
/// opener the screen's own pill/tile uses (via [kbDestinationByLabel]). Labels not
/// in the registry are skipped (defensive). tab 0 (בית) = the catalog section
/// pills · tab 1 (מחלקות) = the live departments + עץ-חכם/מאתר · tab 2 (עדכונים) =
/// the two sub-tabs · tab 3 (חנות) = the store sections + כספים. [ref] is accepted
/// for parity with the other node-list factories (future per-tab live reads).
List<KbToolNode> kbTabToolNodes(int tab, WidgetRef ref) {
  const lists = <int, List<(String, IconData)>>{
    1: <(String, IconData)>[
      ('אינסטלציה', Icons.plumbing),
      ('ברזים וסניטריים', Icons.water_drop_outlined),
      ('כלי עבודה ידני', Icons.handyman),
      ('כלי עבודה חשמלי', Icons.bolt),
      ('עץ חכם', Icons.account_tree),
      ('מאתר', Icons.gps_fixed),
    ],
    2: <(String, IconData)>[
      ('התראות', Icons.notifications_outlined),
      ('שיחות', Icons.chat_bubble_outline),
    ],
    3: <(String, IconData)>[
      ('הסל שלי', Icons.shopping_cart_outlined),
      ('ההזמנות שלי', Icons.receipt_long),
      ('שירותים', Icons.home_repair_service_outlined),
      ('כספים', Icons.account_balance_wallet_outlined),
    ],
  };
  final out = <KbToolNode>[];
  if (tab == 0) {
    // OWNER: tab 0 (בית) LIVE-MIRRORS the catalog section list — 'בית' leads, then
    // every VISIBLE list (incl. user-created, honouring hide + order) is a CHIP, the
    // flag-gated 'מאתר חכם', and a 'רשימות' chip that opens the FULL list manager
    // (create / edit-contents / rename / hide / delete / reorder). This replaces the
    // deleted section-pill row: the lists AND all their options now live in the
    // keyboard. Read (not watched): the grid rebuilds each time it re-opens.
    final home = _destNode('בית', Icons.home_outlined);
    if (home != null) out.add(home);
    final hidden = ref.read(hiddenCatalogSectionsProvider);
    for (final s in ref.read(catalogSectionsListProvider)) {
      if (hidden.contains(s)) continue;
      // A fixed section has a destination (the SAME opener its pill used); a
      // user-created list has none → a manual leaf that activates its section.
      out.add(_destNode(s, _kbListIcon(s)) ?? _listSectionChip(s));
    }
    if (ref.read(featureFlagsProvider).contains(kWordFinderFlag)) {
      out.add(
        KbToolNode.leaf(
          icon: Icons.auto_awesome,
          label: 'מאתר חכם',
          action: (ref, context) {
            ref.read(mainTabProvider.notifier).state = 0;
            ref.read(catalogSectionProvider.notifier).state = 'מאתר חכם';
          },
        ),
      );
    }
    // OWNER · a SEPARATE 'מאתר פשוט' chip next to 'מאתר חכם' — the layman 4-ring
    // dictionary drill (PlainDive). Behind [kPlainDive] (const-false ⇒ this block
    // tree-shakes out ⇒ the keyboard grid is byte-identical by default).
    if (kPlainDive) {
      out.add(
        KbToolNode.leaf(
          icon: Icons.spoke_outlined,
          label: 'מאתר פשוט',
          action: (ref, context) {
            ref.read(mainTabProvider.notifier).state = 0;
            ref.read(catalogSectionProvider.notifier).state = 'מאתר פשוט';
          },
        ),
      );
    }
    out.add(
      KbToolNode.leaf(
        icon: Icons.playlist_add_check,
        label: 'רשימות',
        action: (ref, context) => openManageLists(context, ref),
      ),
    );
  } else {
    for (final (label, icon) in lists[tab] ?? const <(String, IconData)>[]) {
      final node = _destNode(label, icon);
      if (node != null) out.add(node);
    }
    if (tab == 2) {
      // OWNER (same treatment): the התראות type-filter chips — its deleted screen
      // row. Each activates a NotifSection filter (notifSectionProvider) on tab 2.
      for (final (label, section, icon) in _kNotifFilters) {
        out.add(
          KbToolNode.leaf(
            icon: icon,
            label: label,
            action: (ref, context) {
              ref.read(mainTabProvider.notifier).state = 2;
              ref.read(notifSectionProvider.notifier).state = section;
            },
          ),
        );
      }
    }
  }
  // Never leave ▦ empty: if nothing resolved (registry shape changed), fall back
  // to the legacy home tools.
  return out.isEmpty ? kbHomeNodes() : out;
}

/// OWNER: the התראות type-filter chips (its deleted screen row) as keyboard tools —
/// label · the [NotifSection] it selects · its icon.
const _kNotifFilters = <(String, NotifSection, IconData)>[
  ('הכל', NotifSection.all, Icons.notifications_none),
  ('משלוחים', NotifSection.shipments, Icons.local_shipping_outlined),
  ('הזמנות', NotifSection.orders, Icons.shopping_cart_outlined),
  ('בטיחות', NotifSection.safety, Icons.health_and_safety_outlined),
  ('תקציב', NotifSection.budget, Icons.account_balance_wallet_outlined),
  ('מבצעים', NotifSection.deals, Icons.card_giftcard_outlined),
];

IconData _kbListIcon(String label) => switch (label) {
      'מאתר'            => Icons.gps_fixed,
      'עץ חכם'          => Icons.account_tree,
      'קטגוריות'        => Icons.grid_view,
      'וריאנטים'        => Icons.tune,
      'תכנון חיבור'     => Icons.cable,
      'חיפושים אחרונים' => Icons.history,
      'מועדפים'         => Icons.star_border,
      _                 => Icons.list_alt_outlined,
    };

/// A user-created catalog list (which has no [kbDestination]) as a keyboard chip:
/// activates its section (tab 0 + [catalogSectionProvider]), exactly like its pill.
KbToolNode _listSectionChip(String label) => KbToolNode.leaf(
      icon: Icons.list_alt_outlined,
      label: label,
      action: (ref, context) {
        ref.read(mainTabProvider.notifier).state = 0;
        ref.read(catalogSectionProvider.notifier).state = label;
      },
    );

/// The 4 generic keyboard tools (קולי / חיפוש / מצלמה / היכרות) kept accessible
/// from the ⚙ menu on EVERY screen — the owner's "they all stay" — each wired to
/// its REAL opener: voice via the floating keyboard's `isVoiceInput` intercept
/// (the real mic→field path), the rest via [runKeyboardTool] (search → the
/// finder section, camera → the barcode scanner, intro → help mode). Appended
/// after each screen's own overflow items in [kbScreenMenuNodes].
List<KbToolNode> _kbGenericTools() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.mic,
        label: 'קולי',
        isVoiceInput: true,
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.voice),
      ),
      KbToolNode.leaf(
        icon: Icons.search,
        label: 'חיפוש',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.search),
      ),
      KbToolNode.leaf(
        icon: Icons.camera_alt,
        label: 'מצלמה',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.camera),
      ),
      KbToolNode.leaf(
        icon: Icons.lightbulb_outline,
        label: 'היכרות',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.intro),
      ),
    ];

/// The notifications ⋮ "נקה הכל" flow, wired to the SAME confirm-gated clear the
/// mirror-target (`_NotificationsMenuButton`) runs: a destructive confirm, then
/// [dismissAllNotifs] + a toast — never a confirmless wipe. Reached only from the
/// KB_BUTTONS_V2 ⚙ menu ([kbScreenMenuNodes]), so it tree-shakes out off-flag.
Future<void> _clearAllNotifsFlow(BuildContext context, WidgetRef ref) async {
  final ok = await confirmDestructive(
    context,
    title: 'ניקוי כל ההתראות?',
    message: 'כל ההתראות יימחקו לצמיתות.',
    confirmLabel: 'נקה הכל',
  );
  if (!ok || !context.mounted) return;
  dismissAllNotifs(ref);
  showToast(context, 'כל ההתראות נמחקו');
}

/// The chats ⋮ "השתק הכל" flow, mirroring `_ChatsMenuButton`: confirm before
/// muting (un-muting needs none), then [toggleMuteAllChats] + a toast.
Future<void> _muteAllChatsFlow(BuildContext context, WidgetRef ref) async {
  final wasAllMuted = allChatsMuted(ref);
  if (!wasAllMuted) {
    final ok = await confirmDestructive(
      context,
      title: 'השתקת כל השיחות?',
      message: 'כל השיחות יושתקו עד לביטול ההשתקה.',
      confirmLabel: 'השתק',
      confirmColor: BsTokens.brand,
    );
    if (!ok || !context.mounted) return;
  }
  toggleMuteAllChats(ref);
  showToast(context, wasAllMuted ? 'ההשתקה בוטלה' : 'כל השיחות הושתקו');
}

/// Owner button-spec v2 (#4): the CURRENT screen's ⋮ overflow menu as keyboard
/// tools — what the floating ⚙ opens. Mirrors HomeShell's per-tab AppBar overflow
/// popups (`_CatalogMenuButton` / `_NotificationsMenuButton` / `_ChatsMenuButton`
/// / `_StoreMenuButton`). Navigation + mark-read items reuse the SAME public
/// openers/actions those menus run; the confirm-gated destructive items
/// (נקה הכל / השתק הכל) and the private new-chat sheet ship as honest "בקרוב"
/// until exposed (the established deferral — never a confirmless/broken action).
/// tab 2 (עדכונים) reads [updatesSubTabProvider] to mirror the התראות-vs-שיחות
/// split; tabs 0 + 1 share the catalog overflow.
List<KbToolNode> kbScreenMenuNodes(int tab, WidgetRef ref) {
  switch (tab) {
    case 2:
      if (ref.read(updatesSubTabProvider) == 1) {
        // שיחות (chats) overflow — mirrors _ChatsMenuButton.
        return <KbToolNode>[
          KbToolNode.leaf(
            icon: Icons.add_comment_outlined,
            label: 'שיחה חדשה',
            action: (ref, context) => openNewChatSheet(context),
          ),
          KbToolNode.leaf(
            icon: Icons.archive_outlined,
            label: 'ארכיון שיחות',
            action: (ref, context) =>
                Navigator.of(context).push(ChatsArchiveScreen.route()),
          ),
          KbToolNode.leaf(
            icon: Icons.notifications_off_outlined,
            label: 'השתק הכל',
            action: (ref, context) => _muteAllChatsFlow(context, ref),
          ),
          ..._kbGenericTools(),
        ];
      }
      // התראות (notifications) overflow — mirrors _NotificationsMenuButton.
      return <KbToolNode>[
        KbToolNode.leaf(
          icon: Icons.done_all,
          label: 'סמן הכל כנקרא',
          action: (ref, context) => markAllNotifsRead(ref),
        ),
        KbToolNode.leaf(
          icon: Icons.clear_all,
          label: 'נקה הכל',
          action: (ref, context) => _clearAllNotifsFlow(context, ref),
        ),
        KbToolNode.leaf(
          icon: Icons.settings,
          label: 'הגדרות התראות',
          action: (ref, context) =>
              Navigator.of(context).push(NotifSettingsScreen.route()),
        ),
        ..._kbGenericTools(),
      ];
    case 3:
      // חנות (store) overflow — mirrors _StoreMenuButton (שירותים is gated by
      // kHideUnderConstruction in the AppBar, so omitted here for v1).
      return <KbToolNode>[
        KbToolNode.leaf(
          icon: Icons.shopping_cart_outlined,
          label: 'הסל שלי',
          action: (ref, context) =>
              ref.read(storeSectionProvider.notifier).state = StoreSection.cart,
        ),
        KbToolNode.leaf(
          icon: Icons.receipt_long,
          label: 'הזמנות',
          action: (ref, context) => ref
              .read(storeSectionProvider.notifier)
              .state = StoreSection.orders,
        ),
        KbToolNode.leaf(
          icon: Icons.settings,
          label: 'הגדרות',
          action: (ref, context) =>
              Navigator.of(context).push(StoreSettingsScreen.route()),
        ),
        ..._kbGenericTools(),
      ];
    default:
      // בית + מחלקות (catalog/departments) overflow — mirrors _CatalogMenuButton.
      return <KbToolNode>[
        KbToolNode.leaf(
          icon: Icons.smart_toy,
          label: 'בינה מלאכותית ואוטומציה',
          action: (ref, context) =>
              Navigator.of(context).push(AIHubScreen.route()),
        ),
        KbToolNode.leaf(
          icon: Icons.settings,
          label: 'הגדרות',
          action: (ref, context) =>
              Navigator.of(context).push(CatalogSettingsScreen.route()),
        ),
        ..._kbGenericTools(),
      ];
  }
}

// ─── PUSHED-ROUTE screen tool node-lists ([KbScreen] adopters) ────────────────
//
// These are the FIRST screens to ADOPT [KbScreen] (lib/state/keyboard_screen_tools.dart),
// proving the stack-aware mirror end-to-end: each wraps its body in
// `KbScreen(tools: <one of these factories>, child: <its Scaffold>)`, so while the
// route is front-most under [kKbGlobal] the floating ▦ grid shows ITS tools and
// reverts to the parent's on pop. Each factory returns the screen's OWN relevant
// actions, reusing verified openers (route pushes / provider writes) — never a
// broken nav. They are top-level `()` factories (not const — the leaf actions are
// non-const closures), mirroring [kbHomeNodes]/[kbStoreNodes]; an adopter must
// build its list ONCE (e.g. a `static final`) so [KbScreen]'s identity-compare
// (didUpdateWidget) never churns the registration.

/// המלאי שלי ([StockScreen]) tools: 📥 בקשות חומר (its AppBar action) + ⚙ הגדרות
/// חנות (the store-settings route). Keep-floating: the first opens a sheet, the
/// second pushes a route (the keyboard reappears on pop).
List<KbToolNode> kbStockNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.inbox_outlined,
        label: 'בקשות חומר',
        action: (ref, context) =>
            showContractorMaterialRequestsSheet(context),
      ),
      KbToolNode.leaf(
        icon: Icons.settings,
        label: 'הגדרות חנות',
        action: (ref, context) =>
            Navigator.of(context).push(StoreSettingsScreen.route()),
      ),
    ];

/// 🤖 בינה ([AIHubScreen]) tools: 🔍 מאתר + 🌳 עץ חכם (the two catalog entry
/// points that make sense from the AI hub), via the SAME [runKeyboardTool] seam
/// the home tiles use, so the destination stays identical.
List<KbToolNode> kbAiHubNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.gps_fixed,
        label: 'מאתר',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.finder),
      ),
      KbToolNode.leaf(
        icon: Icons.account_tree,
        label: 'עץ חכם',
        action: (ref, context) =>
            runKeyboardTool(ref, context, KbTool.smartTree),
      ),
    ];

/// ⚙️ הגדרות ([CatalogSettingsScreen]) tools: 🔔 הגדרות התראות + 🛍️ הגדרות חנות —
/// the two sibling settings routes, each pushed over (keyboard reappears on pop).
List<KbToolNode> kbCatalogSettingsNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.notifications_outlined,
        label: 'הגדרות התראות',
        action: (ref, context) =>
            Navigator.of(context).push(NotifSettingsScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.storefront_outlined,
        label: 'הגדרות חנות',
        action: (ref, context) =>
            Navigator.of(context).push(StoreSettingsScreen.route()),
      ),
    ];

/// 🔔 הגדרות התראות ([NotifSettingsScreen]) tools: ✅ סמן הכל כנקרא (the same
/// public action the notifications overflow runs) + ⚙ הגדרות (the catalog
/// settings route).
List<KbToolNode> kbNotifSettingsNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.done_all,
        label: 'סמן הכל כנקרא',
        action: (ref, context) => markAllNotifsRead(ref),
      ),
      KbToolNode.leaf(
        icon: Icons.settings,
        label: 'הגדרות',
        action: (ref, context) =>
            Navigator.of(context).push(CatalogSettingsScreen.route()),
      ),
    ];

/// 🛍️ הגדרות חנות ([StoreSettingsScreen]) tools: 📦 הזמנות (jump to the store
/// orders section, the SAME pairing the store menu uses) + 💰 כספים
/// ([openFinanceHub]). Keep-floating: a section jump swaps the screen underneath,
/// a sheet pushes over.
List<KbToolNode> kbStoreSettingsNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.receipt_long,
        label: 'הזמנות',
        action: (ref, context) {
          ref.read(mainTabProvider.notifier).state = 3;
          ref.read(storeSectionProvider.notifier).state = StoreSection.orders;
        },
      ),
      KbToolNode.leaf(
        icon: Icons.account_balance_wallet_outlined,
        label: 'כספים',
        action: (ref, context) => openFinanceHub(context),
      ),
    ];

/// 🗄️ ארכיון שיחות ([ChatsArchiveScreen]) tools: ➕ שיחה חדשה (WIRED to
/// [openNewChatSheet]) + 🔍 חיפוש שיחות (RESETS [updatesChatSearchProvider] for a
/// fresh search) — mirroring the chats overflow's items.
List<KbToolNode> kbChatsArchiveNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.add_comment_outlined,
        label: 'שיחה חדשה',
        action: (ref, context) => openNewChatSheet(context),
      ),
      KbToolNode.leaf(
        icon: Icons.search,
        label: 'חיפוש שיחות',
        // Resets the chat filter for a fresh search (live search = typing, routed
        // to [updatesChatSearchProvider] by the floating keyboard).
        action: (ref, context) {
          ref.read(updatesChatSearchProvider.notifier).state = '';
        },
      ),
    ];

/// AiFinderScreen tools: מאתר + עץ חכם (runKeyboardTool seam, like kbAiHubNodes).
List<KbToolNode> kbAiFinderNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.gps_fixed,
        label: 'מאתר',
        action: (ref, context) => runKeyboardTool(ref, context, KbTool.finder),
      ),
      KbToolNode.leaf(
        icon: Icons.account_tree,
        label: 'עץ חכם',
        action: (ref, context) =>
            runKeyboardTool(ref, context, KbTool.smartTree),
      ),
    ];

/// WorkerProfileScreen tools: נוכחות · טפסים · תיק בטיחות · תלושי שכר.
List<KbToolNode> kbWorkerProfileNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.access_time,
        label: 'נוכחות',
        action: (ref, context) =>
            Navigator.of(context).push(WorkerAttendanceScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.description_outlined,
        label: 'טפסים',
        action: (ref, context) =>
            Navigator.of(context).push(WorkerFormsScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.verified_user_outlined,
        label: 'תיק בטיחות',
        action: (ref, context) =>
            Navigator.of(context).push(WorkerSafetyScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.payments_outlined,
        label: 'תלושי שכר',
        action: (ref, context) => showWorkerPayslipsSheet(context),
      ),
    ];

/// ManagerDashboardScreen tools: קו-פיילוט · שיחות · אזור אישי · הגדרות.
List<KbToolNode> kbManagerDashboardNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.smart_toy,
        label: 'קו-פיילוט',
        action: (ref, context) =>
            Navigator.of(context).push(ManagerCopilotScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.chat_bubble_outline,
        label: 'שיחות',
        action: (ref, context) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ChatsScreen(persona: BsRole.manager),
          ),
        ),
      ),
      KbToolNode.leaf(
        icon: Icons.person_outline,
        label: 'אזור אישי',
        action: (ref, context) =>
            Navigator.of(context).push(ManagerProfileScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.settings_outlined,
        label: 'הגדרות',
        action: (ref, context) => Navigator.of(context).push(
          CatalogSettingsScreen.route(showProfileRow: false),
        ),
      ),
    ];

/// WorkerSettingsScreen tools: התראות · תנאי שימוש · מדיניות פרטיות.
List<KbToolNode> kbWorkerSettingsNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.notifications_outlined,
        label: 'התראות',
        action: (ref, context) =>
            Navigator.of(context).push(NotifSettingsScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.description_outlined,
        label: 'תנאי שימוש',
        action: (ref, context) =>
            Navigator.of(context).push(LegalScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.privacy_tip_outlined,
        label: 'מדיניות פרטיות',
        action: (ref, context) => Navigator.of(context)
            .push(LegalScreen.route(initialTab: LegalTab.privacy)),
      ),
    ];

/// ManagerProfileScreen tools: הגדרות · מעבר בין מסכים.
List<KbToolNode> kbManagerProfileNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.settings_outlined,
        label: 'הגדרות',
        action: (ref, context) => Navigator.of(context).push(
          CatalogSettingsScreen.route(showProfileRow: false),
        ),
      ),
      KbToolNode.leaf(
        icon: Icons.desktop_windows_outlined,
        label: 'מעבר בין מסכים',
        action: (ref, context) => showManagerScreensSheet(context),
      ),
    ];

/// CourierDashboardScreen tools: התראות · פרופיל · הגדרות.
List<KbToolNode> kbCourierDashboardNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.notifications_outlined,
        label: 'התראות',
        action: (ref, context) => showCourierNotifsSheet(context),
      ),
      KbToolNode.leaf(
        icon: Icons.person_outline,
        label: 'פרופיל',
        action: (ref, context) =>
            Navigator.of(context).push(CourierProfileScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.settings_outlined,
        label: 'הגדרות',
        action: (ref, context) =>
            Navigator.of(context).push(CourierSettingsScreen.route()),
      ),
    ];

/// CourierProfileScreen tools: נוכחות · טפסים · תעודות נהג · תלושי שכר.
List<KbToolNode> kbCourierProfileNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.access_time,
        label: 'נוכחות',
        action: (ref, context) =>
            Navigator.of(context).push(CourierAttendanceScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.description_outlined,
        label: 'טפסים',
        action: (ref, context) =>
            Navigator.of(context).push(CourierFormsScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.badge_outlined,
        label: 'תעודות נהג',
        action: (ref, context) =>
            Navigator.of(context).push(CourierCertsScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.payments_outlined,
        label: 'תלושי שכר',
        action: (ref, context) => showWorkerPayslipsSheet(context),
      ),
    ];

/// CourierSettingsScreen tools: תנאי שימוש · מדיניות פרטיות.
List<KbToolNode> kbCourierSettingsNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.description_outlined,
        label: 'תנאי שימוש',
        action: (ref, context) =>
            Navigator.of(context).push(LegalScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.privacy_tip_outlined,
        label: 'מדיניות פרטיות',
        action: (ref, context) => Navigator.of(context)
            .push(LegalScreen.route(initialTab: LegalTab.privacy)),
      ),
    ];

/// StoreDashboardScreen tools: אזור אישי · הגדרות.
List<KbToolNode> kbStoreDashboardNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.person_outline,
        label: 'אזור אישי',
        action: (ref, context) =>
            Navigator.of(context).push(StoreProfileScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.settings_outlined,
        label: 'הגדרות',
        action: (ref, context) =>
            Navigator.of(context).push(SupplierSettingsScreen.route()),
      ),
    ];

/// StoreProfileScreen tools: תעודות עסק · מסמכים · הגדרות ספק.
List<KbToolNode> kbStoreProfileNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.badge_outlined,
        label: 'תעודות עסק',
        action: (ref, context) =>
            Navigator.of(context).push(StoreCertsScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.receipt_long_outlined,
        label: 'מסמכים',
        action: (ref, context) => showStoreDocumentsSheet(context),
      ),
      KbToolNode.leaf(
        icon: Icons.settings_outlined,
        label: 'הגדרות ספק',
        action: (ref, context) =>
            Navigator.of(context).push(SupplierSettingsScreen.route()),
      ),
    ];

/// ProjectsScreen tools: תקציב · משימות · פרויקט חכם.
List<KbToolNode> kbProjectsNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.account_balance_wallet_outlined,
        label: 'תקציב',
        action: (ref, context) =>
            Navigator.of(context).push(BudgetScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.assignment_outlined,
        label: 'משימות',
        action: (ref, context) =>
            Navigator.of(context).push(TasksScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.account_tree_outlined,
        label: 'פרויקט חכם',
        action: (ref, context) =>
            Navigator.of(context).push(SmartProjectScreen.route()),
      ),
    ];

/// SuppliersScreen tools: ליפסקי ברקן.
List<KbToolNode> kbSuppliersNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.factory_outlined,
        label: 'ליפסקי ברקן',
        action: (ref, context) =>
            Navigator.of(context).push(LipskeyBrandScreen.route()),
      ),
    ];

/// ProfileScreen tools: מועדון · החלפת תפקיד · בקשת תפקיד.
List<KbToolNode> kbProfileNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.emoji_events_outlined,
        label: 'מועדון',
        action: (ref, context) =>
            Navigator.of(context).push(RewardsHubScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.swap_horiz,
        label: 'החלפת תפקיד',
        action: (ref, context) => showRolePicker(context),
      ),
      KbToolNode.leaf(
        icon: Icons.badge_outlined,
        label: 'בקשת תפקיד',
        action: (ref, context) => showRoleRequestSheet(context),
      ),
    ];

/// WorkerAppScreen tools: לוח משימות · גאנט משימות · ליקויים · הגדרות.
List<KbToolNode> kbWorkerAppNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.dashboard_outlined,
        label: 'לוח משימות',
        action: (ref, context) =>
            Navigator.of(context).push(WorkerTaskBoardScreen.route()),
      ),
      KbToolNode.leaf(
        icon: Icons.timeline,
        label: 'גאנט משימות',
        action: (ref, context) => showTasksGanttSheet(context),
      ),
      KbToolNode.leaf(
        icon: Icons.report_problem_outlined,
        label: 'ליקויים',
        action: (ref, context) => showDefectsSheet(context),
      ),
      KbToolNode.leaf(
        icon: Icons.settings_outlined,
        label: 'הגדרות',
        action: (ref, context) =>
            Navigator.of(context).push(WorkerSettingsScreen.route()),
      ),
    ];
