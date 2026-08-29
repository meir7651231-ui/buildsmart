// 🧼 אטום · JourneyRow — שורת ציר-זמן: נקודה+קו-מחבר, emoji, תווית, זמן-יחסי,
// גלולת-תקוע אופציונלית. מוצא: _JourneyRow (kIntelLive).
// התרת-סבך: intelEventHe/intelEventEmoji/journeyRelTime ⇒ הקופסה מפרמטת
// (label/timeLabel/emoji); stuck ⇒ סלוט stuckPill (TintedTag מה-content) +
// nodeColor=warnBright; תווית-הנגישות מפורמטת בקופסה (journeyContent).
import 'package:flutter/material.dart';

class JourneyRow extends StatelessWidget {
  const JourneyRow({
    required this.emoji, required this.label, required this.timeLabel,
    required this.nodeColor, required this.connectorColor, required this.isLast,
    required this.inkColor, required this.mutedColor,
    required this.gap, required this.rowGap,
    this.stuckPill, this.semanticsLabel, super.key,
  });

  final String emoji, label, timeLabel;
  final Color nodeColor, connectorColor, inkColor, mutedColor;
  final bool isLast;

  /// BsTokens.space2 / BsTokens.space3 במקור.
  final double gap, rowGap;
  final Widget? stuckPill;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticsLabel,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsetsDirectional.only(top: 2),
                    decoration:
                        BoxDecoration(color: nodeColor, shape: BoxShape.circle),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: connectorColor),
                    ),
                ],
              ),
              SizedBox(width: rowGap),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(bottom: rowGap),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 15)),
                      SizedBox(width: gap),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: inkColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (stuckPill != null) ...[
                        stuckPill!,
                        SizedBox(width: gap),
                      ],
                      Text(
                        timeLabel,
                        style: TextStyle(color: mutedColor, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
