// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__chats_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/pill.dart';
import '../dart-data-bs/auto/screens__chats_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ChatsScreenTokens {
  const ChatsScreenTokens();

}

class ChatsScreenComposed extends StatelessWidget {
  const ChatsScreenComposed({required this.onTap, required this.active, required this.label, required this.t, super.key});

  final VoidCallback onTap;
  final bool active;
  final String label;
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
        ],
      );
}
