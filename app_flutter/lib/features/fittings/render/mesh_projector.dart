// 🔌 מנוע-קטלוג-3D · פאזה C (renderer, שלב 3a) — מקרין-רשתות טהור: world-triangles →
// משולשי-מסך ממוינים (painter's algorithm) עם הצללת-Lambert דו-צדדית. הליבה-הטהורה
// של ה-CustomPainter (הצייר עצמו = wrapper דק). מגודר · הכרטיס-החי לא-נגוע.
//
// הצללה: `N·L` עם `uLight=[0.5,0.9,0.55]` (gen3d:435) + היפוך-נורמל-לעבר-העין
// (`if dot(N,V)<0: N=-N`, gen3d:252) — דו-צדדי כמו המקור. PBR-מלא = שיפור מאוחר.

import 'dart:ui' show Offset, Size;

import 'package:buildsmart/features/fittings/geometry/element_meshes.dart'
    show PartMaterial;
import 'package:buildsmart/features/fittings/geometry/primitives.dart';
import 'package:buildsmart/features/fittings/geometry/route_assembly.dart'
    show WorldPart;
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:buildsmart/features/fittings/render/camera.dart';
import 'package:flutter/foundation.dart' show immutable;

/// כיוון-התאורה של gen3d (`uLight`, `:435`) — verbatim.
const Vec3 kLightDir = Vec3(0.5, 0.9, 0.55);

/// עוצמת-האמביינט (רצפת-ההצללה) — כדי שפאה בצל לא תושחר לגמרי.
const double kAmbient = 0.35;

/// משולש מוכן-לציור: שלוש נקודות-מסך, עומק-מיון (far→near), הצללה ב-[0,1], וחומר.
@immutable
class RenderTriangle {
  const RenderTriangle(this.a, this.b, this.c, this.depth, this.shade,
      {this.mat = PartMaterial.ppr,});
  final Offset a;
  final Offset b;
  final Offset c;
  final double depth; // ממוצע-NDC-z: גדול-יותר = רחוק-יותר
  final double shade; // 0..1 (מוכפל בצבע-הבסיס אצל הצייר)
  final PartMaterial mat; // הצייר בוחר צבע-בסיס לפי החומר
}

/// מקרין רשימת-רשתות (world-space) למשולשי-מסך **ממוינים רחוק→קרוב** עם הצללת-Lambert.
/// משולש עם קודקוד מאחורי-המצלמה (`w≤0`) מדולג (לא-פריס · לעולם לא ציור-שגוי).
List<RenderTriangle> projectMeshes(
  List<Mesh> meshes,
  Mat4 proj,
  Mat4 view,
  Vec3 eye,
  Size size,
) {
  final light = kLightDir.norm();
  final out = <RenderTriangle>[];
  for (final m in meshes) {
    _emit(m, PartMaterial.ppr, proj, view, eye, size, light, out);
  }
  out.sort((x, y) => y.depth.compareTo(x.depth));
  return out;
}

/// כמו [projectMeshes], אך לחלקים-בעלי-חומר (`WorldPart`) — כל משולש נושא את חומר-
/// החלק לצביעה פר-חומר (PP-R / צינור / פליז) אצל הצייר. הפלט ממוין far→near יחד.
List<RenderTriangle> projectParts(
  List<WorldPart> parts,
  Mat4 proj,
  Mat4 view,
  Vec3 eye,
  Size size,
) {
  final light = kLightDir.norm();
  final out = <RenderTriangle>[];
  for (final part in parts) {
    _emit(part.mesh, part.mat, proj, view, eye, size, light, out);
  }
  out.sort((x, y) => y.depth.compareTo(x.depth));
  return out;
}

/// מקרין רשת בודדת ומצרף את משולשיה (עם חומר) ל-[out]. הצללת-Lambert דו-צדדית.
void _emit(
  Mesh m,
  PartMaterial mat,
  Mat4 proj,
  Mat4 view,
  Vec3 eye,
  Size size,
  Vec3 light,
  List<RenderTriangle> out,
) {
  for (var t = 0; t < m.indices.length; t += 3) {
    final i0 = m.indices[t];
    final i1 = m.indices[t + 1];
    final i2 = m.indices[t + 2];
    final w0 = _vertex(m, i0);
    final w1 = _vertex(m, i1);
    final w2 = _vertex(m, i2);
    final s0 = projectToScreen(proj, view, w0, size.width, size.height);
    final s1 = projectToScreen(proj, view, w1, size.width, size.height);
    final s2 = projectToScreen(proj, view, w2, size.width, size.height);
    if (!s0.visible || !s1.visible || !s2.visible) continue; // מאחורי-המצלמה

    final n0 = _normal(m, i0);
    final n1 = _normal(m, i1);
    final n2 = _normal(m, i2);
    var normal = (n0 + n1 + n2).norm();
    final centroid = (w0 + w1 + w2).scale(1 / 3);
    final viewDir = (eye - centroid).norm();
    if (normal.dot(viewDir) < 0) normal = normal.scale(-1); // דו-צדדי (gen3d:252)

    final ndotl = normal.dot(light);
    final lit = ndotl < 0 ? 0.0 : ndotl;
    final shade = kAmbient + (1 - kAmbient) * lit; // ∈ [ambient, 1]
    final depth = (s0.depth + s1.depth + s2.depth) / 3;
    out.add(RenderTriangle(
      Offset(s0.x, s0.y),
      Offset(s1.x, s1.y),
      Offset(s2.x, s2.y),
      depth,
      shade,
      mat: mat,
    ),);
  }
}

/// תיבת-החוסם של אוסף-רשתות: מרכז + רדיוס (למסגור-מצלמה, `:268` ב-gen3d).
/// אוסף-ריק → מרכז-אפס · רדיוס-1 (fallback שפוי, בלי חלוקה-באפס).
({Vec3 center, double radius}) meshBounds(List<Mesh> meshes) {
  var minX = double.infinity;
  var minY = double.infinity;
  var minZ = double.infinity;
  var maxX = double.negativeInfinity;
  var maxY = double.negativeInfinity;
  var maxZ = double.negativeInfinity;
  var any = false;
  for (final m in meshes) {
    for (var v = 0; v < m.vertexCount; v++) {
      any = true;
      final x = m.positions[v * 3];
      final y = m.positions[v * 3 + 1];
      final z = m.positions[v * 3 + 2];
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (z < minZ) minZ = z;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
      if (z > maxZ) maxZ = z;
    }
  }
  if (!any) return (center: const Vec3(0, 0, 0), radius: 1);
  final center = Vec3((minX + maxX) / 2, (minY + maxY) / 2, (minZ + maxZ) / 2);
  final dx = maxX - minX;
  final dy = maxY - minY;
  final dz = maxZ - minZ;
  final radius = 0.5 * (dx > dy ? (dx > dz ? dx : dz) : (dy > dz ? dy : dz));
  return (center: center, radius: radius <= 0 ? 1 : radius);
}

Vec3 _vertex(Mesh m, int i) =>
    Vec3(m.positions[i * 3], m.positions[i * 3 + 1], m.positions[i * 3 + 2]);

Vec3 _normal(Mesh m, int i) =>
    Vec3(m.normals[i * 3], m.normals[i * 3 + 1], m.normals[i * 3 + 2]);
