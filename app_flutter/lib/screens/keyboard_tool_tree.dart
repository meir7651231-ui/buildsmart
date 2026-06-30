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

import 'package:buildsmart/screens/ai_hub_screen.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart' show ChatsArchiveScreen;
import 'package:buildsmart/screens/contractor_tools_sheets.dart'
    show openCheaperAlternativesSheet, openPriceCompareSheet, openScanPlanSheet;
import 'package:buildsmart/screens/finance_hub_sheets.dart' show openFinanceHub;
import 'package:buildsmart/screens/keyboard_tool_actions.dart'
    show runKeyboardTool;
import 'package:buildsmart/screens/notif_settings_screen.dart'
    show NotifSettingsScreen;
import 'package:buildsmart/screens/notifications_screen.dart'
    show markAllNotifsRead;
import 'package:buildsmart/screens/order_notif_sheet.dart'
    show showOrderNotifSheet;
import 'package:buildsmart/screens/site_hub_screen.dart' show openSiteHub;
import 'package:buildsmart/screens/stock_screen.dart' show StockScreen;
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
import 'package:buildsmart/screens/store_settings_screen.dart'
    show StoreSettingsScreen;
import 'package:buildsmart/screens/updates_screen.dart'
    show updatesSubTabProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show KbTile, KbTool;
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
/// 🎤 קולי. Per plan Q2 the first three ship as HONEST "בקרוב" deferred leaves
/// now — the real openers (openNewChatWith / a search-focus seam / a compose
/// attach) are exposed and wired in plan phase 6; the conversation PREDICTIONS
/// (the headline real-data surface) are fully wired in the deriver meanwhile.
/// 🎤 קולי REUSES the existing voice leaf verbatim ([KbToolNode.leaf] with
/// `isVoiceInput: true`): the FLOATING keyboard already intercepts a voice-marked
/// node in `_onTile` and runs mic→`insertAtCaret` itself, so the same leaf works
/// here with no new plumbing (its non-morph `action` is the legacy "בקרוב"
/// fallback only, exactly as in [kbKbdNodes]).
List<KbToolNode> kbUpdatesChatsNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.add_comment_outlined,
        label: 'שיחה חדשה',
        action: (ref, context) => _toolSoon(context, 'שיחה חדשה'),
      ),
      KbToolNode.leaf(
        icon: Icons.search,
        label: 'חיפוש שיחות',
        action: (ref, context) => _toolSoon(context, 'חיפוש שיחות'),
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

/// Owner button-spec v2 (#2): the CURRENT tab's tool node-list — what the floating
/// ▦ (and the #6 buttons-mode) opens. tab 0 (בית) keeps the home tools
/// (byte-identical to the legacy ▦); tab 1 (מחלקות) → [kbDeptNodes]; tab 2
/// (עדכונים) → [kbUpdatesNotifNodes]; tab 3 (חנות) → [kbStoreNodes] for the live
/// [storeSectionProvider]. Centralised HERE (the per-tab node-lists + the
/// store-section provider are already imported) so the floating mount calls ONE
/// function and needs no extra imports. Reads the store section via [ref].
List<KbToolNode> kbTabToolNodes(int tab, WidgetRef ref) => switch (tab) {
      1 => kbDeptNodes(),
      2 => kbUpdatesNotifNodes(),
      3 => kbStoreNodes(ref.read(storeSectionProvider)),
      _ => kbHomeNodes(),
    };

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
            action: (ref, context) => _toolSoon(context, 'שיחה חדשה'),
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
            action: (ref, context) => _toolSoon(context, 'השתק הכל'),
          ),
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
          action: (ref, context) => _toolSoon(context, 'נקה הכל'),
        ),
        KbToolNode.leaf(
          icon: Icons.settings,
          label: 'הגדרות התראות',
          action: (ref, context) =>
              Navigator.of(context).push(NotifSettingsScreen.route()),
        ),
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
      ];
  }
}
