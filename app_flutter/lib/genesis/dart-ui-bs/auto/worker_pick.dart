// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__tasks_screen:_WorkerPick (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class WorkerPick extends StatelessWidget {
  const WorkerPick({required this.selected, required this.onSelect});
  final int selected;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: BsTokens.space3),
      child: Row(children: [
        for (var i = 0; i < kWorkers.length; i++) ...[
          if (i > 0) const SizedBox(width: BsTokens.space2),
          Expanded(
            child: Material(
              color: i == selected
                  ? BsTokens.brandDark
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                onTap: () => onSelect(i),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: BsTokens.space3),
                  child: Text(
                    _wk(i),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: i == selected ? bsOnAccent(context) : BsTokens.inkLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

String _wk(int i) => kWorkers[(i >= 0 && i < kWorkers.length) ? i : 0];
