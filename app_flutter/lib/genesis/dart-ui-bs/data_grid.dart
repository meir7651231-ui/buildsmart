// 🎨 חוט-תצוגה · DataGrid — טבלה קטנה ששורותיה נכנסות בהדרגה (חוק-1/חוק-5).
// המנוע: כותרת + N שורות שמחליקות פנימה מדורג (Interval פר-שורה), טור-מבטא מודגש.
// אפס-דאטה — מספר-שורות · גובה-שורה · צבע-מבטא/טקסט/רקע מוזרקים; נכנס בטעינה.
import 'package:flutter/material.dart';

class DataGrid extends StatefulWidget {
  const DataGrid({
    required this.height,
    required this.rows,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final double height;
  final int rows;
  final double radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  Widget _cell(double flex, Color c, {bool strong = false}) => Expanded(
        flex: (flex * 10).round(),
        child: Container(
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: strong ? c : c.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.rows < 1 ? 1 : widget.rows;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.fillColor,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: Column(
        children: [
          SizedBox(
            height: widget.height,
            child: Row(
              children: [
                _cell(1.6, widget.accentColor, strong: true),
                _cell(1, widget.accentColor, strong: true),
                _cell(1, widget.accentColor, strong: true),
              ],
            ),
          ),
          ...List.generate(n, (i) {
            final start = (i / n) * 0.6;
            final anim = CurvedAnimation(
              parent: _c,
              curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
                  curve: Curves.easeOut),
            );
            return FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: i.isEven
                        ? widget.baseColor.withValues(alpha: 0.04)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      _cell(1.6, widget.baseColor),
                      _cell(1, widget.accentColor, strong: true),
                      _cell(1, widget.baseColor),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
