// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_employer_stock_sheet:_RequestComposer (בנייה-חכמה main) · צרור-1 · props-שורש: fallback, fallback2, fallback3, hintText, labelText, hintText2, fallback4, fallback5
// התוכן: new/dart-data-bs/auto/screens__worker_employer_stock_sheet_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class RequestComposer extends StatelessWidget {
  RequestComposer({required this.fallback, required this.fallback2, required this.fallback3, required this.hintText, required this.labelText, required this.hintText2, required this.fallback4, required this.fallback5, 
    required this.composing,
    required this.itemsCtrl,
    required this.noteCtrl,
    required this.onToggle,
    required this.onSend,
  });
  final String fallback;
  final String fallback2;
  final String fallback3;
  final String hintText;
  final String labelText;
  final String hintText2;
  final String fallback4;
  final String fallback5;

  final bool composing;
  final TextEditingController itemsCtrl;
  final TextEditingController noteCtrl;
  final VoidCallback onToggle;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    if (!composing) {
      return SizedBox(
        width: double.infinity,
        // composite hide: whole button gone when the org hides this element
        child: CfgVisible(
          'worker_employer_stock_sheet.t06',
          child: FilledButton.icon(
          onPressed: onToggle,
          style: FilledButton.styleFrom(
            backgroundColor: BsTokens.brand,
            minimumSize: const Size.fromHeight(48),
          ),
          icon: const Text('🧱', style: TextStyle(fontSize: 16)),
          label: CfgText(
            'worker_employer_stock_sheet.t06',
            fallback,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CfgText(
            'worker_employer_stock_sheet.t07',
            fallback2,
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space1),
          CfgText(
            'worker_employer_stock_sheet.t08',
            fallback3,
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
          const SizedBox(height: BsTokens.space3),
          TextField(
            controller: itemsCtrl,
            maxLines: 4,
            minLines: 3,
            textDirection: TextDirection.rtl,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          TextField(
            controller: noteCtrl,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText2,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Row(
            children: [
              Expanded(
                // composite hide: whole button gone when the org hides this element
                child: CfgVisible(
                  'worker_employer_stock_sheet.t09',
                  child: FilledButton(
                  onPressed: onSend,
                  style: FilledButton.styleFrom(
                    backgroundColor: BsTokens.brand,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: CfgText(
                    'worker_employer_stock_sheet.t09',
                    fallback4,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                ),
              ),
              const SizedBox(width: BsTokens.space2),
              // composite hide: whole button gone when the org hides this element
              CfgVisible(
                'worker_employer_stock_sheet.t10',
                child: OutlinedButton(
                onPressed: onToggle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                child: CfgText('worker_employer_stock_sheet.t10', fallback5),
              ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
