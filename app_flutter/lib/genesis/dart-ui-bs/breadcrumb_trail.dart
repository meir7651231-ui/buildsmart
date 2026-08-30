// 🎨 חוט-תצוגה · BreadcrumbTrail — נתיב-פירורים עם מפרידים (חוק-1/חוק-5).
// המנוע: תוויות-הנתיב עם חצי-הפרדה; האחרונה מודגשת (הפעילה). הקשה מסמנת.
// אפס-דאטה — תוויות · גובה · צבע-פעיל/טקסט/רקע מוזרקים; הבחירה הפנימית שלו.
import 'package:flutter/material.dart';

class BreadcrumbTrail extends StatefulWidget {
  const BreadcrumbTrail({
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
  State<BreadcrumbTrail> createState() => _BreadcrumbTrailState();
}

class _BreadcrumbTrailState extends State<BreadcrumbTrail> {
  int _sel = -1;
  @override
  Widget build(BuildContext context) {
    final labels = widget.labels.isEmpty ? const ['—'] : widget.labels;
    final active = _sel < 0 ? labels.length - 1 : _sel;
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.chevron_left, size: 16, color: widget.baseColor.withValues(alpha: 0.4)),
                ),
              GestureDetector(
                onTap: () => setState(() => _sel = i),
                child: Text(labels[i],
                    style: TextStyle(
                      color: i == active ? widget.accentColor : widget.baseColor.withValues(alpha: 0.7),
                      fontWeight: i == active ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 14,
                    )),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
