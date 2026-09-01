// ✨ NeonBars — עמודות אופקיות גרדיאנט-ניאון מנורמלות-למקסימום + ערך טבלאי
import 'package:flutter/material.dart';

class NeonBars extends StatelessWidget {
  const NeonBars({super.key, required this.labels, required this.values});

  final List<String> labels;
  final List<double> values;

  static const Color _bg = Color(0xFF0E0F1E);
  static const Color _track = Color(0xFF1A1B33);
  static const Color _cyan = Color(0xFF22E1FF);
  static const Color _violet = Color(0xFF7A5CFF);
  static const Color _magenta = Color(0xFFFF3DCB);
  static const Color _ink = Color(0xFFEAEBFF);
  static const Color _mute = Color(0xFF8A8CB8);

  @override
  Widget build(BuildContext context) {
    final int n = labels.length < values.length ? labels.length : values.length;
    double maxV = 0;
    for (int i = 0; i < n; i++) {
      if (values[i] > maxV) maxV = values[i];
    }
    if (maxV <= 0) maxV = 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < n; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == n - 1 ? 0 : 16),
                child: _Row(
                  label: labels[i],
                  value: values[i],
                  fraction: (values[i] / maxV).clamp(0.0, 1.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.fraction});

  final String label;
  final double value;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: NeonBars._mute,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Text(
                _fmt(value),
                style: const TextStyle(
                  color: NeonBars._ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, c) {
            final double w = c.maxWidth * fraction;
            return Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: NeonBars._track,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  height: 12,
                  width: w < 12 ? 12 : w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [NeonBars._cyan, NeonBars._violet, NeonBars._magenta],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: NeonBars._violet.withValues(alpha: 0.55),
                        blurRadius: 14,
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: NeonBars._cyan.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}
