// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__install_studio_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/pipe_link.dart';
import '../dart-ui-bs/auto/sheet_close.dart';
import '../dart-data-bs/auto/screens__install_studio_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class InstallStudioScreenTokens {
  const InstallStudioScreenTokens({required this.from, required this.to});
  final Color from;
  final Color to;
}

class InstallStudioScreenComposed extends StatelessWidget {
  const InstallStudioScreenComposed({required this.onTap, required this.broken, required this.flow, required this.t, super.key});

  final VoidCallback onTap;
  final bool broken;
  final double flow;
  final InstallStudioScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SheetClose(
            label: sheet_close_label,
            message: sheet_close_message,
            onTap: onTap,
          ),
          PipeLink(
            label: pipe_link_label,
            label2: pipe_link_label2,
            from: t.from,
            to: t.to,
            flow: flow,
            broken: broken,
          ),
        ],
      );
}
