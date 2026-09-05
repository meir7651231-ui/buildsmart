// 🧼 אטום · GradientHeroCard — כרטיס-הירו גרדיאנט (glyph 34 · כותרת · תת-כותרת ·
// שברון). איחד _CopilotHero + _StudioHero (badge אופציונלי = וריאנט-הסטודיו).
// נבדק HeroCard מהמדף — כרטיס-שטוח (fill+border, glyph 28) ⇒ מנגנון שונה, לא שכפול.
// התרת-סבך: claudeGatewayProvider/studioCoEditorProvider ⇒ הקופסה בוחרת subtitle
// (live/offline · ai/manual מה-content) ומגדרת הרכבה; ניווט ⇒ onTap.
import 'package:flutter/material.dart';

class GradientHeroCard extends StatelessWidget {
  const GradientHeroCard({
    required this.glyph, required this.title, required this.subtitle,
    required this.onTap, required this.gradientStart, required this.gradientEnd,
    required this.radius, required this.gap, required this.padding,
    this.badge, this.semanticsLabel, this.heroKey, super.key,
  });

  final String glyph, title, subtitle;
  final VoidCallback onTap;
  final Color gradientStart, gradientEnd;
  final double radius;

  /// BsTokens.space3 במקור (הרווח glyph⇄טקסט).
  final double gap;

  /// EdgeInsets.all(BsTokens.space4) במקור.
  final EdgeInsetsGeometry padding;

  /// סלוט-קופסה: תג "ניסיוני" (וריאנט-הסטודיו) — TintedTag/גלולה לבנה מהקופסה.
  final Widget? badge;
  final String? semanticsLabel;
  final Key? heroKey;

  @override
  Widget build(BuildContext context) => Semantics(
        key: heroKey,
        button: true,
        label: semanticsLabel,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Row(
              children: [
                Text(glyph, style: const TextStyle(fontSize: 34)),
                SizedBox(width: gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badge == null)
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(width: gap / 1.5),
                            badge!,
                          ],
                        ),
                      const SizedBox(height: 2),
                      // לבן-מלא במקור — white70 על מותג נכשל בניגודיות.
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left, color: Colors.white),
              ],
            ),
          ),
        ),
      );
}
