// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_app_screen:_WorkerNav (בנייה-חכמה main) · צרור-1 · props-שורש: label, label2, label3, label4
// התוכן: new/dart-data-bs/auto/screens__worker_app_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class WorkerNav extends StatelessWidget {
  WorkerNav({required this.label, required this.label2, required this.label3, required this.label4, 
    required this.currentIndex,
    required this.onTap,
    required this.chatOn,
  });
  final String label;
  final String label2;
  final String label3;
  final String label4;

  final int currentIndex;
  final void Function(int) onTap;

  /// Giant-system V2 — the `chat` module gate (computed in the board's
  /// build(), captured here): false hides the שיחות item. The LOGICAL tab ids
  /// (0 משימות · 1 שיחות · 2 דוחות · 3 אזור אישי) NEVER renumber — the bar's
  /// contiguous VISUAL index is mapped back to the logical id below, so the
  /// body switch and [onTap] keep the #67 contract untouched.
  final bool chatOn;

  @override
  Widget build(BuildContext context) {
    // logical→visual: with שיחות hidden every logical id past 1 sits one
    // visual slot earlier (the parent build clamps logical 1 to 0 before it
    // ever reaches [currentIndex]). All-on: visual == logical, byte-for-byte.
    final visual =
        chatOn || currentIndex < 2 ? currentIndex : currentIndex - 1;
    return BottomNavigationBar(
      currentIndex: visual,
      // visual→logical: the mirror of the mapping above, so a tap always
      // reports the STABLE logical id whether or not שיחות is showing.
      onTap: (i) => onTap(chatOn || i == 0 ? i : i + 1),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: BsTokens.brand,
      unselectedItemColor: const Color(0xFF888888),
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.handyman_outlined),
          activeIcon: Icon(Icons.handyman),
          label: label,
        ),
        // Giant-system V2 — `chat` off hides the שיחות item (the store-board
        // cell treatment); the index mapping above keeps the siblings' logical
        // ids stable.
        if (chatOn)
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: label2,
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: label3,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: label4,
        ),
      ],
    );
  }
}
