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
import 'package:buildsmart/screens/contractor_tools_sheets.dart'
    show openScanPlanSheet;
import 'package:buildsmart/screens/keyboard_tool_actions.dart'
    show runKeyboardTool;
import 'package:buildsmart/screens/site_hub_screen.dart' show openSiteHub;
import 'package:buildsmart/screens/stock_screen.dart' show StockScreen;
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
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
