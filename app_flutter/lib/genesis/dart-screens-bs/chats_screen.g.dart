// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__chats_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/circle_fab.dart';
import '../dart-ui-bs/auto/date_chip.dart';
import '../dart-ui-bs/auto/input_bar.dart';
import '../dart-ui-bs/auto/pill.dart';
import '../dart-ui-bs/auto/privacy_notice.dart';
import '../dart-ui-bs/auto/typing_bubble.dart';
import '../dart-data-bs/auto/screens__chats_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ChatsScreenTokens {
  const ChatsScreenTokens();

}

class ChatsScreenComposed extends StatelessWidget {
  const ChatsScreenComposed({required this.onSend, required this.onTap, required this.active, required this.controller, required this.date, required this.enabled, required this.hintText, required this.icon, required this.label, required this.semanticLabel, required this.tooltip, required this.t, super.key});

  final VoidCallback onSend;
  final VoidCallback onTap;
  final bool active;
  final TextEditingController controller;
  final String date;
  final bool enabled;
  final String hintText;
  final IconData icon;
  final String label;
  final String semanticLabel;
  final String tooltip;
  final ChatsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Pill(
            label: label,
            active: active,
            onTap: onTap,
          ),
          PrivacyNotice(
            fallback: privacy_notice_fallback,
          ),
          DateChip(
            date: date,
          ),
          TypingBubble(
            fallback: typing_bubble_fallback,
          ),
          InputBar(
            hintText: hintText,
            tooltip: tooltip,
            controller: controller,
            enabled: enabled,
            onSend: onSend,
          ),
          CircleFab(
            icon: icon,
            onTap: onTap,
            semanticLabel: semanticLabel,
          ),
        ],
      );
}
