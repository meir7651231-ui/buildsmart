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

/// The signature header block: deep petrol, one big rounded corner and soft
/// decorative circles — the shape language of the client's own site.
class MxHero extends StatelessWidget {
  const MxHero({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.eyebrow = '',
    super.key,
  });
  final String title;
  final String subtitle;
  final String eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(14, 14, 14, 10),
    decoration: const BoxDecoration(
      color: kMxPrimary,
      borderRadius: BorderRadiusDirectional.only(
        topStart: Radius.circular(24),
        topEnd: Radius.circular(24),
        bottomStart: Radius.circular(24),
        bottomEnd: Radius.circular(56),
      ),
      boxShadow: kMxShadow,
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: [
        // One solid gold circle — the brand accent, nothing translucent.
        const PositionedDirectional(
          end: -28,
          bottom: -28,
          child: SizedBox(
            width: 88,
            height: 88,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: kMxAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          eyebrow,
                          style: const TextStyle(
                            color: kMxAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
        ),
      ],
    ),
  );
}

/// A pastel KPI card (after the site's pink stat card): big number, label,
/// icon in the corner. The whole card is the tap target.
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
  Widget build(BuildContext context) {
    final calm = value == 0;
    final c = calm ? kMxOk : color;
    return Semantics(
      button: true,
      label: '$value $label',
      excludeSemantics: true,
      onTap: onTap,
      child: _Pressable(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: mxTintOf(c),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Stack(
            children: [
              PositionedDirectional(
                end: 0,
                top: 0,
                child: Icon(icon, color: c.withValues(alpha: 0.75), size: 26),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: c,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kMxInk,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gentle press feedback (scale 0.97) for custom tappable surfaces.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;
  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTapDown: (_) => setState(() => _down = true),
    onTapCancel: () => setState(() => _down = false),
    onTapUp: (_) => setState(() => _down = false),
    onTap: widget.onTap,
    child: AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: const Duration(milliseconds: 110),
      child: widget.child,
    ),
  );
}

/// A big pick-tile (room / point): white, soft shadow, icon in a pastel
/// circle, press feedback. [alert] = red ring + pink circle.
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
    final tone = alert ? kMxBad : kMxPrimary;
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
      child: _Pressable(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: kMxShadow,
            border:
                alert || selected
                    ? Border.all(color: selected ? kMxCta : kMxBad, width: 2)
                    : null,
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: alert ? kMxPink : kMxTealTint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 30, color: tone),
                  ),
                  if (alert)
                    PositionedDirectional(
                      end: -2,
                      top: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: kMxBad,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              if (caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: alert ? kMxBad : Colors.black54,
                      fontWeight: alert ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
            ],
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
        childAspectRatio: 0.95,
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
  bool urgent = false,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  backgroundColor: Colors.white,
  builder:
      (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.4, end: 1),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.elasticOut,
                  builder:
                      (_, v, child) => Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: urgent ? kMxPink : kMxTealTint,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: urgent ? kMxBad : kMxOk,
                      child: Icon(
                        urgent
                            ? Icons.warning_amber_rounded
                            : Icons.check_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
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
                                  backgroundColor: urgent ? kMxBad : kMxPrimary,
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
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

/// Friendly empty state: layered circles, a calm title, one line of help.
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
    padding: const EdgeInsets.fromLTRB(28, 44, 28, 28),
    child: Column(
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: const BoxDecoration(
            color: kMxTealTint,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: kMxShadow,
            ),
            child: Icon(icon, size: 40, color: kMxPrimary),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ],
    ),
  );
}

/// A white card whose status shows as a tinted border (no edge stripes).
class MxEdgeCard extends StatelessWidget {
  const MxEdgeCard({required this.color, required this.child, super.key});
  final Color color;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      boxShadow: kMxShadow,
    ),
    child: child,
  );
}

/// Small status chip ("ממתין לאישור").
class MxTag extends StatelessWidget {
  const MxTag(this.text, this.color, {super.key});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: color == Colors.white ? Colors.white24 : mxTintOf(color),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
    ),
  );
}

/// The role switch: a custom stadium pill, one radio-like segment per role.
class MxRolePill<T> extends StatelessWidget {
  const MxRolePill({
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
    super.key,
  });
  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            child: Semantics(
              inMutuallyExclusiveGroup: true,
              checked: values[i] == selected,
              button: true,
              label: labels[i],
              excludeSemantics: true,
              onTap: () => onChanged(values[i]),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(values[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        values[i] == selected
                            ? Colors.white
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        labels[i],
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              values[i] == selected ? kMxPrimary : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Sticky action area at the bottom of a page — the main button is always
/// visible, never hidden under the navigation bar or the keyboard.
class MxBottomBar extends StatelessWidget {
  const MxBottomBar({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: kMxLine)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    ),
  );
}

/// − n + stepper with 48 dp targets.
class MxStepper extends StatelessWidget {
  const MxStepper({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.keyPrefix = 'step',
    super.key,
  });
  final int value;
  final int min;
  final int max;
  final String keyPrefix;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton.outlined(
        key: Key('$keyPrefix-minus'),
        tooltip: 'פחות',
        onPressed: value > min ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove),
      ),
      SizedBox(
        width: 44,
        child: Text(
          '$value',
          key: Key('$keyPrefix-value'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      IconButton.outlined(
        key: Key('$keyPrefix-plus'),
        tooltip: 'יותר',
        onPressed: value < max ? () => onChanged(value + 1) : null,
        icon: const Icon(Icons.add),
      ),
    ],
  );
}

/// Red safety banner for urgent faults: what to do now + a call button.
class MxUrgentBanner extends StatelessWidget {
  const MxUrgentBanner({
    required this.title,
    required this.body,
    this.onCall,
    super.key,
  });
  final String title;
  final String body;
  final VoidCallback? onCall;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    decoration: BoxDecoration(
      color: kMxPink,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kMxBad, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: kMxBad),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: kMxBad,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(body, style: const TextStyle(fontSize: 16, height: 1.4)),
        if (onCall != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('urgent-call'),
              onPressed: onCall,
              icon: const Icon(Icons.call),
              label: const Text('התקשרו למנהל האחזקה'),
            ),
          ),
        ],
      ],
    ),
  );
}

/// "יום ראשון · 8 בנובמבר".
String mxDateLabel(DateTime d) {
  const days = ['שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת', 'ראשון'];
  const months = [
    'בינואר',
    'בפברואר',
    'במרץ',
    'באפריל',
    'במאי',
    'ביוני',
    'ביולי',
    'באוגוסט',
    'בספטמבר',
    'באוקטובר',
    'בנובמבר',
    'בדצמבר',
  ];
  return 'יום ${days[d.weekday - 1]} · ${d.day} ${months[d.month - 1]}';
}
