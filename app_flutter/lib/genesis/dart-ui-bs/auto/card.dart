// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__worker_reports_tab:_Card (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class Card extends StatelessWidget {
  const Card({required this.title, required this.children, this.titleId});

  final String title;

  /// Studio content-id for the owner-editable card title. Null ⇒ plain [Text]
  /// (byte-identical); set ⇒ the title renders through [CfgText].
  final String? titleId;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (titleId == null)
            Text(
              title,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            )
          else
            CfgText(
              titleId!,
              title,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          const SizedBox(height: BsTokens.space3),
          ...children,
        ],
      ),
    );
  }
}
