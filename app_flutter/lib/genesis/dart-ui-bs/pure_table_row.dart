// ✨ אטום-תצוגה מפורק (Layer C חי · נספח Spatial) · PureTableRow — שורת-טבלה הלובשת ערכה מהחריץ.
// selected = פס inset-inline-start (RTL) + tint-אקצנט; zebra אופציונלי; עמודת-Value tnum LTR;
// נקודת-Status סמנטית קבועה (ok/warn/err מ-DsPure — לא מורפת). רק האקצנט (פס+tint) מורף דרך
// DsSeam.of(context). התוכן מוזרק — אפס-דומיין (חוק-5/6). material בלבד.
import 'package:flutter/material.dart';
import 'ds/ds_pure.dart';
import 'ds/ds_seam.dart';

enum PureRowStatus { ok, warn, err }

class PureTableRow extends StatelessWidget {
  final String label;
  final String value;
  final String meta;
  final PureRowStatus status;
  final bool selected;
  final bool zebra;
  const PureTableRow({
    super.key,
    required this.label,
    required this.value,
    required this.meta,
    this.status = PureRowStatus.ok,
    this.selected = false,
    this.zebra = false,
  });

  // סמנטי דרך העור — עור-העיצוב מוזרק (חוק-6), לא קבוע באטום.
  Color _statusColor(DsPureSkin skin) => switch (status) {
        PureRowStatus.ok => skin.ok,
        PureRowStatus.warn => skin.warn,
        PureRowStatus.err => skin.err,
      };

  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context); // ערכת-האקצנט הפעילה
    final fonts = DsSeam.fontsOf(context); // חבילת-הפונט הפעילה — פרמטר הפיך
    final skin = DsSeam.skinOf(context); // עור-העיצוב הפעיל (נייטרל+סמנטי) — פרמטר הפיך
    final Color bg = selected
        ? theme.a.withValues(alpha: 0.12)
        : zebra
            ? skin.ink.withValues(alpha: 0.018)
            : Colors.transparent;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      decoration: BoxDecoration(
        color: bg,
        // פס inset-inline-start: ב-RTL הקצה המוביל הוא הימני
        border: selected ? Border(right: BorderSide(color: theme.a, width: 3)) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: TextStyle(color: skin.ink, fontSize: 13, fontFamily: fonts.he)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: skin.ink,
                fontFamily: fonts.grotesk,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(meta, style: TextStyle(color: skin.mut, fontSize: 12, fontFamily: fonts.he)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: _statusColor(skin), shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text(label, style: TextStyle(color: skin.mut, fontSize: 11, fontFamily: fonts.he)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
