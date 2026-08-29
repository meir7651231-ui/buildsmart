// 🧼 אטום · OrdersHiddenNotice — הודעת-פרטיות מרכז-מסך: גליף, כותרת, רמז, וכפתור-פעולה.
// מוצא: screens__store_screen.dart:3894 (_OrdersHidden). התרת-סבך: כתיבת
// storeSettingsProvider (purchaseHistory=true) ⇒ onAction; המונחים (t_36b56af9 /
// t_8ddb4b04 / t_e727f18c, CfgText+CfgVisible) מוזרקים ע״י הקופסה.
import 'package:flutter/material.dart';

class OrdersHiddenNotice extends StatelessWidget {
  const OrdersHiddenNotice({
    required this.glyph, required this.title, required this.hint,
    required this.actionLabel, required this.onAction,
    required this.inkColor, required this.mutedColor, super.key,
  });
  final String glyph, title, hint, actionLabel;
  final VoidCallback onAction;
  final Color inkColor, mutedColor;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(glyph, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(color: inkColor, fontSize: 17, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hint,
                      style: TextStyle(color: mutedColor, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
