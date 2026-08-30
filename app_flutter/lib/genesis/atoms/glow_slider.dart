// 🎨 חוט-תצוגה · GlowSlider — מחוון עם מסלול-זוהר וכדור-נגרר (חוק-1/חוק-5).
// המנוע: גרירה אופקית מעדכנת ערך 0..1; החלק-המלא זוהר. אפס-דאטה —
// תווית · גובה · צבע-מילוי/כדור/מסלול מוזרקים; הערך הפנימי שלו.
import 'package:flutter/material.dart';

class GlowSlider extends StatefulWidget {
  const GlowSlider({
    required this.label,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final String label;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<GlowSlider> createState() => _GlowSliderState();
}

class _GlowSliderState extends State<GlowSlider> {
  double _v = 0.4;

  @override
  Widget build(BuildContext context) {
    final trackH = 8.0;
    final knob = widget.height.clamp(18.0, 40.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: TextStyle(
                color: widget.baseColor.withValues(alpha: 0.8), fontSize: 13)),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            void setFromDx(double dx) =>
                setState(() => _v = (dx / w).clamp(0.0, 1.0));
            return GestureDetector(
              onHorizontalDragUpdate: (d) => setFromDx(d.localPosition.dx),
              onTapDown: (d) => setFromDx(d.localPosition.dx),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: knob,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: trackH,
                      decoration: BoxDecoration(
                        color: widget.fillColor,
                        borderRadius: BorderRadius.circular(trackH),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: _v,
                      child: Container(
                        height: trackH,
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          borderRadius: BorderRadius.circular(trackH),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(_v * 2 - 1, 0),
                      child: Container(
                        width: knob,
                        height: knob,
                        decoration: BoxDecoration(
                          color: widget.baseColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: widget.accentColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
