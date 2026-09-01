// 🧼 אטום · LabeledField — תווית-סקשן קטנה (12) מעל תוכן. שונה מ-TitledSection שבמדף
// (שם 16/w800). מוצא: screens__store_screen.dart:2528 (_NotesField — הכותרת) וגם תבנית
// הכותרות של _ProjectSelector:1798 / _DeliverySelector:2446 / _PaymentSelector:2674.
// התרת-סבך: BsKeyboardField (שדה-מקלדת-אפליקציה) אינו סטנדרט ⇒ child כ-Widget-slot;
// המונח (t_6e42e25a / t_db751a61 / t_a39e5bff / t_6de2dafb, CfgText) מוזרק ע״י הקופסה.
import 'package:flutter/material.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    required this.label, required this.labelColor, required this.gap,
    required this.child, super.key,
  });
  final String label;
  final Color labelColor;
  final double gap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
          SizedBox(height: gap),
          child,
        ],
      );
}
