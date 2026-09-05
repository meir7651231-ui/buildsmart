// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__chat_settings_screen:_InlineTextRow (בנייה-חכמה main) · Stateful+State
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class InlineTextRow extends StatefulWidget {
  const InlineTextRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<InlineTextRow> createState() => InlineTextRowState();
}

class InlineTextRowState extends State<InlineTextRow> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant InlineTextRow old) {
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
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctrl,
            style: const TextStyle(color: BsTokens.inkLight),
            cursorColor: BsTokens.brand,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              filled: true,
              fillColor: const Color(0xFFF2F3F5),
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
