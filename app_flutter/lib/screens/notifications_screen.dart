import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotifSection { all, shipments, orders, safety, budget, deals }

/// A string-id set persisted to SharedPreferences — used for the read /
/// dismissed notification ids so they (and the unread badge) survive restarts.
class PersistedIdSet extends StateNotifier<Set<String>> {
  PersistedIdSet(this._prefsKey) : super(const {}) {
    _load();
  }
  final String _prefsKey;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKey);
      if (list != null) state = list.toSet();
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, state.toList());
    } catch (_) {}
  }

  void set(Set<String> value) {
    state = value;
    _persist();
  }

  void add(String id) {
    state = {...state, id};
    _persist();
  }

  void remove(String id) {
    state = {...state}..remove(id);
    _persist();
  }
}

final notifSectionProvider =
    StateProvider<NotifSection>((_) => NotifSection.all);
final notifReadIdsProvider =
    StateNotifierProvider<PersistedIdSet, Set<String>>(
  (_) => PersistedIdSet('bs.notif-read.v1'),
);
final notifDismissedIdsProvider =
    StateNotifierProvider<PersistedIdSet, Set<String>>(
  (_) => PersistedIdSet('bs.notif-dismissed.v1'),
);
final notifSearchQueryProvider = StateProvider<String>((_) => '');
final notifExpandedGroupsProvider = StateProvider<Set<String>>((_) => {});

// Derived provider — used by home_shell badge.
final notifUnreadCountProvider = Provider<int>((ref) {
  final readIds = ref.watch(notifReadIdsProvider);
  final dismissedIds = ref.watch(notifDismissedIdsProvider);
  return _kNotifs
      .where(
        (n) =>
            n.badge > 0 &&
            !readIds.contains(n.id) &&
            !dismissedIds.contains(n.id),
      )
      .length;
});

// ─── data types ───────────────────────────────────────────────────────────────

typedef _Notif = ({
  String id,
  String emoji,
  String title,
  String preview,
  String time,
  String dateGroup,
  int badge,
  NotifSection type,
  bool highPriority,
});

class _ShowMore {
  const _ShowMore({required this.groupKey, required this.hiddenCount});
  final String groupKey;
  final int hiddenCount;
}

// ─── static data ─────────────────────────────────────────────────────────────

const List<_Notif> _kNotifs = [
  (
    id: 'n1',
    emoji: '📦',
    title: 'הזמנה #1234',
    preview: 'מוכנה לאיסוף — צור קשר עם הספק',
    time: 'עכשיו',
    dateGroup: 'היום',
    badge: 1,
    type: NotifSection.orders,
    highPriority: false,
  ),
  // Three consecutive shipments in 'היום' → collapse triggers
  (
    id: 'n2',
    emoji: '🚛',
    title: 'משלוח #892',
    preview: 'יגיע עד מחר 14:00',
    time: 'לפני שעה',
    dateGroup: 'היום',
    badge: 0,
    type: NotifSection.shipments,
    highPriority: false,
  ),
  (
    id: 'n9',
    emoji: '🚛',
    title: 'משלוח #893',
    preview: 'חבילה ממתינה לאיסוף בחנות',
    time: 'לפני שעתיים',
    dateGroup: 'היום',
    badge: 1,
    type: NotifSection.shipments,
    highPriority: false,
  ),
  (
    id: 'n10',
    emoji: '🚛',
    title: 'משלוח #894',
    preview: 'מסלול עודכן — עצור בשוק עכו',
    time: 'לפני 3 שעות',
    dateGroup: 'היום',
    badge: 0,
    type: NotifSection.shipments,
    highPriority: false,
  ),
  (
    id: 'n3',
    emoji: '🦺',
    title: 'התראת בטיחות',
    preview: 'דרגת סיכון עודכנה לאדום — קומה 3',
    time: 'לפני 3 שעות',
    dateGroup: 'היום',
    badge: 1,
    type: NotifSection.safety,
    highPriority: true,
  ),
  (
    id: 'n4',
    emoji: '🔔',
    title: 'חריגת תקציב',
    preview: 'פרויקט A חרג ב-12% מהתקציב',
    time: 'אתמול',
    dateGroup: 'אתמול',
    badge: 1,
    type: NotifSection.budget,
    highPriority: true,
  ),
  (
    id: 'n5',
    emoji: '🎁',
    title: 'מבצע שבועי',
    preview: 'ציוד חשמל -15% עד יום ראשון',
    time: 'אתמול',
    dateGroup: 'אתמול',
    badge: 0,
    type: NotifSection.deals,
    highPriority: false,
  ),
  (
    id: 'n6',
    emoji: '📦',
    title: 'הזמנה #1198',
    preview: 'אושרה ונמצאת בהכנה',
    time: '21.5',
    dateGroup: 'מוקדם יותר',
    badge: 0,
    type: NotifSection.orders,
    highPriority: false,
  ),
  (
    id: 'n7',
    emoji: '💱',
    title: 'עדכון מחיר',
    preview: 'ברזל 12mm · ₪4.20 → ₪3.85',
    time: '20.5',
    dateGroup: 'מוקדם יותר',
    badge: 0,
    type: NotifSection.deals,
    highPriority: false,
  ),
  (
    id: 'n8',
    emoji: '🎁',
    title: 'תגמול נצבר',
    preview: '120 נקודות נוספו למועדון',
    time: '20.5',
    dateGroup: 'מוקדם יותר',
    badge: 0,
    type: NotifSection.deals,
    highPriority: false,
  ),
];

/// Marks every notification as read. Called from AppBar 3-dot menu.
void markAllNotifsRead(WidgetRef ref) {
  ref.read(notifReadIdsProvider.notifier).set(
      _kNotifs.map((n) => n.id).toSet());
}

/// Dismisses every notification. Called from AppBar 3-dot menu.
void dismissAllNotifs(WidgetRef ref) {
  ref.read(notifDismissedIdsProvider.notifier).set(
      _kNotifs.map((n) => n.id).toSet());
}

// ─── helpers ─────────────────────────────────────────────────────────────────

/// Notification categories hidden by the user's per-type toggles in settings.
/// (orders/shipments/deals/price-drops → orders/shipments/deals/budget).
Set<NotifSection> notifMutedSections(NotifSettings ns) => <NotifSection>{
      if (!ns.typeOrders) NotifSection.orders,
      if (!ns.typeShipments) NotifSection.shipments,
      if (!ns.typeDeals) NotifSection.deals,
      if (!ns.typePriceDrops) NotifSection.budget,
    };

/// Consecutive same-type runs of this length (or more) collapse behind "הצג עוד".
const int kNotifCollapseRunMin = 3;
bool shouldCollapseNotifRun(int runLength) => runLength >= kNotifCollapseRunMin;

/// Pure row-visibility predicate (regression-tested in test/gaps_test.dart).
bool notifPasses({
  required NotifSection type,
  required String title,
  required String preview,
  required bool dismissed,
  required NotifSection section,
  required String query,
  required Set<NotifSection> muted,
}) {
  if (dismissed) return false;
  if (muted.contains(type)) return false;
  if (section != NotifSection.all && type != section) return false;
  if (query.isNotEmpty) {
    final q = query.toLowerCase();
    if (!title.toLowerCase().contains(q) && !preview.toLowerCase().contains(q)) {
      return false;
    }
  }
  return true;
}

/// Importance filter: "all" keeps everything; otherwise only high-priority rows.
bool passesImportance(NotifImportance filter, bool highPriority) =>
    filter == NotifImportance.all || highPriority;

List<_Notif> _filtered({
  required NotifSection section,
  required Set<String> dismissedIds,
  required String query,
  required Set<NotifSection> mutedTypes,
  required NotifImportance importance,
}) =>
    _kNotifs
        .where((n) =>
            passesImportance(importance, n.highPriority) &&
            notifPasses(
              type: n.type,
              title: n.title,
              preview: n.preview,
              dismissed: dismissedIds.contains(n.id),
              section: section,
              query: query,
              muted: mutedTypes,
            ))
        .toList();

// Inserts date-group headers and collapses consecutive same-type groups of ≥3.
/// A date header is inserted whenever the group changes from the previous row.
bool isNewDateGroup(String? current, String next) => next != current;

List<Object> _withHeadersAndCollapse(
  List<_Notif> notifs,
  Set<String> expandedKeys,
) {
  final result = <Object>[];
  String? currentDateGroup;
  var i = 0;
  while (i < notifs.length) {
    final n = notifs[i];
    if (isNewDateGroup(currentDateGroup, n.dateGroup)) {
      currentDateGroup = n.dateGroup;
      result.add(currentDateGroup);
    }
    final groupKey = '${n.dateGroup}__${n.type.name}';
    var j = i + 1;
    while (j < notifs.length &&
        notifs[j].dateGroup == n.dateGroup &&
        notifs[j].type == n.type) {
      j++;
    }
    final groupCount = j - i;
    if (shouldCollapseNotifRun(groupCount) && !expandedKeys.contains(groupKey)) {
      result
        ..add(notifs[i])
        ..add(_ShowMore(groupKey: groupKey, hiddenCount: groupCount - 1));
    } else {
      for (var k = i; k < j; k++) {
        result.add(notifs[k]);
      }
    }
    i = j;
  }
  return result;
}

String? _actionLabel(NotifSection type) => switch (type) {
      NotifSection.orders => 'אשר איסוף',
      NotifSection.safety => 'טפל כעת',
      NotifSection.budget => 'פרטים',
      NotifSection.shipments => 'עקוב',
      _ => null,
    };

// ─── screen ──────────────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _headerVisible = true;

  void _setHeaderVisible(bool v) {
    if (_headerVisible == v) return;
    setState(() => _headerVisible = v);
    ref.read(tabHeaderHiddenProvider.notifier).state = !v;
  }

  bool _handleScroll(ScrollNotification n) {
    if (n is ScrollUpdateNotification && n.depth == 0) {
      final delta = n.scrollDelta ?? 0;
      final px = n.metrics.pixels;
      if (delta > 6 && _headerVisible && px > 50) {
        _setHeaderVisible(false);
      } else if (delta < -6 && !_headerVisible) {
        _setHeaderVisible(true);
      } else if (px <= 2 && !_headerVisible) {
        _setHeaderVisible(true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(tabHeaderHiddenProvider, (_, hidden) {
      if (!hidden && !_headerVisible) _setHeaderVisible(true);
    });
    return Column(
      children: [
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _headerVisible
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [_Header(), _NotifSearchBar(), _SectionChipsRow()],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: const _NotifList(),
          ),
        ),
      ],
    );
  }
}

// ─── header ──────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readIds = ref.watch(notifReadIdsProvider);
    final dismissedIds = ref.watch(notifDismissedIdsProvider);
    final unread = ref.watch(notifUnreadCountProvider);
    final hasReadNotDismissed = _kNotifs.any(
      (n) => readIds.contains(n.id) && !dismissedIds.contains(n.id),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'התראות',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (unread > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: BsTokens.brand,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unread חדשות',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.done_all,
                color: Color(0xFF888888),
                size: 22,
              ),
              tooltip: 'סמן הכל כנקרא',
              onPressed: () {
                ref.read(notifReadIdsProvider.notifier).set(
                    _kNotifs.map((n) => n.id).toSet());
              },
            ),
          ],
          if (hasReadNotDismissed)
            IconButton(
              icon: const Icon(
                Icons.clear_all,
                color: Color(0xFF888888),
                size: 22,
              ),
              tooltip: 'נקה נקראו',
              onPressed: () {
                ref.read(notifDismissedIdsProvider.notifier).set(
                    Set<String>.from(ref.read(notifDismissedIdsProvider))
                      ..addAll(ref.read(notifReadIdsProvider)));
              },
            ),
        ],
      ),
    );
  }
}

// ─── search bar ──────────────────────────────────────────────────────────────

class _NotifSearchBar extends ConsumerStatefulWidget {
  const _NotifSearchBar();

  @override
  ConsumerState<_NotifSearchBar> createState() => _NotifSearchBarState();
}

class _NotifSearchBarState extends ConsumerState<_NotifSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = ref.watch(notifSearchQueryProvider).isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: TextField(
        controller: _controller,
        textDirection: TextDirection.rtl,
        onChanged: (v) =>
            ref.read(notifSearchQueryProvider.notifier).state = v,
        decoration: InputDecoration(
          hintText: 'חיפוש התראות...',
          hintStyle: const TextStyle(color: Color(0xFF888888)),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF888888),
            size: 20,
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF888888),
                    size: 18,
                  ),
                  onPressed: () {
                    _controller.clear();
                    ref.read(notifSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: BsTokens.brand, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─── section chips ───────────────────────────────────────────────────────────

class _SectionChipsRow extends ConsumerWidget {
  const _SectionChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(notifSectionProvider);

    void select(NotifSection s) =>
        ref.read(notifSectionProvider.notifier).state = s;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Pill(
              label: 'הכל',
              active: section == NotifSection.all,
              onTap: () => select(NotifSection.all),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '📦 משלוחים',
              active: section == NotifSection.shipments,
              onTap: () => select(NotifSection.shipments),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '🛒 הזמנות',
              active: section == NotifSection.orders,
              onTap: () => select(NotifSection.orders),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '🦺 בטיחות',
              active: section == NotifSection.safety,
              onTap: () => select(NotifSection.safety),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '💰 תקציב',
              active: section == NotifSection.budget,
              onTap: () => select(NotifSection.budget),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '🎁 מבצעים',
              active: section == NotifSection.deals,
              onTap: () => select(NotifSection.deals),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? BsTokens.brand : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFFAAAAAA),
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── list ────────────────────────────────────────────────────────────────────

class _NotifList extends ConsumerWidget {
  const _NotifList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(notifSectionProvider);
    final dismissedIds = ref.watch(notifDismissedIdsProvider);
    final query = ref.watch(notifSearchQueryProvider);
    final expandedKeys = ref.watch(notifExpandedGroupsProvider);
    final ns = ref.watch(notifSettingsProvider);
    // Per-type toggles from notification settings hide muted categories.
    final mutedTypes = notifMutedSections(ns);
    final items = _withHeadersAndCollapse(
      _filtered(
        section: section,
        dismissedIds: dismissedIds,
        query: query,
        mutedTypes: mutedTypes,
        importance: ns.importanceFilter,
      ),
      expandedKeys,
    );

    if (items.isEmpty) {
      return RefreshIndicator(
        color: BsTokens.brand,
        backgroundColor: const Color(0xFFFFFFFF),
        onRefresh: () => Future.delayed(const Duration(milliseconds: 800)),
        child: LayoutBuilder(
          builder: (_, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🔔', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text(
                      'אין התראות',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'כשיהיו עדכונים — הם יופיעו כאן',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: BsTokens.brand,
      backgroundColor: const Color(0xFFFFFFFF),
      onRefresh: () => Future.delayed(const Duration(milliseconds: 800)),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, i) {
          final curr = items[i];
          final next = i + 1 < items.length ? items[i + 1] : null;
          if (curr is _Notif && next is _Notif) {
            return const Divider(
              height: 1,
              indent: 76,
              color: Color(0xFFF5F5F5),
            );
          }
          return const SizedBox.shrink();
        },
        itemBuilder: (context, i) {
          final item = items[i];
          if (item is String) {
            return _DateHeader(label: item);
          }
          if (item is _ShowMore) {
            return _ShowMoreRow(showMore: item);
          }
          return _DismissibleRow(notif: item as _Notif);
        },
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ShowMoreRow extends ConsumerWidget {
  const _ShowMoreRow({required this.showMore});

  final _ShowMore showMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(notifExpandedGroupsProvider.notifier).state =
            Set<String>.from(ref.read(notifExpandedGroupsProvider))
              ..add(showMore.groupKey);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(76, 8, 16, 8),
        child: Text(
          'הצג עוד ${showMore.hiddenCount} ↓',
          style: const TextStyle(
            color: BsTokens.brand,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DismissibleRow extends ConsumerWidget {
  const _DismissibleRow({required this.notif});

  final _Notif notif;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(notif.id),
      direction: DismissDirection.endToStart,
      background: const ColoredBox(
        color: Colors.redAccent,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete_outline, color: Colors.white, size: 26),
          ),
        ),
      ),
      onDismissed: (_) {
        final id = notif.id;
        final notifier = ref.read(notifDismissedIdsProvider.notifier);
        notifier.add(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('התראה נמחקה'),
            backgroundColor: const Color(0xFFF5F5F5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'ביטול',
              textColor: BsTokens.brand,
              onPressed: () => notifier.remove(id),
            ),
          ),
        );
      },
      child: _NotifRow(notif: notif),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.search, color: Color(0xFF888888), size: 18),
      ),
    );
  }
}

class _NotifRow extends ConsumerWidget {
  const _NotifRow({required this.notif});

  final _Notif notif;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readIds = ref.watch(notifReadIdsProvider);
    final isRead = readIds.contains(notif.id);
    final isUnread = notif.badge > 0 && !isRead;
    final actionLabel = _actionLabel(notif.type);

    Future<void> showLongPressMenu() async {
      final box = context.findRenderObject()! as RenderBox;
      final offset = box.localToGlobal(Offset.zero);
      final choice = await showMenu<String>(
        context: context,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + box.size.height / 2,
          offset.dx + box.size.width,
          0,
        ),
        items: [
          if (isUnread)
            const PopupMenuItem<String>(
              value: 'read',
              child: Row(
                children: [
                  Icon(Icons.done, color: Colors.black54, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'סמן כנקרא',
                    style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 15),
                  ),
                ],
              ),
            ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                SizedBox(width: 12),
                Text(
                  'מחק',
                  style: TextStyle(color: Colors.redAccent, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      );
      if (!context.mounted) {
        return;
      }
      if (choice == 'read') {
        ref.read(notifReadIdsProvider.notifier).add(notif.id);
      } else if (choice == 'delete') {
        ref.read(notifDismissedIdsProvider.notifier).add(notif.id);
      }
    }

    final avatarBg = notif.highPriority
        ? const Color(0xFF3D1515)
        : isUnread
            ? BsTokens.brand.withValues(alpha: 0.15)
            : const Color(0xFFF5F5F5);

    return InkWell(
      onTap: () {
        if (isUnread) {
          ref.read(notifReadIdsProvider.notifier).add(notif.id);
        }
      },
      onLongPress: showLongPressMenu,
      child: Opacity(
        opacity: isRead ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: avatarBg,
                  shape: BoxShape.circle,
                  border: notif.highPriority
                      ? Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.6),
                          width: 2,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  notif.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              color: notif.highPriority
                                  ? Colors.redAccent
                                  : const Color(0xFF1A1A1A),
                              fontSize: 16,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          notif.time,
                          style: TextStyle(
                            color: isUnread
                                ? BsTokens.brand
                                : const Color(0xFF888888),
                            fontSize: 12,
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.preview,
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (actionLabel != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              if (isUnread) {
                                ref
                                    .read(notifReadIdsProvider.notifier)
                                    .add(notif.id);
                              }
                              showToast(context, '$actionLabel — בבנייה');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: BsTokens.brand.withValues(alpha: 0.7),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                actionLabel,
                                style: const TextStyle(
                                  color: BsTokens.brand,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: BsTokens.brand,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${notif.badge}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
