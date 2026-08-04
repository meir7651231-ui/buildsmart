// 🔌 מנוע-קטלוג-3D · פאזה C (renderer, שלב 3b) — הצייר + מסך-ה-preview **המגודר**.
// `RoutePainter` (CustomPainter דק) מצייר את משולשי-`projectMeshes` · `FittingPreview3d`
// מוסיף מסגור-אוטומטי + סיבוב/זום (gestures) · `FittingPreviewScreen` = מסך-בדיקה.
//
// 🔒 **off-live · מגודר `kFittingEngine3d` (default-OFF).** אף route חי אינו מייבא את
// הקובץ הזה ⇒ tree-shaken מ-build-הפרודקשן. נגיש רק ב-build-preview
// (`--dart-define=FITTING_ENGINE_3D=true`). **צעד 43 (הכרטיס-החי) = GO-בעלים מפורש.**

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/geometry/primitives.dart';
import 'package:buildsmart/features/fittings/geometry/route_meshes.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:buildsmart/features/fittings/render/camera.dart';
import 'package:buildsmart/features/fittings/render/mesh_projector.dart';
import 'package:flutter/material.dart';

/// צבע-הבסיס של האביזר (מוכפל בגורם-ההצללה פר-משולש) — ירוק-PP-R.
const Color kFittingBaseColor = Color(0xFF3F8F46);

/// צייר-דק: מקבל רשתות-מוכנות (world-space) + פרמטרי-מצלמה, מקרין ומצייר.
/// כל הלוגיקה-הכבדה ב-`projectMeshes` הטהור (הנבדק-golden); כאן רק מילוי-משולשים.
class RoutePainter extends CustomPainter {
  RoutePainter({
    required this.meshes,
    required this.yaw,
    required this.pitch,
    required this.dist,
    required this.target,
    this.baseColor = kFittingBaseColor,
  });

  final List<Mesh> meshes;
  final double yaw;
  final double pitch;
  final double dist;
  final Vec3 target;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final proj = perspective(kDefaultFov, size.width / size.height, 0.1, 100000);
    final eye = orbitEye(target, dist, yaw, pitch);
    final view = lookAt(eye, target, const Vec3(0, 1, 0));
    final tris = projectMeshes(meshes, proj, view, eye, size);
    final paint = Paint()..style = PaintingStyle.fill;
    for (final t in tris) {
      final path = Path()
        ..moveTo(t.a.dx, t.a.dy)
        ..lineTo(t.b.dx, t.b.dy)
        ..lineTo(t.c.dx, t.c.dy)
        ..close();
      // צבע-הבסיס מעומעם בגורם-ההצללה (Lambert דו-צדדי).
      final s = t.shade.clamp(0.0, 1.0);
      paint.color = Color.fromARGB(
        255,
        (baseColor.r * 255.0 * s).round(),
        (baseColor.g * 255.0 * s).round(),
        (baseColor.b * 255.0 * s).round(),
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(RoutePainter old) =>
      old.yaw != yaw ||
      old.pitch != pitch ||
      old.dist != dist ||
      !identical(old.meshes, meshes) ||
      old.baseColor != baseColor;
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
  late List<Mesh> _meshes;
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
    _meshes = buildRoutePreviewMeshes(widget.route);
    final b = meshBounds(_meshes);
    _target = b.center;
    _dist = b.radius * kFrameDistRatio * 2; // מרווח-נשימה סביב האביזר
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
          meshes: _meshes,
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
      appBar: AppBar(title: const Text('תצוגת-3D · preview (off-live)')),
      body: FittingPreview3d(route: route),
    );
  }
}
