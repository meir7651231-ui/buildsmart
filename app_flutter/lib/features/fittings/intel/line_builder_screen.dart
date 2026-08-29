// 🧠 מנוע-אביזרים · פאזה D slice 2 — מסך "בנה-קו" (היכולת מאחורי כפתור). מציג
// `FittingLinePlan`: סיכום-הרצף (אביזרים · קטרים) + **תצוגת-3D** (`FittingPreview3d`).
// זהו יעד-הכפתור של יכולת-תכנון-החיבור — מגודר `kFittingEngineIntel` (default-OFF),
// off-live. שילוב-סופי (איפה הכפתור יושב בזרימה) = החלטת-בעלים בהמשך.
//
// 🔒 אף route חי אינו מייבא את הקובץ הזה ⇒ tree-shaken כשהדגל כבוי ⇒ הזרימה החיה
// byte-identical. נגיש רק ב-build מגודר (`--dart-define=FITTING_ENGINE_INTEL=true`).

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/intel/line_planner.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';

/// מסך-היכולת "בנה-קו": סיכום-רצף + 3D. מקבל תוכנית מוכנה (או רצף-דמו).
class LineBuilderScreen extends StatelessWidget {
  const LineBuilderScreen({this.plan, super.key});

  final FittingLinePlan? plan;

  static final FittingLinePlan _demo = FittingLinePlan.fromRoute(const [
    RunElement(Family.coupler, 50),
    RunElement(Family.elbow90, 50, dir: Dir.up),
    RunElement(Family.tee, 50),
    RunElement(Family.reducer, 50, od2: 32),
    RunElement(Family.valve, 32),
    RunElement(Family.elbow90, 32, dir: Dir.down),
    RunElement(Family.plug, 32),
  ]);

  @override
  Widget build(BuildContext context) {
    final p = plan ?? _demo;
    return Scaffold(
      backgroundColor: kStageBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2A),
        foregroundColor: Colors.white,
        title: const Text(
          'בנה-קו · preview (off-live)',
          style: TextStyle(fontFamily: 'Heebo', fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          _LineSummary(plan: p),
          const Divider(height: 1, color: Color(0xFF26333F)),
          Expanded(child: FittingPreview3d(route: p.route)),
        ],
      ),
    );
  }
}

/// שורת-סיכום: צ'יפ פר-אביזר ברצף (אימוג'י-משפחה + קוטר). דאטה בלבד, אפס-חישוב חדש.
class _LineSummary extends StatelessWidget {
  const _LineSummary({required this.plan});

  final FittingLinePlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF151F2A),
      padding: const EdgeInsets.all(12),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final el in plan.route)
              Chip(
                backgroundColor: const Color(0xFF23303D),
                label: Text(
                  '${_familyEmoji(el.family)} ${el.family.label} '
                  '${el.od}${el.od2 != null ? '→${el.od2}' : ''}',
                  style: const TextStyle(
                    fontFamily: 'Heebo',
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            if (plan.route.isEmpty)
              const Text('רצף ריק',
                  style: TextStyle(fontFamily: 'Heebo', color: Colors.white70),),
          ],
        ),
      ),
    );
  }
}

String _familyEmoji(Family f) => switch (f) {
      Family.coupler => '⚪',
      Family.elbow90 || Family.elbow45 || Family.miteredElbow => '↰',
      Family.tee => '⊤',
      Family.adapter => '🔩',
      Family.valve => '🔵',
      Family.reducer => '🔻',
      Family.plug => '⬛',
      Family.saddle => '🪧',
      Family.collar => '⭕',
    };
