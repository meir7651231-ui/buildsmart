// 🎨 חוט-תצוגה · AnimatedTabs — פס-לשוניות עם מחוון-החלקה + החלפת-תוכן (חוק-1/חוק-5).
// המנוע: הלשונית הנבחרת נצבעת ומחליקה, התוכן מתחלף (AnimatedSwitcher). אפס-דאטה —
// תוויות-הלשוניות · גובה · צבע-נבחר/טקסט/רקע מוזרקים בחיווט; הבחירה הפנימית שלו.
import 'package:flutter/material.dart';

class AnimatedTabs extends StatefulWidget {
  const AnimatedTabs({
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
  State<AnimatedTabs> createState() => _AnimatedTabsState();
}

class _AnimatedTabsState extends State<AnimatedTabs> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels.isEmpty ? const ['—'] : widget.labels;
    final sel = _sel.clamp(0, labels.length - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: widget.height,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.fillColor,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: Row(
            children: List.generate(labels.length, (i) {
              final on = i == sel;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _sel = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? widget.accentColor : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(widget.radius * 0.7),
                    ),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        color: on
                            ? widget.fillColor
                            : widget.baseColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: Container(
            key: ValueKey(sel),
            height: widget.height * 1.4,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.fillColor,
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              labels[sel],
              style: TextStyle(
                color: widget.baseColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
