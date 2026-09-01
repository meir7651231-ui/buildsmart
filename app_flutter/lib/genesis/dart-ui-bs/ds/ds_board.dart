// 🗂️→📋 לוח-שלבים (Kanban) · אטום-DS עם תפר-דאטה אמיתי — עמודה-פר-שלב, כרטיס-פר-רשומה.
// זו ההדגמה של "תפר-הנתונים": בניגוד לאטמי-האפס-דאטה, DsBoard מקבל records+stages
// אמיתיים (לא seed), מסדר כל רשומה לעמודת-השלב שלה, וקידום = onMove(id, שלב-הבא). חוט-טהור.
import 'package:flutter/material.dart';
import 'ds.dart';

class DsBoard extends StatelessWidget {
  const DsBoard({
    required this.stages,
    required this.records,
    required this.stageOf,
    required this.titleOf,
    required this.onMove,
    super.key,
  });

  final List<String> stages;                       // שמות-השלבים (עמודות)
  final List<Map<String, String>> records;         // הרשומות החיות
  final int Function(Map<String, String>) stageOf; // אינדקס-השלב של רשומה
  final String Function(Map<String, String>) titleOf; // כותרת-הכרטיס (שם-הרשומה)
  final void Function(String id, int toStage) onMove; // קידום/הזזה של רשומה לשלב

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: stages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, col) {
          final inCol = records.where((r) => stageOf(r).clamp(0, stages.length - 1) == col).toList();
          return Container(
            width: 210,
            decoration: BoxDecoration(
              color: DsTokens.cardAlt,
              borderRadius: BorderRadius.circular(DsTokens.rSm),
              border: Border.all(color: DsTokens.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Row(children: [
                    Expanded(child: Text(stages[col], overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.ink, fontSize: 13.5, fontWeight: FontWeight.w800))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                      decoration: BoxDecoration(color: DsTokens.accentSoft, borderRadius: BorderRadius.circular(10)),
                      child: Text('${inCol.length}', style: const TextStyle(color: DsTokens.accentDark, fontSize: 11.5, fontWeight: FontWeight.w800)),
                    ),
                  ]),
                ),
                Expanded(
                  child: inCol.isEmpty
                      ? const Center(child: Text('—', style: TextStyle(color: DsTokens.faint)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          itemCount: inCol.length,
                          itemBuilder: (context, i) {
                            final r = inCol[i];
                            final id = r['__id'] ?? '';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: DsTokens.cardAlt,
                                borderRadius: BorderRadius.circular(DsTokens.rSm),
                                border: Border.all(color: DsTokens.line),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(titleOf(r).isEmpty ? id : titleOf(r), style: const TextStyle(color: DsTokens.ink, fontSize: 13, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    if (col > 0)
                                      _MoveBtn(icon: Icons.chevron_right, onTap: () => onMove(id, col - 1)),
                                    const Spacer(),
                                    if (col < stages.length - 1)
                                      _MoveBtn(icon: Icons.chevron_left, accent: true, onTap: () => onMove(id, col + 1)),
                                  ]),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MoveBtn extends StatelessWidget {
  const _MoveBtn({required this.icon, required this.onTap, this.accent = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent ? DsTokens.accentSoft : DsTokens.track,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 17, color: accent ? DsTokens.accentDark : DsTokens.muted),
        ),
      ),
    );
  }
}
