// 🎨 חוט-תצוגה · StarRating — דירוג-כוכבים נלחץ עם קפיצת-מילוי (חוק-1/חוק-5).
// המנוע: שורת כוכבים; הקשה קובעת דירוג, הכוכבים המלאים קופצים (AnimatedScale).
// אפס-דאטה — תווית · גובה · מספר-כוכבים · צבע-מלא/ריק/רקע מוזרקים; הדירוג הפנימי שלו.
import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  const StarRating({
    required this.label,
    required this.height,
    required this.stars,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final String label;
  final double height;
  final int stars;
  final double radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final n = widget.stars < 1 ? 1 : widget.stars;
    final size = widget.height.clamp(20.0, 56.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: TextStyle(
                color: widget.baseColor.withValues(alpha: 0.8), fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(n, (i) {
            final filled = i < _rating;
            return GestureDetector(
              onTap: () => setState(() => _rating = i + 1),
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: AnimatedScale(
                  scale: filled ? 1.15 : 1,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: filled
                        ? widget.accentColor
                        : widget.baseColor.withValues(alpha: 0.4),
                    size: size,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
