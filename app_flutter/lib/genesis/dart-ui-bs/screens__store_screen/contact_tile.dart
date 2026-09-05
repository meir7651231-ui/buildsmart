// 🧼 אטום · ContactTile — שורת-איש-קשר: אווטאר-גליף בעיגול + שם + אייקון-trailing.
// מוצא: screens__store_screen.dart:1005-1034 (גוף _SichaSheet). אנשי-הקשר עברו ל-content
// (sichaContacts); טוסט-הלחיצה (t_f7944ba2) = קופסה, כאן callback בלבד.
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({
    required this.avatar, required this.name, required this.onTap,
    required this.avatarBgColor, required this.inkColor,
    required this.trailingIcon, required this.trailingColor, super.key,
  });
  final String avatar, name;
  final VoidCallback onTap;
  final Color avatarBgColor, inkColor, trailingColor;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: avatarBgColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(avatar, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(name, style: TextStyle(color: inkColor, fontSize: 15)),
        trailing: Icon(trailingIcon, color: trailingColor),
        onTap: onTap,
      );
}
