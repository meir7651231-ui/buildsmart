// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__studio__panes__find_replace_pane:_Placeholder (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class StudioPanesFindReplacePanePlaceholder extends StatelessWidget {
  const StudioPanesFindReplacePanePlaceholder(this.msg);

  final String msg;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space5),
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: BsTokens.mutedLight),
          ),
        ),
      );
}
