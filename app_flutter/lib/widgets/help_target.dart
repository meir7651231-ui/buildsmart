import 'dart:math' as math;

import 'package:buildsmart/state/help_mode.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Headline / body ink for the bubble + dialog cards. The card sits on
/// `colorScheme.surface`, which is dark in dark mode — the fixed light-theme
/// ink was unreadable there. Light mode keeps the exact former colours.
Color _helpInk(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? BsTokens.inkDark
        : BsTokens.inkLight;

/// Hairline edge for the help card on a dark page (mutedDark at 25%).
const Color _kDarkCardEdge = Color(0x40A89E90);

Color _helpMuted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? BsTokens.mutedDark
        : BsTokens.mutedLight;

/// Wraps an interactive element so that, while "מצב היכרות" (help mode) is
/// active, tapping it pops a Hebrew explanation **bubble out of the element**
/// (a chat-style speech bubble with a tail pointing at the button) describing
/// exactly what it does — instead of performing its real action.
///
/// Outside help mode it returns [child] untouched (zero behaviour change). The
/// reusable building block of the interactive discovery mode (task #30): each
/// explainable element just gets a [title] + [body].
class HelpTarget extends ConsumerStatefulWidget {
  const HelpTarget({
    required this.title,
    required this.body,
    required this.child,
    super.key,
  });

  /// Short Hebrew name of the element (the bubble headline).
  final String title;

  /// Precise Hebrew explanation of what the element does.
  final String body;

  /// The real element (button, icon, FAB, …).
  final Widget child;

  @override
  ConsumerState<HelpTarget> createState() => _HelpTargetState();
}

class _HelpTargetState extends ConsumerState<HelpTarget> {
  /// The open bubble, if any. Owned here so it can never outlive the element
  /// it explains: it closes when help mode turns off, when the element's
  /// route stops being the top route (pushed over or popped), and when the
  /// element leaves the tree. Before, a back-press left it floating over the
  /// previous screen.
  OverlayEntry? _entry;

  void _close() {
    final e = _entry;
    _entry = null;
    // No `mounted` guard: an entry closed before its first frame (tap and
    // pop in the same frame) is not mounted yet and would stay on screen with
    // a dead close layer. Clearing [_entry] first already rules out a double
    // remove.
    e
      ?..remove()
      ..dispose();
  }

  /// Close after the current frame — an overlay entry must not be removed
  /// while the tree is building.
  void _closeSoon() {
    if (_entry == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _close());
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(helpModeProvider);
    // Registers a dependency on the route, so this rebuilds when another
    // route is pushed over it or it starts popping.
    final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (!active || !routeIsCurrent) _closeSoon();
    final child = widget.child;
    if (!active) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showBubble(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Render the element but swallow its own taps while explaining.
          IgnorePointer(child: child),
          // Highlight ring marking it as explainable.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x1AFF7A18),
                  border: Border.all(color: BsTokens.brand, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBubble(BuildContext context) {
    _close(); // one bubble per element
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final origin = box.localToGlobal(Offset.zero);
    final target = origin & box.size;
    final screen = MediaQuery.of(context).size;
    final entry = OverlayEntry(
      builder:
          (_) => _HelpBubble(
            target: target,
            screen: screen,
            title: widget.title,
            body: widget.body,
            onDismiss: _close,
          ),
    );
    _entry = entry;
    overlay.insert(entry);
  }
}

/// Shows the help explanation for an element that can't anchor a tail-bubble
/// out of itself — a bottom-nav tab, a popup-menu entry, anything the
/// [HelpTarget] wrapper can't reach. Same card chrome as [_HelpBubble] (💡 +
/// title + body), centred as a lightweight dialog. Call this from a host's
/// help-mode tap branch while "מצב היכרות" ([helpModeProvider]) is active.
Future<void> showHelpInfo(
  BuildContext context, {
  required String title,
  required String body,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x33000000),
    builder:
        (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(BsTokens.space4),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Theme.of(ctx).brightness == Brightness.dark
                            ? Border.all(color: _kDarkCardEdge)
                            : null,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 20,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  // Scrolls when a long explanation meets a short screen or a
                  // large text scale, instead of overflowing.
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(BsTokens.space4),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: BsTokens.brand,
                            size: 18,
                          ),
                          const SizedBox(width: BsTokens.space2),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: _helpInk(ctx),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: BsTokens.space2),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: _helpMuted(ctx),
                        ),
                      ),
                      const SizedBox(height: BsTokens.space3),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const CfgText('help_target.got_it', 'הבנתי'),
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
  );
}

/// One custom bottom-nav cell (icon + label) — used INSTEAD of a
/// [BottomNavigationBarItem] so each tab can be wrapped in a [HelpTarget]
/// (the built-in nav bar can't carry per-item help). Selected → brand orange,
/// otherwise grey. The InkWell drives navigation; in help mode the wrapping
/// HelpTarget swallows the tap and pops the bubble out of the tab instead.
class BottomNavCell extends StatelessWidget {
  const BottomNavCell({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? BsTokens.brand : const Color(0xFF888888);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme.merge(
            data: IconThemeData(color: color, size: 24),
            child: icon,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: selected ? 12 : 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Test seam for the bubble width rule ([_HelpBubble.bubbleWidthFor]).
@visibleForTesting
double helpBubbleWidthForTest(double screenWidth) =>
    _HelpBubble.bubbleWidthFor(screenWidth);

/// The chat-style speech bubble: a rounded card + a tail that points at the
/// [target] element. Placed below the target when it sits in the top half of
/// the screen, otherwise above it. A full-screen transparent layer dismisses
/// it on an outside tap.
class _HelpBubble extends StatelessWidget {
  const _HelpBubble({
    required this.target,
    required this.screen,
    required this.title,
    required this.body,
    required this.onDismiss,
  });

  final Rect target;
  final Size screen;
  final String title;
  final String body;
  final VoidCallback onDismiss;

  static const double _bubbleW = 270;
  static const double _tailW = 20;
  static const double _tailH = 10;
  static const double _gap = 6;
  static const double _margin = 12;

  /// The bubble width on a screen [screenWidth] wide: the design width,
  /// shrunk so it always keeps [_margin] on both sides. Before this a screen
  /// narrower than 294px made `clamp(min, max)` throw (min > max) on tap.
  static double bubbleWidthFor(double screenWidth) =>
      math.max(0, math.min(_bubbleW, screenWidth - 2 * _margin));

  @override
  Widget build(BuildContext context) {
    final below = target.center.dy < screen.height / 2;
    final bubbleW = bubbleWidthFor(screen.width);

    // Horizontal: centre the bubble on the target, clamped to the screen.
    // Both bounds are ordered (max ≥ min) for every screen width.
    final maxLeft = math.max(_margin, screen.width - bubbleW - _margin);
    final left = (target.center.dx - bubbleW / 2).clamp(_margin, maxLeft);
    // Tail x within the bubble, aligned under/over the target centre.
    final tailCenterX = (target.center.dx - left).clamp(
      _tailW,
      math.max(_tailW, bubbleW - _tailW),
    );

    // Vertical room on the side the bubble opens to — a long explanation
    // scrolls inside the card instead of running off the screen.
    // Status bar / notch / home indicator are not usable room.
    final pad = MediaQuery.paddingOf(context);
    final room =
        below
            ? screen.height - pad.bottom - target.bottom - _gap - _tailH - _margin
            : target.top - pad.top - _gap - _tailH - _margin;
    final surface = Theme.of(context).colorScheme.surface;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final maxCardH = math.max(96, room).toDouble();

    final tail = CustomPaint(
      size: const Size(_tailW, _tailH),
      painter: _TailPainter(pointUp: below, color: surface),
    );

    final card = Container(
      width: bubbleW,
      constraints: BoxConstraints(maxHeight: maxCardH),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        // On a dark page the shadow barely shows — a hairline keeps the
        // card's edge visible. Light mode is unchanged.
        border: dark ? Border.all(color: _kDarkCardEdge) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Semantics(
        liveRegion: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BsTokens.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb, color: BsTokens.brand, size: 18),
                  const SizedBox(width: BsTokens.space2),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _helpInk(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BsTokens.space2),
              Text(
                body,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: _helpMuted(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // A column carrying the tail on the side that faces the target.
    final tailRow = SizedBox(
      width: bubbleW,
      height: _tailH,
      child: Stack(
        children: [Positioned(left: tailCenterX - _tailW / 2, child: tail)],
      ),
    );

    final bubble = Column(
      mainAxisSize: MainAxisSize.min,
      children: below ? [tailRow, card] : [card, tailRow],
    );

    // BlockSemantics: while the bubble is up, a screen reader reads the bubble
    // and its close layer, not the page underneath.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlockSemantics(
        child: Stack(
          children: [
            // Dismiss layer — a tap anywhere outside closes the bubble. Named
            // for screen readers, which otherwise had no way out of it.
            Positioned.fill(
              child: Semantics(
                button: true,
                label: 'סגירת ההסבר',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDismiss,
                  child: const ColoredBox(color: Color(0x0D000000)),
                ),
              ),
            ),
            Positioned(
              left: left,
              top: below ? target.bottom + _gap : null,
              bottom: below ? null : screen.height - target.top + _gap,
              child: Material(color: Colors.transparent, child: bubble),
            ),
          ],
        ),
      ),
    );
  }
}

/// 💡 toggle for "מצב היכרות". A tap flips [helpModeProvider] (and the icon
/// reflects the active state); an optional [onLongPress] lets a host keep a
/// secondary action (e.g. the home app-bar replays the intro tour).
class HelpToggleButton extends ConsumerWidget {
  const HelpToggleButton({this.onLongPress, this.color, super.key});

  final VoidCallback? onLongPress;

  /// Icon colour when inactive (defaults to the brand orange). Pass white when
  /// the button sits on the orange hero.
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(helpModeProvider);
    return GestureDetector(
      onLongPress: onLongPress,
      child: IconButton(
        icon: Icon(
          on ? Icons.lightbulb : Icons.lightbulb_outline,
          color: on ? BsTokens.brandDark : (color ?? BsTokens.brand),
        ),
        tooltip:
            onLongPress == null
                ? 'מצב היכרות'
                : 'מצב היכרות (לחיצה ארוכה: סיור)',
        onPressed: () => ref.read(helpModeProvider.notifier).update((v) => !v),
      ),
    );
  }
}

/// The orange "מצב היכרות" ribbon with an ✕ that exits the mode. Drop it at the
/// top of a screen (render it only while [helpModeProvider] is active).
class HelpModeBanner extends ConsumerWidget {
  const HelpModeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: BsTokens.brand,
      child: Padding(
        // Vertical size comes from the 48dp close target (a11y) — keeps the
        // ribbon height visually unchanged.
        padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
        child: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.white, size: 20),
            const SizedBox(width: BsTokens.space2),
            const Expanded(
              child: CfgText(
                'help_target.banner',
                'מצב היכרות — לחצו על אלמנט מודגש כדי ללמוד מה הוא עושה',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            InkWell(
              onTap: () => ref.read(helpModeProvider.notifier).state = false,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              // ≥48dp tap target (a11y) — icon visuals unchanged.
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a Scaffold body so the "מצב היכרות" banner sits **above** the content
/// (pushing it down) instead of overlaying it — no element gets covered. Use as
/// the Scaffold `body`. The banner shows only while help mode is active.
class HelpModeScaffold extends ConsumerWidget {
  const HelpModeScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(helpModeProvider);
    return Column(
      children: [if (on) const HelpModeBanner(), Expanded(child: child)],
    );
  }
}

/// Small triangular tail for the speech bubble.
class _TailPainter extends CustomPainter {
  _TailPainter({required this.pointUp, required this.color});

  final bool pointUp;

  /// Same fill as the card it hangs off (`colorScheme.surface`) — a fixed
  /// white tail stuck out on the dark card.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointUp) {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0);
    }
    path.close();
    canvas
      ..drawShadow(path, const Color(0x33000000), 3, false)
      ..drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TailPainter old) =>
      old.pointUp != pointUp || old.color != color;
}
