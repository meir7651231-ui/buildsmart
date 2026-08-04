// 🧠 מנוע-אביזרים · פאזה D slice 7 — יכולת "מבט-פירוק" (exploded-view · 💥). מרחיקה
// את אביזרי-הקו לאורך-הרַץ (`assembleRoute(explode:)`, פורט מ-gen3d) כדי להראות איך
// הקו מתפרק/מורכב. סליידר 0→1. מגודר · off-live · הזרימה החיה byte-identical.
//
// 🔒 אף מסך-חי לא מייבא `intel/` ⇒ tree-shaken. `explode=0` באסמבלר = זהה-בית למקור.

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';

/// מסך "מבט-פירוק": 3D + סליידר-פיצוץ (💥). מפרק/מרכיב את הקו חזותית.
class ExplodedViewScreen extends StatefulWidget {
  const ExplodedViewScreen({this.route = _demoRoute, super.key});

  final List<RunElement> route;

  static const List<RunElement> _demoRoute = [
    RunElement(Family.coupler, 50),
    RunElement(Family.elbow90, 50, dir: Dir.up),
    RunElement(Family.tee, 50),
    RunElement(Family.reducer, 50, od2: 32),
    RunElement(Family.valve, 32),
    RunElement(Family.plug, 32),
  ];

  @override
  State<ExplodedViewScreen> createState() => _ExplodedViewScreenState();
}

class _ExplodedViewScreenState extends State<ExplodedViewScreen> {
  double _explode = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kStageBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2A),
        foregroundColor: Colors.white,
        title: const Text(
          'מבט-פירוק · preview (off-live)',
          style: TextStyle(fontFamily: 'Heebo', fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: FittingPreview3d(route: widget.route, explode: _explode)),
          Container(
            color: const Color(0xFF151F2A),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  const Text('💥 פירוק',
                      style: TextStyle(
                          fontFamily: 'Heebo', color: Colors.white, fontSize: 13,),),
                  Expanded(
                    child: Slider(
                      value: _explode,
                      max: 3,
                      activeColor: const Color(0xFF7FC08A),
                      onChanged: (v) => setState(() => _explode = v),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(_explode.toStringAsFixed(1),
                        style: const TextStyle(
                            fontFamily: 'Heebo', color: Colors.white70,),),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
