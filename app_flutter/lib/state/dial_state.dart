import 'package:buildsmart/state/menu_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which FAB dial is currently open. Only ONE dial is open at a time
/// (R1 — 5 FABs, never two trays at once). Null = nothing open.
enum OpenDial { none, bs, search, bsMode, menu }

final openDialProvider = StateProvider<OpenDial>((_) => OpenDial.none);

/// Active persona within the BS dial (null = root, showing 5 tiles).
final activePersonaProvider = StateProvider<String?>((_) => null);

/// Drill path within the active persona's tree (by section title).
/// Empty = at the persona's L2 view. Each entry = one anchor deeper.
final bsDrillPathProvider = StateProvider<List<String>>((_) => const []);

/// Section id of the manager dashboard leaf whose inline metric panel is open
/// (one of the `md-*` ids), or null when no metric panel is showing. Tapping a
/// `md-*` leaf opens its panel INLINE in the dial (R2 — no new screen); tapping
/// again (or any other dial action) closes it.
final bsMetricLeafProvider = StateProvider<String?>((_) => null);

/// Section id of the manager 📦 הזמנות leaf whose inline order-list panel is
/// open (one of the `mo-*` ids), or null when none is showing. Each `mo-*`
/// leaf maps to ONE order-flow stage; tapping it opens that stage's REAL orders
/// INLINE in the dial (R2 — no new screen); tapping again (or any other dial
/// action) closes it. Mirrors [bsMetricLeafProvider] for the M2 order leaves.
final bsOrderLeafProvider = StateProvider<String?>((_) => null);

/// Section id of the manager 👥 לקוחות leaf whose inline customer-list panel is
/// open (one of the `mc-*` ids), or null when none is showing. Each `mc-*` leaf
/// maps to ONE customer status filter (פעיל · אשראי גבוה); tapping it opens the
/// REAL customers in that status from `mgrCustomerList` INLINE in the dial
/// (R2 — no new screen); tapping again (or any other dial action) closes it.
/// Mirrors [bsMetricLeafProvider]/[bsOrderLeafProvider] for the M3 customer
/// leaves. The metric / order / customer panels are MUTUALLY EXCLUSIVE.
final bsCustomerLeafProvider = StateProvider<String?>((_) => null);

/// Section id of the manager 🛠️ ניהול leaf whose inline DATA panel is open
/// (one of the data-view `mm-*` ids — `mm-cats` · `mm-settings`), or null when
/// none is showing. Tapping such a leaf opens its REAL data INLINE in the dial
/// (R2 — no new screen): `mm-cats` lists the catalog categories + their product
/// counts, `mm-settings` lists the contractor-app config rows — each verbatim
/// from the legacy `renderMgrManage` (@index.html:16645-16743). Tapping again
/// (or any other dial action) closes it. The two action-only `mm-*` leaves
/// (`mm-trees` · `mm-brands`, whose legacy body is a `prompt()`-driven server
/// edit) do NOT open a panel — they fire a labelled toast. Mirrors the M1/M2/M3
/// leaf providers; the metric / order / customer / manage panels are MUTUALLY
/// EXCLUSIVE.
final bsManageLeafProvider = StateProvider<String?>((_) => null);

/// Section id of the 🏪 חנות ספק (store) leaf whose inline order-list panel is
/// open (one of the `so-*` ids — `so-new` · `so-prep` · `so-ready`), or null
/// when none is showing. Each leaf maps to ONE order-flow stage the STORE owns
/// (new · preparing · ready); tapping it opens that stage's REAL orders off the
/// SHARED `ordersEngineProvider` INLINE in the dial (R2 — no new screen), each
/// row carrying an advance button that calls `.advance(id)` on the SAME engine
/// the manager reads. Tapping again (or any other dial action) closes it.
/// Mirrors the manager [bsOrderLeafProvider]; store / courier panels are kept on
/// their OWN providers so the manager's static-seed panel is untouched.
final bsStoreLeafProvider = StateProvider<String?>((_) => null);

/// Section id of the 🛵 שליח (courier) leaf whose inline order-list panel is
/// open (`pickup` · `ca-pickup` · `ca-transit` · `ca-delivered`), or null when
/// none is showing. Each leaf maps to ONE order-flow stage the COURIER owns
/// (ready→pickup→transit→delivered); tapping it opens that stage's REAL orders
/// off the SHARED `ordersEngineProvider` INLINE in the dial (R2), each open row
/// carrying an advance button that calls `.advance(id)` on the SAME engine — so
/// a courier pickup/transit/deliver reflows the manager's live counts. Tapping
/// again (or any other dial action) closes it.
final bsCourierLeafProvider = StateProvider<String?>((_) => null);

/// Section id of the 🦺 עובד (worker) leaf whose inline task-list panel is open
/// (one of the `st-*` ids), or null when none is showing. Each `st-*` leaf maps
/// to ONE task status bucket; tapping it opens the LIVE worker tasks in that
/// status INLINE in the dial (R2). Mutually exclusive with the M1–M4 manager
/// panels and the W2 store/courier panels.
final bsWorkerLeafProvider = StateProvider<String?>((_) => null);

/// Which menu tab is currently drilled into (null = 3-tab root).
enum MenuTab { home, projects, settings }

final menuTabProvider = StateProvider<MenuTab?>((_) => null);

/// Active tool within the Search FAB (null = 4-tool root).
/// catalog is now a main bottom-nav tab, not a search tool.
enum SearchTool { voice, barcode, filters, sort }

final searchToolProvider = StateProvider<SearchTool?>((_) => null);

/// Which main bottom-nav tab is active.
/// 0 = קטלוג · 1 = שיחות · 2 = התראות · 3 = חנות
final mainTabProvider = StateProvider<int>((_) => 0);

/// True when the active tab's header is scrolled out of view.
/// Each screen sets this; the AppBar reads it to show/hide the search icon.
final tabHeaderHiddenProvider = StateProvider<bool>((_) => false);

void resetAllDials(WidgetRef ref) {
  ref.read(openDialProvider.notifier).state = OpenDial.none;
  ref.read(activePersonaProvider.notifier).state = null;
  ref.read(bsDrillPathProvider.notifier).state = const [];
  ref.read(bsMetricLeafProvider.notifier).state = null;
  ref.read(bsOrderLeafProvider.notifier).state = null;
  ref.read(bsCustomerLeafProvider.notifier).state = null;
  ref.read(bsManageLeafProvider.notifier).state = null;
  ref.read(bsStoreLeafProvider.notifier).state = null;
  ref.read(bsCourierLeafProvider.notifier).state = null;
  ref.read(bsWorkerLeafProvider.notifier).state = null;
  ref.read(menuTabProvider.notifier).state = null;
  ref.read(searchToolProvider.notifier).state = null;
  // Menu tab drill paths (menu_state.dart — already imported).
  ref.read(homeDrillProvider.notifier).state = const [];
  ref.read(projectsDrillProvider.notifier).state = const [];
  // Settings sub-state.
  ref.read(settingsGroupProvider.notifier).state = null;
  ref.read(settingsDrillProvider.notifier).state = const [];
}
