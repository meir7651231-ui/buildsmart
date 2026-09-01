// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מחבר-ישות-למסך: רשומות-ישות ⇒ מסך-Composed מפורק (סורק-אוטומטי). אל תערוך ידנית.
import '../dart-screens-bs/lipskey_product_sheet.g.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-data-bs/auto/gen_app_bind4_content.dart';
import 'package:flutter/material.dart';

class GenAppBind4Screen extends StatelessWidget {
  const GenAppBind4Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => LipskeyProductSheetComposed(
          onChanged: (_) {},
          pickerOptionItems: appStore.scoped('app_ent4', gen_app_bind4_c0).map((r) => PickerOptionItem(value: r.entries.firstWhere((e) => !e.key.startsWith('__') && e.value.trim().isNotEmpty, orElse: () => MapEntry('', r['__id'] ?? '')).value.trim(), isSelected: false, onTap: () {})).toList(),
          qty: 0,
          subtitle: '',
          text: '',
          t: const LipskeyProductSheetTokens(),
        ),
      );
}
