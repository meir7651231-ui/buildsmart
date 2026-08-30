// 🎨 חוט-תצוגה · SegPicker — בורר-מקטעים עם מחוון-החלקה (חוק-1/חוק-5).
// המנוע: כדור-בחירה מחליק מתחת למקטע-הנבחר (AnimatedAlign). אפס-דאטה —
// תוויות · גובה · צבע-נבחר/טקסט/רקע מוזרקים; הבחירה הפנימית שלו.
import 'package:flutter/material.dart';

class SegPicker extends StatefulWidget {
  const SegPicker({
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
  State<SegPicker> createState() => _SegPickerState();
}

class _SegPickerState extends State<SegPicker> {
  int _sel = 0;
  @override
  Widget build(BuildContext context) {
    final labels = widget.labels.isEmpty ? const ['—'] : widget.labels;
    final sel = _sel.clamp(0, labels.length - 1);
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
      child: LayoutBuilder(
        builder: (context, c) {
          final segW = c.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: Alignment(labels.length == 1 ? 0 : (sel / (labels.length - 1)) * 2 - 1, 0),
                child: Container(
                  width: segW,
                  height: double.infinity,
                  decoration: BoxDecoration(color: widget.accentColor, borderRadius: BorderRadius.circular(widget.radius * 0.7)),
                ),
              ),
              Row(
                children: List.generate(labels.length, (i) {
                  final on = i == sel;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _sel = i),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(labels[i],
                            style: TextStyle(
                              color: on ? widget.fillColor : widget.baseColor.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w700, fontSize: 14,
                            )),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
