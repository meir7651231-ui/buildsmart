// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__chats_screen:_TypingBubble (בנייה-חכמה main) · צרור-1 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__chats_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/screens/chats_screen.dart';

class TypingBubble extends StatelessWidget {
  TypingBubble({required this.fallback});
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: chatBubbleAlignment(isMe: false), // typing = incoming = other
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(16),
            topEnd: Radius.circular(16),
            bottomStart: Radius.circular(16),
            bottomEnd: Radius.circular(4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: CfgText(
          'chats_screen.typing',
          fallback,
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
