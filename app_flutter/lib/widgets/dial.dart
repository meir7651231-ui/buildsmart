import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Dial primitives — the BuildSmart UI law (R2/R3/R4):
///   no full-screen windows for new features; everything is a dial.
///   Every row = circle + label, two separate widgets.
///
/// A DialRow renders a circle (icon or emoji) and a separate pill label
/// to its inline-start side. Stacked vertically by DialColumn — column-reverse
/// so items "rise" from the FAB at the bottom.

class DialRow extends StatelessWidget {
  const DialRow({
    required this.label,
    required this.icon,
    this.onTap,
    this.active = false,
    this.emoji,
    super.key,
  });

  final String label;
  final IconData icon;
  final String? emoji;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = active ? BsTokens.brand : BsTokens.cardDark;
    final fg = active ? Colors.white : BsTokens.brand;

    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BsTokens.radiusCircle),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: BsTokens.dialCircle,
                height: BsTokens.dialCircle,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  boxShadow: BsTokens.circleShadow,
                ),
                child: Center(
                  child: emoji != null
                      ? Text(
                          emoji!,
                          style: const TextStyle(
                            fontSize: BsTokens.dialEmojiSize,
                            height: 1,
                          ),
                        )
                      : Icon(icon, size: BsTokens.dialIconSize, color: fg),
                ),
              ),
              const SizedBox(width: BsTokens.space2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space3,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  boxShadow: BsTokens.labelShadow,
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: active ? Colors.white : BsTokens.inkDark,
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

/// Stacks dial rows so they rise from the FAB (column-reverse in CSS).
/// Adds a staggered fade-in matching .dial__item animation.
class DialColumn extends StatelessWidget {
  const DialColumn({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final reversed = children.reversed.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < reversed.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: BsTokens.space3),
            child: _StaggerIn(
              delay: Duration(milliseconds: 28 * (reversed.length - 1 - i)),
              child: reversed[i],
            ),
          ),
      ],
    );
  }
}

class _StaggerIn extends StatefulWidget {
  const _StaggerIn({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  State<_StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<_StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: BsTokens.dialIn,
    );
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _c, curve: BsTokens.dialCurve),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
