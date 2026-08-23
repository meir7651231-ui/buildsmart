// 🧊 מנוע-קטלוג-3D — drop-in **סטטי** של ה-3D האמיתי לעמוד-הגלריה של הכרטיס-הפנימי.
// מקבל רצף-`RunElement` (המוצר + אביזרים-תואמים), מרכיב עם ה-assembler שלי ומצייר
// דרך `RoutePainter` בזווית-קבועה — **בלי מחוות** (אין התנגשות עם PageView/זום של
// הגלריה). זה ה-render המרותך (צנרת · פליז · ברק), לא קוביות-איזומטריות.
//
// 🔒 מגודר (`kFittingEngine3d`) · טהור-widget · אפס-state. ה-CARD מחליף שורה-אחת:
// `Line3DView(cells: …)` → `ProductLine3D(route: …)`. אינטראקציה מלאה = `FittingPreview3d`.

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/geometry/route_assembly.dart';
import 'package:buildsmart/features/fittings/render/camera.dart';
import 'package:buildsmart/features/fittings/render/mesh_projector.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';

/// תצוגת-3D סטטית (לא-אינטראקטיבית) של רצף-אביזרים — מסגור-אוטומטי מ-bbox, זווית
/// ברירת-מחדל של gen3d. רצף-ריק → ריק (הקורא מציג fallback · לעולם לא קורס).
class ProductLine3D extends StatelessWidget {
  const ProductLine3D({
    required this.route,
    this.height = 320,
    this.background = kStageBackground,
    this.borderRadius = 18,
    super.key,
  });

  /// הרצף לרינדור (המוצר + אחים-תואמים) — כפי שהכרטיס כבר בונה עם `runElementFor`.
  final List<RunElement> route;
  final double height;
  final Color background;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final parts = assembleRoute(route);
    if (parts.isEmpty) return SizedBox(height: height);
    final b = meshBounds([for (final p in parts) p.mesh]);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: RoutePainter(
            parts: parts,
            yaw: kDefaultYaw,
            pitch: kDefaultPitch,
            dist: b.radius * kFrameDistRatio * 2,
            target: b.center,
            background: background,
          ),
        ),
      ),
    );
  }
}
