// 🔌 מנוע-קטלוג-3D · פאזה C (שלב 41, המשך) — turtle-3D וקטורי מלא: פורס `Route`
// למרחב-3D כרצף מיקומים-ומסגרות. פורט ישיר של `buildPlan()` ב-`gen3d.html:322-345`
// (מימוש-הייחוס). מגודר (`features/fittings/`) · טהור · אפס גזירת-פיזיקה חדשה.
//
// מצב-הצב: `P` (מיקום) · `F` (קדימה) · `U` (מעלה). לכל אביזר: מונח במסגרת הנוכחית,
// מתקדם `P += F·ex + bendAxis·ey`, ובברך מסובב `F`/`U` בזווית-הפנייה עם Gram-Schmidt
// (בדיוק כמו gen3d). ה-golden: אבולוציית-המסגרת (ברך-90° → F מ-`[1,0,0]` ל-`[0,1,0]`)
// זהה למקור.

import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/layout/turtle.dart';
import 'package:flutter/foundation.dart' show immutable;

/// וקטור-3D immutable מינימלי (המתמטיקה של ה-turtle · לא תלוי-פלטפורמה).
@immutable
class Vec3 {
  const Vec3(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 scale(double s) => Vec3(x * s, y * s, z * s);
  double dot(Vec3 o) => x * o.x + y * o.y + z * o.z;
  Vec3 cross(Vec3 o) =>
      Vec3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  Vec3 norm() {
    final n = length;
    return n == 0 ? this : scale(1 / n);
  }

  @override
  bool operator ==(Object other) =>
      other is Vec3 && other.x == x && other.y == y && other.z == z;
  @override
  int get hashCode => Object.hash(x, y, z);
  @override
  String toString() =>
      '(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)}, ${z.toStringAsFixed(3)})';
}

/// מיקום-ומסגרת של אביזר יחיד ברצף הפרוס: היכן מרכזו ובאיזו אוריינטציה.
@immutable
class Placement {
  const Placement({
    required this.family,
    required this.od,
    required this.position,
    required this.forward,
    required this.up,
  });
  final String family;
  final int od;
  final Vec3 position; // P בעת ההנחה
  final Vec3 forward; // F
  final Vec3 up; // U
}

/// כיוון-הפנייה (`dirVec` ב-gen3d): up→U · down→−U · right→side · left→−side,
/// כאשר `side = norm(F × U)`.
Vec3 _dirVec(Dir d, Vec3 f, Vec3 u) {
  final side = f.cross(u).norm();
  return switch (d) {
    Dir.down => u.scale(-1),
    Dir.right => side,
    Dir.left => side.scale(-1),
    Dir.up => u,
  };
}

/// פורס `route` לרצף מיקומים-ומסגרות ב-3D (turtle §3). טהור. אביזר לא-פריס
/// (משפחה שאין לה `layoutDeltaFor`) מדולג — fallback, לעולם לא מיקום-שגוי (M1).
/// `terminal` (פקק) סוגר את הרצף. פורט 1:1 מ-`gen3d.buildPlan`.
List<Placement> layoutRoute(List<RunElement> route) {
  var p = const Vec3(0, 0, 0);
  var f = const Vec3(1, 0, 0);
  var u = const Vec3(0, 1, 0);
  final out = <Placement>[];
  for (final el in route) {
    final delta = layoutDeltaFor(el.family.label, el.od, od2: el.od2);
    if (delta == null) continue; // לא-פריס → דלג (fallback)
    final b = _dirVec(el.dir, f, u);
    out.add(Placement(
        family: el.family.label, od: el.od, position: p, forward: f, up: u,),);
    final bendAxis = delta.turn != 0 ? b : u;
    p = p + f.scale(delta.ex) + bendAxis.scale(delta.ey);
    if (delta.turn != 0) {
      final t = delta.turn;
      final nF = (f.scale(math.cos(t)) + b.scale(math.sin(t))).norm();
      final nB = (f.scale(-math.sin(t)) + b.scale(math.cos(t))).norm();
      // gen3d: up→U=nB · down→U=−nB · left/right→U נשמר; ואז Gram-Schmidt.
      var newU = u;
      if (el.dir == Dir.up) {
        newU = nB;
      } else if (el.dir == Dir.down) {
        newU = nB.scale(-1);
      }
      f = nF;
      u = (newU - f.scale(newU.dot(f))).norm(); // Gram-Schmidt: U ⟂ F
    }
    if (delta.terminal) break;
  }
  return out;
}
