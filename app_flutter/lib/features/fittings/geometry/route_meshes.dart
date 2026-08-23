// 🔌 מנוע-קטלוג-3D · פאזה C (renderer, שלב 1) — רשתות-מסלול במרחב-עולם. לכל אביזר
// ברצף: צינור בגודל-ה-envelope, מונח במסגרת-הפריסה (F/U/side) של ה-turtle — טרנספורם
// **וקטורי טהור** (בלי מטריצות · נמוך-סיכון). מגודר · טהור · הכרטיס-החי לא-נגוע.
//
// זהו ה-preview: רצף-צילינדרים מנותב ב-3D, נאמן-לפריסה. שכבת-ה-render (CustomPainter)
// מטילה אותו למסך. פירוט-מלא (elemMeshes פר-משפחה) = שיפור מאוחר.

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/geometry/primitives.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart';
import 'package:buildsmart/features/fittings/plan/envelope.dart';

/// בונה רשת-preview לכל אביזר ברצף (world-space). כל אביזר = צינור בגודל-ה-envelope
/// (קוטר רדיאלי · אורך-ציר) מונח במסגרת-הפריסה. אביזר ללא-envelope מדולג (M1).
List<Mesh> buildRoutePreviewMeshes(List<RunElement> route) {
  final out = <Mesh>[];
  for (final pl in layoutRoute(route)) {
    final env = envelopeFor(pl.family, pl.od);
    if (env == null) continue; // לא-פריס → דלג (fallback)
    final ro = env.radialDiameter / 2;
    // צינור מקומי לאורך ציר-X; דופן ~0.6 מהרדיוס (מראה-פנים חלול לתצוגה).
    final local = tube(0, env.axialLength, ro, ro * 0.6);
    out.add(_placeInFrame(local, pl.position, pl.forward, pl.up));
  }
  return out;
}

/// טרנספורם רשת-מקומית למרחב-עולם דרך מסגרת (P, F, U): מקומי-X→F · Y→U · Z→side,
/// כאשר `side = norm(F × U)`. נורמלים מסובבים בלבד (בלי הזזה). וקטורי טהור.
Mesh _placeInFrame(Mesh local, Vec3 p, Vec3 f, Vec3 u) {
  final side = f.cross(u).norm();
  final wp = <double>[];
  final wn = <double>[];
  for (var v = 0; v < local.vertexCount; v++) {
    final lx = local.positions[v * 3];
    final ly = local.positions[v * 3 + 1];
    final lz = local.positions[v * 3 + 2];
    final w = p + f.scale(lx) + u.scale(ly) + side.scale(lz);
    wp.addAll([w.x, w.y, w.z]);
    final nx = local.normals[v * 3];
    final ny = local.normals[v * 3 + 1];
    final nz = local.normals[v * 3 + 2];
    final n = (f.scale(nx) + u.scale(ny) + side.scale(nz)).norm();
    wn.addAll([n.x, n.y, n.z]);
  }
  return Mesh(wp, wn, local.indices);
}
