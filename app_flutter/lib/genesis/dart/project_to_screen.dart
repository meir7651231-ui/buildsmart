// ⚛️ אטום-Dart (דרגת-חוזה) · projectToScreen
// מוצא: buildsmart/app_flutter/lib/features/fittings/render/camera.dart:102-118 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית, אפס import (רק dart:core). מתמטיקה טהורה,
//        בלי Flutter/canvas.
//
// אחים שהוטבעו (טיפוסי-שכן, כלל-1):
//   • `Vec3` — מ-route_layout.dart:18, רק `x`/`y`/`z` (מתודות-הווקטור הושמטו).
//   • `Mat4` — מ-camera.dart, `m` + `mul` + `apply` (מתמטיקה טהורה verbatim).
//   • `ScreenPoint` — מ-camera.dart, constructor + שדות + getter `visible`.
//
// קלט:  proj/view — מטריצות column-major; world — נקודת-עולם; width/height — מסך.
// פלט:  נקודת-מסך (NDC→פיקסלים, ציר-Y מתהפך).

/// טיפוס-שכן מוטבע (route_layout.dart:18) — רק x/y/z.
class Vec3 {
  const Vec3(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}

/// טיפוס-שכן מוטבע (camera.dart) — מטריצה column-major (`m[col*4 + row]`).
class Mat4 {
  const Mat4(this.m);
  final List<double> m; // אורך 16

  /// מכפלה `this·b` (column-major).
  Mat4 mul(Mat4 b) {
    final o = List<double>.filled(16, 0);
    for (var c = 0; c < 4; c++) {
      for (var r = 0; r < 4; r++) {
        var s = 0.0;
        for (var k = 0; k < 4; k++) {
          s += m[k * 4 + r] * b.m[c * 4 + k];
        }
        o[c * 4 + r] = s;
      }
    }
    return Mat4(o);
  }

  /// מחיל את המטריצה על נקודה הומוגנית `(p, w)` → `(x, y, z, w)`.
  ({double x, double y, double z, double w}) apply(Vec3 p, {double w = 1}) {
    final x = m[0] * p.x + m[4] * p.y + m[8] * p.z + m[12] * w;
    final y = m[1] * p.x + m[5] * p.y + m[9] * p.z + m[13] * w;
    final z = m[2] * p.x + m[6] * p.y + m[10] * p.z + m[14] * w;
    final ww = m[3] * p.x + m[7] * p.y + m[11] * p.z + m[15] * w;
    return (x: x, y: y, z: z, w: ww);
  }
}

/// טיפוס-שכן מוטבע (camera.dart) — נקודת-מסך.
class ScreenPoint {
  const ScreenPoint(this.x, this.y, this.depth, this.w);
  final double x;
  final double y;
  final double depth; // NDC-z
  final double w; // clip-w
  bool get visible => w > 0;
}

/// מקרין נקודת-עולם למסך `width×height` דרך `proj·view`. טהור.
ScreenPoint projectToScreen(
  Mat4 proj,
  Mat4 view,
  Vec3 world,
  double width,
  double height,
) {
  final clip = proj.mul(view).apply(world);
  if (clip.w == 0) return const ScreenPoint(0, 0, 0, 0);
  final ndcX = clip.x / clip.w;
  final ndcY = clip.y / clip.w;
  final ndcZ = clip.z / clip.w;
  final sx = (ndcX * 0.5 + 0.5) * width;
  final sy = (1 - (ndcY * 0.5 + 0.5)) * height;
  return ScreenPoint(sx, sy, ndcZ, clip.w);
}
