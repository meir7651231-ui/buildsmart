// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__home_shell:_MenuRow (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class HomeShellMenuRow extends StatelessWidget {
  const HomeShellMenuRow({required this.emoji, required this.label, this.cfgId});
  final String emoji;
  final String label;

  /// Optional BuildSmart-Studio element id. When set, the label routes through
  /// [CfgText] (owner-editable; identical style/params, byte-identical fallback);
  /// null ⇒ a plain [Text], exactly as before.
  final String? cfgId;

  @override
  Widget build(BuildContext context) {
    final id = cfgId;
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Flexible(
          child:
              id == null
                  ? Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 15,
                    ),
                  )
                  : CfgText(
                    id,
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 15,
                    ),
                  ),
        ),
      ],
    );
  }
}
