// 🧠 מנוע-אביזרים · פאזה E-lite slice 1 — מסך "נפילת-לחץ" (יכולת-מאחורי-כפתור).
// מציג את אומדן-הלחץ של קו-מתוכנן: ΔP · צוואר-הבקבוק · הצעות-ייעוץ. מגודר · off-live.
//
// 🔒 אף מסך-חי לא מייבא `intel/` ⇒ tree-shaken ⇒ הזרימה החיה byte-identical.

import 'package:buildsmart/features/fittings/intel/line_planner.dart';
import 'package:buildsmart/features/fittings/intel/line_pressure.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:flutter/material.dart';

/// מסך "נפילת-לחץ": ΔP + צוואר-בקבוק + הצעות. מקבל תוכנית-קו מוכנה.
class LinePressureScreen extends StatelessWidget {
  const LinePressureScreen({required this.plan, super.key});

  final FittingLinePlan plan;

  @override
  Widget build(BuildContext context) {
    final r = pressureDropForPlan(plan);
    final over = r.exceedsBudget;
    return Scaffold(
      backgroundColor: kStageBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2A),
        foregroundColor: Colors.white,
        title: const Text(
          'נפילת-לחץ · preview (off-live)',
          style: TextStyle(fontFamily: 'Heebo', fontWeight: FontWeight.w700),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                const Text('ΔP',
                    style: TextStyle(
                        fontFamily: 'Heebo',
                        color: Colors.white70,
                        fontSize: 20,),),
                const SizedBox(width: 12),
                Text('${r.dropBar.toStringAsFixed(2)} bar',
                    style: TextStyle(
                        fontFamily: 'Heebo',
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                        color: over
                            ? const Color(0xFFE06666)
                            : const Color(0xFF7FC08A),),),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'K=${r.totalK.toStringAsFixed(2)} · אורך=${r.frictionMetres.toStringAsFixed(1)}מ׳ · '
              'קדח-מינ׳=${r.minBoreMm.toStringAsFixed(1)}מ״מ',
              style: const TextStyle(
                  fontFamily: 'Heebo', color: Colors.white54, fontSize: 12,),
            ),
            if (r.bottleneck != null) ...[
              const SizedBox(height: 4),
              Text('צוואר-בקבוק: ${r.bottleneck!.nameHe}',
                  style: const TextStyle(
                      fontFamily: 'Heebo', color: Colors.white70, fontSize: 13,),),
            ],
            const Divider(height: 28, color: Color(0xFF26333F)),
            const Text('הצעות',
                style: TextStyle(
                    fontFamily: 'Heebo', color: Colors.white70, fontSize: 13,),),
            const SizedBox(height: 8),
            if (r.suggestions.isEmpty || r.warnings.isEmpty)
              const Text('אין הערות-זרימה — הקו בתקציב.',
                  style: TextStyle(fontFamily: 'Heebo', color: Colors.white54,),)
            else
              for (final s in r.suggestions.where((x) => x.actionKind != SuggestionKind.ok))
                _SuggestionTile(s: s),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.s});
  final FlowSuggestion s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text('• ${s.problem}',
          style: const TextStyle(
              fontFamily: 'Heebo', color: Colors.white, fontSize: 13,),),
    );
  }
}
