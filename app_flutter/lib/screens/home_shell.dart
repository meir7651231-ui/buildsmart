import 'package:buildsmart/data/repositories/backend.dart'
    show kIntelLive, kUserSystem;
import 'package:buildsmart/features/global_search/global_search.dart'
    show kGlobalSearch;
import 'package:buildsmart/config/app_brand.dart' show AppBrand;
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/ai_hub_screen.dart';
import 'package:buildsmart/screens/camera_sheet.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/consent_modal.dart';
import 'package:buildsmart/screens/departments_screen.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/onboarding_screen.dart';
import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/screens/store_settings_screen.dart';
import 'package:buildsmart/screens/updates_screen.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/help_mode.dart';
import 'package:buildsmart/state/intel/screen_view.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/state/org_gates.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/version.g.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/pending_approval_banner.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart'
    show kKeyboardToolStrip;
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cart line indices whose recent-add chat bubble the user dismissed (via its
/// X). Cleared whenever the cart shrinks so later adds surface fresh bubbles.
final cartBubbleDismissedProvider = StateProvider<Set<int>>((_) => {});

/// #31 — "מצב היכרות" copy for the 4 bottom-nav destinations, in tab order
/// (בית · מחלקות · עדכונים · חנות). The tabs live in the Scaffold's nav bar
/// (outside the freeze overlay), so help mode can't wrap them in a tail-bubble;
/// instead a help-mode tap pops [showHelpInfo] with the matching entry rather
/// than navigating.
const List<(String, String)> _kTabHelp = [
  (
    'בית',
    'מסך הבית החכם — נחיתה עם תוכן מותאם ("תוכן הבית"), ומשם כניסה לקטלוג המלא.',
  ),
  (
    'מחלקות',
    'רשת המחלקות — דפדוף לפי קטגוריות מוצרים (אינסטלציה · גמר · כלים…) לניווט מהיר בקטלוג.',
  ),
  (
    'עדכונים',
    'ההתראות והשיחות במקום אחד — הזמנות, חוסרים והודעות מספקים ומהצוות. התג מציג כמה לא נקראו.',
  ),
  ('חנות', 'החנות — הסל שלך, ההזמנות והמעקב אחריהן. כאן משלימים את הרכישה.'),
];

/// WhatsApp-style shell: AppBar + 4 bottom tabs.
/// Tabs: קטלוג · שיחות · התראות · חנות (RTL order: catalog on right).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(mainTabProvider);
    final helpMode = ref.watch(helpModeProvider);

    // Benzi #4 — one-time "לאן לשלוח" popup on the FIRST product selection
    // (cart 0→1, not on load), never at checkout. Persisted flag stops repeats.
    ref.listen<List<SmartCartLine>>(smartCartProvider, (prev, next) {
      if (prev != null &&
          prev.isEmpty &&
          next.isNotEmpty &&
          !ref.read(shipToPromptedProvider)) {
        ref.read(shipToPromptedProvider.notifier).state = true;
        saveShipToPrompted();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) openShipToSheet(context, ref);
        });
      }
    });

    // Step 92 — automatic `screen_view` on every tab switch. ONE read-only
    // `ref.listen` on `mainTabProvider` (the RECONCILED real tab source, §3):
    // `listen`, never a new `watch`, so this adds ZERO rebuild on top of the tab
    // UI watch above (:69) and the 4 tabs stay byte-identical. The route half
    // (pushed screens) is the app-global `intelRouteObserver` (main.dart).
    listenTabScreenView(ref);

    // Step 86 — one-time, version-gated analytics-consent modal. COMPILE-GATED
    // behind [kIntelLive] (const-false in every normal build) → this branch AND
    // the whole consent_modal surface tree-shake away, so the shipped shell is
    // BYTE-IDENTICAL to today (the step-81 `_StudioHero` hero pattern). When
    // INTEL_LIVE is flipped on it prompts once until the user consents to the
    // current policy version.
    if (kIntelLive) {
      maybeShowConsentModal(context, ref);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const _HomeAppBar(),
      body: Stack(
        children: [
          IndexedStack(
            index: tabIndex,
            children: const [
              CatalogScreen(), // 0 · בית — smart-home landing (#32) + catalog
              DepartmentsScreen(), // 1 · מחלקות
              UpdatesScreen(), // 2 · עדכונים — התראות + שיחות merged
              StoreScreen(), // 3 · חנות
            ],
          ),
          // U1.5.2 — "ממתין לאישור" strip. COMPILE-GATED behind [kUserSystem]
          // (const-false in every normal build) → this branch AND the banner
          // tree-shake away, so the shell is BYTE-IDENTICAL to today (the
          // `if (kIntelLive)` consent pattern). When USER_SYSTEM is on it shows
          // ONLY for a signed-in pending user (else SizedBox.shrink).
          if (kUserSystem)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: PendingApprovalBanner(),
            ),
          // GLOBAL SEARCH (kGlobalSearch, const ⇒ this collection-if folds out when
          // off ⇒ shell byte-identical): option A — typing shows the ONE unified
          // results panel IN PLACE over WHATEVER tab is active (not just the
          // catalog). A Positioned.fill above the IndexedStack but below the help
          // layer + the global keyboard, so results replace the screen content while
          // the floating keyboard keeps working. The child watches the live query
          // and paints the opaque panel only once a query is present.
          // Giant-system V2 — AND'd with the `search` module gate (const FIRST,
          // so kGlobalSearch off still folds the branch out; absent=on ⇒ the
          // all-on default keeps the mount byte-identical).
          if (kGlobalSearch && modOn(ref, 'search'))
            const Positioned.fill(child: _GlobalSearchOverlay()),
          // "מצב היכרות": freezes the content + a banner. Explainable elements
          // (📷 in the app-bar, the cart FAB) sit above this and stay tappable.
          if (helpMode) const Positioned.fill(child: _HelpModeOverlay()),
          // 🃏 The FLOATING card-keyboard (the NAVIGATOR layer). A separate
          // Positioned SIBLING of the IndexedStack — it overlays the BOTTOM like
          // a real keyboard, so the screen underneath stays FULL (the IndexedStack
          // is never wrapped/resized/scaled/dimmed). Gated by kKeyboardToolStrip,
          // so with the flag OFF this collapses away (shell byte-identical).
          // kKbGlobal ON → the keyboard mounts app-globally (main.dart) instead,
          // so HomeShell SKIPS its own mount here (no double); OFF → mounts here.
          if (kKeyboardToolStrip &&
              !kKbGlobal &&
              ref.watch(keyboardOverlayOpenProvider))
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(top: false, child: FloatingCardKeyboard()),
            ),
          // ⌨️ The keyboard FAB — mirrors the cart FAB on the OPPOSITE side. The
          // cart FAB uses floatingActionButtonLocation.endFloat (bottom-end =
          // bottom-LEFT under RTL), so this one sits at the bottom-START
          // (bottom-RIGHT under RTL). Hidden while the overlay is open so it never
          // sits on top of the keyboard. Gated by kKeyboardToolStrip.
          if (kKeyboardToolStrip &&
              !kKbGlobal &&
              !ref.watch(keyboardOverlayOpenProvider))
            PositionedDirectional(
              start: 16,
              bottom: 16,
              child: FloatingActionButton(
                heroTag: 'keyboard-fab',
                onPressed:
                    () =>
                        ref.read(keyboardOverlayOpenProvider.notifier).state =
                            true,
                backgroundColor: BsTokens.brand,
                foregroundColor: Colors.white,
                tooltip: 'מקלדת חכמה',
                child: const Icon(Icons.keyboard),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: tabIndex,
        onTap: (i) {
          resetAllDials(ref);
          if (i == 0) {
            // בית — the smart-home landing, unscoped (clear any department).
            ref.read(homeDepartmentProvider.notifier).state = null;
            ref.read(catalogSystemFilterProvider.notifier).state = null;
            ref.read(catalogTreePathProvider.notifier).state = const [];
            ref.read(catalogSectionProvider.notifier).state = 'בית';
          } else if (i == 1) {
            // מחלקות — back to the departments grid.
            ref.read(homeDepartmentProvider.notifier).state = null;
            ref.read(catalogSystemFilterProvider.notifier).state = null;
            ref.read(catalogTreePathProvider.notifier).state = const [];
          }
          ref.read(mainTabProvider.notifier).state = i;
        },
      ),
      floatingActionButton:
          tabIndex != 3
              ? (helpMode
                  ? const HelpTarget(
                    title: 'סל הקנייה',
                    body:
                        'הסל הצף מציג כמה פריטים נאספו. לחיצה עליו קופצת '
                        'לחנות עם הסל המסונן — משם ממשיכים להזמנה.',
                    child: CartFab(),
                  )
                  : const CartFab())
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// GLOBAL SEARCH ([kGlobalSearch]) — the in-place results overlay (owner: option
/// A). Mounted by [HomeShell] over the active tab; it watches the keyboard's live
/// query and, once it reaches 2 chars, paints the opaque unified panel
/// ([GlobalSearchResultsView]) over the whole body — so the results REPLACE the
/// screen content wherever you are, no "עוד…" and no jump. Below the threshold it
/// is an empty, non-absorbing box, leaving the tab fully interactive. The global
/// floating keyboard (main.dart) sits ABOVE this, so typing keeps working. Only
/// mounted on the flag-gated path, so it tree-shakes with the feature when off.
class _GlobalSearchOverlay extends ConsumerWidget {
  const _GlobalSearchOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(keyboardDiveQueryProvider).trim().length >= 2;
    if (!active) return const SizedBox.shrink();
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const GlobalSearchResultsView(),
    );
  }
}

/// The "מצב היכרות" freeze layer: a top banner + a dim scrim over the frozen
/// content. Explainable elements (the 📷 app-bar icon, the cart FAB) sit above
/// this layer and stay tappable; tapping the dim area nudges the user toward
/// them, and the ✕ (or the 💡 again) exits the mode.
class _HelpModeOverlay extends ConsumerWidget {
  const _HelpModeOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Material(
          color: BsTokens.brand,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space4,
              vertical: BsTokens.space3,
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                const SizedBox(width: BsTokens.space2),
                const Expanded(
                  child: CfgText(
                    'home.helpmode.banner',
                    'מצב היכרות — לחצו על אלמנט מודגש כדי ללמוד מה הוא עושה',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'צא ממצב היכרות',
                  child: Tooltip(
                    message: 'צא ממצב היכרות',
                    child: InkWell(
                      onTap:
                          () =>
                              ref.read(helpModeProvider.notifier).state = false,
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      // ≥48dp tap target around the small ✕ (a11y), without
                      // enlarging the visible glyph.
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text(
                      'במצב היכרות — לחצו על כפתור מודגש (📷 או הסל). '
                      '✕ או 💡 ליציאה.',
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                );
            },
            child: const ColoredBox(color: Color(0x14000000)),
          ),
        ),
      ],
    );
  }
}

/// Floating cart button — visible whenever the cart has items (and we're not
/// already on the store tab). Tapping jumps to the store.
///
/// Public so PUSHED routes (e.g. the AI hub) can reuse the exact look/animation/
/// count logic. Such a route must pop itself BEFORE landing on the cart tab, so
/// it passes [popFirst] = true — the home use site keeps the default (no pop,
/// because home is itself a tab).
class CartFab extends ConsumerWidget {
  const CartFab({super.key, this.popFirst = false});

  /// When true (PUSHED-route hosts like the AI hub), tapping first pops the
  /// current route (`Navigator.maybePop`) and then lands on the cart tab.
  final bool popFirst;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(smartCartProvider);
    final count = lines.fold<int>(0, (sum, l) => sum + l.productQty);
    final dismissed = ref.watch(cartBubbleDismissedProvider);

    // Clear dismissals when the cart shrinks (indices would otherwise drift),
    // so a later add surfaces fresh bubbles. Side-effect via listen.
    ref.listen<List<SmartCartLine>>(smartCartProvider, (prev, next) {
      if (prev != null && next.length < prev.length) {
        ref.read(cartBubbleDismissedProvider.notifier).state = {};
      }
    });

    // Last two added (chronological: older on top, newest nearest the FAB),
    // minus any the user closed.
    final n = lines.length;
    final recentIdx = [
      for (var i = n - 2 < 0 ? 0 : n - 2; i < n; i++)
        if (!dismissed.contains(i)) i,
    ];

    void openCart() {
      resetAllDials(ref);
      // From a PUSHED-route host (AI hub) pop back to the home shell first, so
      // landing on the cart tab is actually visible underneath.
      if (popFirst) Navigator.of(context).maybePop();
      // Land on the store's "הסל" filter so only cart items show.
      ref.read(storeSectionProvider.notifier).state = StoreSection.cart;
      ref.read(mainTabProvider.notifier).state = 3;
    }

    // White cart on the orange FAB + a count badge. (Removed the decorative
    // "+", which read as "add to cart" rather than "open cart".)
    final fab = FloatingActionButton(
      heroTag: 'cart-fab',
      onPressed: openCart,
      backgroundColor: BsTokens.brand,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white, width: 2),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(Icons.shopping_cart, color: bsOnAccent(context), size: 26),
          if (count > 0)
            Positioned(
              top: -10,
              right: -12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BsTokens.brand, width: 1.5),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BsTokens.brand,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final i in recentIdx) ...[
          _CartChatBubble(
            line: lines[i],
            onTap: () => openCartLineProductSheet(context, lines[i]),
            onClose:
                () =>
                    ref.read(cartBubbleDismissedProvider.notifier).state = {
                      ...dismissed,
                      i,
                    },
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 2),
        fab,
      ],
    );
  }
}

/// A single recent-add product styled as a chat bubble above the cart FAB.
/// Tapping the bubble re-opens that product's detail sheet for editing
/// (everything but the name); the small circular X dismisses just this bubble.
/// Inline floating message — no full window/modal (R2).
class _CartChatBubble extends StatelessWidget {
  const _CartChatBubble({
    required this.line,
    required this.onTap,
    required this.onClose,
  });

  final SmartCartLine line;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final d = cartLineDisplay(line);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              // Chat-bubble shape: tail-corner (bottom-left, toward the FAB)
              // squared off, the rest rounded.
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: BsTokens.brand.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(line.productEmoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 7),
                // Main name + product-type description (two compact lines).
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      if (d.attrs.isNotEmpty)
                        Text(
                          d.attrs,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 10.5,
                            height: 1.2,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Price + quantity.
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₪${line.total}',
                      style: const TextStyle(
                        color: BsTokens.brand,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '×${line.productQty}',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 10.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.edit_outlined,
                  size: 13,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
        // Close X — small circle floating at the top-start corner. The visible
        // circle stays 20dp; a transparent 48dp tap target is centred on it for
        // a11y (≥48dp) without enlarging the glyph.
        PositionedDirectional(
          top: -21,
          start: -21,
          child: Semantics(
            button: true,
            label: 'הסר התראה זו',
            child: Tooltip(
              message: 'הסר',
              child: SizedBox(
                width: 48,
                height: 48,
                child: InkWell(
                  onTap: onClose,
                  customBorder: const CircleBorder(),
                  child: Center(
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(
                        side: BorderSide(color: Color(0x22000000)),
                      ),
                      elevation: 2,
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: Icon(
                          Icons.close,
                          size: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// AppBar — mirrors WhatsApp Business layout in RTL.
/// Title "BuildSmart" (right in RTL) — tap to open BS/profile dial.
/// Actions (left in RTL): camera (opens barcode) · more-vert (menu).
class _HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(mainTabProvider);
    // Giant-system V2 — the `chat` module gate, watched ONCE here in build();
    // the updates-tab ⋮ ternary below uses the captured boolean (absent=on ⇒
    // the all-on default keeps the bar byte-identical).
    final chatOn = modOn(ref, 'chat');
    // Registered user's first name → chip beside the logo (guest/demo → none).
    final profile = ref.watch(userProfileProvider);
    final firstName =
        profile.registered && profile.name.trim().isNotEmpty
            ? profile.name.trim().split(RegExp(r'\s+')).first
            : '';
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 4,
      title: Tooltip(
        message: 'BS',
        child: InkWell(
          onTap: () => showRolePicker(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // #31 — explains the logo's real job: it opens the role
                    // picker. (Help mode intercepts the tap; the ancestor
                    // InkWell still runs showRolePicker outside help mode.)
                    const HelpTarget(
                      title: 'החלפת לוח / זהות',
                      body:
                          'לחיצה על הלוגו פותחת את בורר התפקידים — מעבר בין '
                          'לוח קבלן · מנהל · חנות · שליח · עובד. כך עוברים בין '
                          'סוגי המשתמשים באפליקציה.',
                      child: CfgText(
                        'home.topbar.brand',
                        // stage-5: profile-aware wordmark (default byte-identical
                        // 'BuildSmart'; Studio overrides still win at runtime).
                        AppBrand.name,
                        style: TextStyle(
                          color: BsTokens.brand,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    if (firstName.isNotEmpty) ...[
                      const SizedBox(width: BsTokens.space2),
                      // The name chip is its OWN tap target → opens a read-only
                      // profile CARD (the editor is one tap further, behind
                      // 'ערוך פרופיל'). This inner GestureDetector wins taps on
                      // the chip; the outer InkWell still handles the logo/version
                      // (showRolePicker). HitTestBehavior.opaque so the whole chip
                      // area (incl. padding) is hot.
                      Semantics(
                        button: true,
                        label: 'הפרופיל שלי',
                        child: Tooltip(
                          message: 'הפרופיל שלי',
                          // #31 — the chip explains itself in help mode (opens
                          // the read-only profile card); the GestureDetector's
                          // real onTap still fires outside help mode.
                          child: HelpTarget(
                            title: 'הפרופיל שלי',
                            body:
                                'פותח כרטיס פרופיל לקריאה — שם · מקצוע · '
                                'כתובת · ח.פ. · איש קשר; ומשם "ערוך פרופיל" '
                                'לעריכה מלאה.',
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => showProfileCard(context),
                              // ≥48dp tap target around the small pill (a11y),
                              // without enlarging the visible chip.
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 48,
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0E3),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      firstName,
                                      style: const TextStyle(
                                        color: BsTokens.brandDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (tabIndex == 0 &&
                    ref.watch(catalogSectionProvider) == 'עץ חכם')
                  const _PulsingStatus(text: 'עץ חכם הופעל')
                else
                  // תווית-גרסה: kVersionLabel + kBuild (ה-sha) — secondary/אפור, לא
                  // ירוק (ליטוש). ה-sha משתנה בכל פריסה, כך שאפשר לוודא "אני על החדש"
                  // (לא cache ישן). ירוק שמור ל-_PulsingStatus החי.
                  // הגרסה נגזרת מ-version.g.dart (gitignored, אוטומטי — לקח #72).
                  const Row(
                    key: Key('version_chrome'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '$kVersionLabel · $kBuild',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Search icon — appears when the active tab's header is scrolled away.
        // Giant-system V2 — AND'd with the `search` module gate (absent=on ⇒
        // the all-on default keeps the bar byte-identical).
        if (ref.watch(tabHeaderHiddenProvider) && modOn(ref, 'search'))
          HelpTarget(
            title: 'חיפוש',
            body:
                'מחזיר את שורת החיפוש של הטאב הפעיל (שנעלמה בגלילה) '
                'כדי לחפש מוצר או פריט במהירות.',
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.black54),
              tooltip: 'חיפוש',
              onPressed: () {
                ref.read(tabHeaderHiddenProvider.notifier).state = false;
              },
            ),
          ),
        HelpTarget(
          title: 'מצלמה / סורק',
          body:
              'פותח את הסורק: צילום ברקוד או מק"ט לזיהוי מוצר, '
              'או סריקת תוכנית כדי להפיק ממנה רשימת מוצרים — בלי להקליד ידנית.',
          child: IconButton(
            icon: const Icon(
              Icons.photo_camera_outlined,
              color: Colors.black54,
            ),
            tooltip: 'מצלמה',
            onPressed: () => openCameraSheet(context),
          ),
        ),
        // #31 — the ⋮ menu explains itself in help mode (copy tailored to the
        // active tab); outside help mode it opens the real popup as before.
        if (tabIndex == 0 || tabIndex == 1)
          const HelpTarget(
            title: 'תפריט הקטלוג',
            body:
                'כלים נוספים של הקטלוג — בינה מלאכותית ואוטומציה, '
                'והגדרות האפליקציה.',
            child: _CatalogMenuButton(), // בית + מחלקות drill into the catalog
          )
        else if (tabIndex == 2)
          // עדכונים — menu follows the active sub-toggle (התראות / שיחות).
          // `chat` module off ⇒ the whole chats branch is dark and the
          // notifications menu stands for the tab (org_gates, absent=on).
          (chatOn && ref.watch(updatesSubTabProvider) == 1
              ? const HelpTarget(
                title: 'תפריט השיחות',
                body:
                    'כלים לשיחות — פתיחת שיחה חדשה, ארכיון, '
                    'והשתקת כל השיחות.',
                child: _ChatsMenuButton(),
              )
              : const HelpTarget(
                title: 'תפריט ההתראות',
                body:
                    'כלים להתראות — סימון הכל כנקרא, ניקוי הכל, '
                    'והגדרות התראות.',
                child: _NotificationsMenuButton(),
              ))
        else
          const HelpTarget(
            title: 'תפריט החנות',
            body: 'כלים לחנות — הסל שלי, ההזמנות, שירותים, והגדרות החנות.',
            child: _StoreMenuButton(),
          ),
        // 💡 — tap toggles "מצב היכרות" (interactive help mode); long-press
        // still replays the first-run intro slides.
        Builder(
          builder: (context) {
            final helpOn = ref.watch(helpModeProvider);
            return GestureDetector(
              onLongPress: () => showIntroTour(context),
              child: IconButton(
                icon: Icon(
                  helpOn ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: helpOn ? BsTokens.brandDark : BsTokens.brand,
                ),
                tooltip: 'מצב היכרות (לחיצה ארוכה: סיור)',
                onPressed:
                    () =>
                        ref.read(helpModeProvider.notifier).update((on) => !on),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notifUnreadCountProvider);
    // #31 — each tab is wrapped in HelpTarget so help mode highlights it (orange
    // ring) AND pops a bubble out of the tab itself, consistent with the app-bar
    // icons (the old BottomNavigationBar couldn't carry per-item HelpTargets).
    // Outside help mode the InkWell navigates exactly as before.
    // giant-v3 — nav.* terms swap the DISPLAYED label only; _kTabHelp stays
    // INDEX-keyed with the default vocabulary (help copy speaks the app's
    // canonical names in wave-1 — a declared, documented seam).
    Widget tab(int i, Widget icon, String label) => Expanded(
      child: HelpTarget(
        title: _kTabHelp[i].$1,
        body: _kTabHelp[i].$2,
        child: BottomNavCell(
          icon: icon,
          label: label,
          selected: currentIndex == i,
          onTap: () => onTap(i),
        ),
      ),
    );
    return Material(
      color: const Color(0xFFFFFFFF),
      elevation: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              tab(
                0,
                Icon(currentIndex == 0 ? Icons.home : Icons.home_outlined),
                orgTerm(ref, 'nav.home', 'בית'),
              ),
              tab(1, const Icon(Icons.apps), orgTerm(ref, 'nav.catalog', 'מחלקות')),
              tab(
                2,
                _BadgedIcon(
                  icon:
                      currentIndex == 2
                          ? Icons.notifications
                          : Icons.notifications_outlined,
                  count: unreadCount,
                ),
                orgTerm(ref, 'nav.updates', 'עדכונים'),
              ),
              tab(3, const Icon(Icons.shopping_cart_outlined), orgTerm(ref, 'nav.store', 'חנות')),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return Icon(icon);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          top: -5,
          right: -6,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: BsTokens.brand,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
            child: Text(
              count > 9 ? '9+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── catalog 3-dot menu ────────────────────────────────────────────────────────

class _CatalogMenuButton extends ConsumerWidget {
  const _CatalogMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Giant-system V2 — the `ai` module gate, watched ONCE here in build();
    // the itemBuilder/onSelected closures below use the CAPTURED boolean
    // (absent=on ⇒ the all-on default keeps the menu byte-identical — the
    // list merely drops its const, a behavioral no-op; entries stay const).
    final aiOn = modOn(ref, 'ai');
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      tooltip: 'תפריט',
      color: const Color(0xFFFFFFFF),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) => _onSelected(context, ref, value, aiOn: aiOn),
      itemBuilder:
          (_) => [
            // 🏠 home-tab tools, surfaced natively (mirror the menu-dial 🏠 branch).
            // `ai` module off ⇒ the AI row goes dark (its divider with it —
            // no orphan rule above 'הגדרות').
            if (aiOn) ...const [
              PopupMenuItem<String>(
                value: 'ai_hub',
                child: _MenuRow(
                  emoji: '🤖',
                  label: 'בינה מלאכותית ואוטומציה',
                  cfgId: 'home.catalogmenu.aihub',
                ),
              ),
              PopupMenuDivider(),
            ],
            const PopupMenuItem<String>(
              value: 'settings',
              child: _MenuRow(emoji: '⚙️', label: 'הגדרות'),
            ),
          ],
    );
  }

  void _onSelected(
    BuildContext context,
    WidgetRef ref,
    String value, {
    required bool aiOn,
  }) {
    switch (value) {
      case 'ai_hub':
        // `ai` module off ⇒ the dispatch is dark too (belt over the hidden
        // row — a stale open menu can't push the hub).
        if (aiOn) Navigator.of(context).push(AIHubScreen.route());
      case 'settings':
        Navigator.of(context).push(CatalogSettingsScreen.route());
    }
  }
}

// ─── chats 3-dot menu ───────────────────────────────────────────────────────────

class _ChatsMenuButton extends ConsumerWidget {
  const _ChatsMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Giant-system V2 — the `chat` module gate, watched ONCE here in build();
    // the itemBuilder/onSelected closures below use the CAPTURED boolean
    // (absent=on ⇒ the all-on default keeps the menu byte-identical).
    final chatOn = modOn(ref, 'chat');
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      tooltip: 'תפריט',
      color: const Color(0xFFFFFFFF),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) => _onSelected(context, ref, value, chatOn: chatOn),
      itemBuilder: (_) {
        final allMuted = allChatsMuted(ref);
        return [
          // `chat` module off ⇒ every row here is dark (the list goes empty
          // and the popup simply doesn't open) — the CAPTURED chatOn decides,
          // never a watch inside the closure; allMuted stays the read-at-open
          // precedent.
          if (chatOn) ...[
            const PopupMenuItem<String>(
              value: 'new_chat',
              child: _MenuRow(emoji: '✏️', label: 'שיחה חדשה'),
            ),
            const PopupMenuItem<String>(
              value: 'archive',
              child: _MenuRow(
                emoji: '🗂️',
                label: 'ארכיון שיחות',
                cfgId: 'home.chatsmenu.archive',
              ),
            ),
            PopupMenuItem<String>(
              value: 'mute_all',
              child: _MenuRow(
                emoji: allMuted ? '🔔' : '🔇',
                label: allMuted ? 'בטל השתקת הכל' : 'השתק הכל',
              ),
            ),
          ],
          // 'הגדרות' (→ ChatSettingsScreen) REMOVED: that screen was the dead
          // call-settings tree (read receipts / typing / video compression /
          // call ringtone / cloud backup — none real). The screen file is kept
          // but is no longer reachable from any menu or search entry.
        ];
      },
    );
  }

  Future<void> _onSelected(
    BuildContext context,
    WidgetRef ref,
    String value, {
    required bool chatOn,
  }) async {
    // `chat` module off ⇒ every action here is dark — belt over the hidden
    // entry point + the empty item list (a stale open menu can't dispatch).
    if (!chatOn) return;
    switch (value) {
      case 'new_chat':
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: const Color(0xFFFFFFFF),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const _NewChatSheet(),
        );
      case 'archive':
        Navigator.of(context).push(ChatsArchiveScreen.route());
      case 'mute_all':
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
  }
}

/// Public opener for the "שיחה חדשה" contact-picker sheet ([_NewChatSheet]) — the
/// SAME sheet the chats ⋮ menu ('new_chat') shows. Exposed so the floating
/// keyboard's ⚙ menu (`kbScreenMenuNodes`, behind KB_BUTTONS_V2) opens the real
/// picker instead of a "בקרוב" placeholder. Referenced only from that flag-gated
/// path (`kKbButtonsV2 ? … : kbKbdNodes()` const-folds away when off), so it
/// tree-shakes out on a normal build — byte-identical.
void openNewChatSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  backgroundColor: const Color(0xFFFFFFFF),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (_) => const _NewChatSheet(),
);

// ─── notifications 3-dot menu ──────────────────────────────────────────────────────

class _NotificationsMenuButton extends ConsumerWidget {
  const _NotificationsMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      tooltip: 'תפריט',
      color: const Color(0xFFFFFFFF),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) => _onSelected(context, ref, value),
      itemBuilder:
          (_) => const [
            PopupMenuItem<String>(
              value: 'mark_all_read',
              child: _MenuRow(
                emoji: '✅',
                label: 'סמן הכל כנקרא',
                cfgId: 'home.notifmenu.readall',
              ),
            ),
            PopupMenuItem<String>(
              value: 'clear_all',
              child: _MenuRow(
                emoji: '🗑️',
                label: 'נקה הכל',
                cfgId: 'home.notifmenu.clearall',
              ),
            ),
            PopupMenuItem<String>(
              value: 'notif_settings',
              child: _MenuRow(
                emoji: '🔔',
                label: 'הגדרות התראות',
                cfgId: 'home.notifmenu.settings',
              ),
            ),
          ],
    );
  }

  Future<void> _onSelected(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    switch (value) {
      case 'mark_all_read':
        markAllNotifsRead(ref);
        showToast(context, 'כל ההתראות סומנו כנקרא');
      case 'clear_all':
        final ok = await confirmDestructive(
          context,
          title: 'ניקוי כל ההתראות?',
          message: 'כל ההתראות יימחקו לצמיתות.',
          confirmLabel: 'נקה הכל',
        );
        if (!ok || !context.mounted) return;
        dismissAllNotifs(ref);
        showToast(context, 'כל ההתראות נמחקו');
      case 'notif_settings':
        Navigator.of(context).push(NotifSettingsScreen.route());
    }
  }
}

// ─── store 3-dot menu ───────────────────────────────────────────────────────────────

class _StoreMenuButton extends ConsumerWidget {
  const _StoreMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      tooltip: 'תפריט',
      color: const Color(0xFFFFFFFF),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) => _onSelected(context, ref, value),
      itemBuilder:
          (_) => [
            const PopupMenuItem<String>(
              value: 'cart',
              child: _MenuRow(
                emoji: '🛒',
                label: 'הסל שלי',
                cfgId: 'home.storemenu.cart',
              ),
            ),
            const PopupMenuItem<String>(
              value: 'orders',
              child: _MenuRow(
                emoji: '📦',
                label: 'הזמנות',
                cfgId: 'home.storemenu.orders',
              ),
            ),
            // 🔧 שירותים opens the all-"בבנייה" services section — hidden for Apple
            // review (kHideUnderConstruction); the route + section stay (reversible).
            if (!kHideUnderConstruction)
              const PopupMenuItem<String>(
                value: 'services',
                child: _MenuRow(emoji: '🔧', label: 'שירותים'),
              ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'settings',
              child: _MenuRow(emoji: '⚙️', label: 'הגדרות'),
            ),
          ],
    );
  }

  void _onSelected(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'cart':
        ref.read(storeSectionProvider.notifier).state = StoreSection.cart;
      case 'orders':
        ref.read(storeSectionProvider.notifier).state = StoreSection.orders;
      case 'services':
        ref.read(storeSectionProvider.notifier).state = StoreSection.services;
      case 'settings':
        Navigator.of(context).push(StoreSettingsScreen.route());
    }
  }
}

// ─── shared menu row ──────────────────────────────────────────────────────────────────

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.emoji, required this.label, this.cfgId});
  final String emoji;
  final String label;

  /// Optional BuildSmart-Studio element id. When set, the label routes through
  /// [CfgText] (owner-editable; identical style/params, byte-identical fallback);
  /// null ⇒ a plain [Text], exactly as before.
  final String? cfgId;

  @override
  Widget build(BuildContext context) {
    final id = cfgId;
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Flexible(
          child:
              id == null
                  ? Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 15,
                    ),
                  )
                  : CfgText(
                    id,
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 15,
                    ),
                  ),
        ),
      ],
    );
  }
}

// ─── new chat sheet ──────────────────────────────────────────────────────────────────────

class _NewChatSheet extends StatelessWidget {
  const _NewChatSheet();

  static const _contacts = [
    (emoji: '👷', label: 'קבלן'),
    (emoji: '🏪', label: 'ספק'),
    (emoji: '🛵', label: 'שליח'),
    (emoji: '🦺', label: 'עובד'),
    (emoji: '💬', label: 'תמיכה'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerRight,
            child: CfgText(
              'home.newchat.title',
              '✏️ שיחה חדשה',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerRight,
            child: CfgText(
              'home.newchat.subtitle',
              'בחר סוג איש קשר',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF5F5F5), height: 1),
          ..._contacts.map(
            (c) => ListTile(
              leading: Text(c.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(
                c.label,
                style: const TextStyle(color: BsTokens.inkLight, fontSize: 15),
              ),
              trailing: const Icon(
                Icons.chevron_left,
                color: Color(0xFF888888),
              ),
              onTap: () {
                Navigator.pop(context);
                openNewChatWith(context, emoji: c.emoji, name: c.label);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── profile card (name-chip → read-only profile) ──────────────────────────

/// Opens a read-only profile CARD as a modal bottom sheet (RTL, BsTokens).
///
/// Reached only via the app-bar name chip. Surfaces the filled details
/// (name · profession · address · businessId · contact — empties omitted) and
/// a primary 'ערוך פרופיל' that pushes the existing editor. The editor is one
/// tap further, so the chip no longer drops straight into a form.
void showProfileCard(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _ProfileCard(),
  );
}

/// The read-only profile card body (mirrors the _ProfileScreen _HeaderCard
/// idiom + the _NewChatSheet sheet chrome). Detail rows whose value is empty
/// are omitted — no blank lines.
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(userProfileProvider);
    final hasName = p.name.trim().isNotEmpty;
    final name = hasName ? p.name.trim() : 'אורח';
    final rows = <(IconData, String)>[
      if (p.profession.trim().isNotEmpty)
        (Icons.work_outline, p.profession.trim()),
      if (p.address.trim().isNotEmpty) (Icons.place_outlined, p.address.trim()),
      if (p.businessId.trim().isNotEmpty)
        (Icons.badge_outlined, p.businessId.trim()),
      if (p.contact.trim().isNotEmpty)
        (Icons.alternate_email, p.contact.trim()),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header: avatar circle + big name (mirrors profile_screen
            // _HeaderCard), with a close affordance on the leading edge.
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0E3),
                    shape: BoxShape.circle,
                  ),
                  child: ExcludeSemantics(
                    child:
                        hasName
                            ? Text(
                              name.characters.first,
                              style: const TextStyle(
                                color: BsTokens.brandDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            )
                            : const Icon(
                              Icons.person,
                              color: BsTokens.brandDark,
                              size: 28,
                            ),
                  ),
                ),
                const SizedBox(width: BsTokens.space3),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF888888)),
                  tooltip: 'סגור',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (rows.isNotEmpty) ...[
              const SizedBox(height: BsTokens.space3),
              const Divider(color: Color(0xFFF5F5F5), height: 1),
              const SizedBox(height: BsTokens.space2),
              for (final (icon, value) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: BsTokens.space2,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: BsTokens.mutedLight),
                      const SizedBox(width: BsTokens.space3),
                      Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: BsTokens.space4),
            SizedBox(
              width: double.infinity,
              // composite-hide: hiding this element drops the whole button.
              child: CfgVisible(
                'home.profilecard.editCta',
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(ProfileScreen.route());
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: BsTokens.brand,
                    padding: const EdgeInsets.symmetric(
                      vertical: BsTokens.space3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                    ),
                  ),
                  child: CfgText(
                    'home.profilecard.editCta',
                    'ערוך פרופיל',
                    style: TextStyle(
                      color: bsOnAccent(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pulsing green status shown in the app-bar logo area (e.g. when the
/// "עץ חכם" section is active).
class _PulsingStatus extends ConsumerStatefulWidget {
  const _PulsingStatus({required this.text});
  final String text;

  @override
  ConsumerState<_PulsingStatus> createState() => _PulsingStatusState();
}

class _PulsingStatusState extends ConsumerState<_PulsingStatus>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  @override
  void initState() {
    super.initState();
    if (ref.read(catalogSettingsProvider).reducedMotion) {
      _ctrl.value = 1;
    } else {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.35,
        end: 1,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: bsSuccess(context), size: 7),
          const SizedBox(width: 4),
          CfgText(
            'home.status.smarttree',
            widget.text,
            style: TextStyle(
              color: bsSuccess(context),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
