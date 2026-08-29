// 🧼 אטום · NameChip — גלולת-השם-הפרטי שליד הלוגו: pill קטן בתוך מטרת-הקשה ≥48dp
// (ConstrainedBox+Center — הגלולה הנראית לא גדלה). מוצא: גוף _HomeAppBar,
// צ׳יפ-השם (screens__home_shell.dart:721-768).
// התרת-סבך: userProfileProvider + גזירת-השם-הפרטי (split רווחים) ⇒ הקופסה מזריקה
// label מוכן; showProfileCard ⇒ onTap; ה-HelpTarget העוטף = חיווט-קופסה.
// תווית-הנגישות + tooltip (במקור אותה מחרוזת) ⇒ content. היו צרובים:
// 0xFFFFF0E3 · BsTokens.brandDark ⇒ fillColor/textColor.
import 'package:flutter/material.dart';

class NameChip extends StatelessWidget {
  const NameChip({
    required this.label,
    required this.semanticsLabel,
    required this.tooltip,
    required this.onTap,
    required this.fillColor,
    required this.textColor,
    super.key,
  });

  final String label;

  /// במקור Semantics.label ו-Tooltip.message היו אותה מחרוזת — מוזרקים בנפרד.
  final String semanticsLabel, tooltip;
  final VoidCallback onTap;
  final Color fillColor, textColor;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semanticsLabel,
        child: Tooltip(
          message: tooltip,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
