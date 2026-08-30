// 🎨 חוט-תצוגה · IconGrid — רשת-אייקונים נבחרים עם קפיצת-בחירה (חוק-1/חוק-5).
// המנוע: רשת אריחי-אייקון; הקשה מסמנת בקפיצת-סקייל וצבע (AnimatedContainer/Scale).
// אפס-דאטה — גובה · מספר-אריחים · צבע-נבחר/אייקון/רקע מוזרקים; הבחירה הפנימית שלו.
import 'package:flutter/material.dart';

class IconGrid extends StatefulWidget {
  const IconGrid({
    required this.height,
    required this.cells,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final double height;
  final int cells;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<IconGrid> createState() => _IconGridState();
}

class _IconGridState extends State<IconGrid> {
  int _sel = 0;
  static const _icons = [
    Icons.home, Icons.star, Icons.favorite, Icons.bolt,
    Icons.camera_alt, Icons.map, Icons.music_note, Icons.settings,
  ];
  @override
  Widget build(BuildContext context) {
    final n = (widget.cells < 1 ? 1 : widget.cells).clamp(1, 8);
    return SizedBox(
      height: widget.height,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
        itemCount: n,
        itemBuilder: (context, i) {
          final on = i == _sel;
          return GestureDetector(
            onTap: () => setState(() => _sel = i),
            child: AnimatedScale(
              scale: on ? 1.08 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: on ? widget.accentColor : widget.fillColor,
                  borderRadius: BorderRadius.circular(widget.radius),
                  border: Border.all(color: widget.accentColor.withValues(alpha: on ? 0 : 0.35)),
                ),
                child: Icon(_icons[i % _icons.length], color: on ? widget.fillColor : widget.baseColor.withValues(alpha: 0.8)),
              ),
            ),
          );
        },
      ),
    );
  }
}
