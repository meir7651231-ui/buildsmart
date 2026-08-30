// 🎨 חוט-תצוגה · AvatarStack — ערימת-פרצופים חופפת עם "+N" (חוק-1/חוק-5).
// המנוע: N עיגולי-אווטאר חופפים בגוונים מדורגים; מעל התקרה ⇒ תג "+נותרים". אפס-דאטה —
// גובה · מספר-פרצופים · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class AvatarStack extends StatelessWidget {
  const AvatarStack({
    required this.height,
    required this.faces,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final double height;
  final int faces;
  final double radius;
  final Color accentColor, baseColor, fillColor;

  @override
  Widget build(BuildContext context) {
    final n = faces < 1 ? 1 : faces;
    final show = n > 5 ? 5 : n;
    final d = height.clamp(28.0, 64.0);
    return SizedBox(
      height: d,
      child: Stack(
        children: [
          for (var i = 0; i < show; i++)
            Positioned(
              right: i * d * 0.62,
              child: Container(
                width: d, height: d,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.lerp(baseColor, accentColor, i / show),
                  shape: BoxShape.circle,
                  border: Border.all(color: fillColor, width: 2),
                ),
                child: Text('${i + 1}',
                    style: TextStyle(color: fillColor, fontWeight: FontWeight.w800, fontSize: d * 0.34)),
              ),
            ),
          if (n > show)
            Positioned(
              right: show * d * 0.62,
              child: Container(
                width: d, height: d,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fillColor, shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 2),
                ),
                child: Text('+${n - show}',
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: d * 0.3)),
              ),
            ),
        ],
      ),
    );
  }
}
