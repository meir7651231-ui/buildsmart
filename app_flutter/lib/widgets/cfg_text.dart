import 'package:buildsmart/state/studio/config_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The No-Code Studio CONSUMER widget — a drop-in replacement for a `Text` on a
/// registered element `id`. It watches [resolvedCfgProvider] so an owner Studio
/// edit (text / emoji / visibility) becomes VISIBLE live:
///
///   `const Text('הזמן עכשיו', style: s)`  →  `CfgText('cart.cta', 'הזמן עכשיו', style: s)`
///
/// Zero-regression contract: with NO edit the resolver returns [CfgNode.identity],
/// so this renders [fallback] verbatim (byte-identical to the original Text). An
/// edit overlays: `text` replaces the label, `emoji` is prefixed, `hidden==true`
/// collapses the element to [SizedBox.shrink]. Because CfgText is its own
/// [ConsumerWidget], the surrounding widget does NOT need a `ref`.
class CfgText extends ConsumerWidget {
  const CfgText(
    this.id,
    this.fallback, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
  });

  /// The registered element id (e.g. `'catalog.action.addToProject'`).
  final String id;

  /// The verbatim original text — shown when no owner override exists.
  final String fallback;

  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool? softWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(resolvedCfgProvider(id));
    if (cfg.hidden ?? false) return const SizedBox.shrink();
    final label = cfg.text ?? fallback;
    final shown = cfg.emoji != null ? '${cfg.emoji} $label' : label;
    return Text(
      shown,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
    );
  }
}
