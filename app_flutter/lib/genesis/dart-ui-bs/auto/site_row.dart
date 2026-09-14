// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — מחובר-לחריץ (retrofit-תפר): קורא skin.* מ-DsSeam.
// מוצא: screens__budget_screen:_SiteRow (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class SiteRow extends StatelessWidget {
  const SiteRow({required this.name, required this.value});
  final String name;
  final String value;
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context); // מלוא-העיצוב מהחריץ (חוק-7: נופל ל-DsPure.skin בלי PureScope)
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
              child: Text('🏗️ $name',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: skin.ink))),
          Text('$value ›',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: skin.ink)),
        ],
      ),
    );
  }
}
