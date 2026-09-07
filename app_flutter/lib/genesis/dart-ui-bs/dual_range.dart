// 🎨 חוט-תצוגה · DualRange — מחוון-טווח עם שני כדורים (חוק-1/חוק-5).
// המנוע: שני כדורים נגררים על מסלול; החלק ביניהם זוהר.
// תפר-דאטה (G21 · §20-ג): low/high (0–100) = הטווח האמיתי מוזרק בחיווט; גרירה מדווחת onChanged(low, high).
// עיצוב — גובה · צבע-מילוי/כדור/מסלול מוזרקים.
import 'package:flutter/material.dart';
class DualRange extends StatefulWidget {
  const DualRange({required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, required this.low, required this.high, this.onChanged, super.key});
  /// הטווח האמיתי 0–100 (שקע-דאטה).
  final double low, high;
  /// דיווח-גרירה (low, high) ב-0–100.
  final void Function(double low, double high)? onChanged;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<DualRange> createState() => _DualRangeState();
}
class _DualRangeState extends State<DualRange> {
  late double _lo = (widget.low / 100).clamp(0.0, 1.0), _hi = (widget.high / 100).clamp(0.0, 1.0);
  @override void didUpdateWidget(DualRange old) { super.didUpdateWidget(old); if (old.low != widget.low || old.high != widget.high) { _lo = (widget.low / 100).clamp(0.0, 1.0); _hi = (widget.high / 100).clamp(0.0, 1.0); } }
  @override Widget build(BuildContext context) {
    final knob = widget.height.clamp(18.0, 36.0);
    return SizedBox(height: knob, child: LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return Stack(alignment: Alignment.centerLeft, children: [
        Container(height: 8, decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(8))),
        Positioned(left: _lo * w, width: (_hi - _lo) * w, child: Container(height: 8,
          decoration: BoxDecoration(color: widget.accentColor, borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: widget.accentColor.withValues(alpha: 0.5), blurRadius: 8)]))),
        for (final isLo in [true, false])
          Align(alignment: Alignment(((isLo ? _lo : _hi) * 2 - 1), 0),
            child: GestureDetector(
              onHorizontalDragUpdate: (d) => setState(() {
                final v = ((isLo ? _lo : _hi) + d.delta.dx / w).clamp(0.0, 1.0);
                if (isLo) { _lo = v > _hi ? _hi : v; } else { _hi = v < _lo ? _lo : v; }
                widget.onChanged?.call(_lo * 100, _hi * 100);
              }),
              child: Container(width: knob, height: knob,
                decoration: BoxDecoration(color: widget.baseColor, shape: BoxShape.circle,
                  border: Border.all(color: widget.accentColor, width: 2))))),
      ]);
    }));
  }
}
