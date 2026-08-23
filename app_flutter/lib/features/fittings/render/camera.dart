// 🔌 מנוע-קטלוג-3D · פאזה C (renderer, שלב 2) — מצלמה/היטל טהורים. פורט 1:1 מ-
// `gen3d.html:140-142` (`persp`/`look`) + `:426` (`eye`). מטריצות **column-major**
// בדיוק כמו gen3d. מגודר · טהור (בלי Flutter/canvas) · הכרטיס-החי לא-נגוע.
//
// זה הליבה-הניתנת-לבדיקה של ה-render: world-point → מסך. שכבת-הציור (CustomPainter)
// = הפרוסה-הבאה; היא צורכת את `projectToScreen` בלבד. אפס גזירת-פיזיקה חדשה.

import 'dart:math' as math;

import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:flutter/foundation.dart' show immutable;

/// מטריצת 4×4 **column-major** (`m[col*4 + row]`) — בדיוק פריסת gen3d (`Float32Array`).
@immutable
class Mat4 {
  const Mat4(this.m);
  final List<double> m; // אורך 16

  /// מכפלה `this·b` (column-major) — פורט 1:1 מ-`M.mul` ב-gen3d.
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

/// היטל-פרספקטיבה — פורט 1:1 מ-`M.persp(f, as, n, fa)` ב-gen3d (`:140`).
/// `fov` ברדיאנים · `aspect = W/H` · מישורי-חיתוך `near`/`far`.
Mat4 perspective(double fov, double aspect, double near, double far) {
  final t = 1 / math.tan(fov / 2);
  final m = List<double>.filled(16, 0);
  m[0] = t / aspect;
  m[5] = t;
  m[10] = (far + near) / (near - far);
  m[11] = -1;
  m[14] = 2 * far * near / (near - far);
  return Mat4(m);
}

/// מטריצת-מבט (look-at) — פורט 1:1 מ-`M.look(e, c, u)` ב-gen3d (`:141`).
Mat4 lookAt(Vec3 eye, Vec3 center, Vec3 up) {
  var z = eye - center;
  z = z.norm();
  var x = up.cross(z);
  final xl = x.length;
  x = xl == 0 ? x : x.scale(1 / xl);
  final y = z.cross(x);
  return Mat4([
    x.x, y.x, z.x, 0, //
    x.y, y.y, z.y, 0, //
    x.z, y.z, z.z, 0, //
    -x.dot(eye), -y.dot(eye), -z.dot(eye), 1, //
  ]);
}

/// מיקום-העין במסלול-מסלול (orbit) סביב `target` — פורט 1:1 מ-`eye()` ב-gen3d (`:426`).
Vec3 orbitEye(Vec3 target, double dist, double yaw, double pitch) => Vec3(
      target.x + dist * math.cos(pitch) * math.sin(yaw),
      target.y + dist * math.sin(pitch),
      target.z + dist * math.cos(pitch) * math.cos(yaw),
    );

/// זווית/מרחק ברירת-המחדל של gen3d (`yaw=-0.6 · pitch=0.26 · fov=0.72`, `:425/434`).
const double kDefaultYaw = -0.6;
const double kDefaultPitch = 0.26;
const double kDefaultFov = 0.72;

/// יחס-המסגור של gen3d: `DIST = rad·2.7` (`:268`, בלי סקאלת-`S` — היחס סקאלה-חסין).
const double kFrameDistRatio = 2.7;

/// נקודה-מוקרנת: פיקסלי-מסך (`x`,`y`) + עומק ל-painter's-algorithm + `w` (clip).
/// `w ≤ 0` ⇒ מאחורי-המצלמה (הקורא מדלג).
@immutable
class ScreenPoint {
  const ScreenPoint(this.x, this.y, this.depth, this.w);
  final double x;
  final double y;
  final double depth; // NDC-z: קטן-יותר = קרוב-יותר
  final double w; // clip-w: >0 ⇒ לפני-המצלמה
  bool get visible => w > 0;
}

/// מקרין נקודת-עולם למסך `W×H` דרך `proj·view` (בדיוק כמו ה-shader ב-gen3d:
/// `uProj * uView * pos`). NDC→פיקסלים, ציר-Y מתהפך (מסך יורד-כלפי-מטה).
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
