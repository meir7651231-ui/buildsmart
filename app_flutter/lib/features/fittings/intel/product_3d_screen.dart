// 🧠 מנוע-אביזרים · פאזה D slice 3 — יכולת "הצג-בתלת-ממד" (כפתור-עצמאי). מוצר-קטלוג
// בודד → תצוגת-3D (`FittingPreview3d`) **+ מפרט-המנוע המלא** (`buildableSpecFor`:
// מידות · קצוות · שיטת-חיבור · ריתוך+caveat · בטיחות-קו-חם · תקנים). מגודר · off-live.
//
// 🔒 אף route חי אינו מייבא את הקובץ הזה ⇒ tree-shaken ⇒ הזרימה החיה byte-identical.
// מקורקע: `routeFromProducts` (D1 · גשר) + `buildableSpecFor` (פאזה B) + C6 (3D).

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/fittings/engine/catalog_map.dart';
import 'package:buildsmart/features/fittings/intel/line_planner.dart';
import 'package:buildsmart/features/fittings/plan/buildable_spec.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';

/// מסך "הצג-בתלת-ממד" למוצר בודד: 3D למעלה + לוח-מפרט למטה. אביזר לא-פריס-במנוע
/// (`routeFromProducts` ריק) → מציג לוח-מפרט/הודעה בלי 3D, לעולם לא קורס (M1).
class Product3dScreen extends StatelessWidget {
  const Product3dScreen({required this.product, this.tempC = 20, super.key});

  final LipskeyCatalogProduct product;
  final int tempC;

  @override
  Widget build(BuildContext context) {
    final route = routeFromProducts([product]);
    final family = familyOf(product);
    final od = odOf(product);
    final spec = (family != null && od != null)
        ? buildableSpecFor(family, od, od2: od2Of(product), tempC: tempC)
        : null;

    return Scaffold(
      backgroundColor: kStageBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2A),
        foregroundColor: Colors.white,
        title: const Text(
          'הצג בתלת-ממד · preview (off-live)',
          style: TextStyle(fontFamily: 'Heebo', fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: route.isEmpty
                ? const Center(
                    child: Text(
                      'האביזר אינו פריס-במנוע (fallback לתמונה)',
                      style: TextStyle(fontFamily: 'Heebo', color: Colors.white70),
                    ),
                  )
                : FittingPreview3d(route: route),
          ),
          const Divider(height: 1, color: Color(0xFF26333F)),
          Expanded(flex: 2, child: _SpecPanel(product: product, spec: spec)),
        ],
      ),
    );
  }
}

/// לוח-מפרט קריא: כותרת · מידות-מפתח · שיטות-חיבור · ריתוך(+caveat) · בטיחות · תקנים.
class _SpecPanel extends StatelessWidget {
  const _SpecPanel({required this.product, required this.spec});

  final LipskeyCatalogProduct product;
  final BuildableSpec? spec;

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(fontFamily: 'Heebo', color: Colors.white70, fontSize: 12);
    const value = TextStyle(fontFamily: 'Heebo', color: Colors.white, fontSize: 13);
    final s = spec;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(product.nameHe,
              style: const TextStyle(
                fontFamily: 'Heebo',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),),
          const SizedBox(height: 8),
          if (s == null)
            const Text('אין מפרט-מנוע למוצר זה', style: label)
          else ...[
            Text('משפחה: ${s.family} · קוטר: ${s.od}'
                '${s.od2 != null ? '→${s.od2}' : ''}', style: value,),
            const SizedBox(height: 6),
            const Text('שיטות-חיבור', style: label),
            Text(s.connectionMethods.isEmpty ? '—' : s.connectionMethods.join(' · '),
                style: value,),
            const SizedBox(height: 6),
            const Text('ריתוך (ערכי-ייחוס)', style: label),
            Text(
              s.weld == null
                  ? 'מחוץ-לטבלה'
                  : 'ראש ${s.weld!.headTempC}°C · ${s.weld!.caveat}',
              style: value,
            ),
            const SizedBox(height: 6),
            const Text('בטיחות קו-חם', style: label),
            Text(
              s.hotLineSafety.isEmpty
                  ? 'לא-נדרשת (קו-קר)'
                  : s.hotLineSafety.map((a) => a.title).join(' · '),
              style: value,
            ),
            const SizedBox(height: 6),
            const Text('תקנים', style: label),
            Text(s.standards.isEmpty ? '—' : s.standards.join(' · '), style: value),
          ],
        ],
      ),
    );
  }
}
