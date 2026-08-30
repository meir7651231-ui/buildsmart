// 🧼 אטום · CartChatBubble — מוצר-שנוסף-לאחרונה בסגנון בועת-צ׳אט מעל ה-FAB: גליף +
// שם + שורת-מאפיינים + מחיר/כמות + ✕-סגירה צף (מטרת-הקשה 48dp). מוצא: _CartChatBubble
// (screens__home_shell.dart:486-647).
// התרת-סבך: SmartCartLine + cartLineDisplay(line) ⇒ הקופסה מפרקת ומזריקה
// emoji/name/attrs; תבניות המחיר והכמות (priceTpl/qtyTpl ב-content) מפורמטות בקופסה
// ⇒ priceLabel/qtyLabel מוכנים. תווית-הנגישות + tooltip של ה-✕ ⇒ content
// (cartChatBubbleContent). היו צרובים: Theme.of(surface) · BsTokens.brand(.25) ·
// BsTokens.inkLight · 0xFF888888 · shadow-שחור(.16) · black38/54 · 0x22000000 ⇒ params.
import 'package:flutter/material.dart';

class CartChatBubble extends StatelessWidget {
  const CartChatBubble({
    required this.emoji,
    required this.name,
    required this.attrs,
    required this.priceLabel,
    required this.qtyLabel,
    required this.onTap,
    required this.onClose,
    required this.closeSemanticsLabel,
    required this.closeTooltip,
    required this.bubbleColor,
    required this.borderColor,
    required this.shadowColor,
    required this.nameColor,
    required this.mutedColor,
    required this.priceColor,
    required this.editIconColor,
    required this.closeFillColor,
    required this.closeBorderColor,
    required this.closeIconColor,
    super.key,
  });

  final String emoji, name;

  /// שורת-מאפייני-המוצר; ריקה ⇒ שורה שנייה לא מרונדרת (כמו d.attrs.isNotEmpty במקור).
  final String attrs;

  /// מחיר/כמות מפורמטים-מראש בקופסה (₪-תבנית ו-×-תבנית ב-content).
  final String priceLabel, qtyLabel;
  final VoidCallback onTap, onClose;
  final String closeSemanticsLabel, closeTooltip;
  final Color bubbleColor, borderColor, shadowColor;
  final Color nameColor, mutedColor, priceColor, editIconColor;
  final Color closeFillColor, closeBorderColor, closeIconColor;

  static const _bubbleRadius = BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
    bottomRight: Radius.circular(16),
    bottomLeft: Radius.circular(4),
  );

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: _bubbleRadius,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color: bubbleColor,
                // צורת-בועה: פינת-הזנב (תחתית-שמאל, לכיוון ה-FAB) קטומה.
                borderRadius: _bubbleRadius,
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: nameColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        if (attrs.isNotEmpty)
                          Text(
                            attrs,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 10.5,
                              height: 1.2,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        priceLabel,
                        style: TextStyle(
                          color: priceColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        qtyLabel,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 10.5,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit_outlined, size: 13, color: editIconColor),
                ],
              ),
            ),
          ),
          // ✕-סגירה — עיגול 20dp נראה, מטרת-הקשה שקופה 48dp ממורכזת עליו (a11y).
          PositionedDirectional(
            top: -21,
            start: -21,
            child: Semantics(
              button: true,
              label: closeSemanticsLabel,
              child: Tooltip(
                message: closeTooltip,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: InkWell(
                    onTap: onClose,
                    customBorder: const CircleBorder(),
                    child: Center(
                      child: Material(
                        color: closeFillColor,
                        shape: CircleBorder(side: BorderSide(color: closeBorderColor)),
                        elevation: 2,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Icon(Icons.close, size: 13, color: closeIconColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
