// 🎨 חוט-תצוגה · DropSelect — בורר שנפתח למטה בהנפשה (חוק-1/חוק-5).
// המנוע: הקשה פותחת רשימת-אפשרויות בגובה מונפש (AnimatedSize) + חץ מסתובב.
// אפס-דאטה — תוויות · גובה · צבע-מבטא/טקסט/רקע מוזרקים; הבחירה הפנימית שלו.
import 'package:flutter/material.dart';
class DropSelect extends StatefulWidget {
  const DropSelect({required this.labels, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final List<String> labels; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<DropSelect> createState() => _DropSelectState();
}
class _DropSelectState extends State<DropSelect> {
  bool _open = false; int _sel = 0;
  @override Widget build(BuildContext context) {
    final labels = widget.labels.isEmpty ? const ['—'] : widget.labels;
    final sel = _sel.clamp(0, labels.length - 1);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      GestureDetector(onTap: () => setState(() => _open = !_open), behavior: HitTestBehavior.opaque,
        child: Container(height: widget.height, padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: widget.accentColor.withValues(alpha: _open ? 0.8 : 0.3))),
          child: Row(children: [
            Expanded(child: Text(labels[sel], style: TextStyle(color: widget.baseColor, fontSize: 15, fontWeight: FontWeight.w600))),
            AnimatedRotation(turns: _open ? 0.5 : 0, duration: const Duration(milliseconds: 200),
              child: Icon(Icons.expand_more, color: widget.accentColor)),
          ]))),
      AnimatedSize(duration: const Duration(milliseconds: 220), curve: Curves.easeOut,
        child: _open ? Container(margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: widget.accentColor.withValues(alpha: 0.25))),
          child: Column(children: [
            for (var i = 0; i < labels.length; i++)
              GestureDetector(onTap: () => setState(() { _sel = i; _open = false; }), behavior: HitTestBehavior.opaque,
                child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: i == sel ? widget.accentColor.withValues(alpha: 0.12) : null,
                  child: Text(labels[i], style: TextStyle(color: widget.baseColor, fontSize: 14)))),
          ])) : const SizedBox(width: double.infinity)),
    ]);
  }
}
