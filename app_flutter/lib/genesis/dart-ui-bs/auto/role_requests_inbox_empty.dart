// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__role_requests_inbox_screen:_Empty (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class RoleRequestsInboxEmpty extends StatelessWidget {
  const RoleRequestsInboxEmpty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: const Color(0xFFBBBBBB)),
          const SizedBox(height: BsTokens.space3),
          Text(
            text,
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
