// 🧼 אטום · HelpFreezeOverlay — שכבת-ההקפאה של מצב-ההיכרות: באנר-עליון (אייקון +
// טקסט + כפתור-יציאה ≥48dp) מעל scrim-מעומעם שתופס הקשות. מוצא: _HelpModeOverlay
// (screens__home_shell.dart:291-367).
// התרת-סבך: helpModeProvider (כתיבת-היציאה) ⇒ onExit; ה-SnackBar של הקשת-ה-scrim
// (ScaffoldMessenger + שתי מחרוזות-ההדרכה) ⇒ onScrimTap — הקופסה מציגה; CfgText
// home.helpmode.banner ⇒ bannerSlot (הקופסה מזרימה CfgText, ברירת-מחדל Text מ-bannerText).
// היו צרובים: BsTokens.brand/space4/space3/space2/radiusPill · Colors.white ·
// Color(0x14000000) ⇒ כולם params.
import 'package:flutter/material.dart';

class HelpFreezeOverlay extends StatelessWidget {
  const HelpFreezeOverlay({
    required this.bannerText,
    required this.exitLabel,
    required this.onExit,
    required this.onScrimTap,
    required this.bannerFillColor,
    required this.bannerInkColor,
    required this.scrimColor,
    required this.hPad,
    required this.vPad,
    required this.iconGap,
    required this.exitRadius,
    this.bannerSlot,
    super.key,
  });

  final String bannerText;

  /// תווית-הנגישות + tooltip של כפתור-היציאה (במקור אותה מחרוזת לשניהם).
  final String exitLabel;
  final VoidCallback onExit;

  /// הקשה על האזור המעומעם — הקופסה מציגה snackbar-הכוונה (fx לא באטום).
  final VoidCallback onScrimTap;
  final Color bannerFillColor, bannerInkColor, scrimColor;
  final double hPad, vPad, iconGap, exitRadius;

  /// slot-דריסה לטקסט-הבאנר (CfgText בקופסה); null ⇒ Text(bannerText).
  final Widget? bannerSlot;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Material(
            color: bannerFillColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: bannerInkColor, size: 20),
                  SizedBox(width: iconGap),
                  Expanded(
                    child: bannerSlot ??
                        Text(
                          bannerText,
                          style: TextStyle(
                            color: bannerInkColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                  ),
                  Semantics(
                    button: true,
                    label: exitLabel,
                    child: Tooltip(
                      message: exitLabel,
                      child: InkWell(
                        onTap: onExit,
                        borderRadius: BorderRadius.circular(exitRadius),
                        // ≥48dp סביב ה-✕ הקטן (a11y) בלי להגדיל את הגליף.
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.close, color: bannerInkColor, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onScrimTap,
              child: ColoredBox(color: scrimColor),
            ),
          ),
        ],
      );
}
