// 🎨 חוט-תצוגה · TagInput — שדה-תיוג עם צ'יפים ניתנים-להסרה (חוק-1/חוק-5).
// המנוע: תוויות כצ'יפים עם × להסרה + גלולת "הוסף". אפס-דאטה — תוויות · גובה ·
// צבע-מבטא/טקסט/רקע מוזרקים; רשימת-התיוג הפנימית שלו.
import 'package:flutter/material.dart';
class TagInput extends StatefulWidget {
  const TagInput({required this.labels, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final List<String> labels; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<TagInput> createState() => _TagInputState();
}
class _TagInputState extends State<TagInput> {
  late List<String> _tags = [...widget.labels];
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius),
      border: Border.all(color: widget.accentColor.withValues(alpha: 0.3))),
    child: Wrap(spacing: 8, runSpacing: 8, children: [
      for (var i = 0; i < _tags.length; i++)
        Container(height: widget.height, padding: const EdgeInsets.only(right: 12, left: 6),
          decoration: BoxDecoration(color: widget.accentColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: widget.accentColor.withValues(alpha: 0.5))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_tags[i], style: TextStyle(color: widget.baseColor, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            GestureDetector(onTap: () => setState(() => _tags.removeAt(i)),
              child: Icon(Icons.close, size: 15, color: widget.baseColor.withValues(alpha: 0.6))),
          ])),
      Container(height: widget.height, width: widget.height,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.accentColor)),
        child: Icon(Icons.add, size: 18, color: widget.accentColor)),
    ]));
}
