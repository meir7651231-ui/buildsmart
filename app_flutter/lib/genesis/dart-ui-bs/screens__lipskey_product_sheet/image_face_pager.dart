// 🧼 אטום · ImageFacePager — פנים-כרטיס: תמונה נלחצת-לזום + פייג'ר 1/N + כפתור-היפוך.
// מוצא: screens__lipskey_product_sheet.dart:1559-1732 (_ProductSide) + 1760-1891
// (_SpecSide) — דדופ פנים-מסך: אותו מנגנון (didUpdateWidget מאפס פייג'ר לפי resetKey,
// טאפ=זום, chip 1/N עם יעד-48dp, כפתור-flip תחתון-שמאלי 48dp). ההבדלים ⇒ props:
// background/overlay (גרדיאנט-רדיאלי של צד-המוצר), cornerBadge (תג PPR-CT), אייקון/תווית
// כפתור-ההיפוך, hint (שקע ל-ZoomHintBadge). productImage (data/product_images) ⇒
// imageBuilder — הקופסה מזרימה את התמונות; מונחי-הפייג'ר (t_a0e071ac / t_7c95e6fb)
// ותווית-ההיפוך (t_e0157a6d / t_d5bd65f6) מוזרמים מ-content.
import 'package:flutter/material.dart';

class ImageFacePager extends StatefulWidget {
  const ImageFacePager({
    required this.resetKey,
    required this.imageCount,
    required this.imageBuilder,
    required this.onZoom,
    required this.onFlip,
    required this.pagerLabel,
    required this.flipLabel,
    required this.flipIcon,
    required this.backgroundColor,
    required this.flipBgColor,
    required this.flipFgColor,
    required this.pagerBgColor,
    required this.pagerFgColor,
    this.backgroundOverlay,
    this.cornerBadge,
    this.hint,
    this.expandStack = false,
    super.key,
  });

  /// מזהה-איפוס (במקור: product.sku) — התחלפות ⇒ הפייג'ר חוזר לתמונה 0.
  final String resetKey;
  final int imageCount;
  final Widget Function(BuildContext context, int index) imageBuilder;
  final VoidCallback onZoom, onFlip;

  /// תווית-Semantics/Tooltip של chip-הפייג'ר.
  final String pagerLabel;

  /// תווית כפתור-ההיפוך התחתון + האייקון שלו.
  final String flipLabel;
  final IconData flipIcon;
  final Color backgroundColor, flipBgColor, flipFgColor, pagerBgColor, pagerFgColor;

  /// שכבת-רקע (גרדיאנט-רדיאלי בצד-המוצר; null בצד-המפרט).
  final Widget? backgroundOverlay;

  /// תג-פינה תחתון-ימני (PPR-CT בצד-המוצר).
  final Widget? cornerBadge;

  /// שקע לתג-רמז-הזום (ZoomHintBadge) בפינה העליונה-ימנית.
  final Widget? hint;

  /// true = StackFit.expand (צד-המפרט); false = יישור-מרכז (צד-המוצר).
  final bool expandStack;

  @override
  State<ImageFacePager> createState() => _ImageFacePagerState();
}

class _ImageFacePagerState extends State<ImageFacePager> {
  int _i = 0;

  @override
  void didUpdateWidget(ImageFacePager old) {
    super.didUpdateWidget(old);
    if (old.resetKey != widget.resetKey) _i = 0;
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.imageCount;
    final i = count > 0 ? _i % count : 0;
    return GestureDetector(
      onTap: widget.onZoom,
      child: Container(
        color: widget.backgroundColor,
        child: Stack(
          fit: widget.expandStack ? StackFit.expand : StackFit.loose,
          alignment: Alignment.center,
          children: [
            if (widget.backgroundOverlay != null) widget.backgroundOverlay!,
            widget.imageBuilder(context, i),
            if (count > 1)
              Positioned(
                top: 0,
                left: 0,
                child: Semantics(
                  button: true,
                  label: widget.pagerLabel,
                  child: Tooltip(
                    message: widget.pagerLabel,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _i = (i + 1) % count),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 48, minHeight: 48),
                        child: Center(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: widget.pagerBgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${i + 1}/$count',
                                style: TextStyle(
                                    color: widget.pagerFgColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.hint != null)
              Positioned(top: 10, right: 10, child: widget.hint!),
            if (widget.cornerBadge != null)
              Positioned(bottom: 10, right: 10, child: widget.cornerBadge!),
            Positioned(
              bottom: 0,
              left: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onFlip,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: widget.flipBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.flipIcon,
                              color: widget.flipFgColor, size: 14),
                          const SizedBox(width: 5),
                          Text(widget.flipLabel,
                              style: TextStyle(
                                  color: widget.flipFgColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
