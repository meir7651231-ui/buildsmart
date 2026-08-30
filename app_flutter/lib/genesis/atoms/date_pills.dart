// 🎨 חוט-תצוגה · DatePills — רצועת-תאריכים אופקית עם נבחר (חוק-1/חוק-5).
// המנוע: N גלולות-תאריך; הנבחרת נצבעת (AnimatedContainer). הקשה מסמנת.
// אפס-דאטה — גובה · מספר-ימים · צבע-נבחר/טקסט/רקע מוזרקים; הבחירה הפנימית שלו.
import 'package:flutter/material.dart';
class DatePills extends StatefulWidget {
  const DatePills({required this.height, required this.days, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final double height; final int days; final double radius;
  final Color accentColor, baseColor, fillColor;
  @override State<DatePills> createState() => _DatePillsState();
}
class _DatePillsState extends State<DatePills> {
  int _sel = 2;
  @override Widget build(BuildContext context) {
    final n = (widget.days < 1 ? 1 : widget.days).clamp(1, 14);
    return SizedBox(height: widget.height, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: n,
      itemBuilder: (context, i) {
        final on = i == _sel;
        return GestureDetector(onTap: () => setState(() => _sel = i),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            width: widget.height * 0.7, margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: on ? widget.accentColor : widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 5, height: 5, decoration: BoxDecoration(
                color: on ? widget.fillColor : widget.baseColor.withValues(alpha: 0.4), shape: BoxShape.circle)),
              const SizedBox(height: 5),
              Text('${(i % 28) + 1}', style: TextStyle(color: on ? widget.fillColor : widget.baseColor, fontWeight: FontWeight.w800, fontSize: 15)),
            ])));
      }));
  }
}
