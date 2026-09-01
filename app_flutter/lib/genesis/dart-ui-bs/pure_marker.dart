// ✨ אטום-תצוגה מפורק (Layer C חי · נספח Spatial) · PureMarker — סמן-מפה הלובש ערכה מהחריץ.
// ארבעה מצבים: normal(מתאר-אקצנט) / selected(מילוי-אקצנט מוגדל) / cluster(עיגול+מונה tnum) /
// disabled(faint). נייטרל/דיו קבועים; רק האקצנט מורף דרך DsSeam.of(context). material בלבד
// (CustomPaint לטיפת-הסמן). התוכן (מונה-האשכול) מוזרק — אפס-דומיין (חוק-5/6).
import 'package:flutter/material.dart';
import 'ds/ds_pure.dart';
import 'ds/ds_seam.dart';

enum PureMarkerState { normal, selected, cluster, disabled }

class PureMarker extends StatelessWidget {
  final PureMarkerState state;
  final int count; // ל-cluster בלבד
  const PureMarker({super.key, this.state = PureMarkerState.normal, this.count = 0});

  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context); // ערכת-האקצנט הפעילה
    if (state == PureMarkerState.cluster) {
      return Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: theme.a, shape: BoxShape.circle),
        child: Text(
          '$count',
          textDirection: TextDirection.ltr,
          style: const TextStyle(
            color: DsPure.sunken,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      );
    }
    final selected = state == PureMarkerState.selected;
    final disabled = state == PureMarkerState.disabled;
    final Color stroke = disabled ? DsPure.faint : theme.aHi;
    return SizedBox(
      width: selected ? 38 : 30,
      height: selected ? 46 : 38,
      child: CustomPaint(
        painter: _PinPainter(
          fill: selected ? theme.a : DsPure.surface,
          stroke: selected ? theme.aHi : (disabled ? DsPure.faint : theme.a),
          dot: selected ? DsPure.sunken : stroke,
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color fill, stroke, dot;
  _PinPainter({required this.fill, required this.stroke, required this.dot});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, cx = w / 2;
    final path = Path()
      ..moveTo(cx, h)
      ..cubicTo(cx - w * 0.5, h * 0.55, cx - w * 0.5, h * 0.1, cx, h * 0.1)
      ..cubicTo(cx + w * 0.5, h * 0.1, cx + w * 0.5, h * 0.55, cx, h);
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(Offset(cx, h * 0.32), 3.6, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_PinPainter old) => old.fill != fill || old.stroke != stroke || old.dot != dot;
}
