// שדה-חיפוש: סינון-רשומות חי לפי-מחרוזת. תיבת-חיפוש עם אייקון · ניקוי. חוט-טהור מעל ds.
import 'package:flutter/material.dart';
import 'ds.dart';

class DsSearch extends StatelessWidget {
  const DsSearch({required this.value, required this.onChanged, this.bare = false, super.key});
  final String value;
  final ValueChanged<String> onChanged;
  /// G13c · bare=true ⇒ שורת-הקלט בלבד (בלי מסגרת/ריפוד/אייקון-חיפוש) — לחריץ-ה-control של אטום-forge שמצייר את המסגרת. false ⇒ ביט-זהה.
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    return bare ? _row(lk, bare: true) : Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: lk.cardAlt,
            borderRadius: BorderRadius.circular(lk.rSm),
            border: Border.all(color: lk.line),
          ),
          child: _row(lk, bare: false),
        ),
      );
  }
  Widget _row(DsLook lk, {required bool bare}) => Row(
            children: [
              if (!bare) Icon(Icons.search, size: 18, color: lk.faint),
              if (!bare) const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: onChanged,
                  style: TextStyle(color: lk.ink, fontSize: 14.5, fontWeight: FontWeight.w500),
                  cursorColor: lk.accent,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'חיפוש...',
                    hintStyle: TextStyle(color: lk.faint, fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (value.isNotEmpty)
                GestureDetector(
                  onTap: () => onChanged(''),
                  child: Icon(Icons.close, size: 17, color: lk.faint),
                ),
            ],
          );
}
