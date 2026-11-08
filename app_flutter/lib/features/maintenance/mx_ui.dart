/// Maintenance module — the small design system the screens are built from.
///
/// Principles (users are house staff, technicians and a store owner — not
/// "computer people"):
///   • pick, don't type: big icon tiles instead of drop-downs and keyboards;
///   • one obvious next step per screen (a single full-width primary button);
///   • every action ends in a clear confirmation (success sheet / toast);
///   • ≥ 56 dp touch targets, large type, AA contrast, screen-reader labels.
library;

import 'package:buildsmart/features/maintenance/mx_brand.dart';
import 'package:flutter/material.dart';

// ── icons ────────────────────────────────────────────────────────────────────

IconData mxRoomIcon(String room) {
  if (room.contains('מטבח')) return Icons.kitchen_outlined;
  if (room.contains('רחצה')) return Icons.shower_outlined;
  if (room.contains('שינה')) return Icons.bed_outlined;
  if (room.contains('כביסה')) return Icons.local_laundry_service_outlined;
  if (room.contains('לוח חשמל') || room.contains('כניסה')) {
    return Icons.door_front_door_outlined;
  }
  if (room.contains('סלון')) return Icons.weekend_outlined;
  if (room.contains('ממ"ד') || room.contains('מקלט')) {
    return Icons.shield_outlined;
  }
  return Icons.meeting_room_outlined;
}

IconData mxPointIcon(String type) => switch (type) {
  'שקע' => Icons.power_outlined,
  'מתג' => Icons.toggle_on_outlined,
  'גוף תאורה' || 'תאורת חירום' => Icons.lightbulb_outline,
  'ברז' || 'ברז ניל' => Icons.water_drop_outlined,
  'סיפון' || 'מחסום רצפה' => Icons.water_outlined,
  'אסלה' => Icons.wc_outlined,
  'סוללת מקלחת' => Icons.shower_outlined,
  'מגביל טמפרטורה' => Icons.thermostat_outlined,
  'מאחז יד' => Icons.accessible_outlined,
  'מאוורר' => Icons.mode_fan_off_outlined,
  'מזגן' => Icons.ac_unit_outlined,
  'מעצור חלון' => Icons.window_outlined,
  'תריס' => Icons.blinds_outlined,
  'מזוזה' => Icons.menu_book_outlined,
  'דוד שמש' => Icons.solar_power_outlined,
  'שעון שבת' => Icons.schedule_outlined,
  'ממסר פחת' || 'מאמ"ת' => Icons.electrical_services_outlined,
  'חיישן יציאה' => Icons.sensor_door_outlined,
  'גלאי עשן' => Icons.smoke_free_outlined,
  'מטף' => Icons.fire_extinguisher_outlined,
  'מנעול' => Icons.lock_outline,
  _ => Icons.build_outlined,
};

/// Quick fault reasons per point type — tap instead of typing.
List<String> mxQuickReasons(String type) => switch (type) {
  'שקע' || 'מתג' => const ['לא עובד', 'ניצוצות / ריח שרוף', 'שבור / רופף'],
  'גוף תאורה' || 'תאורת חירום' => const ['לא נדלק', 'מהבהב', 'שבור'],
  'ברז' ||
  'ברז ניל' ||
  'סוללת מקלחת' => const ['מטפטף', 'לא יוצאים מים', 'מים חמים מדי / קרים'],
  'סיפון' || 'מחסום רצפה' => const ['סתום', 'דולף', 'ריח רע'],
  'אסלה' => const ['לא מפסיק למלא', 'סתומה', 'דולפת'],
  'מזגן' => const ['לא מקרר / מחמם', 'מטפטף מים', 'רעש חזק'],
  'מעצור חלון' || 'תריס' => const ['שבור', 'החלון נפתח יותר מדי', 'תקוע'],
  'גלאי עשן' => const ['מצפצף', 'נפל / חסר'],
  _ => const ['לא עובד', 'שבור', 'אחר'],
};

// ── building blocks ──────────────────────────────────────────────────────────

class MxHero extends StatelessWidget {
  const MxHero({
    required this.title,
    required this.subtitle,
    this.trailing,
    super.key,
  });
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
    decoration: const BoxDecoration(
      color: kMxPrimary,
      borderRadius: BorderRadiusDirectional.only(
        topStart: Radius.circular(18),
        topEnd: Radius.circular(18),
        bottomStart: Radius.circular(18),
        bottomEnd: Radius.circular(44),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

/// A KPI card: icon chip, big number, label. Whole card is the tap target.
class MxStatCard extends StatelessWidget {
  const MxStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });
  final int value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$value $label',
    excludeSemantics: true,
    onTap: onTap,
    child: Material(
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: kMxLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: value == 0 ? kMxOk : color,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 14, height: 1.2),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// A big square pick-tile (room / point). [alert] paints a red ring + dot.
class MxTile extends StatelessWidget {
  const MxTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.caption = '',
    this.alert = false,
    this.selected = false,
    super.key,
  });
  final IconData icon;
  final String label;
  final String caption;
  final bool alert;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ring = selected ? kMxCta : (alert ? kMxBad : kMxLine);
    return Semantics(
      button: true,
      selected: selected,
      label: [
        label,
        if (caption.isNotEmpty) caption,
        if (alert) 'יש תקלה',
      ].join(', '),
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? kMxCta.withValues(alpha: 0.06) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: ring, width: selected || alert ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 34, color: alert ? kMxBad : kMxPrimary),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                if (caption.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      caption,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive grid of [MxTile]s (2 columns on phones, more on wide screens).
class MxTileGrid extends StatelessWidget {
  const MxTileGrid({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cols = (c.maxWidth / 170).floor().clamp(2, 5);
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.15,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: children,
      );
    },
  );
}

/// Full-width primary button (56 dp).
class MxPrimaryButton extends StatelessWidget {
  const MxPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = kMxCta,
    super.key,
  });
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
    child: SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          textStyle: const TextStyle(
            fontFamily: 'Heebo',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.check, size: 22),
        label: Text(label),
      ),
    ),
  );
}

/// A step of a progress timeline.
typedef MxStep = (String label, bool done, bool current);

/// Horizontal progress timeline ("נפתחה → אצל טכנאי → טופלה"). Every step
/// takes an equal share of the width, so it never overflows on a narrow phone.
class MxTimeline extends StatelessWidget {
  const MxTimeline(this.steps, {super.key});
  final List<MxStep> steps;
  @override
  Widget build(BuildContext context) {
    final reached = steps.lastIndexWhere((s) => s.$2 || s.$3);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          // The rail runs between the first and last dot centers.
          Positioned.fill(
            top: 13,
            bottom: null,
            child: LayoutBuilder(
              builder: (context, c) {
                final step = c.maxWidth / steps.length;
                final done = reached <= 0 ? 0.0 : step * reached;
                return SizedBox(
                  height: 3,
                  child: Stack(
                    children: [
                      PositionedDirectional(
                        start: step / 2,
                        end: step / 2,
                        top: 0,
                        height: 3,
                        child: const ColoredBox(color: kMxLine),
                      ),
                      PositionedDirectional(
                        start: step / 2,
                        width: done,
                        top: 0,
                        height: 3,
                        child: const ColoredBox(color: kMxPrimary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, done, current) in steps)
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            done ? kMxPrimary : (current ? kMxCta : kMxLine),
                        child: Icon(
                          done ? Icons.check : Icons.circle,
                          size: done ? 16 : 8,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.1,
                          fontWeight:
                              current ? FontWeight.w800 : FontWeight.w500,
                          color: current ? kMxCta : kMxInk,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Big, calm confirmation after an important action.
Future<void> mxShowSuccess(
  BuildContext context, {
  required String title,
  required String body,
  required List<(String label, Key key, VoidCallback onTap)> actions,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  backgroundColor: Colors.white,
  builder:
      (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: kMxOk,
                child: Icon(Icons.check_rounded, color: Colors.white, size: 46),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              for (final (i, (label, key, onTap)) in actions.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child:
                        i == 0
                            ? FilledButton(
                              key: key,
                              style: FilledButton.styleFrom(
                                backgroundColor: kMxPrimary,
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                onTap();
                              },
                              child: Text(label),
                            )
                            : OutlinedButton(
                              key: key,
                              onPressed: () {
                                Navigator.pop(ctx);
                                onTap();
                              },
                              child: Text(label),
                            ),
                  ),
                ),
            ],
          ),
        ),
      ),
);

/// "בוקר טוב" / "צהריים טובים" / "ערב טוב" / "לילה טוב".
String mxGreeting(DateTime now) {
  final h = now.hour;
  if (h >= 5 && h < 12) return 'בוקר טוב';
  if (h >= 12 && h < 17) return 'צהריים טובים';
  if (h >= 17 && h < 22) return 'ערב טוב';
  return 'לילה טוב';
}

// ── round 2 components ───────────────────────────────────────────────────────

/// "היום" / "מחר" / "עוד 5 ימים" / "באיחור יום אחד" / "באיחור 3 ימים".
String mxDaysLabel(DateTime due, DateTime now) {
  final d =
      DateTime(
        due.year,
        due.month,
        due.day,
      ).difference(DateTime(now.year, now.month, now.day)).inDays;
  if (d == 0) return 'היום';
  if (d == 1) return 'מחר';
  if (d == -1) return 'באיחור יום אחד';
  if (d < 0) return 'באיחור ${-d} ימים';
  if (d < 31) return 'עוד $d ימים';
  final m = (d / 30).round();
  return m == 1 ? 'עוד כחודש' : 'עוד כ-$m חודשים';
}

/// Section title with an optional count bubble.
class MxSectionTitle extends StatelessWidget {
  const MxSectionTitle(
    this.title, {
    this.count,
    this.color = kMxPrimary,
    super.key,
  });
  final String title;
  final int? count;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// Icon + label + value row used on detail cards.
class MxInfoRow extends StatelessWidget {
  const MxInfoRow(this.icon, this.label, this.value, {super.key});
  final IconData icon;
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kMxPrimary),
        const SizedBox(width: 10),
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
        Expanded(
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            child: value,
          ),
        ),
      ],
    ),
  );
}

/// Stock level bar: filled share of 2×min, red under min, green above.
class MxStockBar extends StatelessWidget {
  const MxStockBar({required this.qty, required this.min, super.key});
  final int qty;
  final int min;
  @override
  Widget build(BuildContext context) {
    final target = (min * 2).clamp(1, 1 << 30);
    final v = (qty / target).clamp(0.0, 1.0);
    final c = qty < min ? kMxBad : kMxOk;
    return Semantics(
      label: 'במלאי $qty, מינימום $min',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: v,
          minHeight: 6,
          color: c,
          backgroundColor: kMxLine,
        ),
      ),
    );
  }
}

/// Friendly empty state.
class MxEmpty extends StatelessWidget {
  const MxEmpty({
    required this.icon,
    required this.title,
    this.body = '',
    super.key,
  });
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
    child: Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: kMxPrimary.withValues(alpha: 0.08),
          child: Icon(icon, size: 40, color: kMxPrimary),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ],
      ],
    ),
  );
}

/// A white rounded card with a colored start edge (status at a glance).
class MxEdgeCard extends StatelessWidget {
  const MxEdgeCard({required this.color, required this.child, super.key});
  final Color color;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kMxLine),
    ),
    clipBehavior: Clip.antiAlias,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 6, color: color),
          Expanded(
            child: Padding(padding: const EdgeInsets.all(14), child: child),
          ),
        ],
      ),
    ),
  );
}
