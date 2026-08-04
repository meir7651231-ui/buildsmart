// 🔌 מנוע-קטלוג-3D · renderer-polish 2 (הצייר) — הצייר + מסך-ה-preview **המגודר**.
// `RoutePainter` (CustomPainter דק) מצייר את משולשי-`projectParts` (חלקים-בעלי-חומר
// מ-`assembleRoute`), צבע פר-חומר (PP-R ירוק · צינור אפור · פליז). `FittingPreview3d`
// מוסיף מסגור-אוטומטי + סיבוב/זום · `FittingPreviewScreen` = מסך-בדיקה.
//
// 🔒 **off-live · מגודר `kFittingEngine3d` (default-OFF).** אף route חי אינו מייבא את
// הקובץ הזה ⇒ tree-shaken. נגיש רק ב-`--dart-define=FITTING_ENGINE_3D=true`.
// **צעד 43 (הכרטיס-החי) = GO-בעלים מפורש.**

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/geometry/element_meshes.dart'
    show PartMaterial;
import 'package:buildsmart/features/fittings/geometry/route_assembly.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:buildsmart/features/fittings/render/camera.dart';
import 'package:buildsmart/features/fittings/render/mesh_projector.dart';
import 'package:flutter/material.dart';

/// צבע-בסיס פר-חומר (מוכפל בגורם-ההצללה פר-משולש). PP-R ירוק · צינור אפור · פליז.
const Color kPprColor = Color(0xFF3F8F46);
const Color kPipeColor = Color(0xFFAAB4BD);
const Color kBrassColor = Color(0xFFC9A24B);

/// רקע-הבמה (כהה) — כדי שהצנרת הירוקה/פליז תבלוט.
const Color kStageBackground = Color(0xFF0E141C);

/// צבע-הבסיס של חומר-חלק.
Color colorForMaterial(PartMaterial mat) => switch (mat) {
      PartMaterial.ppr => kPprColor,
      PartMaterial.pipe => kPipeColor,
      PartMaterial.brass => kBrassColor,
    };

/// צייר-דק: מקבל חלקים-מוכנים (world-space, בעלי-חומר) + פרמטרי-מצלמה, מקרין ומצייר.
/// כל הלוגיקה-הכבדה ב-`projectParts` הטהור (הנבדק-golden); כאן רק רקע + מילוי-משולשים.
class RoutePainter extends CustomPainter {
  RoutePainter({
    required this.parts,
    required this.yaw,
    required this.pitch,
    required this.dist,
    required this.target,
    this.background = kStageBackground,
  });

  final List<WorldPart> parts;
  final double yaw;
  final double pitch;
  final double dist;
  final Vec3 target;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final proj = perspective(kDefaultFov, size.width / size.height, 0.1, 100000);
    final eye = orbitEye(target, dist, yaw, pitch);
    final view = lookAt(eye, target, const Vec3(0, 1, 0));
    final tris = projectParts(parts, proj, view, eye, size);
    final paint = Paint()..style = PaintingStyle.fill;
    for (final t in tris) {
      final base = colorForMaterial(t.mat);
      final s = t.shade.clamp(0.0, 1.0);
      paint.color = Color.fromARGB(
        255,
        (base.r * 255.0 * s).round(),
        (base.g * 255.0 * s).round(),
        (base.b * 255.0 * s).round(),
      );
      canvas.drawPath(
        Path()
          ..moveTo(t.a.dx, t.a.dy)
          ..lineTo(t.b.dx, t.b.dy)
          ..lineTo(t.c.dx, t.c.dy)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RoutePainter old) =>
      old.yaw != yaw ||
      old.pitch != pitch ||
      old.dist != dist ||
      !identical(old.parts, parts) ||
      old.background != background;
}

/// תצוגת-3D אינטראקטיבית של רצף-אביזרים: מסגור-אוטומטי מ-bbox + גרירה-לסיבוב +
/// צביטה-לזום. **מגודר · off-live** — נבנה רק ב-build-preview.
class FittingPreview3d extends StatefulWidget {
  const FittingPreview3d({required this.route, super.key});

  final List<RunElement> route;

  @override
  State<FittingPreview3d> createState() => _FittingPreview3dState();
}

class _FittingPreview3dState extends State<FittingPreview3d> {
  late List<WorldPart> _parts;
  late Vec3 _target;
  late double _dist;
  double _yaw = kDefaultYaw;
  double _pitch = kDefaultPitch;
  double _distAtGestureStart = 0;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void didUpdateWidget(FittingPreview3d old) {
    super.didUpdateWidget(old);
    if (!identical(old.route, widget.route)) _rebuild();
  }

  void _rebuild() {
    _parts = assembleRoute(widget.route);
    final b = meshBounds(_parts.map((p) => p.mesh).toList());
    _target = b.center;
    _dist = b.radius * kFrameDistRatio * 2; // מרווח-נשימה סביב הרצף
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (_) => _distAtGestureStart = _dist,
      onScaleUpdate: (d) {
        setState(() {
          if (d.scale != 1.0) {
            _dist = (_distAtGestureStart / d.scale).clamp(1.0, 1e7);
          }
          _yaw -= d.focalPointDelta.dx * 0.008;
          _pitch = (_pitch + d.focalPointDelta.dy * 0.008).clamp(-1.2, 1.2);
        });
      },
      child: CustomPaint(
        painter: RoutePainter(
          parts: _parts,
          yaw: _yaw,
          pitch: _pitch,
          dist: _dist,
          target: _target,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// מסך-בדיקה מגודר ל-preview (off-live). רצף-ברירת-מחדל להדגמה. **צעד 43 = GO-בעלים.**
class FittingPreviewScreen extends StatelessWidget {
  const FittingPreviewScreen({
    this.route = _demoRoute,
    super.key,
  });

  final List<RunElement> route;

  static const List<RunElement> _demoRoute = [
    RunElement(Family.coupler, 32),
    RunElement(Family.elbow90, 32, dir: Dir.up),
    RunElement(Family.coupler, 32),
    RunElement(Family.elbow90, 32),
    RunElement(Family.plug, 32),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kStageBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2A),
        foregroundColor: Colors.white,
        title: const Text(
          'תצוגה תלת-ממדית · preview (off-live)',
          // Heebo is bundled by the app (pubspec fonts); set it explicitly so the
          // Hebrew title renders correctly even outside the app's ambient theme.
          style: TextStyle(fontFamily: 'Heebo', fontWeight: FontWeight.w700),
        ),
      ),
      body: FittingPreview3d(route: route),
    );
  }
}
