import 'package:buildsmart/state/app_profile.dart' show kProfileImageBaseUrl;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Base URL of the cloud image store (Cloudflare R2). Full-quality product/page
/// images live here; the app does NOT bundle them, so it stays light. Override
/// at build time with --dart-define=IMAGE_BASE_URL=... ; empty → bundled assets
/// — the default follows the build profile ([kProfileImageBaseUrl]): today's
/// R2 base on demo/buildsmart, empty (bundled assets) on clean.
// stage-3.4: profile-aware default (explicit define still wins).
const String kImageBaseUrl = String.fromEnvironment(
  'IMAGE_BASE_URL',
  defaultValue: kProfileImageBaseUrl,
);

/// Bounded on-device cache so the device never fills up — even with a 60k+
/// image catalog: only viewed images are kept, at most [_maxCachedImages]
/// (LRU evicted). ~700 × ~80KB ≈ a few tens of MB, hard-capped.
const int _maxCachedImages = 700;
final CacheManager productImageCache = CacheManager(
  Config(
    'bsProductImageCache',
    maxNrOfCacheObjects: _maxCachedImages,
    stalePeriod: const Duration(days: 60),
  ),
);

/// Pure mapping: a bundled asset path → its full-quality CDN URL. Strips the
/// leading `assets/` so the on-disk layout maps 1:1 to the bucket layout
/// ('assets/lipskey/products/x.jpeg' → '<base>/lipskey/products/x.jpeg').
String productImageUrl(String assetPath) {
  final rel = assetPath.startsWith('assets/')
      ? assetPath.substring('assets/'.length)
      : assetPath;
  return '$kImageBaseUrl/$rel';
}

/// Single source of truth for resolving a product/page image given its bundled
/// asset path (e.g. 'assets/lipskey/products/116635.jpeg').
/// - [kImageBaseUrl] set  → full-quality image from the CDN, cached on-device.
/// - [kImageBaseUrl] empty → the bundled asset (unchanged).
ImageProvider resolveProductImage(String assetPath) {
  if (kImageBaseUrl.isEmpty) {
    return AssetImage(assetPath);
  }
  return CachedNetworkImageProvider(
    productImageUrl(assetPath),
    cacheManager: productImageCache,
  );
}

/// Subtle neutral placeholder shown while a CDN image streams in, and the
/// fade-in once the first frame arrives. Applied as the DEFAULT `frameBuilder`
/// for [productImage] so every call-site gets it for free (no blank circles /
/// boxes popping in on a slow connection). A caller that passes its own
/// `frameBuilder` keeps full control. Bundled-asset mode decodes synchronously,
/// so `wasSynchronouslyLoaded` short-circuits and there is no visible flicker.
Widget _productImagePlaceholder(
  BuildContext context,
  Widget child,
  int? frame,
  bool wasSynchronouslyLoaded,
) {
  if (wasSynchronouslyLoaded || frame != null) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: child,
    );
  }
  // First frame not decoded yet → faint grey skeleton box so the grid keeps its
  // shape instead of looking broken. (Plain ColoredBox — this data-layer file
  // imports flutter/widgets only, not material, so no spinner widget here.)
  return const ColoredBox(color: Color(0x14000000));
}

/// DEFAULT `errorBuilder` for [productImage]: a failed load (offline / CDN
/// error / bad bytes) collapses to nothing instead of a stuck skeleton plus
/// FlutterError noise. A caller that passes its own `errorBuilder` (all
/// current call-sites do — emoji fallbacks) keeps full control.
Widget _productImageErrorFallback(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
) {
  return const SizedBox.shrink();
}

/// Drop-in replacement for `Image.asset(path, ...)` that routes through
/// [resolveProductImage] (CDN + cache, or bundled fallback). Accepts the common
/// `Image` arguments so call-sites migrate by replacing `Image.asset(` →
/// `productImage(`.
///
/// When the caller does not supply a [frameBuilder], a shared loading
/// placeholder + fade-in ([_productImagePlaceholder]) is used so slow CDN
/// fetches show a subtle grey skeleton instead of a blank box. Likewise, when
/// no [errorBuilder] is supplied, a failed load renders nothing
/// ([_productImageErrorFallback]) instead of a stuck skeleton.
Widget productImage(
  String assetPath, {
  Key? key,
  double? width,
  double? height,
  BoxFit? fit,
  AlignmentGeometry alignment = Alignment.center,
  ImageRepeat repeat = ImageRepeat.noRepeat,
  Color? color,
  BlendMode? colorBlendMode,
  bool gaplessPlayback = false,
  FilterQuality filterQuality = FilterQuality.medium,
  ImageErrorWidgetBuilder? errorBuilder,
  ImageFrameBuilder? frameBuilder,
  String? semanticLabel,
}) {
  return Image(
    key: key,
    image: resolveProductImage(assetPath),
    width: width,
    height: height,
    fit: fit,
    alignment: alignment,
    repeat: repeat,
    color: color,
    colorBlendMode: colorBlendMode,
    gaplessPlayback: gaplessPlayback,
    filterQuality: filterQuality,
    errorBuilder: errorBuilder ?? _productImageErrorFallback,
    frameBuilder: frameBuilder ?? _productImagePlaceholder,
    semanticLabel: semanticLabel,
    // Most product images sit beside the product name as text, so an unlabelled
    // image is decorative — exclude it from semantics to avoid a screen reader
    // announcing a meaningless "image". A caller that passes a [semanticLabel]
    // (e.g. a standalone hero image) gets it announced instead.
    excludeFromSemantics: semanticLabel == null,
  );
}
