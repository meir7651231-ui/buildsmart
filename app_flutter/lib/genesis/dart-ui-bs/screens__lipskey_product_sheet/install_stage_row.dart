// 🧼 אטום · InstallStageRow — שורת-שלב-התקנה מתקפלת: עיגול-מספר + גליף + תווית (+תיאור).
// מוצא: screens__lipskey_product_sheet.dart:1894-1987 (_StageRow).
// התרת-סבך: LipskeyCatStage (טיפוס-דאטה) ⇒ שדות שטוחים (numberText/emoji/label/desc/
// isFinal); צבעי success/accent (BsTokens.success · 0xFF64FFDA · 0xFF3D5A80) ⇒ פיגמנטים.
import 'package:flutter/material.dart';

class InstallStageRow extends StatelessWidget {
  const InstallStageRow({
    required this.numberText,
    required this.emoji,
    required this.label,
    required this.desc,
    required this.isActive,
    required this.isFinal,
    required this.onTap,
    required this.finalColor,
    required this.stepColor,
    required this.stepBaseColor,
    required this.inkColor,
    required this.descColor,
    required this.idleBgColor,
    required this.idleBorderColor,
    required this.chevronColor,
    super.key,
  });
  final String numberText, emoji, label, desc;
  final bool isActive, isFinal;
  final VoidCallback onTap;

  /// finalColor = צבע שלב-סיום (success במקור); stepColor = צבע שלב-רגיל (0xFF64FFDA);
  /// stepBaseColor = בסיס-הרקעים של שלב-רגיל (0xFF3D5A80).
  final Color finalColor, stepColor, stepBaseColor;
  final Color inkColor, descColor, idleBgColor, idleBorderColor, chevronColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? (isFinal
                    ? finalColor.withOpacity(0.12)
                    : stepBaseColor.withOpacity(0.2))
                : idleBgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? (isFinal
                      ? finalColor.withOpacity(0.6)
                      : stepColor.withOpacity(0.5))
                  : idleBorderColor,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isFinal
                      ? finalColor.withOpacity(0.2)
                      : stepBaseColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(numberText,
                    style: TextStyle(
                        color: isFinal ? finalColor : stepColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: inkColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    if (isActive && desc.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(desc,
                          style: TextStyle(color: descColor, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              Icon(
                isActive ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: chevronColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
