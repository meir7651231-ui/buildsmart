// IO (mobile/desktop-native) side of the photo_downscale seam — see
// photo_downscale.dart. There is no browser canvas here, and none is needed:
// image_picker downscales natively on these platforms (maxWidth 800 / q60),
// so this stub honestly reports "no re-encode available".

import 'dart:typed_data';

/// Always returns null on non-web platforms (no canvas re-encoder here);
/// callers keep their original bytes. See photo_downscale_web.dart for the
/// real implementation.
Future<String?> downscaleToJpegDataUrl(
  Uint8List bytes, {
  int maxWidth = 800,
  double quality = 0.6,
}) async =>
    null;
