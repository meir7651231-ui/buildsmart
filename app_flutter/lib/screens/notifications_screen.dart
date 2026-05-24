import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotifSection { all, shipments, orders, safety, budget, deals }

final notifSectionProvider =
    StateProvider<NotifSection>((_) => NotifSection.all);
final notifReadIdsProvider = StateProvider<Set<String>>((_) => {});
final notifDismissedIdsProvider = StateProvider<Set<String>>((_) => {});
final notifSearchQueryProvider = StateProvider<String>((_) => '');

// ─── static data ─────────────────────────────────────────────────────────────

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
  (
    id: 'n2',
    emoji: '🚛',
    title: 'משלוח בדרך',
    preview: 'משלוח #892 יגיע עד מחר 14:00',
    time: 'לפני שעה',
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

List<_Notif> _filtered({
  required NotifSection section,
  required Set<String> dismissedIds,
  required String query,
}) =>
    _kNotifs.where((n) {
      if (dismissedIds.contains(n.id)) return false;
      if (section != NotifSection.all && n.type != section) return false;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!n.title.toLowerCase().contains(q) &&
            !n.preview.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

// Inserts date-group header strings before the first notification of each group.
List<Object> _withHeaders(List<_Notif> notifs) {
  final result = <Object>[];
  String? current;
  for (final n in notifs) {
    if (n.dateGroup != current) {
      current = n.dateGroup;
      result.add(current);
    }
    result.add(n);
  }
  return result;
}

// ─── screen ──────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Header(),
        _NotifSearchBar(),
        _SectionChipsRow(),
        Expanded(child: _NotifList()),
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
    final unread = _kNotifs
        .where(
          (n) =>
              n.badge > 0 &&
              !readIds.contains(n.id) &&
              !dismissedIds.contains(n.id),
        )
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'התראות',
              style: TextStyle(
                color: Colors.white,
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
                ref.read(notifReadIdsProvider.notifier).state =
                    _kNotifs.map((n) => n.id).toSet();
              },
            ),
          ],
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
          fillColor: const Color(0xFF2A2A2A),
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
      color: active ? BsTokens.brand : const Color(0xFF2A2A2A),
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
    final items = _withHeaders(
      _filtered(section: section, dismissedIds: dismissedIds, query: query),
    );

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔔', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'אין התראות',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'כשיהיו עדכונים — הם יופיעו כאן',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, i) {
        final curr = items[i];
        final next = i + 1 < items.length ? items[i + 1] : null;
        if (curr is _Notif && next is _Notif) {
          return const Divider(
            height: 1,
            indent: 76,
            color: Color(0xFF2A2A2A),
          );
        }
        return const SizedBox.shrink();
      },
      itemBuilder: (context, i) {
        final item = items[i];
        if (item is String) return _DateHeader(label: item);
        return _DismissibleRow(notif: item as _Notif);
      },
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
        final ids = Set<String>.from(ref.read(notifDismissedIdsProvider))
          ..add(notif.id);
        ref.read(notifDismissedIdsProvider.notifier).state = ids;
      },
      child: _NotifRow(notif: notif),
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
                  Icon(Icons.done, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'סמן כנקרא',
                    style: TextStyle(color: Colors.white, fontSize: 15),
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
      if (!context.mounted) return;
      if (choice == 'read') {
        final ids = Set<String>.from(ref.read(notifReadIdsProvider))
          ..add(notif.id);
        ref.read(notifReadIdsProvider.notifier).state = ids;
      } else if (choice == 'delete') {
        final ids = Set<String>.from(ref.read(notifDismissedIdsProvider))
          ..add(notif.id);
        ref.read(notifDismissedIdsProvider.notifier).state = ids;
      }
    }

    final avatarBg = notif.highPriority
        ? const Color(0xFF3D1515)
        : isUnread
            ? BsTokens.brand.withValues(alpha: 0.15)
            : const Color(0xFF2A2A2A);

    return InkWell(
      onTap: () {
        if (isUnread) {
          final ids = Set<String>.from(ref.read(notifReadIdsProvider))
            ..add(notif.id);
          ref.read(notifReadIdsProvider.notifier).state = ids;
        }
      },
      onLongPress: showLongPressMenu,
      child: Opacity(
        opacity: isRead ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
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
                  if (isUnread)
                    Positioned(
                      top: -2,
                      left: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: BsTokens.brand,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${notif.badge}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
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
                                  : Colors.white,
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
                    Text(
                      notif.preview,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
