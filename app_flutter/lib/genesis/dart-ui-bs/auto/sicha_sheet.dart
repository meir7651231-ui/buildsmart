// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__store_screen:_SichaSheet (בנייה-חכמה main) · צרור-2 · props-שורש: name, name2, name3, name4, title, onTap
// התוכן: new/dart-data-bs/auto/screens__store_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class SichaSheet extends StatelessWidget {
  SichaSheet({required this.name, required this.name2, required this.name3, required this.name4, required this.title, required this.onTap});
  final String name;
  final String name2;
  final String name3;
  final String name4;
  final String title;
  final VoidCallback onTap;

  static const _contacts = [
    (avatar: '👷', name: name),
    (avatar: '🏪', name: name2),
    (avatar: '🛵', name: name3),
    (avatar: '👔', name: name4),
  ];

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: title,
      emoji: '📞',
      children:
          _contacts
              .map(
                (c) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF333333),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(c.avatar, style: const TextStyle(fontSize: 20)),
                  ),
                  title: Text(
                    c.name,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 15,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.phone_outlined,
                    color: Colors.black38,
                  ),
                  onTap: onTap,
                ),
              )
              .toList(),
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.title,
    required this.emoji,
    required this.children,
  });

  final String title;
  final String emoji;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$emoji $title',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
