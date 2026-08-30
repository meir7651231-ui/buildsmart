// 🎨 חוט-תצוגה · NotifItem — פריט-התראה עם אייקון ונקודה-לא-נקראה (חוק-1/חוק-5).
// המנוע: אייקון + כותרת + זמן + נקודת-מבטא פועמת. אפס-דאטה —
// כותרת · זמן · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class NotifItem extends StatefulWidget {
  const NotifItem({required this.title, required this.sub, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String title, sub; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<NotifItem> createState() => _NotifItemState();
}
class _NotifItemState extends State<NotifItem> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Container(
    height: widget.height, padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: widget.accentColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(widget.radius)),
        child: Icon(Icons.notifications, color: widget.accentColor, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(widget.title, style: TextStyle(color: widget.baseColor, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(widget.sub, style: TextStyle(color: widget.baseColor.withValues(alpha: 0.55), fontSize: 12)),
      ])),
      AnimatedBuilder(animation: _c, builder: (context, _) => Container(width: 9, height: 9,
        decoration: BoxDecoration(color: widget.accentColor.withValues(alpha: 0.5 + 0.5 * _c.value), shape: BoxShape.circle))),
    ]));
}
