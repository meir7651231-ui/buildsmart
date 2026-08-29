// WEB side of the photo_downscale seam — see photo_downscale.dart.
//
// The browser-canvas re-encode: bytes → Blob → <img> → draw scaled onto a
// <canvas> → `canvas.toDataURL('image/jpeg', quality)`. This is the exact
// approach image_picker_for_web uses for its own maxWidth/imageQuality
// handling, applied here to the webcam capture (which arrives as raw frame
// bytes) and to the >1.5MB persist-budget guard in services/task_photo.dart.

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Downscales [bytes] (any browser-decodable image) to at most [maxWidth]
/// pixels wide and re-encodes it as a JPEG data-URL at [quality] (0..1).
///
/// Returns null when the browser cannot decode/encode the payload — the
/// caller keeps its original bytes (honest fallback, no invented image).
Future<String?> downscaleToJpegDataUrl(
  Uint8List bytes, {
  int maxWidth = 800,
  double quality = 0.6,
}) async {
  try {
    final blob = web.Blob(<JSAny>[bytes.toJS].toJS);
    final url = web.URL.createObjectURL(blob);
    try {
      final img = web.HTMLImageElement()..src = url;
      // decode() resolves once the pixels are ready and rejects on a payload
      // the browser cannot parse — the catch below turns that into null.
      await img.decode().toDart;
      final w = img.naturalWidth;
      final h = img.naturalHeight;
      if (w <= 0 || h <= 0) return null;
      final scale = w > maxWidth ? maxWidth / w : 1.0;
      final tw = (w * scale).round().clamp(1, w);
      final th = (h * scale).round().clamp(1, h);
      final canvas = web.HTMLCanvasElement()
        ..width = tw
        ..height = th;
      final ctx = canvas.getContext('2d');
      if (ctx == null) return null;
      (ctx as web.CanvasRenderingContext2D)
          .drawImage(img, 0, 0, tw.toDouble(), th.toDouble());
      final dataUrl = canvas.toDataUrl('image/jpeg', quality);
      // A canvas that failed to export returns 'data:,' — honest null.
      return dataUrl.startsWith('data:image') ? dataUrl : null;
    } finally {
      web.URL.revokeObjectURL(url);
    }
  } on Object catch (_) {
    return null; // undecodable payload / canvas failure — caller keeps bytes
  }
}
