// 🧠 מנוע-אביזרים · פאזה D slice 6 — capstone "תוכנית-בנייה" (יכולת-מאחורי-כפתור).
// מאחד לרצף-אביזרים: **תצוגת-3D** (C6) + **סיכום-רצף** + **כתב-חיתוך** (D5, אורכי-צינור
// פר-מרווח). זהו הכפתור שמציג את ה-cut-list. מגודר · off-live · הזרימה החיה byte-identical.
//
// 🔒 אף route חי אינו מייבא `intel/` ⇒ tree-shaken. מרכיב `cutListUniform` (מקורקע ב-
// cut_list פאזה B) + `FittingPreview3d`. מרחק-מרכזים = נומינלי לתצוגה (קלט-תכן אמיתי בהמשך).

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/intel/line_cuts.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';

/// מסך "תוכנית-בנייה": 3D + סיכום-רצף + טבלת-כתב-חיתוך. מרחק-מרכזים נומינלי (מוגדר).
class BuildPlanScreen extends StatelessWidget {
  const BuildPlanScreen({
    this.route = _demoRoute,
    this.nominalSpacing = 200,
    super.key,
  });

  final List<RunElement> route;
  final double nominalSpacing;

  static const List<RunElement> _demoRoute = [
    RunElement(Family.coupler, 50),
    RunElement(Family.elbow90, 50, dir: Dir.up),
    RunElement(Family.tee, 50),
    RunElement(Family.reducer, 50, od2: 32),
    RunElement(Family.coupler, 32),
    RunElement(Family.elbow90, 32, dir: Dir.down),
    RunElement(Family.plug, 32),
  ];

  @override
  Widget build(BuildContext context) {
    final cuts = cutListUniform(route, nominalSpacing);
    return Scaffold(
      backgroundColor: kStageBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2A),
        foregroundColor: Colors.white,
        title: const Text(
          'תוכנית-בנייה · preview (off-live)',
          style: TextStyle(fontFamily: 'Heebo', fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(flex: 3, child: FittingPreview3d(route: route)),
          const Divider(height: 1, color: Color(0xFF26333F)),
          Expanded(
            flex: 2,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  const Text('כתב-חיתוך (אורכי-צינור פר-מרווח)',
                      style: TextStyle(
                          fontFamily: 'Heebo',
                          color: Colors.white70,
                          fontSize: 12,),),
                  const SizedBox(height: 8),
                  if (cuts.isEmpty)
                    const Text('אין מרווחי-צינור ברצף',
                        style: TextStyle(
                            fontFamily: 'Heebo', color: Colors.white54,),)
                  else
                    for (final c in cuts) _CutTile(seg: c),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CutTile extends StatelessWidget {
  const _CutTile({required this.seg});
  final CutSegment seg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF23303D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${seg.cutLength.toStringAsFixed(1)} מ״מ',
                style: const TextStyle(
                    fontFamily: 'Heebo',
                    color: Color(0xFF7FC08A),
                    fontWeight: FontWeight.w700,),),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${seg.fromFamily} ← צינור OD${seg.od} → ${seg.toFamily}',
              style: const TextStyle(
                  fontFamily: 'Heebo', color: Colors.white, fontSize: 13,),
            ),
          ),
        ],
      ),
    );
  }
}
