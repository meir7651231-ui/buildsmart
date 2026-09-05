// 🧼 אטום · TintedTag — תג/גלולה בשטיפת-צבע (מילוי-אלפא + טקסט בצבע-מלא).
// איחד: _StagePill (אלפא .12, רדיוס-גלולה, fs12 w800, ריפוד 10/4) ·
// _ApprovalBadge/_RoleBadge (אלפא .10, רדיוס 6, typeLabel w700, ריפוד space2/3) ·
// _RfmPill (אלפא .10, רדיוס 6, typeLabel w700, ריפוד space2/3) — פיגמנטים כ-params.
// התרת-סבך: orgTerm של _RfmPill ⇒ הקופסה מזריקה label סופי (rfmTiers מה-content).
import 'package:flutter/material.dart';

class TintedTag extends StatelessWidget {
  const TintedTag({
    required this.label, required this.color, required this.fillAlpha,
    required this.radius, required this.fontSize, required this.fontWeight,
    required this.horizontalPadding, required this.verticalPadding, super.key,
  });

  final String label;
  final Color color;
  final double fillAlpha, radius, fontSize, horizontalPadding, verticalPadding;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: fillAlpha),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      );
}
