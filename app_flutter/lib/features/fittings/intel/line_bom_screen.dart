// 🧠 מנוע-אביזרים · פאזה D slice 4 — מסך "כתב-כמויות" (יכולת-מאחורי-כפתור · מגודר).
// מציג `LineBom`: טבלת מוצר×כמות · סה״כ-פריסים · חיווי-שלמות · מונה-בטיחות-קריטית.
// off-live · מרכיב את `lineBom` (המקורקע ב-`buildInstallation`). שילוב-סופי = בעלים.
//
// 🔒 אף route חי אינו מייבא את הקובץ הזה ⇒ tree-shaken ⇒ הזרימה החיה byte-identical.

import 'package:buildsmart/features/fittings/intel/line_bom.dart';
import 'package:flutter/material.dart';

/// מסך-היכולת "כתב-כמויות": רשימת-קנייה + סטטוס. מקבל BOM מוכן (או דמו).
class LineBomScreen extends StatelessWidget {
  const LineBomScreen({this.bom, super.key});

  final LineBom? bom;

  static const LineBom _demo = LineBom(
    rows: [
      BomRow('99310150', 'מצמד PPR 50', 2),
      BomRow('99320150', 'ברך PPR 90° 50', 2),
      BomRow('99330150', 'מסעף PPR 50', 1),
      BomRow('99340153', 'מצרה PPR 50×32', 1),
      BomRow('99350132', 'ברז כדורי PPR 32', 1),
      BomRow('99360132', 'פקק PPR 32', 1),
    ],
    totalPieces: 8,
    complete: true,
    criticalOpen: 0,
  );

  @override
  Widget build(BuildContext context) {
    final b = bom ?? _demo;
    const bg = Color(0xFF0E141C);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2A),
        foregroundColor: Colors.white,
        title: const Text(
          'כתב-כמויות · preview (off-live)',
          style: TextStyle(fontFamily: 'Heebo', fontWeight: FontWeight.w700),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusBar(bom: b),
            const Divider(height: 1, color: Color(0xFF26333F)),
            Expanded(
              child: b.rows.isEmpty
                  ? const Center(
                      child: Text('אין פריטים',
                          style: TextStyle(
                              fontFamily: 'Heebo', color: Colors.white70,),),
                    )
                  : ListView.separated(
                      itemCount: b.rows.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFF1B2530)),
                      itemBuilder: (_, i) => _BomRowTile(row: b.rows[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.bom});
  final LineBom bom;

  @override
  Widget build(BuildContext context) {
    final ok = bom.complete && bom.criticalOpen == 0;
    return Container(
      color: const Color(0xFF151F2A),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.warning_amber,
              color: ok ? const Color(0xFF3F8F46) : const Color(0xFFE0A82E),
              size: 20,),
          const SizedBox(width: 8),
          Text(
            'סה״כ ${bom.totalPieces} פריטים'
            '${bom.complete ? '' : ' · יש פערים'}'
            '${bom.criticalOpen > 0 ? ' · ${bom.criticalOpen} בטיחות חסרים' : ''}',
            style: const TextStyle(
                fontFamily: 'Heebo', color: Colors.white, fontSize: 13,),
          ),
        ],
      ),
    );
  }
}

class _BomRowTile extends StatelessWidget {
  const _BomRowTile({required this.row});
  final BomRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF23303D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('×${row.qty}',
                style: const TextStyle(
                    fontFamily: 'Heebo',
                    color: Color(0xFF7FC08A),
                    fontWeight: FontWeight.w700,),),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(row.nameHe,
                style: const TextStyle(
                    fontFamily: 'Heebo', color: Colors.white, fontSize: 13,),),
          ),
          Text(row.sku,
              style: const TextStyle(
                  fontFamily: 'Heebo', color: Colors.white38, fontSize: 11,),),
        ],
      ),
    );
  }
}
