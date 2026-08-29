// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__chat_settings_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/screens__chat_settings_screen/quick_reply_banner.dart';
import '../dart-data-bs/auto/screens__chat_settings_screen_content.dart';
import '../dart-data-bs/screens__chat_settings_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ChatSettingsScreenTokens {
  const ChatSettingsScreenTokens({required this.accentColor, required this.chipBorderColor, required this.chipFillColor, required this.inkColor});
  final Color accentColor;
  final Color chipBorderColor;
  final Color chipFillColor;
  final Color inkColor;
}

class ChatSettingsScreenComposed extends StatelessWidget {
  const ChatSettingsScreenComposed({required this.onEditTap,VoidCallback?, required this.onTemplateTap,ValueChanged<String>, required this.templates, required this.t, super.key});

  final VoidCallback? onEditTap;
  final ValueChanged<String> onTemplateTap;
  final List<String> templates;
  final ChatSettingsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          QuickReplyBanner(
            leadingGlyph: chatSettingsScreenContent.leadingGlyph,
            title: chatSettingsScreenContent.title,
            templates: templates,
            onTemplateTap: onTemplateTap,
            inkColor: t.inkColor,
            accentColor: t.accentColor,
            chipFillColor: t.chipFillColor,
            chipBorderColor: t.chipBorderColor,
            editLabel: chatSettingsScreenContent.editLabel,
            onEditTap: onEditTap,
          ),
        ],
      );
}
