import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Base URL of the cloud image store (Cloudflare R2). Full-quality product/page
/// images live here; the app does NOT bundle them, so it stays light. Override
/// at build time with --dart-define=IMAGE_BASE_URL=... ; empty → bundled assets.
const String kImageBaseUrl = String.fromEnvironment(
  'IMAGE_BASE_URL',
  defaultValue: 'https://pub-51f8c6ddf2de47e6b63e0f9588211cba.r2.dev',
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

/// Drop-in replacement for `Image.asset(path, ...)` that routes through
/// [resolveProductImage] (CDN + cache, or bundled fallback). Accepts the common
/// `Image` arguments so call-sites migrate by replacing `Image.asset(` →
/// `productImage(`.
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
    errorBuilder: errorBuilder,
    frameBuilder: frameBuilder,
    semanticLabel: semanticLabel,
  );
}
