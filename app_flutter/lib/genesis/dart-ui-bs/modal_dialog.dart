// 🎨 חוט-תצוגה · ModalDialog — דיאלוג שנכנס בקפיצה עם שני כפתורים (חוק-1/חוק-5).
// המנוע: כרטיס-דיאלוג עם כניסת scale+fade (AnimationController). אפס-דאטה —
// כותרת · תת-כותרת · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class ModalDialog extends StatefulWidget {
  const ModalDialog({required this.title, required this.sub, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String title, sub; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<ModalDialog> createState() => _ModalDialogState();
}
class _ModalDialogState extends State<ModalDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    return ScaleTransition(scale: Tween<double>(begin: 0.8, end: 1).animate(anim),
      child: FadeTransition(opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
        child: Container(height: widget.height, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius * 1.4),
            boxShadow: [BoxShadow(color: widget.accentColor.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 12))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.title, style: TextStyle(color: widget.baseColor, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(widget.sub, style: TextStyle(color: widget.baseColor.withValues(alpha: 0.7), fontSize: 13)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: Container(height: 42, alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.radius),
                  border: Border.all(color: widget.baseColor.withValues(alpha: 0.3))),
                child: Icon(Icons.close, color: widget.baseColor.withValues(alpha: 0.7), size: 20))),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 42, alignment: Alignment.center,
                decoration: BoxDecoration(color: widget.accentColor, borderRadius: BorderRadius.circular(widget.radius)),
                child: Icon(Icons.check, color: widget.fillColor, size: 20))),
            ]),
          ]))));
  }
}
