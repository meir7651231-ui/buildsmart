// 🎨 חוט-תצוגה · AlertBanner — פס-התראה עם אייקון ופס-מבטא (חוק-1/חוק-5).
// המנוע: פס עם אייקון + הודעה + פס-צד מבטא שפועם עדין (AnimationController).
// אפס-דאטה — תווית · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class AlertBanner extends StatefulWidget {
  const AlertBanner({required this.label, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String label; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<AlertBanner> createState() => _AlertBannerState();
}
class _AlertBannerState extends State<AlertBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: _c, builder: (context, _) => Container(
    height: widget.height, clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: widget.accentColor.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(widget.radius)),
    child: Row(children: [
      Container(width: 4, color: widget.accentColor.withValues(alpha: 0.6 + 0.4 * _c.value)),
      const SizedBox(width: 14),
      Icon(Icons.info_outline, color: widget.accentColor, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text(widget.label, style: TextStyle(color: widget.baseColor, fontSize: 14, fontWeight: FontWeight.w600))),
      const SizedBox(width: 12),
    ])));
}
