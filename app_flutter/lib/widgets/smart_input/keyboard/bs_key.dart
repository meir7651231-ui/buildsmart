import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter/material.dart';

/// A single key on the custom Hebrew keyboard. Pure presentation: it renders a
/// [KbKey] model and forwards taps via [onTap]. No controller / Riverpod / flag
/// awareness lives here — layout & state are the caller's job.
class BsKey extends StatelessWidget {
  /// The key to render (label, kind, output, flex, superscript).
  final KbKey model;

  /// Invoked when the key is tapped.
  final VoidCallback onTap;

  /// When true the key is the Send action → brand-orange fill with an
  /// accent-legible foreground.
  final bool isAccent;

  const BsKey({
    super.key,
    required this.model,
    required this.onTap,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = isAccent ? BsTokens.brand : Colors.white;
    final Color fg = isAccent ? bsOnAccent(context) : BsTokens.inkLight;

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
        child: Semantics(
          button: true,
          label: _semanticLabel,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
              border: isAccent
                  ? null
                  : Border.all(color: BsTokens.divider),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(child: _content(fg)),
                if (model.superscript != null)
                  Positioned(
                    top: BsTokens.spaceHair,
                    right: BsTokens.space1,
                    child: Text(
                      model.superscript!,
                      style: TextStyle(
                        fontSize: BsTokens.fontXs + 2, // ~10
                        color: fg.withValues(alpha: 0.45),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tool kinds render a Material icon; symbols and text kinds render the label.
  Widget _content(Color fg) {
    final IconData? icon = _iconFor(model.kind);
    if (icon != null) {
      return Icon(icon, size: BsTokens.dialIconSize, color: fg);
    }
    return Text(
      model.label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 17,
        color: fg,
        fontWeight: isAccent ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  /// Maps tool kinds to their Material icon. Returns null for kinds that render
  /// their label as text (letter, period, punct, space, symbols).
  static IconData? _iconFor(KeyKind kind) {
    switch (kind) {
      case KeyKind.backspace:
        return Icons.backspace_outlined;
      case KeyKind.enter:
        return Icons.keyboard_return;
      case KeyKind.send:
        return Icons.send;
      case KeyKind.language:
        return Icons.language;
      case KeyKind.letter:
      case KeyKind.space:
      case KeyKind.symbols:
      case KeyKind.period:
      case KeyKind.punct:
        return null;
    }
  }

  /// A human/screen-reader-friendly label: action name for tool keys, raw
  /// label otherwise.
  String get _semanticLabel {
    switch (model.kind) {
      case KeyKind.backspace:
        return 'מחק';
      case KeyKind.enter:
        return 'שורה חדשה';
      case KeyKind.send:
        return 'שלח';
      case KeyKind.language:
        return 'שפה';
      case KeyKind.space:
        return 'רווח';
      case KeyKind.symbols:
      case KeyKind.letter:
      case KeyKind.period:
      case KeyKind.punct:
        return model.label;
    }
  }
}
