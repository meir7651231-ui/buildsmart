// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 10 — CfgText, the content wrapper.
//
// `CfgText(id, fallback)` is a drop-in for `Text(fallback)`. With an empty doc (⇒
// kStudioFlag OFF) the resolved node is identity ⇒ it renders the Hebrew literal
// VERBATIM, with the SAME style/align/maxLines as the raw Text — the zero-regression
// contract. When the owner has published an override it applies text / emoji / a
// token-driven style on top, and (in edit-mode) wraps the result in EditHandle.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_node.dart' show CfgStyle;
import 'package:buildsmart/state/studio/config_store.dart'
    show resolvedNodeProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:buildsmart/widgets/studio/edit_handle.dart' show EditHandle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owner-facing color tokens → palette color. Unknown ⇒ null (keep the base color).
/// The theme editor (step 24) offers exactly this vocabulary; expand together.
Color? cfgColorFromToken(String? t) {
  switch (t) {
    case 'brand':
      return BsTokens.brand;
    case 'brandDark':
      return BsTokens.brandDark;
    case 'success':
      return BsTokens.success;
    case 'danger':
      return BsTokens.danger;
    case 'warn':
      return BsTokens.warnText;
    case 'ink':
      return BsTokens.inkLight;
    case 'muted':
      return BsTokens.mutedLight;
    default:
      return null;
  }
}

/// Owner-facing weight tokens → [FontWeight]. Unknown ⇒ null (keep the base).
FontWeight? cfgWeightFromToken(String? t) {
  switch (t) {
    case 'bold':
    case 'w700':
      return FontWeight.w700;
    case 'semibold':
    case 'w600':
      return FontWeight.w600;
    case 'medium':
    case 'w500':
      return FontWeight.w500;
    case 'normal':
    case 'w400':
      return FontWeight.w400;
    default:
      return null;
  }
}

/// Owner-facing size tokens → font size (BsTokens type scale). Unknown ⇒ null.
double? cfgSizeFromToken(String? t) {
  switch (t) {
    case 'sm':
      return BsTokens.typeLabel; // 13
    case 'md':
      return BsTokens.typeBody; // 14
    case 'lg':
      return BsTokens.typeSubhead; // 16
    case 'xl':
      return BsTokens.typeTitleMd; // 20
    default:
      return null;
  }
}

/// The effective text style. **No override ⇒ returns [callSite] EXACTLY** (the
/// identity path — proven equal in the test, so OFF is zero-regression). With an
/// override it folds the tokens onto the inherited+call-site base: explicit
/// size/weight/color tokens first, then [CfgStyle.fontScale] multiplies.
TextStyle? applyCfgTextStyle(
  BuildContext context,
  TextStyle? callSite,
  CfgStyle? override,
) {
  if (override == null) return callSite; // ← zero-regression identity
  var eff = DefaultTextStyle.of(context).style.merge(callSite);
  final color = cfgColorFromToken(override.colorToken);
  if (color != null) eff = eff.copyWith(color: color);
  final weight = cfgWeightFromToken(override.weightToken);
  if (weight != null) eff = eff.copyWith(fontWeight: weight);
  final size = cfgSizeFromToken(override.sizeToken);
  if (size != null) eff = eff.copyWith(fontSize: size);
  final scale = override.fontScale;
  if (scale != null) eff = eff.copyWith(fontSize: (eff.fontSize ?? 14) * scale);
  return eff;
}

/// A studio-editable text. Drop-in for `Text(fallback, …)`: empty doc ⇒ the literal
/// verbatim; published override ⇒ text/emoji/style applied; edit-mode ⇒ EditHandle.
class CfgText extends ConsumerWidget {
  const CfgText(
    this.id,
    this.fallback, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String id;
  final String fallback;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(resolvedNodeProvider(id));
    final txt = n.text ?? fallback;
    final display = n.emoji == null ? txt : '${n.emoji} $txt';
    return EditHandle.maybe(
      ref,
      id,
      child: Text(
        display,
        style: applyCfgTextStyle(context, style, n.style),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
      ),
    );
  }
}
