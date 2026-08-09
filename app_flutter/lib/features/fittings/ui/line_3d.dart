// 📦 D12 · תצוגת קוביות-3D — הקו כקוביות איזומטריות במרחב (צילומים #10/#11).
// כל תא-גריד = קובייה; הקו זורם ב-6 כיוונים והטי מסתעף לעומק (הממד השלישי,
// בלתי-אפשרי במישור שטוח). ציור טהור ב-CustomPainter (היטל איזומטרי 2:1, מיון-
// עומק painter's-algorithm, 3 פאות מוצללות). מגודר `kFittingEngine`.

import 'package:buildsmart/features/fittings/engine/grid_cell.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:flutter/material.dart';

const Color _cInk = Color(0xFF232A33);

/// Fitting → cube colour (orange for real fittings, cool grey for pipe-ish).
Color _familyColor(Family f) => switch (f) {
      Family.coupler || Family.reducer || Family.adapter => const Color(0xFFB0BAC6),
      Family.plug => const Color(0xFF3A424C),
      _ => const Color(0xFFEE6A2A),
    };

/// Isometric 3D view of a placed line.
class Line3DView extends StatelessWidget {
  const Line3DView({required this.cells, this.height = 300, super.key});

  final List<GridCell> cells;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('line3d'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            '📦 סודוקו תלת-ממד — הקו זורם ב-6 כיוונים · הטי מסתעף לעומק',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: _cInk),
          ),
        ),
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _IsoPainter(cells)),
        ),
      ],
    );
  }
}

class _IsoPainter extends CustomPainter {
  _IsoPainter(this.cells);

  final List<GridCell> cells;

  static const double s = 44; // cube edge (px)
  double get hw => s * 0.866; // half-width  (cos30)
  double get hh => s * 0.5; // quarter-height (sin30)

  @override
  void paint(Canvas canvas, Size size) {
    if (cells.isEmpty) return;
    // Centre the model.
    final cx = cells.map((c) => c.x).reduce((a, b) => a + b) / cells.length;
    final cy = cells.map((c) => c.y).reduce((a, b) => a + b) / cells.length;
    final ox = size.width / 2 - (cx - cy) * hw;
    final oy = size.height / 2 - (cx + cy) * hh;

    // Painter's algorithm: far cells first (smaller x+y, then lower z).
    final sorted = [...cells]
      ..sort((a, b) {
        final d = (a.x + a.y).compareTo(b.x + b.y);
        return d != 0 ? d : a.z.compareTo(b.z);
      });

    for (final cell in sorted) {
      final px = ox + (cell.x - cell.y) * hw;
      final py = oy + (cell.x + cell.y) * hh - cell.z * s;
      _cube(canvas, px, py, _familyColor(cell.element.family));
    }
  }

  void _cube(Canvas c, double px, double py, Color base) {
    final top = Path()
      ..moveTo(px, py - hh)
      ..lineTo(px + hw, py)
      ..lineTo(px, py + hh)
      ..lineTo(px - hw, py)
      ..close();
    final left = Path()
      ..moveTo(px - hw, py)
      ..lineTo(px, py + hh)
      ..lineTo(px, py + hh + s)
      ..lineTo(px - hw, py + s)
      ..close();
    final right = Path()
      ..moveTo(px, py + hh)
      ..lineTo(px + hw, py)
      ..lineTo(px + hw, py + s)
      ..lineTo(px, py + hh + s)
      ..close();
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 1.5;
    c
      ..drawPath(top, Paint()..color = base)
      ..drawPath(left, Paint()..color = _shade(base, 0.74))
      ..drawPath(right, Paint()..color = _shade(base, 0.58))
      ..drawPath(top, stroke)
      ..drawPath(left, stroke)
      ..drawPath(right, stroke);
  }

  // Darken toward black by (1-f) — avoids the deprecated .red/.green/.blue.
  Color _shade(Color b, double f) => Color.lerp(b, Colors.black, 1 - f) ?? b;

  @override
  bool shouldRepaint(covariant _IsoPainter old) => old.cells != cells;
}
