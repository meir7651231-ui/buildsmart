// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_copilot_screen:_InputBar (בנייה-חכמה main) · צרור-1 · props-שורש: hintText, tooltip
// התוכן: new/dart-data-bs/auto/screens__manager_copilot_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class InputBar extends StatelessWidget {
  InputBar(
      {required this.hintText, required this.tooltip, required this.controller, required this.enabled, required this.onSend});
  final String hintText;
  final String tooltip;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: const Border(top: BorderSide(color: BsTokens.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: hintText,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: BsTokens.space4, vertical: BsTokens.space3),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            IconButton.filled(
              tooltip: tooltip, // a11y: screen-reader label for the send button
              onPressed: enabled ? onSend : null,
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
