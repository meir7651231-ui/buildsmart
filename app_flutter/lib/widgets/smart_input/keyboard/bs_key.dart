import 'package:buildsmart/data/product_images.dart' show resolveProductImage;
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter/material.dart';

/// Per-cell RESPONSIVE sizing for the keyboard — the cell HEIGHT, glyph FONT
/// size, and ICON size that every leaf cell ([BsKey] and the strip/tile widgets
/// in bs_keyboard.dart) renders at. [BsKeyboard] computes one of these from the
/// viewport width (mobile vs desktop) and supplies it via [BsKbScale]; each leaf
/// reads it with [BsKbScale.of].
///
/// The default ([desktop]) is the historical 44 / 20 / 22, and it is ALSO the
/// fallback [BsKbScale.of] returns when no [BsKbScale] is in scope (a leaf
/// mounted in a direct widget test). So every existing direct mount and every
/// desktop render stays byte-identical; only a narrow (phone) viewport shrinks.
@immutable
class KbCellMetrics {
  const KbCellMetrics({
    this.cellHeight = 44,
    this.fontSize = 20,
    this.iconSize = BsTokens.dialIconSize,
  });

  /// Minimum height of one cell (a key / tool tile / chip / toggle).
  final double cellHeight;

  /// Font size of the key/label glyph.
  final double fontSize;

  /// Size of an icon-kind glyph (send · globe · enter · tool icons · ▦ · ⚙️).
  final double iconSize;

  /// The historical desktop sizing — also the no-scope fallback.
  static const KbCellMetrics desktop = KbCellMetrics();

  @override
  bool operator ==(Object other) =>
      other is KbCellMetrics &&
      other.cellHeight == cellHeight &&
      other.fontSize == fontSize &&
      other.iconSize == iconSize;

  @override
  int get hashCode => Object.hash(cellHeight, fontSize, iconSize);
}

/// Provides the responsive [KbCellMetrics] to the keyboard's leaf cells. A leaf
/// reads its sizing with `BsKbScale.of(context)`; with no [BsKbScale] ancestor
/// the call returns [KbCellMetrics.desktop], so an unscoped leaf is unchanged.
class BsKbScale extends InheritedWidget {
  const BsKbScale({required this.metrics, required super.child, super.key});

  final KbCellMetrics metrics;

  /// The nearest scope's metrics, or [KbCellMetrics.desktop] when none is in
  /// scope (keeping direct/legacy mounts byte-identical).
  static KbCellMetrics of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BsKbScale>()?.metrics ??
      KbCellMetrics.desktop;

  @override
  bool updateShouldNotify(BsKbScale oldWidget) => metrics != oldWidget.metrics;
}

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

  /// Optional product-thumbnail asset shown BEFORE the text label.
  ///
  /// Null is the default EVERYWHERE — every existing call site omits it, so the
  /// key renders byte-identically to before (a single centered [Text] / [Icon],
  /// no structural change). Only the word-finder's FINAL selection keys (a
  /// ShowProducts / connections product key) pass a real per-product crop here.
  /// When non-null AND the key is a text kind, [_content] becomes a centered
  /// Row: a small rounded thumbnail, a hair gap, then the SAME [Text] label
  /// (kept as a plain `Text` so `find.widgetWithText(BsKey, label)` still
  /// matches). An icon-kind key NEVER takes a leading image — its early `Icon`
  /// return in [_content] runs first and ignores this entirely.
  // OWNER-REVIEW: the thumbnail SIZE (~32 logical px), POSITION (leading, before
  // the label), and FORMAT (rounded, BoxFit.cover, cacheWidth ~64) are all
  // reversible defaults — pass null (the default) anywhere to drop the image and
  // fall back to the plain text key.
  final String? leadingImageAsset;

  /// Optional leading axis glyph (swarm R8 / §5 #22): a small icon before the
  /// label so a merged chip's AXIS is distinguishable without colour (WCAG 1.4.1).
  /// Null on every non-chip key → byte-identical. (Chips carry no thumbnail, so
  /// this and [leadingImageAsset] are mutually exclusive in practice.)
  final IconData? axisGlyph;

  /// Optional Semantics label override (swarm R8 / §5 #23, WCAG 2.5.3): a merged
  /// chip announces '${axisName}: ${displayLabel}'. Null → the raw [model.label]
  /// (today's behaviour) for every other key.
  final String? semanticOverride;

  const BsKey({
    super.key,
    required this.model,
    required this.onTap,
    this.isAccent = false,
    this.leadingImageAsset,
    this.axisGlyph,
    this.semanticOverride,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = isAccent ? BsTokens.brand : Colors.white;
    final Color fg = isAccent ? bsOnAccent(context) : BsTokens.inkLight;
    // RESPONSIVE sizing — desktop 44/20/22 (the const default when no scope),
    // mobile shrinks via the [BsKbScale] that [BsKeyboard] installs.
    final KbCellMetrics m = BsKbScale.of(context);

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
        child: Semantics(
          button: true,
          label: _semanticLabel,
          // When an axis-prefixed override is set (a merged chip), announce ONLY
          // that clean label — exclude the child Text so a screen reader hears
          // 'גודל: 1/2"' once, not a doubled 'גודל: 1/2" … 1/2"' (swarm R8). Null
          // override ⇒ false ⇒ every other key is byte-identical.
          excludeSemantics: semanticOverride != null,
          child: Container(
            // Owner: UNIFORM keyboard — every cell (keys · tools · nav chips ·
            // bottom row) is the SAME height with the SAME glyph; the exact
            // values are responsive (desktop 44/20, mobile 30/19 — owner spec).
            constraints: BoxConstraints(minHeight: m.cellHeight),
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
                Center(child: _content(fg, m)),
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
  ///
  /// When [leadingImageAsset] is non-null on a TEXT kind, the label is preceded
  /// by a small rounded product thumbnail in a centered [Row]. The icon branch
  /// runs FIRST, so an icon-kind key never takes a leading image. When the asset
  /// is null the original single-[Text] body is returned UNCHANGED (no Row, no
  /// wrapping) so every plain key in the app stays byte-identical.
  Widget _content(Color fg, KbCellMetrics m) {
    final IconData? icon = _iconFor(model.kind);
    if (icon != null) {
      return Icon(icon, size: m.iconSize, color: fg);
    }
    final label = Text(
      model.label,
      textAlign: TextAlign.center,
      style: TextStyle(
        // Glyph size is responsive (desktop 20, mobile 19 — owner spec).
        fontSize: m.fontSize,
        color: fg,
        fontWeight: isAccent ? FontWeight.w700 : FontWeight.w500,
      ),
    );
    final asset = leadingImageAsset;
    if (asset == null) {
      // A leading AXIS glyph (swarm R8 / §5 #22) when set — a small icon before
      // the label so a merged chip's axis is distinguishable WITHOUT colour. Null
      // on every non-chip key, so a plain key returns the bare label UNCHANGED.
      final glyph = axisGlyph;
      if (glyph == null) return label;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(glyph, size: m.fontSize * 0.9, color: fg.withValues(alpha: 0.75)),
          const SizedBox(width: BsTokens.spaceHair),
          Flexible(child: label),
        ],
      );
    }
    // Thumbnail pinned to the FAR (RTL) edge: the keyboard is LTR-ordered, so the
    // LAST child sits at the key's RIGHT edge. The label fills the rest via an
    // [Expanded] (the image is pushed hard to the right, not centered beside the
    // text). The label stays a plain [Text] (so text-based finds keep matching)
    // with two lines + ellipsis so a long label never overflows a narrow key.
    // OWNER-REVIEW: thumbnail anchored to the right edge.
    return Row(
      children: [
        Expanded(
          child: Text(
            model.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: m.fontSize,
              color: fg,
              fontWeight: isAccent ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: BsTokens.space1),
        _Thumb(asset),
      ],
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
      case KeyKind.gear:
        return Icons.settings;
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
      case KeyKind.gear:
        return 'כלי מקלדת';
      case KeyKind.symbols:
      case KeyKind.letter:
      case KeyKind.period:
      case KeyKind.punct:
        // semanticOverride is null on every key EXCEPT a merged card-keyboard
        // chip (which announces '${axisName}: ${displayLabel}', §5 #23) → every
        // other key is byte-identical.
        return semanticOverride ?? model.label;
    }
  }
}

/// A small rounded product thumbnail shown at the trailing (right) edge of a
/// [BsKey], beside its label.
///
/// Resolves the image through the app's single source of truth
/// [resolveProductImage] — the SAME helper every other product surface uses — so
/// it streams from the Cloudflare R2 CDN (or the bundled asset when no CDN base
/// is configured). It deliberately does NOT use a raw `Image.asset`: the app
/// does not bundle the product crops, so a raw asset load would silently
/// collapse to nothing in a release build (the resolver-bypass class this
/// avoids). The provider is wrapped in a [ResizeImage] at [_cacheWidth] so a
/// list of thumbnails never decodes at full resolution, and the `errorBuilder`
/// returns an empty `SizedBox.shrink` so a missing, corrupt, or not-yet-fetched
/// image NEVER throws and NEVER overflows the key — in the widget-test
/// environment the bytes do not decode, so this is the path that keeps those
/// tests green while `find.byType(Image)` still sees the Image widget.
// OWNER-REVIEW: size / radius / cacheWidth are reversible visual defaults.
class _Thumb extends StatelessWidget {
  const _Thumb(this.asset);

  final String asset;

  static const double _size = 40; // logical px — beside the label, at the edge
  static const double _radius = 6;
  static const int _cacheWidth = 80; // ~2x _size, memory-frugal decode

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: Image(
        // Route through the app image resolver (CDN + on-device cache, or the
        // bundled asset when no CDN base is set) — NOT a raw Image.asset, which
        // would find no bundled crop and vanish in a release build. ResizeImage
        // caps decode memory for a list of small thumbnails.
        image: ResizeImage(resolveProductImage(asset), width: _cacheWidth),
        width: _size,
        height: _size,
        // contain (not cover) so the WHOLE product is visible — never cropped.
        // OWNER-REVIEW: BoxFit.contain.
        fit: BoxFit.contain,
        // Decorative beside the text label — the key's Semantics carries meaning.
        excludeFromSemantics: true,
        // A missing / undecodable / not-yet-fetched image collapses to nothing —
        // never a crash, never an overflow. Critical for tests and for products
        // with no photo.
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
