// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_copilot_screen:_Welcome (בנייה-חכמה main) · צרור-1 · props-שורש: fallback, fallback2, fallback3, fallback4
// התוכן: new/dart-data-bs/auto/screens__manager_copilot_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class Welcome extends StatelessWidget {
  Welcome({required this.fallback, required this.fallback2, required this.fallback3, required this.fallback4, required this.onAsk, required this.onBrief});
  final String fallback;
  final String fallback2;
  final String fallback3;
  final String fallback4;
  final void Function(String) onAsk;
  final VoidCallback onBrief;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(BsTokens.space4),
      children: [
        const SizedBox(height: BsTokens.space4),
        const Text('🤖', style: TextStyle(fontSize: 44), textAlign: TextAlign.center),
        const SizedBox(height: BsTokens.space3),
        CfgText('manager_copilot_screen.welcome_headline', fallback,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        CfgText('manager_copilot_screen.welcome_sub', fallback2,
            textAlign: TextAlign.center,
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
        const SizedBox(height: BsTokens.space4),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onBrief,
            icon: const Text('☀️'),
            label: CfgText('manager_copilot_screen.morning_brief', fallback3),
          ),
        ),
        const SizedBox(height: BsTokens.space4),
        CfgText('manager_copilot_screen.or_ask', fallback4,
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
        const SizedBox(height: BsTokens.space2),
        Wrap(
          spacing: BsTokens.space2,
          runSpacing: BsTokens.space2,
          children: [
            for (final q in kManagerCopilotSuggestions)
              ActionChip(
                label: Text(q),
                onPressed: () => onAsk(q),
                backgroundColor: Theme.of(context).colorScheme.surface,
                labelStyle: const TextStyle(
                    color: BsTokens.inkLight, fontSize: 13),
              ),
          ],
        ),
      ],
    );
  }
}
