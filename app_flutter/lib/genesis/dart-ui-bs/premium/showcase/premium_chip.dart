// ✨ PremiumChip — צ׳יפ-פרימיום: label + icon? + selected + onTap + count?. מילוי-גרדיאנט
// וזוהר-מבטא בנבחר · משטח+hairline בלא-נבחר · נקודת-מצב · מונה · מיקרו-לחיצה.
// a11y: Semantics(selected/button) · reduced-motion · אין-צבע-לבד (אייקון+נקודה). חוט-טהור.
import 'package:flutter/material.dart';

class PremiumChip extends StatefulWidget {
  const PremiumChip({
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.count,
    super.key,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final int? count;

  static const _accentA = Color(0xFF7A6BFF);
  static const _accentB = Color(0xFF5B4CE0);
  static const _glow = Color(0xFF6C5CE7);
  static const _surface = Color(0xFF16171F);
  static const _hair = Color(0x1FFFFFFF);
  static const _ink = Color(0xFFF4F5F7);
  static const _muted = Color(0xFF9AA0AC);

  @override
  State<PremiumChip> createState() => _PremiumChipState();
}

class _PremiumChipState extends State<PremiumChip> {
  bool _pressed = false;
  bool get _enabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final sel = widget.selected;
    final fg = sel ? Colors.white : PremiumChip._muted;

    final chip = AnimatedContainer(
      duration: Duration(milliseconds: reduce ? 0 : 180),
      curve: Curves.easeOut,
      height: 38,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
      decoration: BoxDecoration(
        gradient: sel
            ? const LinearGradient(colors: [PremiumChip._accentA, PremiumChip._accentB])
            : null,
        color: sel ? null : PremiumChip._surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: sel ? const Color(0x2EFFFFFF) : PremiumChip._hair),
        boxShadow: sel
            ? [BoxShadow(color: PremiumChip._glow.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5))]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 16, color: fg),
            const SizedBox(width: 7),
          ] else if (sel) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            widget.label,
            style: TextStyle(
                color: sel ? PremiumChip._ink : PremiumChip._muted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1),
          ),
          if (widget.count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(7, 2, 7, 2),
              decoration: BoxDecoration(
                color: sel ? const Color(0x33FFFFFF) : const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${widget.count}',
                style: TextStyle(
                    color: sel ? Colors.white : PremiumChip._muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: sel,
      label: widget.label,
      child: Opacity(
        opacity: _enabled ? 1 : 0.5,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          child: AnimatedScale(
            scale: _pressed && _enabled ? 0.95 : 1,
            duration: Duration(milliseconds: reduce ? 0 : 110),
            child: chip,
          ),
        ),
      ),
    );
  }
}
