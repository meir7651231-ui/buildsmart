// ✨ אטום-תצוגה מפורק (Layer C חי · נספח Temporal) · PureDateCell — תא-יום הלובש ערכה מהחריץ.
// חמישה מצבים: normal / today(טבעת-אקצנט) / selected(מילוי-אקצנט) / event(נקודת-אקצנט) / disabled(faint).
// נייטרל/דיו קבועים (DsPure); רק ערכת-האקצנט מורפת דרך DsSeam.of(context) (חוק-5/6). המספר מוזרק,
// LTR + tnum; האטום לא יודע זהות/דומיין. material בלבד.
import 'package:flutter/material.dart';
import 'ds/ds_pure.dart';
import 'ds/ds_seam.dart';

enum PureDateState { normal, today, selected, event, disabled }

class PureDateCell extends StatelessWidget {
  final int day;
  final PureDateState state;
  final double size;
  const PureDateCell({
    super.key,
    required this.day,
    this.state = PureDateState.normal,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context); // ערכת-האקצנט הפעילה — הזרקת-חיווט
    final selected = state == PureDateState.selected;
    final today = state == PureDateState.today;
    final disabled = state == PureDateState.disabled;
    final Color textColor = selected
        ? DsPure.sunken
        : today
            ? theme.aHi
            : disabled
                ? DsPure.faint
                : DsPure.ink;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : null,
        border: today ? Border.all(color: theme.aHi, width: 1.5) : null,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$day',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: textColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (state == PureDateState.event)
            Positioned(
              bottom: 5,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: theme.a, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}
