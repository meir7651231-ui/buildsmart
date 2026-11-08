/// Maintenance module — the small design system the screens are built from.
///
/// Design round 2 (after the 3-designer critique):
///   • one semantic color rule — red ONLY for safety / overdue / destructive,
///     petrol for every primary action, gold for "waiting";
///   • one card (white, radius 16, elevation 1, no border), status in badges;
///   • type 32/24/20/16/14/12, weights 400/600/700, tabular figures;
///   • the signature "קשת הבית" (home arch) in thin gold instead of blobs;
///   • motion tokens: enter 240 ms easeOutCubic, exit 180 ms, press 0.97,
///     all motion off under the system's reduce-motion setting.
library;

import 'package:buildsmart/features/maintenance/mx_brand.dart';
import 'package:buildsmart/features/maintenance/mx_home.dart';
import 'package:buildsmart/features/maintenance/mx_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:buildsmart/features/maintenance/mx_home.dart';
export 'package:buildsmart/features/maintenance/mx_icons.dart';

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

// ── motion ───────────────────────────────────────────────────────────────────

/// Motion tokens: enter 240 ms easeOutCubic, exit 180 ms easeInCubic.
const Duration kMxEnter = Duration(milliseconds: 240);
const Duration kMxExit = Duration(milliseconds: 180);

bool _still(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Fade + 8 px rise on first build; [index] staggers lists by 30 ms.
class MxAppear extends StatelessWidget {
  const MxAppear({required this.child, this.index = 0, super.key});
  final Widget child;
  final int index;
  @override
  Widget build(BuildContext context) {
    if (_still(context)) return child;
    final total = kMxEnter + Duration(milliseconds: 30 * index.clamp(0, 10));
    final start = 1 - kMxEnter.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder:
          (_, v, c) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 8 * (1 - v)),
              child: c,
            ),
          ),
      child: child,
    );
  }
}

// ── signature: the home arch ─────────────────────────────────────────────────

/// "קשת הבית" — a doorway outline in a thin gold line: home, dignity, care.
/// Replaces decorative blobs everywhere (hero, empty states, success, QR).
class MxArchPainter extends CustomPainter {
  const MxArchPainter({
    this.color = kMxAccent,
    this.stroke = 1.5,
    this.progress = 1,
  });
  final Color color;
  final double stroke;
  final double progress;

  static Path arch(Size s, double inset) {
    final w = s.width - inset * 2;
    final r = w / 2;
    return Path()
      ..moveTo(inset, s.height - inset)
      ..lineTo(inset, inset + r)
      ..arcToPoint(
        Offset(s.width - inset, inset + r),
        radius: Radius.circular(r),
      )
      ..lineTo(s.width - inset, s.height - inset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;
    final p = arch(size, stroke);
    if (progress >= 1) {
      canvas.drawPath(p, paint);
      return;
    }
    for (final m in p.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(MxArchPainter old) =>
      old.progress != progress || old.color != color || old.stroke != stroke;
}

class MxArch extends StatelessWidget {
  const MxArch({
    this.width = 72,
    this.height = 96,
    this.color = kMxAccent,
    this.stroke = 1.5,
    this.draw = false,
    this.child,
    super.key,
  });
  final double width;
  final double height;
  final Color color;
  final double stroke;

  /// Draw the line in (600 ms) on first build.
  final bool draw;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    Widget paint(double v) => CustomPaint(
      size: Size(width, height),
      painter: MxArchPainter(color: color, stroke: stroke, progress: v),
      child: SizedBox(
        width: width,
        height: height,
        child:
            child == null
                ? null
                : Padding(
                  padding: EdgeInsets.only(top: width * 0.28),
                  child: Center(child: child),
                ),
      ),
    );
    if (!draw || _still(context)) return paint(1);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => paint(v),
    );
  }
}

// ── building blocks ──────────────────────────────────────────────────────────

/// Petrol greeting card (board only): Hebrew date in gold, one status
/// sentence, and the home arch standing on the card's floor — a doorway
/// framing the number that matters today. [alert] turns the arch crimson.
class MxHero extends StatelessWidget {
  const MxHero({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.eyebrow = '',
    this.eyebrow2 = '',
    this.count,
    this.countLabel = '',
    this.alert = false,
    super.key,
  });
  final String title;
  final String subtitle;
  final String eyebrow;
  final String eyebrow2;
  final Widget? trailing;
  final int? count;
  final String countLabel;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final tone = alert ? const Color(0xFFFF8A9B) : kMxAccent;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: kMxPrimary,
        borderRadius: kMxCardRadius,
        boxShadow: kMxShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow.isNotEmpty)
                      Text(
                        eyebrow,
                        style: const TextStyle(
                          color: kMxAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (eyebrow2.isNotEmpty)
                      Text(
                        eyebrow2,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                          fontFeatures: kMxTabular,
                        ),
                      ),
                    if (eyebrow.isNotEmpty || eyebrow2.isNotEmpty)
                      const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mxNb(subtitle),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (count != null)
              MxArch(
                width: 96,
                height: 132,
                stroke: 2.5,
                color: tone,
                draw: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MxCountUp(
                      value: count!,
                      style: TextStyle(
                        color: tone,
                        fontSize: 40,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        fontFeatures: kMxTabular,
                      ),
                      delay: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      countLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else if (trailing != null)
              trailing!,
          ],
        ),
      ),
    );
  }
}

/// A number that counts up (700 ms easeOutQuart, optional delay); still
/// under reduce-motion.
class MxCountUp extends StatelessWidget {
  const MxCountUp({
    required this.value,
    required this.style,
    this.delay = Duration.zero,
    super.key,
  });
  final int value;
  final TextStyle style;
  final Duration delay;
  @override
  Widget build(BuildContext context) {
    if (_still(context) || value == 0) return Text('$value', style: style);
    const run = Duration(milliseconds: 700);
    final total = run + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: Curves.easeOutQuart,
      ),
      builder: (_, v, _) => Text('${(value * v).round()}', style: style),
    );
  }
}

/// Keep the last two words together (no single orphan word on a line).
String mxNb(String s) {
  final i = s.lastIndexOf(' ');
  if (i <= 0 || ' '.allMatches(s).length < 2) return s;
  return '${s.substring(0, i)}\u00A0${s.substring(i + 1)}';
}

/// "פריט אחד" / "3 פריטים" — Hebrew count agreement.
String mxCount(int n, String one, String many) =>
    n == 1 ? one : '$n\u00A0$many';

/// KPI tile: white, icon + label on one row, the number below (counts up).
/// Color appears only when the value needs action; zero is a calm "✓".
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

  /// [MxGlyph] or [IconData].
  final Object icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final calm = value == 0;
    final c = calm ? kMxZero : color;
    final ink = c == kMxBad ? kMxBad : (c == kMxWarn ? kMxWarn : kMxPrimary);
    return Semantics(
      button: true,
      label: calm ? '$label: אין' : '$value $label',
      excludeSemantics: true,
      onTap: onTap,
      child: _Pressable(
        onTap: onTap,
        child: Container(
          height: 80,
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: kMxCardRadius,
            boxShadow: kMxShadow,
            border: c == kMxBad ? Border.all(color: kMxPink, width: 1.5) : null,
          ),
          child: Row(
            children: [
              MxIconBox(icon, color: calm ? kMxZero : ink),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MxCountUp(
                      value: value,
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: calm ? kMxZero : ink,
                        fontFeatures: kMxTabular,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kMxMuted,
                      ),
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

/// Gentle press feedback (scale 0.97, 90 ms) for custom tappable surfaces.
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
    onTap: () {
      HapticFeedback.selectionClick();
      widget.onTap();
    },
    child: AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: const Duration(milliseconds: 90),
      child: widget.child,
    ),
  );
}

/// A pick-tile (room / point in the staff report): white card, icon in a
/// tinted circle, red dot when something there is already faulty.
class MxTile extends StatelessWidget {
  const MxTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.caption = '',
    this.alert = false,
    this.selected = false,
    this.showOk = false,
    super.key,
  });

  /// [MxGlyph] or [IconData].
  final Object icon;
  final String label;
  final String caption;
  final bool alert;
  final bool selected;

  /// Show the small sage check when nothing is wrong here.
  final bool showOk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
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
      child: AnimatedContainer(
        duration: kMxEnter,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: kMxCardRadius,
          boxShadow:
              alert
                  ? [
                    BoxShadow(
                      color: kMxBad.withValues(alpha: 0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                  : kMxShadow,
          border:
              selected
                  ? Border.all(color: kMxPrimary, width: 2)
                  : alert
                  ? Border.all(color: kMxBad, width: 1.5)
                  : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxIconBox(
                  icon,
                  size: 46,
                  color: alert ? kMxBad : (showOk ? kMxOk : kMxPrimary),
                ),
                const Spacer(),
                if (alert)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: kMxBad,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: kMxPink, spreadRadius: 5)],
                    ),
                  )
                else if (showOk)
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: kMxSage,
                      shape: BoxShape.circle,
                    ),
                    child: const MxIcon(
                      MxGlyphs.check,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: alert ? const Color(0xFFA3262F) : kMxMuted,
                    fontWeight: alert ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Responsive grid of [MxTile]s (2 columns on phones, more on wide screens).
class MxTileGrid extends StatelessWidget {
  const MxTileGrid({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cols = (c.maxWidth / 170).floor().clamp(2, 5);
      // Fixed tile height (not an aspect ratio): content never clips on a
      // 320 dp phone, and tiles don't balloon on a wide one.
      return GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 148,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final (i, w) in children.indexed) MxAppear(index: i, child: w),
        ],
      );
    },
  );
}

/// Full-width primary button (52 dp). Petrol by default; pass [kMxBad] only
/// for safety / destructive actions.
class MxPrimaryButton extends StatelessWidget {
  const MxPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = kMxPrimary,
    this.foreground = Colors.white,
    super.key,
  });
  final String label;
  final IconData? icon;
  final Color color;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) =>
                s.contains(WidgetState.disabled)
                    ? color.withValues(alpha: 0.3)
                    : color,
          ),
          foregroundColor: WidgetStatePropertyAll(foreground),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: kMxFont,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.check_rounded, size: 22),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    ),
  );
}

/// A step of a progress timeline.
typedef MxStep = (String label, bool done, bool current);

/// Horizontal progress timeline. Done = petrol check, current = petrol with a
/// gold ring (gentle pulse), future = small quiet dot on the rail.
class MxTimeline extends StatelessWidget {
  const MxTimeline(this.steps, {super.key});
  final List<MxStep> steps;
  @override
  Widget build(BuildContext context) {
    final reached = steps.lastIndexWhere((s) => s.$2 || s.$3);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Stack(
        children: [
          Positioned.fill(
            top: 13,
            bottom: null,
            child: LayoutBuilder(
              builder: (context, c) {
                final step = c.maxWidth / steps.length;
                final done = reached <= 0 ? 0.0 : step * reached;
                return SizedBox(
                  height: 2,
                  child: Stack(
                    children: [
                      PositionedDirectional(
                        start: step / 2,
                        end: step / 2,
                        top: 0,
                        height: 2,
                        child: const ColoredBox(color: kMxLine),
                      ),
                      PositionedDirectional(
                        start: step / 2,
                        width: done,
                        top: 0,
                        height: 2,
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
                      SizedBox(
                        height: 28,
                        child: Center(
                          child:
                              done
                                  ? const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: kMxPrimary,
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  )
                                  : current
                                  ? const _Pulse(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: kMxPrimary,
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(
                                          BorderSide(
                                            color: kMxAccent,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      child: SizedBox(width: 26, height: 26),
                                    ),
                                  )
                                  : Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: kMxLine,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
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
                          height: 1.25,
                          fontWeight:
                              current ? FontWeight.w700 : FontWeight.w500,
                          color:
                              current
                                  ? kMxPrimary
                                  : done
                                  ? kMxInk
                                  : kMxMuted,
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

/// Slow breathing scale (1 → 1.08, 1.6 s) for "you are here"; still when the
/// system asks for reduced motion.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});
  final Widget child;
  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true, count: 6);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween<double>(
      begin: 1,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
    child: widget.child,
  );
}

/// Compact order progress: 5 thin segments + only the current step's name.
/// When everything is done it collapses to one "התקבל ✓" badge.
class MxSegments extends StatelessWidget {
  const MxSegments({required this.labels, required this.rank, super.key});
  final List<String> labels;

  /// Index of the current step; == labels.length - 1 means finished.
  final int rank;
  @override
  Widget build(BuildContext context) {
    final finished = rank >= labels.length - 1;
    if (finished) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, size: 20, color: kMxPrimary),
            const SizedBox(width: 8),
            Text(
              labels.last,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kMxPrimary,
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'שלב ${rank + 1} מתוך ${labels.length}: ${labels[rank]}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kMxPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: AnimatedContainer(
                    duration: kMxEnter,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          i < rank
                              ? kMxPrimary
                              : i == rank
                              ? kMxAccent
                              : kMxLine,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// "הבית מטופל": the full-screen success ceremony (1.4 s) — the gold arch
/// draws itself, the doorway fills with warm light from the floor, a white
/// check is drawn inside, a light haptic lands, then the words rise.
Future<void> mxShowSuccess(
  BuildContext context, {
  required String title,
  required String body,
  required List<(String label, Key key, VoidCallback onTap)> actions,
  List<(String title, String sub, bool done)> timeline = const [],
}) => Navigator.of(context).push(
  PageRouteBuilder<void>(
    transitionDuration: kMxEnter,
    reverseTransitionDuration: kMxExit,
    pageBuilder:
        (ctx, _, _) => _MomentPage(
          title: title,
          body: body,
          actions: actions,
          timeline: timeline,
        ),
    transitionsBuilder:
        (_, a, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
          child: child,
        ),
  ),
);

/// The safety takeover: a crimson circle grows from the bottom (where the
/// thumb just was) to fill the screen, the warning rises inside a white
/// arch, numbered steps the person ticks, and the call button at the
/// thumb. "הבנתי" unlocks only after every step is ticked.
Future<void> mxShowSafety(
  BuildContext context, {
  required String title,
  required List<String> steps,
  required String callLabel,
  required VoidCallback onCall,
  required VoidCallback onDone,
  Object icon = MxGlyphs.warning,
  String place = '',
  String note = '',
}) {
  HapticFeedback.heavyImpact();
  Future<void>.delayed(
    const Duration(milliseconds: 180),
    HapticFeedback.heavyImpact,
  );
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: kMxExit,
      pageBuilder:
          (ctx, _, _) => _SafetyPage(
            title: title,
            steps: steps,
            callLabel: callLabel,
            onCall: onCall,
            onDone: onDone,
            icon: icon,
            place: place,
            note: note,
          ),
      transitionsBuilder:
          (ctx, a, _, child) =>
              _still(ctx)
                  ? FadeTransition(opacity: a, child: child)
                  : ClipPath(
                    clipper: _Reveal(
                      CurvedAnimation(
                        parent: a,
                        curve: const Cubic(0.2, 0, 0, 1),
                      ).value,
                    ),
                    child: child,
                  ),
    ),
  );
}

class _Reveal extends CustomClipper<Path> {
  _Reveal(this.t);
  final double t;
  @override
  Path getClip(Size s) {
    final c = Offset(s.width / 2, s.height * 0.86);
    final r = s.longestSide * 1.1 * t;
    return Path()..addOval(Rect.fromCircle(center: c, radius: r));
  }

  @override
  bool shouldReclip(_Reveal old) => old.t != t;
}

class _MomentPage extends StatefulWidget {
  const _MomentPage({
    required this.title,
    required this.body,
    required this.actions,
    required this.timeline,
  });
  final String title;
  final String body;
  final List<(String, Key, VoidCallback)> actions;
  final List<(String, String, bool)> timeline;
  @override
  State<_MomentPage> createState() => _MomentPageState();
}

/// "הדלת נפתחת": the house's door swings open (0.1–0.55), warm light spills
/// out, a gold check is drawn in the doorway (0.5–0.7) with a light haptic,
/// sparkles appear, then the words and the timeline rise.
class _MomentPageState extends State<_MomentPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _buzzed = false;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      if (!_buzzed && _c.value >= 0.6) {
        _buzzed = true;
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _c.value = 1;
    } else if (_c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rise = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.55, 1, curve: Curves.easeOutCubic),
    );
    Widget risen(Widget child) => FadeTransition(
      opacity: rise,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(rise),
        child: child,
      ),
    );
    return Scaffold(
      backgroundColor: kMxCream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: _c,
                      builder:
                          (_, _) => CustomPaint(
                            size: const Size(220, 196),
                            painter: _CeremonyPainter(_c.value),
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  risen(
                    Column(
                      children: [
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: kMxPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mxNb(widget.body),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: kMxMuted,
                            fontSize: 17,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.timeline.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    risen(
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: kMxCardRadius,
                          boxShadow: kMxShadow,
                        ),
                        child: Column(
                          children: [
                            for (final (i, (t, sub, done))
                                in widget.timeline.indexed)
                              _MomentStep(
                                title: t,
                                sub: sub,
                                done: done,
                                last: i == widget.timeline.length - 1,
                                nextDone:
                                    i + 1 < widget.timeline.length &&
                                    widget.timeline[i + 1].$3,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, (label, key, onTap)) in widget.actions.indexed)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: SizedBox(
                        height: i == 0 ? 58 : 46,
                        child:
                            i == 0
                                ? FilledButton(
                                  key: key,
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    textStyle: const TextStyle(
                                      fontFamily: kMxFont,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onTap();
                                  },
                                  child: Text(label),
                                )
                                : TextButton(
                                  key: key,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onTap();
                                  },
                                  child: Text(label),
                                ),
                      ),
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

class _MomentStep extends StatelessWidget {
  const _MomentStep({
    required this.title,
    required this.sub,
    required this.done,
    required this.last,
    required this.nextDone,
  });
  final String title;
  final String sub;
  final bool done;
  final bool last;
  final bool nextDone;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              if (done)
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: kMxSage,
                    shape: BoxShape.circle,
                  ),
                  child: const MxIcon(
                    MxGlyphs.check,
                    size: 16,
                    color: Colors.white,
                  ),
                )
              else
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFCFC4B4),
                      width: 2,
                    ),
                  ),
                ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: nextDone ? kMxSage : const Color(0xFFE5DACB),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18, top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                    color: done ? kMxInk : const Color(0xFF9A928A),
                  ),
                ),
                if (sub.isNotEmpty)
                  Text(
                    mxNb(sub),
                    style: const TextStyle(fontSize: 13, color: kMxMuted),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// Door opens (0.1–0.55) → gold check in the doorway (0.5–0.7) →
/// sparkles (0.55–0.85). The warm glow grows with the door.
class _CeremonyPainter extends CustomPainter {
  _CeremonyPainter(this.t);
  final double t;
  double _seg(double a, double b, [Curve c = Curves.easeInOutCubic]) =>
      c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
  @override
  void paint(Canvas canvas, Size size) {
    final door = _seg(0.1, 0.55);
    final c = Offset(size.width / 2, size.height * 0.52);
    final r = size.width * 0.62;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE9B8).withValues(alpha: 0.4 + 0.6 * door),
            const Color(0x00FFE9B8),
          ],
          stops: const [0, 0.7],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    const hw = 138.0;
    const hh = hw * 96 / 76;
    final dx = (size.width - hw) / 2;
    final dy = size.height - hh;
    canvas
      ..save()
      ..translate(dx, dy);
    MxHousePainter(
      MxHouseState.ok,
      door: door,
      bubble: false,
    ).paint(canvas, const Size(hw, hh));
    const k = hw / 76;
    final ck = _seg(0.5, 0.7, Curves.easeOut);
    if (ck > 0) {
      final check =
          Path()
            ..moveTo(34 * k, 80.5 * k)
            ..lineTo(37 * k, 83.5 * k)
            ..lineTo(42.5 * k, 77.5 * k);
      for (final m in check.computeMetrics()) {
        canvas.drawPath(
          m.extractPath(0, m.length * ck),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = kMxWarn
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
    canvas.restore();
    final sp = _seg(0.55, 0.85, Curves.easeOut);
    if (sp > 0) {
      final gold = Paint()..color = kMxAccent.withValues(alpha: sp);
      for (final (x, y, rr) in const [
        (0.1, 0.35, 3.0),
        (0.9, 0.2, 2.6),
        (0.94, 0.62, 3.0),
        (0.06, 0.66, 2.2),
        (0.78, 0.08, 2.0),
      ]) {
        canvas.drawCircle(
          Offset(x * size.width, y * size.height),
          rr * sp,
          gold,
        );
      }
      void star(double x, double y, double s) {
        final o = Offset(x * size.width, y * size.height);
        final p =
            Path()
              ..moveTo(o.dx, o.dy - s)
              ..lineTo(o.dx + s * 0.28, o.dy - s * 0.28)
              ..lineTo(o.dx + s, o.dy)
              ..lineTo(o.dx + s * 0.28, o.dy + s * 0.28)
              ..lineTo(o.dx, o.dy + s)
              ..lineTo(o.dx - s * 0.28, o.dy + s * 0.28)
              ..lineTo(o.dx - s, o.dy)
              ..lineTo(o.dx - s * 0.28, o.dy - s * 0.28)
              ..close();
        canvas.drawPath(p, gold);
      }

      star(0.22, 0.14, 9 * sp);
      star(0.82, 0.36, 7 * sp);
    }
  }

  @override
  bool shouldRepaint(_CeremonyPainter old) => old.t != t;
}

class _SafetyPage extends StatefulWidget {
  const _SafetyPage({
    required this.title,
    required this.steps,
    required this.callLabel,
    required this.onCall,
    required this.onDone,
    required this.icon,
    required this.place,
    required this.note,
  });
  final String title;
  final List<String> steps;
  final String callLabel;
  final VoidCallback onCall;
  final VoidCallback onDone;
  final Object icon;
  final String place;
  final String note;
  @override
  State<_SafetyPage> createState() => _SafetyPageState();
}

class _SafetyPageState extends State<_SafetyPage> {
  late final List<bool> _done = List.filled(widget.steps.length, false);

  @override
  Widget build(BuildContext context) {
    final all = _done.every((d) => d);
    final n = _done.where((d) => d).length;
    return Scaffold(
      backgroundColor: kMxBad,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.65),
            radius: 1.3,
            colors: [Color(0xFFDB4B4F), kMxBad, Color(0xFFA82A33)],
            stops: [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
                  children: [
                    Center(
                      child: _Pulse(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: _still(context) ? 1 : 0.6,
                            end: 1,
                          ),
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutBack,
                          builder:
                              (_, v, c) => Transform.scale(scale: v, child: c),
                          child: Container(
                            width: 150,
                            height: 150,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                            child: Container(
                              width: 108,
                              height: 108,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x4D5A000A),
                                    blurRadius: 30,
                                    offset: Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: mxIcon(
                                widget.icon,
                                size: 54,
                                color: kMxBad,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (widget.place.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        mxNb(widget.place),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 16,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Semantics(
                      label:
                          'צעד ${(n + 1).clamp(1, _done.length)} מתוך ${_done.length}',
                      excludeSemantics: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          children: [
                            Text(
                              all
                                  ? 'כל הצעדים בוצעו'
                                  : 'צעד ${n + 1} מתוך ${_done.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                fontFeatures: kMxTabular,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(end: n / _done.length),
                                  duration: kMxEnter,
                                  builder:
                                      (_, v, _) => LinearProgressIndicator(
                                        value: v,
                                        minHeight: 6,
                                        color: Colors.white,
                                        backgroundColor: Colors.white24,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final (i, s) in widget.steps.indexed)
                      MxAppear(
                        index: i * 2,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AnimatedContainer(
                            duration: kMxEnter,
                            decoration: BoxDecoration(
                              color:
                                  _done[i]
                                      ? Colors.white.withValues(alpha: 0.94)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow:
                                  _done[i]
                                      ? null
                                      : const [
                                        BoxShadow(
                                          color: Color(0x2E50000A),
                                          blurRadius: 20,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                            ),
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                key: Key('safety-step-$i'),
                                borderRadius: BorderRadius.circular(22),
                                onTap: () {
                                  HapticFeedback.heavyImpact();
                                  setState(() => _done[i] = !_done[i]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      AnimatedScale(
                                        scale: _done[i] ? 1 : 0.92,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeOutBack,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          width: 34,
                                          height: 34,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                _done[i]
                                                    ? kMxSage
                                                    : Colors.white,
                                            border:
                                                _done[i]
                                                    ? null
                                                    : Border.all(
                                                      color: kMxBad,
                                                      width: 2.5,
                                                    ),
                                          ),
                                          child:
                                              _done[i]
                                                  ? const MxIcon(
                                                    MxGlyphs.check,
                                                    size: 19,
                                                    color: Colors.white,
                                                  )
                                                  : Text(
                                                    '${i + 1}',
                                                    style: const TextStyle(
                                                      color: kMxBad,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          s,
                                          style: TextStyle(
                                            fontSize: 16.5,
                                            height: 1.35,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _done[i]
                                                    ? const Color(0xFF9A928A)
                                                    : kMxInk,
                                            decoration:
                                                _done[i]
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                            decorationColor: const Color(
                                              0xFFC9BFB4,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // At the thumb: the call first, then "done".
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 74,
                      child: FilledButton(
                        key: const Key('urgent-call'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: kMxBad,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: kMxFont,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: widget.onCall,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: kMxPink,
                                shape: BoxShape.circle,
                              ),
                              child: const MxIcon(
                                MxGlyphs.phone,
                                size: 23,
                                color: kMxBad,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                widget.callLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const MxIcon(
                              MxGlyphs.check,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.note,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 48,
                      child: AnimatedSwitcher(
                        duration: kMxEnter,
                        child:
                            all
                                ? FilledButton(
                                  key: const Key('success-mine'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white24,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.pop(context);
                                    widget.onDone();
                                  },
                                  child: const Text('הבנתי, ביצעתי'),
                                )
                                : TextButton(
                                  key: const Key('success-mine'),
                                  style: TextButton.styleFrom(
                                    disabledForegroundColor: Colors.white70,
                                  ),
                                  onPressed: null,
                                  child: const Text('סמנו את כל הצעדים'),
                                ),
                      ),
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

/// "בוקר טוב" / "צהריים טובים" / "ערב טוב" / "לילה טוב".
String mxGreeting(DateTime now) {
  final h = now.hour;
  if (h >= 5 && h < 12) return 'בוקר טוב';
  if (h >= 12 && h < 17) return 'צהריים טובים';
  if (h >= 17 && h < 22) return 'ערב טוב';
  return 'לילה טוב';
}

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
  if (d < 0) return 'באיחור ${-d} ימים';
  if (d < 31) return 'עוד $d ימים';
  final m = (d / 30).round();
  return m == 1 ? 'עוד כחודש' : 'עוד כ־$m חודשים';
}

/// "לפני 5 דק׳" / "לפני 3 שע׳" / "אתמול" / "8 בנוב׳".
String mxAgo(DateTime at, DateTime now) {
  final d = now.difference(at);
  if (d.inMinutes < 1) return 'עכשיו';
  if (d.inMinutes < 60) return 'לפני ${d.inMinutes} דק׳';
  if (d.inHours < 24 && at.day == now.day) {
    return 'לפני ${d.inHours} שע׳';
  }
  if (d.inDays < 2) return 'אתמול';
  return mxShortDate(at);
}

/// "8 בנוב׳" — Hebrew short date, no LTR digits run to flip.
String mxShortDate(DateTime d) {
  const m = [
    'בינו׳',
    'בפבר׳',
    'במרץ',
    'באפר׳',
    'במאי',
    'ביוני',
    'ביולי',
    'באוג׳',
    'בספט׳',
    'באוק׳',
    'בנוב׳',
    'בדצמ׳',
  ];
  return '${d.day} ${m[d.month - 1]}';
}

/// Section title (20/700) with an optional quiet count badge.
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
    padding: const EdgeInsetsDirectional.fromSTEB(22, 24, 22, 10),
    child: Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kMxInk,
            ),
          ),
        ),
        if (count != null && count! > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: mxTintOf(color),
              borderRadius: BorderRadius.circular(kMxR6),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                fontFeatures: kMxTabular,
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
  final Object icon;
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mxIcon(icon, size: 20, color: kMxPrimary),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: kMxMuted, fontSize: 14),
          ),
        ),
        Expanded(
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
            child: value,
          ),
        ),
      ],
    ),
  );
}

/// Stock level bar: filled share of 2×min, red under min, petrol above.
class MxStockBar extends StatelessWidget {
  const MxStockBar({required this.qty, required this.min, super.key});
  final int qty;
  final int min;
  @override
  Widget build(BuildContext context) {
    final target = (min * 2).clamp(1, 1 << 30);
    final v = (qty / target).clamp(0.0, 1.0);
    final c = qty < min ? kMxBad : kMxPrimary;
    return Semantics(
      label: 'במלאי $qty, מינימום $min',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: v,
          minHeight: 4,
          color: c,
          backgroundColor: kMxPanel,
        ),
      ),
    );
  }
}

/// Empty state: the home arch with an icon (or a drawn check when
/// [success]), a calm title and one line on what to do now.
class MxEmpty extends StatelessWidget {
  const MxEmpty({
    required this.icon,
    required this.title,
    this.body = '',
    this.success = false,
    super.key,
  });
  final Object icon;
  final String title;
  final String body;
  final bool success;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
    child: Column(
      children: [
        if (success)
          const MxHouseArt(state: MxHouseState.ok, width: 92)
        else
          MxIconBox(icon, size: 76, background: kMxPeach),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            mxNb(body),
            textAlign: TextAlign.center,
            style: const TextStyle(color: kMxMuted, fontSize: 16, height: 1.45),
          ),
        ],
      ],
    ),
  );
}

/// The one card: white, radius 16, elevation 1, no border.
class MxCard extends StatelessWidget {
  const MxCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 12),
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: kMxCardRadius,
      boxShadow: kMxShadow,
    ),
    child: child,
  );
}

/// Kept for call sites: status now lives in the badge, so the card is the
/// plain [MxCard] ([color] is ignored on purpose — no colored borders).
class MxEdgeCard extends StatelessWidget {
  const MxEdgeCard({required this.color, required this.child, super.key});
  final Color color;
  final Widget child;
  @override
  Widget build(BuildContext context) => MxCard(child: child);
}

/// Status badge: 24 dp, radius 6, 12/600 on the color's tint.
class MxTag extends StatelessWidget {
  const MxTag(this.text, this.color, {super.key});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 132),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color == Colors.white ? Colors.white24 : mxBoxTint(color),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 1.3,
      ),
    ),
  );
}

/// The role switch (demo only — real use signs in): one small chip on the
/// petrol bar, "מנהל ▾"; tapping opens a sheet (handled by the screen).
class MxRoleChip extends StatelessWidget {
  const MxRoleChip({required this.label, required this.onTap, super.key});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'תפקיד: $label. החלפת תפקיד',
    excludeSemantics: true,
    onTap: onTap,
    child: _Pressable(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 10, 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: kMxShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: kMxPeach,
              child: Text(
                label.characters.first,
                style: const TextStyle(
                  color: kMxPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: kMxPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more_rounded, size: 18, color: kMxMuted),
          ],
        ),
      ),
    ),
  );
}

/// Initials avatar for people (no clip-art).
class MxAvatar extends StatelessWidget {
  const MxAvatar(this.name, {this.size = 32, super.key});
  final String name;
  final double size;
  @override
  Widget build(BuildContext context) {
    final parts = name.split(RegExp(r'\s+|–')).where((p) => p.isNotEmpty);
    final ini = parts.take(1).map((p) => p.characters.first).join();
    // Decorative: the name is always next to it — don't read it twice.
    return ExcludeSemantics(
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: kMxTealTint,
        child: Text(
          ini,
          style: TextStyle(
            color: kMxPrimary,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }
}

/// Sticky action area at the bottom of a page — elevation 2, so content
/// scrolling under it reads as "under", never cut by a hard line.
class MxBottomBar extends StatelessWidget {
  const MxBottomBar({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: kMxCream, boxShadow: kMxShadow2),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    ),
  );
}

/// + n − stepper. In RTL "+" sits at the start (right), "−" at the end; 44 dp
/// round targets; a disabled side stays visible at 35 %.
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
  Widget build(BuildContext context) {
    Widget b(String k, IconData icon, String tip, VoidCallback? f) => SizedBox(
      width: 44,
      height: 44,
      child: IconButton.outlined(
        key: Key('$keyPrefix-$k'),
        tooltip: tip,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          side: BorderSide(
            color: f == null ? kMxPrimary.withValues(alpha: 0.25) : kMxPrimary,
          ),
        ),
        onPressed: f,
        icon: Icon(icon, size: 20),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        b(
          'plus',
          Icons.add_rounded,
          'יותר',
          value < max ? () => onChanged(value + 1) : null,
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            key: Key('$keyPrefix-value'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFeatures: kMxTabular,
            ),
          ),
        ),
        b(
          'minus',
          Icons.remove_rounded,
          'פחות',
          value > min ? () => onChanged(value - 1) : null,
        ),
      ],
    );
  }
}

/// Urgent strip: crimson start edge that breathes until someone acts.
class MxUrgentBanner extends StatelessWidget {
  const MxUrgentBanner({
    required this.title,
    required this.body,
    this.onCall,
    this.callLabel = 'התקשרו למנהל האחזקה',
    super.key,
  });
  final String title;
  final String body;
  final VoidCallback? onCall;
  final String callLabel;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    decoration: const BoxDecoration(
      color: kMxPink,
      borderRadius: kMxCardRadius,
    ),
    clipBehavior: Clip.antiAlias,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Breathe(
            child: ColoredBox(color: kMxBad, child: SizedBox(width: 4)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: const TextStyle(fontSize: 16, height: 1.45),
                  ),
                  if (onCall != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('urgent-call'),
                        style: FilledButton.styleFrom(backgroundColor: kMxBad),
                        onPressed: onCall,
                        icon: const Icon(Icons.call_rounded),
                        label: Text(callLabel),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Opacity 0.6 ↔ 1, 1.2 s — "still needs someone".
class _Breathe extends StatefulWidget {
  const _Breathe({required this.child});
  final Widget child;
  @override
  State<_Breathe> createState() => _BreatheState();
}

class _BreatheState extends State<_Breathe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
    lowerBound: 0.6,
    value: 1,
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true, count: 6);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _c, child: widget.child);
}

/// Horizontal filter chips: 16 dp edge padding, a 24 dp fade at the end so
/// a cut chip reads as "more", counts as a small badge (not in brackets).
class MxFilterChips extends StatelessWidget {
  const MxFilterChips({
    required this.keyPrefix,
    required this.items,
    required this.selected,
    required this.onSelect,
    super.key,
  });
  final String keyPrefix;
  final List<(String key, String label, int? count)> items;
  final String selected;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback:
        (r) => LinearGradient(
          begin: AlignmentDirectional.centerStart.resolve(
            Directionality.of(context),
          ),
          end: AlignmentDirectional.centerEnd.resolve(
            Directionality.of(context),
          ),
          colors: const [
            Colors.white,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [0, 0.5, 1 - 24 / r.width.clamp(48, 4000), 1],
        ).createShader(r),
    blendMode: BlendMode.dstIn,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          for (final (k, label, count) in items)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                key: Key('$keyPrefix-$k'),
                visualDensity: VisualDensity.compact,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: selected == k ? Colors.white : kMxInk,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (count != null && count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: selected == k ? Colors.white24 : kMxTealTint,
                          borderRadius: BorderRadius.circular(kMxR6),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFeatures: kMxTabular,
                            color: selected == k ? Colors.white : kMxPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                selected: selected == k,
                selectedColor: kMxPrimary,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selected == k ? kMxPrimary : const Color(0xFFC9C7B4),
                ),
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  onSelect(k);
                },
              ),
            ),
        ],
      ),
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
  return 'יום ${days[d.weekday - 1]} · ${d.day} ${months[d.month - 1]}';
}

// ── design round 3: the arch as a system ─────────────────────────────────────

/// The doorway arch as a [ShapeBorder]: a container shape for icons, tiles
/// and houses. Status is the stroke color (gold ok · petrol in progress ·
/// crimson fault · grey closed).
class MxArchBorder extends OutlinedBorder {
  const MxArchBorder({super.side});

  static Path pathFor(Rect r) {
    final rad = r.width / 2;
    const k = 6.0;
    return Path()
      ..moveTo(r.left, r.bottom - k)
      ..lineTo(r.left, r.top + rad)
      ..arcToPoint(Offset(r.right, r.top + rad), radius: Radius.circular(rad))
      ..lineTo(r.right, r.bottom - k)
      ..quadraticBezierTo(r.right, r.bottom, r.right - k, r.bottom)
      ..lineTo(r.left + k, r.bottom)
      ..quadraticBezierTo(r.left, r.bottom, r.left, r.bottom - k)
      ..close();
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      pathFor(rect.deflate(side.width));
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => pathFor(rect);
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(pathFor(rect.deflate(side.width / 2)), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => MxArchBorder(side: side.scale(t));
  @override
  MxArchBorder copyWith({BorderSide? side}) =>
      MxArchBorder(side: side ?? this.side);
}

/// Status → arch stroke color.
Color mxArchTone({bool fault = false, bool open = false, bool closed = false}) {
  if (fault) return kMxBad;
  if (open) return kMxPrimary;
  if (closed) return const Color(0xFFC9C6B5);
  return kMxAccent;
}

/// An icon standing in a small arch (replaces the generic tinted circle).
class MxArchBadge extends StatelessWidget {
  const MxArchBadge(
    this.icon, {
    this.color = kMxAccent,
    this.iconColor = kMxPrimary,
    this.width = 40,
    this.height = 48,
    this.fill = kMxSurface,
    super.key,
  });

  /// [MxGlyph] or [IconData].
  final Object icon;
  final Color color;
  final Color iconColor;
  final double width;
  final double height;
  final Color fill;
  // "בית": a tinted rounded square; the status color tints the box and,
  // for danger, the icon too ([height] kept for old call sites).
  @override
  Widget build(BuildContext context) {
    final tint = switch (color) {
      kMxBad => kMxPink,
      kMxWarn => kMxGoldTint,
      kMxPrimary => kMxTealTint,
      kMxOk => kMxSageTint,
      kMxAccent => kMxPeachSoft,
      _ => kMxPanel,
    };
    return MxIconBox(
      icon,
      size: width,
      color: color == kMxBad ? kMxBad : (color == kMxOk ? kMxOk : iconColor),
      background: tint,
    );
  }
}

/// A house on the street: 0 = all good, 1 = open job, 2 = urgent.
typedef MxHouse = (String id, String label, int state);

MxHouseState mxHouseState(int s) => switch (s) {
  2 => MxHouseState.urgent,
  1 => MxHouseState.job,
  _ => MxHouseState.ok,
};

/// "הרחוב": every apartment as a small drawn house, grouped by site with a
/// tree between sites, scrolling sideways when the organization grows.
/// Meant to stand on the hills of an [MxScene]. On Friday before Shabbat,
/// when every house is fine, the windows light up one after another.
class MxStreet extends StatelessWidget {
  const MxStreet({
    required this.groups,
    required this.onTap,
    this.celebrate = false,
    this.houseWidth = 58,
    super.key,
  });
  final List<(String title, List<MxHouse> houses)> groups;
  final ValueChanged<String> onTap;
  final bool celebrate;
  final double houseWidth;
  @override
  Widget build(BuildContext context) {
    var n = 0;
    final children = <Widget>[];
    for (final (gi, (title, houses)) in groups.indexed) {
      if (gi > 0) {
        children.add(
          const Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 30),
            child: MxTree(height: 40),
          ),
        );
      }
      children.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final h in houses)
                  _House(
                    h,
                    n++,
                    onTap,
                    celebrate: celebrate,
                    width: houseWidth,
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7B6A58),
              ),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: children,
      ),
    );
  }
}

/// The street sized to its window: houses shrink (down to 44) so a small
/// organization fits in one view; a big one scrolls sideways.
class MxStreetFit extends StatelessWidget {
  const MxStreetFit({
    required this.groups,
    required this.onTap,
    this.celebrate = false,
    super.key,
  });
  final List<(String title, List<MxHouse> houses)> groups;
  final ValueChanged<String> onTap;
  final bool celebrate;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) {
      final n = groups.fold(0, (a, g) => a + g.$2.length);
      final trees = (groups.length - 1).clamp(0, 99) * 42.0;
      final w = (((c.maxWidth - 20 - trees) / (n == 0 ? 1 : n)) - 8).clamp(
        44.0,
        66.0,
      );
      return MxStreet(
        groups: groups,
        onTap: onTap,
        celebrate: celebrate,
        houseWidth: w,
      );
    },
  );
}

class _House extends StatelessWidget {
  const _House(
    this.h,
    this.i,
    this.onTap, {
    required this.celebrate,
    required this.width,
  });
  final MxHouse h;
  final int i;
  final ValueChanged<String> onTap;
  final bool celebrate;
  final double width;
  @override
  Widget build(BuildContext context) {
    final (id, label, state) = h;
    final st = mxHouseState(state);
    Widget art = MxHouseArt(state: st, width: width);
    if (celebrate) {
      art =
          _still(context)
              ? MxHouseArt(state: st, width: width, lit: 1)
              : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 900 + 160 * i),
                curve: Interval(
                  (160 * i) / (900 + 160 * i),
                  1,
                  curve: Curves.easeOutCubic,
                ),
                builder:
                    (_, v, _) => MxHouseArt(state: st, width: width, lit: v),
              );
    }
    final what = switch (state) {
      2 => 'תקלה דחופה',
      1 => 'יש קריאה פתוחה',
      _ => 'הכול תקין',
    };
    return Semantics(
      button: true,
      label: '$label, $what',
      excludeSemantics: true,
      onTap: () => onTap(id),
      child: _Pressable(
        onTap: () => onTap(id),
        child: Padding(
          key: Key('street-$id'),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(tag: 'house-$id', child: art),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      state == 2
                          ? const Color(0xFFA3262F)
                          : const Color(0xFF5E5A52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Our own segmented switch: cream track, a white thumb that slides
/// (240 ms easeOutCubic). No Material leftovers.
class MxSwitch<T> extends StatelessWidget {
  const MxSwitch({
    required this.items,
    required this.selected,
    required this.onChanged,
    super.key,
  });
  final List<(T value, Widget label)> items;
  final T selected;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) {
    final i = items.indexWhere((x) => x.$1 == selected).clamp(0, items.length);
    final n = items.length;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: kMxPanel,
        borderRadius: BorderRadius.circular(kMxR12),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: kMxEnter,
            curve: Curves.easeOutCubic,
            alignment: AlignmentDirectional(
              n == 1 ? 0 : -1 + 2 * i / (n - 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              heightFactor: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: kMxShadow,
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final (v, label) in items)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: v == selected,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChanged(v);
                      },
                      child: Center(
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: v == selected ? kMxPrimary : kMxMuted,
                          ),
                          child: label,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom-nav icon: the active tab wears a small gold arch above it.
class MxNavIcon extends StatelessWidget {
  const MxNavIcon(this.icon, {this.selected = false, super.key});
  final Object icon;
  final bool selected;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 24,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        mxIcon(icon, color: selected ? kMxPrimary : const Color(0xFF7C7A70)),
        Positioned(
          top: -9,
          child: AnimatedOpacity(
            opacity: selected ? 1 : 0,
            duration: kMxEnter,
            child: const CustomPaint(
              size: Size(16, 6),
              painter: MxArchPainter(),
            ),
          ),
        ),
      ],
    ),
  );
}

/// One tab of [MxNavBar]: icon, label, and a count of things to act on.
typedef MxNavItem = (Object icon, String label, int badge);

/// "בית" navigation: a floating petrol pill. The active tab opens into a
/// peach capsule with its name; with three tabs or fewer every name shows.
class MxNavBar extends StatelessWidget {
  const MxNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    super.key,
  });
  final List<MxNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final all = items.length <= 3;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: kMxPrimary,
            borderRadius: BorderRadius.circular(33),
            boxShadow: kMxShadow3,
          ),
          child: Row(
            mainAxisAlignment:
                all
                    ? MainAxisAlignment.spaceEvenly
                    : MainAxisAlignment.spaceBetween,
            children: [
              for (final (i, (icon, label, badge)) in items.indexed)
                if (all || i == selectedIndex)
                  Flexible(
                    child: _NavTab(
                      key: Key('nav-$label'),
                      icon: icon,
                      label: label,
                      badge: badge,
                      selected: i == selectedIndex,
                      showLabel: true,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSelect(i);
                      },
                    ),
                  )
                else
                  _NavTab(
                    key: Key('nav-$label'),
                    icon: icon,
                    label: label,
                    badge: badge,
                    selected: false,
                    showLabel: false,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelect(i);
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.badge,
    required this.selected,
    required this.showLabel,
    required this.onTap,
    super.key,
  });
  final Object icon;
  final String label;
  final int badge;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? kMxPrimary : const Color(0xFFB9D0D5);
    return Semantics(
      button: true,
      selected: selected,
      label: badge > 0 ? '$label, $badge' : label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: kMxEnter,
          curve: Curves.easeOutCubic,
          height: 48,
          width: showLabel ? null : 48,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: showLabel ? 14 : 0),
          decoration: BoxDecoration(
            color: selected ? kMxPeach : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  mxIcon(icon, size: 22, color: fg),
                  if (badge > 0)
                    PositionedDirectional(
                      top: -7,
                      end: -9,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 18),
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kMxAccent,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: selected ? kMxPeach : kMxPrimary,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            color: kMxPrimary,
                            fontFeatures: kMxTabular,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
