// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__home_shell.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/home_shell_badged_icon.dart';
import '../dart-ui-bs/auto/home_shell_menu_row.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class HomeShellTokens {
  const HomeShellTokens();

}

class HomeShellComposed extends StatelessWidget {
  const HomeShellComposed({required this.cfgId, required this.count, required this.emoji, required this.icon, required this.label, required this.t, super.key});


  final String? cfgId;
  final int count;
  final String emoji;
  final IconData icon;
  final String label;
  final HomeShellTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          HomeShellBadgedIcon(
            icon: icon,
            count: count,
          ),
          HomeShellMenuRow(
            emoji: emoji,
            label: label,
            cfgId: cfgId,
          ),
        ],
      );
}
