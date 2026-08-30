// 🎨 חוט-תצוגה · AccordionPanel — פאנלים מתקפלים (פתיחה חלקה) (חוק-1/חוק-5).
// המנוע: הקשה על כותרת פותחת/סוגרת גוף בגובה מונפש (AnimatedCrossFade + חץ מסתובב).
// אפס-דאטה — תוויות-הפאנלים · גובה-שורה · צבע-מבטא/טקסט/רקע מוזרקים; הפתוח הפנימי שלו.
import 'package:flutter/material.dart';

class AccordionPanel extends StatefulWidget {
  const AccordionPanel({
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
  State<AccordionPanel> createState() => _AccordionPanelState();
}

class _AccordionPanelState extends State<AccordionPanel> {
  int _open = 0;

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels.isEmpty ? const ['—'] : widget.labels;
    return Column(
      children: List.generate(labels.length, (i) {
        final open = i == _open;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: widget.fillColor,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: widget.accentColor.withValues(alpha: open ? 0.6 : 0.2),
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => _open = open ? -1 : i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: widget.height,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              color: widget.baseColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(Icons.expand_more,
                              color: widget.accentColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 240),
                crossFadeState: open
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: widget.baseColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                secondChild: const SizedBox(width: double.infinity),
              ),
            ],
          ),
        );
      }),
    );
  }
}
