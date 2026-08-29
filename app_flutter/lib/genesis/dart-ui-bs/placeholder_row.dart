// 🧼 אטום-משותף · PlaceholderRow — שורת-"בבנייה" (איחד _PlaceholderRow ×3).
// התווית+הודעת-הטוסט מוזרקות (היה צרוב 'בבנייה') — אפס-דאטה, אפס-toast-ישיר.
import 'package:flutter/material.dart';

class PlaceholderRow extends StatelessWidget {
  const PlaceholderRow({
    required this.label, required this.badge, required this.onTap,
    required this.inkColor, required this.mutedColor, super.key,
  });
  final String label, badge;
  final VoidCallback onTap;
  final Color inkColor, mutedColor;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(label, style: TextStyle(color: inkColor)),
        trailing: Text(badge, style: TextStyle(color: mutedColor, fontSize: 12)),
        onTap: onTap,
      );
}
