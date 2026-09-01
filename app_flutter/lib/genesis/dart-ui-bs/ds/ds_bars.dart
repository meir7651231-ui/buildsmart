// תרשים-עמודות אופקי (חוט-טהור): תוויות + ערכים ⇒ עמודות מנורמלות-למקסימום. אפס-תלות
// חיצונית (material בלבד), אפס-דאטה. מציג השוואה-חזותית של מדדי-הדשבורד החיים.
import 'package:flutter/material.dart';
import 'ds.dart';

class DsBars extends StatelessWidget {
  const DsBars({required this.labels, required this.values, this.title = '', super.key});
  final List<String> labels;
  final List<double> values;
  final String title;

  @override
  Widget build(BuildContext context) {
    final max = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final safeMax = max <= 0 ? 1.0 : max;
    return Container(
      margin: const EdgeInsets.only(bottom: DsTokens.gap),
      padding: const EdgeInsets.fromLTRB(DsTokens.pad, 16, DsTokens.pad, 16),
      decoration: BoxDecoration(color: DsTokens.card, borderRadius: BorderRadius.circular(DsTokens.r), boxShadow: DsTokens.shadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title.isNotEmpty) Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(title, style: const TextStyle(color: DsTokens.ink, fontSize: 15.5, fontWeight: FontWeight.w800)),
          ),
          for (var i = 0; i < labels.length && i < values.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(width: 96, child: Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.muted, fontSize: 12.5, fontWeight: FontWeight.w600))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(height: 22, decoration: BoxDecoration(color: DsTokens.track, borderRadius: BorderRadius.circular(6))),
                        FractionallySizedBox(
                          widthFactor: (values[i] / safeMax).clamp(0.02, 1.0),
                          child: Container(
                            height: 22,
                            decoration: const BoxDecoration(
                              gradient: DsTokens.neonGrad,
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                              boxShadow: [BoxShadow(color: Color(0x557C3AED), blurRadius: 10, offset: Offset(0, 2))],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 46,
                    child: Text(
                      values[i] == values[i].roundToDouble() ? values[i].toStringAsFixed(0) : values[i].toStringAsFixed(1),
                      textAlign: TextAlign.end,
                      style: const TextStyle(color: DsTokens.ink, fontSize: 13.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
