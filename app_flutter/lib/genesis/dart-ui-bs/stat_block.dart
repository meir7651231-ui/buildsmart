// 🎨 חוט-תצוגה · StatBlock — שורת-מדדים מרוכזת (חוק-1/חוק-5).
// המנוע: N מדדי-מיני זה-לצד-זה, ערך + תווית.
// תפר-דאטה (G21 · §20-ג): values = הערכים האמיתיים (מקבילים ל-labels) מוזרקים בחיווט — לא מומצאים.
// עיצוב — גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class StatBlock extends StatelessWidget {
  const StatBlock({required this.labels, required this.values, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final List<String> labels;
  /// הערכים האמיתיים, אחד לכל תווית (שקע-דאטה).
  final List<num> values;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override Widget build(BuildContext context) {
    final ls = labels.isEmpty ? const ['—'] : labels;
    return Container(height: height, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(radius * 1.2)),
      child: Row(children: [
        for (var i = 0; i < ls.length; i++) Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(i < values.length ? '${values[i]}' : '—',
            style: TextStyle(color: accentColor, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(ls[i], style: TextStyle(color: baseColor.withValues(alpha: 0.65), fontSize: 12),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ]));
  }
}
