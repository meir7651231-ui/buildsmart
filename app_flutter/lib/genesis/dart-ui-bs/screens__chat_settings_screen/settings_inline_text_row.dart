// 🧼 אטום · SettingsInlineTextRow — תווית + שדה-טקסט inline (שתי שורות, ממולא).
// מוצא: screens__chat_settings_screen.dart · _InlineTextRow (שורות 1006–1079), verbatim.
// label/hint מוזרקים מהתוכן; צבעי hint/מילוי (היו hex צרובים) הפכו לפרמטרי-פיגמנט.
import 'package:flutter/material.dart';

class SettingsInlineTextRow extends StatefulWidget {
  const SettingsInlineTextRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.labelColor,
    required this.inkColor,
    required this.cursorColor,
    required this.hintColor,
    required this.fillColor,
    super.key,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final Color labelColor;
  final Color inkColor;
  final Color cursorColor;
  final Color hintColor;
  final Color fillColor;

  @override
  State<SettingsInlineTextRow> createState() => _SettingsInlineTextRowState();
}

class _SettingsInlineTextRowState extends State<SettingsInlineTextRow> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant SettingsInlineTextRow old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: TextStyle(color: widget.labelColor, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctrl,
            style: TextStyle(color: widget.inkColor),
            cursorColor: widget.cursorColor,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: widget.hintColor),
              filled: true,
              fillColor: widget.fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
