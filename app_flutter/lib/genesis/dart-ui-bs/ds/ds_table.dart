// 🗂️→▦ טבלה-ממוינת · אטום-DS עם תפר-דאטה אמיתי — עמודה-פר-שדה, שורה-פר-רשומה, מיון-בלחיצה.
// בניגוד ל-data_grid (אפס-דאטה, int rows דקורטיבי), DsTable מקבל labels+rows אמיתיים,
// ממיין בלחיצה-על-כותרת (מספרי אם שני-הצדדים מספר, אחרת לקסיקלי), גלילה-אופקית. חוט-טהור.
import 'package:flutter/material.dart';
import 'ds.dart';

class DsTable extends StatefulWidget {
  const DsTable({required this.labels, required this.rows, super.key});
  final List<String> labels;
  final List<List<String>> rows;

  @override
  State<DsTable> createState() => _DsTableState();
}

class _DsTableState extends State<DsTable> {
  int _sort = -1;   // עמודת-המיון (-1 = ללא)
  bool _asc = true;

  List<List<String>> get _sorted {
    final rows = [...widget.rows];
    if (_sort < 0) return rows;
    rows.sort((a, b) {
      final x = _sort < a.length ? a[_sort] : '';
      final y = _sort < b.length ? b[_sort] : '';
      final nx = num.tryParse(x), ny = num.tryParse(y);
      final c = (nx != null && ny != null) ? nx.compareTo(ny) : x.compareTo(y);
      return _asc ? c : -c;
    });
    return rows;
  }

  void _tap(int col) => setState(() {
        if (_sort == col) {
          _asc = !_asc;
        } else {
          _sort = col;
          _asc = true;
        }
      });

  @override
  Widget build(BuildContext context) {
    final rows = _sorted;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 22,
        headingRowHeight: 40,
        dataRowMinHeight: 38,
        dataRowMaxHeight: 46,
        headingTextStyle: const TextStyle(color: DsTokens.ink, fontSize: 12.5, fontWeight: FontWeight.w800),
        dataTextStyle: const TextStyle(color: DsTokens.ink, fontSize: 12.5, fontWeight: FontWeight.w500),
        columns: [
          for (var i = 0; i < widget.labels.length; i++)
            DataColumn(
              label: InkWell(
                onTap: () => _tap(i),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(child: Text(widget.labels[i], overflow: TextOverflow.ellipsis)),
                  if (_sort == i) Icon(_asc ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 18, color: DsTokens.accent),
                ]),
              ),
            ),
        ],
        rows: [
          for (final r in rows)
            DataRow(cells: [
              for (var i = 0; i < widget.labels.length; i++)
                DataCell(Text(i < r.length ? r[i] : '', overflow: TextOverflow.ellipsis)),
            ]),
        ],
      ),
    );
  }
}
