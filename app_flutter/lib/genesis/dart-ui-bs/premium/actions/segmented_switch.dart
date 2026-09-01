// ✨ SegmentedSwitch — בורר-מקטעים בקופסת-זכוכית כהה; המקטע הנבחר בגרדיאנט סגול→מגנטה עם זוהר. מקבל items · selected · onSelect.
import 'package:flutter/material.dart';

class SegmentedSwitch extends StatelessWidget {
  const SegmentedSwitch({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  final List<String> items;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0E0B1A).withValues(alpha: 0.85),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++)
            _Segment(
              label: items[i],
              active: i == selected,
              onTap: () => onSelect(i),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: active
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
              )
            : null,
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.42),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : const Color(0xFFF2F3FF).withValues(alpha: 0.55),
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
