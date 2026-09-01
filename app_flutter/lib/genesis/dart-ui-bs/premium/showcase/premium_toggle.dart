// ✨ PremiumToggle — מתג-פרימיום: value + onChanged + label?. מסילת-גרדיאנט זוהרת במצב-דלוק,
// כפתור-קפיץ שמחליק (spring), זוהר-מבטא, אייקון-מצב פנימי. a11y: Semantics(toggled) ·
// reduced-motion · touch≥48. חוט-טהור: material בלבד · פיגמנט const · טקסט דרך פרמטר · RTL.
import 'package:flutter/material.dart';

class PremiumToggle extends StatelessWidget {
  const PremiumToggle({required this.value, this.onChanged, this.label, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  static const _trackOff = Color(0xFF1B1C24);
  static const _knob = Color(0xFFFFFFFF);
  static const _accentA = Color(0xFF7A6BFF);
  static const _accentB = Color(0xFF5B4CE0);
  static const _glow = Color(0xFF6C5CE7);
  static const _ink = Color(0xFFE9EDF3);
  static const _hair = Color(0x1FFFFFFF);

  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final d = Duration(milliseconds: reduce ? 0 : 240);

    final track = AnimatedContainer(
      duration: d,
      curve: Curves.easeOutCubic,
      width: 54,
      height: 32,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: value
            ? const LinearGradient(colors: [_accentA, _accentB])
            : null,
        color: value ? null : _trackOff,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: value ? const Color(0x33FFFFFF) : _hair),
        boxShadow: value
            ? [BoxShadow(color: _glow.withValues(alpha: 0.42), blurRadius: 14, offset: const Offset(0, 4))]
            : null,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: d,
            curve: Curves.easeOutBack,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: _knob,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x59000000), blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: AnimatedSwitcher(
                duration: d,
                child: Icon(
                  value ? Icons.check_rounded : Icons.close_rounded,
                  key: ValueKey(value),
                  size: 15,
                  color: value ? _accentB : const Color(0xFF9AA0AC),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final row = label == null
        ? track
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label!,
                  style: const TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 14),
              track,
            ],
          );

    return Semantics(
      toggled: value,
      enabled: _enabled,
      label: label,
      child: Opacity(
        opacity: _enabled ? 1 : 0.5,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? () => onChanged!(!value) : null,
          child: row,
        ),
      ),
    );
  }
}
