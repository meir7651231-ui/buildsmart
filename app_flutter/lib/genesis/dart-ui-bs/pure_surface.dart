// ✨ אטום-תצוגה מפורק (Layer C חי) · PureSurface — משטח-Pure הלובש את הערכה מהחריץ.
// מרכיב A(pure-look⇒DsPure) + B(מנוע-Dart) + C(seam): נייטרל/דיו קבועים; הילת-האקצנט (gl) מורפת
// דרך DsSeam.of(context). התוכן מוזרק (child) — האטום לא יודע תוכן/זהות (חוק-5/6). material בלבד.
import 'package:flutter/material.dart';
import 'ds/ds_pure.dart';
import 'ds/ds_seam.dart';

class PureSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  const PureSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context); // ערכת-האקצנט הפעילה — הזרקת-חיווט
    final fonts = DsSeam.fontsOf(context); // חבילת-הפונט הפעילה — פרמטר הפיך
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: DsPure.surface, // נייטרל קבוע
        border: Border.all(color: DsPure.hair),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: theme.gl, blurRadius: 24, offset: const Offset(0, 8))], // אקצנט מורף
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: DsPure.ink, fontSize: 15, height: 1.45, fontFamily: fonts.he),
        child: child,
      ),
    );
  }
}
