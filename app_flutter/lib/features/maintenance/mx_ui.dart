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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// Compact petrol greeting card (board only): Hebrew date in gold, one
/// status sentence, the home arch in the end corner — never under the text.
class MxHero extends StatelessWidget {
  const MxHero({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.eyebrow = '',
    this.eyebrow2 = '',
    super.key,
  });
  final String title;
  final String subtitle;
  final String eyebrow;
  final String eyebrow2;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
    decoration: const BoxDecoration(
      color: kMxPrimary,
      borderRadius: kMxCardRadius,
      boxShadow: kMxShadow,
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: [
        const PositionedDirectional(
          end: 16,
          bottom: 0,
          child: MxArch(width: 56, height: 76),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 88, 16),
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
                const SizedBox(height: 8),
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
        if (trailing != null)
          PositionedDirectional(end: 16, top: 16, child: trailing!),
      ],
    ),
  );
}

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
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final calm = value == 0;
    final alarm = !calm && color == kMxBad;
    final c = calm ? kMxZero : color;
    return Semantics(
      button: true,
      label: calm ? '$label: אין' : '$value $label',
      excludeSemantics: true,
      onTap: onTap,
      child: _Pressable(
        onTap: onTap,
        child: Container(
          height: 96,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: alarm ? kMxPink : Colors.white,
            borderRadius: kMxCardRadius,
            boxShadow: alarm ? null : kMxShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: calm ? kMxZero : color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: calm ? kMxMuted : kMxInk,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (calm)
                const Row(
                  children: [
                    Icon(Icons.check_rounded, size: 22, color: kMxZero),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'הכול תקין',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: kMxZero,
                        ),
                      ),
                    ),
                  ],
                )
              else
                _CountUp(value: value, color: c),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountUp extends StatelessWidget {
  const _CountUp({required this.value, required this.color});
  final int value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    Text t(int v) => Text(
      '$v',
      style: TextStyle(
        fontSize: 32,
        height: 1,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: kMxTabular,
      ),
    );
    if (_still(context)) return t(value);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
      builder: (_, v, _) => t(v.round()),
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
    super.key,
  });
  final IconData icon;
  final String label;
  final String caption;
  final bool alert;
  final bool selected;
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: kMxCardRadius,
          boxShadow: kMxShadow,
          border: selected ? Border.all(color: kMxPrimary, width: 2) : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: kMxTealTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: kMxPrimary),
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
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: alert ? kMxBad : kMxMuted,
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
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
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
    super.key,
  });
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) =>
                s.contains(WidgetState.disabled)
                    ? color.withValues(alpha: 0.3)
                    : color,
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Heebo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
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
        child: MxTag('${labels.last} ✓', kMxPrimary),
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

/// "הבית מטופל": the full-screen success moment — petrol, the gold arch
/// draws itself around a white check. Same moment for report / store / PM.
Future<void> mxShowSuccess(
  BuildContext context, {
  required String title,
  required String body,
  required List<(String label, Key key, VoidCallback onTap)> actions,
}) {
  HapticFeedback.lightImpact();
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: kMxEnter,
      reverseTransitionDuration: kMxExit,
      pageBuilder:
          (ctx, _, _) => _MomentPage(
            background: kMxPrimary,
            icon: const MxArch(
              width: 120,
              height: 156,
              stroke: 3,
              draw: true,
              child: Icon(Icons.check_rounded, size: 56, color: Colors.white),
            ),
            title: title,
            body: body,
            actions: actions,
          ),
      transitionsBuilder:
          (_, a, _, child) => FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
            child: child,
          ),
    ),
  );
}

/// The safety takeover: full crimson screen, "stop", numbered steps the
/// person ticks, a big call button with name and number. "הבנתי" unlocks
/// only after every step is ticked.
Future<void> mxShowSafety(
  BuildContext context, {
  required String title,
  required List<String> steps,
  required String callLabel,
  required VoidCallback onCall,
  required VoidCallback onDone,
}) {
  HapticFeedback.heavyImpact();
  Future<void>.delayed(
    const Duration(milliseconds: 180),
    HapticFeedback.heavyImpact,
  );
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: kMxEnter,
      reverseTransitionDuration: kMxExit,
      pageBuilder:
          (ctx, _, _) => _SafetyPage(
            title: title,
            steps: steps,
            callLabel: callLabel,
            onCall: onCall,
            onDone: onDone,
          ),
      transitionsBuilder:
          (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ),
  );
}

class _MomentPage extends StatelessWidget {
  const _MomentPage({
    required this.background,
    required this.icon,
    required this.title,
    required this.body,
    required this.actions,
  });
  final Color background;
  final Widget icon;
  final String title;
  final String body;
  final List<(String, Key, VoidCallback)> actions;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          children: [
            const Spacer(),
            icon,
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 16,
                height: 1.45,
              ),
            ),
            const Spacer(),
            for (final (i, (label, key, onTap)) in actions.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: i == 0 ? 52 : 48,
                  child:
                      i == 0
                          ? FilledButton(
                            key: key,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: background,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              onTap();
                            },
                            child: Text(label),
                          )
                          : TextButton(
                            key: key,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
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
    ),
  );
}

class _SafetyPage extends StatefulWidget {
  const _SafetyPage({
    required this.title,
    required this.steps,
    required this.callLabel,
    required this.onCall,
    required this.onDone,
  });
  final String title;
  final List<String> steps;
  final String callLabel;
  final VoidCallback onCall;
  final VoidCallback onDone;
  @override
  State<_SafetyPage> createState() => _SafetyPageState();
}

class _SafetyPageState extends State<_SafetyPage> {
  late final List<bool> _done = List.filled(widget.steps.length, false);

  @override
  Widget build(BuildContext context) {
    final all = _done.every((d) => d);
    return Scaffold(
      backgroundColor: kMxBad,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          children: [
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: _still(context) ? 1 : 0.6, end: 1),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                builder: (_, v, c) => Transform.scale(scale: v, child: c),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 72,
                  color: Colors.white,
                  semanticLabel: 'אזהרה',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'עשו עכשיו, לפי הסדר, וסמנו כל צעד:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            for (final (i, s) in widget.steps.indexed)
              MxAppear(
                index: i * 3,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.white,
                    borderRadius: kMxCardRadius,
                    child: InkWell(
                      key: Key('safety-step-$i'),
                      borderRadius: kMxCardRadius,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _done[i] = !_done[i]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _done[i] ? kMxBad : kMxPink,
                              ),
                              child:
                                  _done[i]
                                      ? const Icon(
                                        Icons.check_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      )
                                      : Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          color: kMxBad,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                  color: kMxInk,
                                  decoration:
                                      _done[i]
                                          ? TextDecoration.lineThrough
                                          : null,
                                  decorationColor: kMxMuted,
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
            const SizedBox(height: 12),
            SizedBox(
              height: 64,
              child: FilledButton.icon(
                key: const Key('urgent-call'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kMxBad,
                  textStyle: const TextStyle(
                    fontFamily: 'Heebo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: widget.onCall,
                icon: const Icon(Icons.call_rounded, size: 26),
                label: Text(widget.callLabel),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                key: const Key('success-mine'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white54,
                  side: BorderSide(color: all ? Colors.white : Colors.white38),
                ),
                onPressed:
                    all
                        ? () {
                          Navigator.pop(context);
                          widget.onDone();
                        }
                        : null,
                child: Text(all ? 'הבנתי, ביצעתי' : 'סמנו את כל הצעדים'),
              ),
            ),
          ],
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
    padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8),
    child: Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        if (count != null) ...[
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
  final IconData icon;
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kMxPrimary),
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
  final IconData icon;
  final String title;
  final String body;
  final bool success;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
    child: Column(
      children: [
        MxArch(
          width: 96,
          height: 124,
          stroke: 2,
          draw: success,
          child: Icon(
            success ? Icons.check_rounded : icon,
            size: 40,
            color: kMxPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            body,
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
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color == Colors.white ? Colors.white24 : mxTintOf(color),
      borderRadius: BorderRadius.circular(kMxR6),
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
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: kMxAccent,
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
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: Colors.white70,
            ),
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
    decoration: const BoxDecoration(color: Colors.white, boxShadow: kMxShadow2),
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
