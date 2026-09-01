// ✨ PremiumField — שדה-קלט פרימיום: label + value? + hint? + icon? + onChanged? + obscure.
// תווית-צפה שעולה בפוקוס · טבעת-פוקוס זוהרת · קו-אורורה תחתון שנדלק · אייקון מוביל.
// a11y: TextField נגיש (label/hint) · reduced-motion · ניגוד. חוט-טהור: material בלבד · RTL.
import 'package:flutter/material.dart';

class PremiumField extends StatefulWidget {
  const PremiumField({
    required this.label,
    this.value,
    this.hint,
    this.icon,
    this.onChanged,
    this.obscure = false,
    super.key,
  });

  final String label;
  final String? value;
  final String? hint;
  final IconData? icon;
  final ValueChanged<String>? onChanged;
  final bool obscure;

  static const _surface = Color(0xFF14151C);
  static const _hair = Color(0x1FFFFFFF);
  static const _accent = Color(0xFF7A6BFF);
  static const _glow = Color(0xFF6C5CE7);
  static const _ink = Color(0xFFF4F5F7);
  static const _muted = Color(0xFF9AA0AC);

  @override
  State<PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<PremiumField> {
  late final TextEditingController _tc = TextEditingController(text: widget.value);
  final FocusNode _fn = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _fn.addListener(() => setState(() => _focused = _fn.hasFocus));
  }

  @override
  void dispose() {
    _tc.dispose();
    _fn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final d = Duration(milliseconds: reduce ? 0 : 180);
    final active = _focused || _tc.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDefaultTextStyle(
          duration: d,
          style: TextStyle(
            color: _focused ? PremiumField._accent : PremiumField._muted,
            fontSize: active ? 12.5 : 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          child: Text(widget.label),
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: d,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: PremiumField._surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: _focused ? PremiumField._accent : PremiumField._hair,
              width: _focused ? 1.5 : 1,
            ),
            boxShadow: _focused
                ? [BoxShadow(color: PremiumField._glow.withValues(alpha: 0.28), blurRadius: 16, offset: const Offset(0, 4))]
                : null,
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                const SizedBox(width: 14),
                Icon(widget.icon,
                    size: 18, color: _focused ? PremiumField._accent : PremiumField._muted),
              ],
              Expanded(
                child: TextField(
                  controller: _tc,
                  focusNode: _fn,
                  obscureText: widget.obscure,
                  onChanged: (v) {
                    widget.onChanged?.call(v);
                    setState(() {});
                  },
                  cursorColor: PremiumField._accent,
                  style: const TextStyle(
                      color: PremiumField._ink, fontSize: 15, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                        color: Color(0xFF60636E), fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        ),
        // קו-אורורה תחתון שנדלק בפוקוס
        AnimatedContainer(
          duration: d,
          curve: Curves.easeOut,
          margin: const EdgeInsetsDirectional.fromSTEB(6, 5, 6, 0),
          height: 2,
          width: _focused ? 240 : 0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [Color(0xFF39D6F0), Color(0xFF7A6BFF), Color(0xFFC66BFF)],
            ),
          ),
        ),
      ],
    );
  }
}
