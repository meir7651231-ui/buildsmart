// 🧼 אטום · SmartQtyStepper — סטפר −/כמות/+ קומפקטי ליעדי 48dp (a11y), רקע-מבטא שקוף.
// מוצא: screens__store_screen.dart:2068 (_SmartQtyStepper). tooltips היו צרובים
// (t_c3f9ac23 / t_f3943fe9) ⇒ incrementLabel/decrementLabel props; setLineQty = קופסה.
import 'package:flutter/material.dart';

class SmartQtyStepper extends StatelessWidget {
  const SmartQtyStepper({
    required this.qty, required this.onMinus, required this.onPlus,
    required this.incrementLabel, required this.decrementLabel,
    required this.accentColor, required this.inkColor, super.key,
  });
  final int qty;
  final VoidCallback onMinus, onPlus;
  final String incrementLabel, decrementLabel;
  final Color accentColor, inkColor;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback onTap, String label) => Tooltip(
          message: label,
          child: Semantics(
            button: true,
            label: label,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(child: Icon(icon, size: 18, color: accentColor)),
              ),
            ),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove, onMinus, decrementLabel),
          SizedBox(
            width: 22,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: TextStyle(color: inkColor, fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
          btn(Icons.add, onPlus, incrementLabel),
        ],
      ),
    );
  }
}
