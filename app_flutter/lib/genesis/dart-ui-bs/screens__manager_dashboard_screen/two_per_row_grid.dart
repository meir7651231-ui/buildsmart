// 🧼 אטום · TwoPerRowGrid — פריסת שני-אריחים-בשורה (Wrap ברוחב מחושב).
// מוצא: לולאת-הפריסה של _MetricGrid (LayoutBuilder + Wrap). הילדים = MetricTile
// שהקופסה מרכיבה מ-metricTilesContent + managerAnalyticsProvider.
import 'package:flutter/material.dart';

class TwoPerRowGrid extends StatelessWidget {
  const TwoPerRowGrid({required this.children, required this.gap, super.key});

  final List<Widget> children;

  /// BsTokens.space3 במקור.
  final double gap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final tileW = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final t in children) SizedBox(width: tileW, child: t),
            ],
          );
        },
      );
}
