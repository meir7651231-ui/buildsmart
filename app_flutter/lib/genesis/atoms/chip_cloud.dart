// 🎨 חוט-תצוגה · ChipCloud — ענן-תגיות נבחרות עם קפיצת-בחירה (חוק-1/חוק-5).
// המנוע: הקשה על תגית מסמנת/מבטלת בקפיצת-סקייל וצבע (AnimatedContainer/Scale).
// אפס-דאטה — תוויות · גובה · צבע-נבחר/טקסט/רקע מוזרקים בחיווט; הבחירה הפנימית שלו.
import 'package:flutter/material.dart';

class ChipCloud extends StatefulWidget {
  const ChipCloud({
    required this.labels,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final List<String> labels;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<ChipCloud> createState() => _ChipCloudState();
}

class _ChipCloudState extends State<ChipCloud> {
  final Set<int> _sel = {};

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels.isEmpty ? const ['—'] : widget.labels;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(labels.length, (i) {
        final on = _sel.contains(i);
        return GestureDetector(
          onTap: () => setState(() => on ? _sel.remove(i) : _sel.add(i)),
          child: AnimatedScale(
            scale: on ? 1.06 : 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? widget.accentColor : widget.fillColor,
                borderRadius: BorderRadius.circular(widget.radius),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: on ? 0 : 0.4),
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: on ? widget.fillColor : widget.baseColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
