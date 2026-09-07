// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מחבר-ישות-למסך: רשומות-ישות ⇒ מסך-Composed מפורק (סורק-אוטומטי). אל תערוך ידנית.
import '../dart-screens-bs/lipskey_product_sheet.g.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';

class GenAppSechirutBind4Screen extends StatelessWidget {
  const GenAppSechirutBind4Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => LipskeyProductSheetComposed(
          onChanged: (_) {},
          pickerOptionItems: appStore.records('app_sechirut_ent4').map((r) => PickerOptionItem(value: r.entries.firstWhere((e) => !e.key.startsWith('__') && e.value.trim().isNotEmpty, orElse: () => MapEntry('', r['__id'] ?? '')).value.trim(), isSelected: false, onTap: () {})).toList(),
          qty: 0,
          subtitle: '',
          text: '',
          t: const LipskeyProductSheetTokens(),
        ),
      );
}
