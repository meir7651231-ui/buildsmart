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

  Color get _statusColor => switch (status) {
        PureRowStatus.ok => DsPure.ok,
        PureRowStatus.warn => DsPure.warn,
        PureRowStatus.err => DsPure.err,
      };

  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context); // ערכת-האקצנט הפעילה
    final Color bg = selected
        ? theme.a.withValues(alpha: 0.12)
        : zebra
            ? DsPure.ink.withValues(alpha: 0.018)
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
            child: Text(label, style: const TextStyle(color: DsPure.ink, fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: DsPure.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(meta, style: const TextStyle(color: DsPure.mut, fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text(label, style: const TextStyle(color: DsPure.mut, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
