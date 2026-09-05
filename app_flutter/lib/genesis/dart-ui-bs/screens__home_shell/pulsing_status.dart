// 🧼 אטום · PulsingStatus — שורת-סטטוס מהבהבת: נקודה + טקסט בדעיכת-fade חוזרת
// (850ms, easeInOut, 0.35→1). מוצא: _PulsingStatus/_PulsingStatusState
// (screens__home_shell.dart:1828-1884).
// התרת-סבך: catalogSettingsProvider.reducedMotion ⇒ prop reducedMotion (הקופסה
// קוראת; true ⇒ סטטי במלוא-האטימות); bsSuccess(context) ⇒ color; CfgText
// home.status.smarttree ⇒ textSlot (הקופסה מזרימה CfgText; null ⇒ Text(text)).
import 'package:flutter/material.dart';

class PulsingStatus extends StatefulWidget {
  const PulsingStatus({
    required this.text,
    required this.color,
    required this.reducedMotion,
    this.textSlot,
    super.key,
  });

  final String text;
  final Color color;

  /// true ⇒ בלי אנימציה (נעצר במלוא-האטימות) — דין-הנגישות של המקור.
  final bool reducedMotion;

  /// slot-דריסה לטקסט (CfgText בקופסה); null ⇒ Text(text).
  final Widget? textSlot;

  @override
  State<PulsingStatus> createState() => _PulsingStatusState();
}

class _PulsingStatusState extends State<PulsingStatus>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  @override
  void initState() {
    super.initState();
    if (widget.reducedMotion) {
      _ctrl.value = 1;
    } else {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween<double>(
          begin: 0.35,
          end: 1,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: widget.color, size: 7),
            const SizedBox(width: 4),
            widget.textSlot ??
                Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
          ],
        ),
      );
}
