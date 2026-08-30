// 🎨 חוט-תצוגה · PriceTicker — טיקר-מסחר עם מספר מטפס וחץ-מגמה (חוק-1/חוק-5).
// המנוע: הערך מטפס 0→יעד (AnimationController) + חץ-עלייה מהבהב + תווית. אפס-דאטה —
// תווית · גובה · יעד · צבע-מספר/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class PriceTicker extends StatefulWidget {
  const PriceTicker({
    required this.label,
    required this.height,
    required this.target,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final String label;
  final double height;
  final int target;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<PriceTicker> createState() => _PriceTickerState();
}

class _PriceTickerState extends State<PriceTicker> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final v = (widget.target * (0.85 + 0.15 * _c.value)).round();
            return Row(
              children: [
                Icon(Icons.trending_up, color: widget.accentColor, size: widget.height * 0.34),
                const SizedBox(width: 8),
                Text('$v',
                    style: TextStyle(color: widget.accentColor, fontSize: widget.height * 0.4, fontWeight: FontWeight.w900)),
                const Spacer(),
                Text(widget.label, style: TextStyle(color: widget.baseColor.withValues(alpha: 0.7), fontSize: 13)),
              ],
            );
          },
        ),
      );
}
