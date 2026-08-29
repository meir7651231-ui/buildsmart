// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__lipskey_product_sheet:_QtyStepper (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class QtyStepper extends StatelessWidget {
  const QtyStepper({required this.qty, required this.onChanged});
  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget b(String s, VoidCallback t) => InkWell(
          onTap: t,
          child: SizedBox(
              width: 38,
              height: 44,
              child: Center(
                  child: Text(s,
                      style: const TextStyle(
                          color: BsTokens.inkLight, fontSize: 20)))),
        );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: BsTokens.brand),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          b('−', () => onChanged(qty - 1)),
          SizedBox(
              width: 34,
              child: Center(
                  child: Text('$qty',
                      style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)))),
          b('+', () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}
