// 🗂️→📅 לוח-שנה · אטום-DS עם תפר-דאטה אמיתי — פורס רשומות על גריד-חודש לפי שדה-תאריך.
// בניגוד ל-mini_calendar (אפס-דאטה, today==תא-17), DsCalendar מקבל records+dateOf אמיתיים
// וסופר כמה נופלות בכל יום. ניווט-חודש חי (DateTime.now בזמן-ריצה — לא בזמן-חילול). חוט-טהור.
import 'package:flutter/material.dart';
import 'ds.dart';

class DsCalendar extends StatefulWidget {
  const DsCalendar({required this.records, required this.dateOf, required this.titleOf, super.key});
  final List<Map<String, String>> records;
  final String Function(Map<String, String>) dateOf;   // ISO 'YYYY-MM-DD' או ריק
  final String Function(Map<String, String>) titleOf;

  @override
  State<DsCalendar> createState() => _DsCalendarState();
}

class _DsCalendarState extends State<DsCalendar> {
  int _off = 0;   // היסט-חודשים מהחודש הנוכחי

  static const _months = ['ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני', 'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'];
  static const _dows = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ש'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final anchor = DateTime(now.year, now.month + _off);
    final first = DateTime(anchor.year, anchor.month, 1);
    final daysInMonth = DateTime(anchor.year, anchor.month + 1, 0).day;
    final lead = first.weekday % 7;   // ראשון=0

    // ספירת רשומות פר-יום בחודש המוצג
    final byDay = <int, int>{};
    for (final r in widget.records) {
      final d = DateTime.tryParse(widget.dateOf(r));
      if (d != null && d.year == anchor.year && d.month == anchor.month) {
        byDay[d.day] = (byDay[d.day] ?? 0) + 1;
      }
    }

    final cells = <Widget>[];
    for (var i = 0; i < lead; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final n = byDay[day] ?? 0;
      final isToday = _off == 0 && day == now.day;
      cells.add(Container(
        decoration: BoxDecoration(
          color: n > 0 ? DsTokens.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: DsTokens.accent, width: 1.5) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day', style: TextStyle(color: n > 0 ? DsTokens.accentDark : DsTokens.muted, fontSize: 12.5, fontWeight: n > 0 ? FontWeight.w800 : FontWeight.w500)),
            if (n > 0) Text('$n', style: const TextStyle(color: DsTokens.accentDark, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            _NavBtn(icon: Icons.chevron_right, onTap: () => setState(() => _off--)),
            Expanded(child: Center(child: Text('${_months[anchor.month - 1]} ${anchor.year}', style: const TextStyle(color: DsTokens.ink, fontSize: 14, fontWeight: FontWeight.w800)))),
            _NavBtn(icon: Icons.chevron_left, onTap: () => setState(() => _off++)),
          ]),
        ),
        Row(children: [
          for (final d in _dows) Expanded(child: Center(child: Text(d, style: const TextStyle(color: DsTokens.faint, fontSize: 11.5, fontWeight: FontWeight.w700)))),
        ]),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1.1,
          children: cells,
        ),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: DsTokens.track,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(5), child: Icon(icon, size: 18, color: DsTokens.muted)),
        ),
      );
}
