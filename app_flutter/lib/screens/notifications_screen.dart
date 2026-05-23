import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotifSection { all, shipments, orders, budget, deals }

final notifSectionProvider =
    StateProvider<NotifSection>((_) => NotifSection.all);

// ─── static data ─────────────────────────────────────────────────────────────

typedef _Notif = ({
  String emoji,
  String title,
  String preview,
  String time,
  int badge,
  NotifSection type,
});

const List<_Notif> _kNotifs = [
  (
    emoji: '📦',
    title: 'הזמנה #1234',
    preview: 'מוכנה לאיסוף — צור קשר עם הספק',
    time: 'עכשיו',
    badge: 1,
    type: NotifSection.orders,
  ),
  (
    emoji: '🚛',
    title: 'משלוח בדרך',
    preview: 'משלוח #892 יגיע עד מחר 14:00',
    time: 'לפני שעה',
    badge: 0,
    type: NotifSection.shipments,
  ),
  (
    emoji: '🔔',
    title: 'חריגת תקציב',
    preview: 'פרויקט A חרג ב-12% מהתקציב',
    time: 'אתמול',
    badge: 1,
    type: NotifSection.budget,
  ),
  (
    emoji: '🎁',
    title: 'מבצע שבועי',
    preview: 'ציוד חשמל -15% עד יום ראשון',
    time: 'אתמול',
    badge: 0,
    type: NotifSection.deals,
  ),
  (
    emoji: '📦',
    title: 'הזמנה #1198',
    preview: 'אושרה ונמצאת בהכנה',
    time: '21.5',
    badge: 0,
    type: NotifSection.orders,
  ),
  (
    emoji: '🦺',
    title: 'התראת בטיחות',
    preview: 'דרגת סיכון עודכנה לאדום — קומה 3',
    time: '21.5',
    badge: 1,
    type: NotifSection.orders,
  ),
  (
    emoji: '💱',
    title: 'עדכון מחיר',
    preview: 'ברזל 12mm · ₪4.20 → ₪3.85',
    time: '20.5',
    badge: 0,
    type: NotifSection.deals,
  ),
  (
    emoji: '🎁',
    title: 'תגמול נצבר',
    preview: '120 נקודות נוספו למועדון',
    time: '20.5',
    badge: 0,
    type: NotifSection.deals,
  ),
];

List<_Notif> _filtered(NotifSection s) => s == NotifSection.all
    ? _kNotifs
    : _kNotifs.where((n) => n.type == s).toList();

int get _totalBadge =>
    _kNotifs.fold(0, (sum, n) => sum + n.badge);

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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'התראות',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_totalBadge > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: BsTokens.brand,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_totalBadge חדשות',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── search bar ──────────────────────────────────────────────────────────────

class _NotifSearchBar extends StatelessWidget {
  const _NotifSearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: TextField(
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'חיפוש התראות...',
          hintStyle: const TextStyle(color: Color(0xFF888888)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF888888), size: 20),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            _Pill(label: 'הכל',          active: section == NotifSection.all,       onTap: () => select(NotifSection.all)),
            const SizedBox(width: 8),
            _Pill(label: '📦 משלוחים',   active: section == NotifSection.shipments, onTap: () => select(NotifSection.shipments)),
            const SizedBox(width: 8),
            _Pill(label: '🛒 הזמנות',    active: section == NotifSection.orders,    onTap: () => select(NotifSection.orders)),
            const SizedBox(width: 8),
            _Pill(label: '💰 תקציב',     active: section == NotifSection.budget,    onTap: () => select(NotifSection.budget)),
            const SizedBox(width: 8),
            _Pill(label: '🎁 מבצעים',    active: section == NotifSection.deals,     onTap: () => select(NotifSection.deals)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});

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

// ─── list ─────────────────────────────────────────────────────────────────────

class _NotifList extends ConsumerWidget {
  const _NotifList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(notifSectionProvider);
    final items = _filtered(section);

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔔', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'אין התראות',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
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
      key: ValueKey(section),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 76,
        color: Color(0xFF2A2A2A),
      ),
      itemBuilder: (context, i) => _NotifRow(notif: items[i]),
    );
  }
}

class _NotifRow extends StatelessWidget {
  const _NotifRow({required this.notif});

  final _Notif notif;

  @override
  Widget build(BuildContext context) {
    final hasBadge = notif.badge > 0;
    return InkWell(
      onTap: () => showToast(context, '${notif.title} — בבנייה'),
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
                    color: hasBadge
                        ? BsTokens.brand.withValues(alpha: 0.15)
                        : const Color(0xFF2A2A2A),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(notif.emoji, style: const TextStyle(fontSize: 24)),
                ),
                if (hasBadge)
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
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: hasBadge ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        notif.time,
                        style: TextStyle(
                          color: hasBadge ? BsTokens.brand : const Color(0xFF888888),
                          fontSize: 12,
                          fontWeight: hasBadge ? FontWeight.w600 : FontWeight.w400,
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
    );
  }
}
