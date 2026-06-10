// #85ב · REAL proof photo — the single camera/picker seam for the worker's
// mandatory "שלח לאישור" proof AND the editable profile photo (#85ד).
//
// Honest behavior (אין חצי-עבודה): a user cancel — or any picker/permission
// failure — returns null; the CALLER decides what "no photo" means (e.g.
// block the submit with 'חובה לצלם הוכחת-ביצוע'). No fake placeholder is ever
// returned from here.
//
// Capture chain — honest, no simulation:
//  • WEB (desktop browsers!): a REAL getUserMedia webcam dialog FIRST
//    (screens/webcam_capture_sheet.dart — live preview + shutter, the same
//    camera access the barcode scanner already proves works). A user close
//    there is a final cancel (null, no second picker). Only a webcam ERROR
//    (no camera / permission denied / init failure) falls back to the
//    browser file picker — honestly framed as a file pick, after the sheet's
//    own 'אין גישה למצלמה' toast.
//  • MOBILE: image_picker's ImageSource.camera as before; if the camera
//    source THROWS (no hardware/permission) we retry once with
//    ImageSource.gallery. A user cancel is returned as null AS-IS.
//
// Every result is downscaled (maxWidth 800 / JPEG q60 — natively on mobile,
// via the photo_downscale canvas seam on web) so the data-URL stays small
// enough for the SharedPreferences persist layer (localStorage on web, ~5MB
// budget — a 800px/q60 JPEG is ~50-150KB). A result that still exceeds
// [kMaxPhotoDataUrlChars] (~1.5MB) is re-encoded smaller, and rejected with
// an honest 'התמונה גדולה מדי' toast if even that fails.
//
// SERVER-SWAP: once the server lands, the bytes upload to storage and the
// task keeps a https URL instead of a data-URL — every caller is unchanged
// (the photo field stays a String).

import 'dart:convert';
import 'dart:typed_data';

import 'package:buildsmart/screens/webcam_capture_sheet.dart';
import 'package:buildsmart/services/photo_downscale.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

/// Hard ceiling for a photo data-URL (~1.5MB of base64 text) — beyond this
/// the localStorage persist layer is at real risk of a quota failure.
const int kMaxPhotoDataUrlChars = 1500 * 1024;

/// Opens a REAL capture flow and returns the photo as a data-URL string
/// (`data:image/...;base64,...`), or null on cancel/failure — see the
/// library doc for the per-platform chain.
Future<String?> pickTaskPhoto(BuildContext context) async {
  if (kIsWeb) {
    // WEB — the real webcam dialog first (getUserMedia, like the scanner).
    final shot = await openWebcamCapture(context);
    if (shot == kWebcamCancelled) return null; // intentional cancel — done
    if (shot != null) {
      if (!context.mounted) return null;
      return _guardSize(context, shot);
    }
    // shot == null → the webcam ERRORED (toast already shown by the sheet);
    // honest fallback: the browser file picker.
    if (!context.mounted) return null;
    return _pickViaImagePicker(context, ImageSource.gallery);
  }
  // MOBILE — the device camera, with a one-shot gallery retry on a camera
  // failure (no hardware / denied permission). A user cancel stays null.
  return _pickViaImagePicker(
    context,
    ImageSource.camera,
    fallback: ImageSource.gallery,
  );
}

/// The image_picker leg — picks from [source] (retrying once with [fallback]
/// only when [source] THROWS), then encodes + size-guards the result.
Future<String?> _pickViaImagePicker(
  BuildContext context,
  ImageSource source, {
  ImageSource? fallback,
}) async {
  final picker = ImagePicker();
  XFile? file;
  try {
    file = await picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 60,
    );
  } on Object catch (_) {
    if (fallback == null) return null;
    try {
      file = await picker.pickImage(
        source: fallback,
        maxWidth: 800,
        imageQuality: 60,
      );
    } on Object catch (_) {
      return null; // both sources failed — honest null
    }
  }
  if (file == null) return null; // user cancelled — honest null

  try {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    // maxWidth/imageQuality re-encode to JPEG on mobile; on web a PNG may
    // pass through unchanged — honor the reported mime when present.
    final mime = file.mimeType ?? 'image/jpeg';
    final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    if (!context.mounted) return null;
    return _guardSize(context, dataUrl);
  } on Object catch (_) {
    return null; // unreadable file — honest null
  }
}

/// The ~1.5MB persist-budget guard: an oversized data-URL is re-encoded
/// smaller (640px / q50 via the canvas seam); when even that is impossible
/// or still too big, the photo is REJECTED with an honest 'התמונה גדולה מדי'
/// toast — never silently persisted into a quota failure.
Future<String?> _guardSize(BuildContext context, String dataUrl) async {
  if (dataUrl.length <= kMaxPhotoDataUrlChars) return dataUrl;
  final bytes = _dataUrlBytes(dataUrl);
  final smaller = bytes == null
      ? null
      : await downscaleToJpegDataUrl(bytes, maxWidth: 640, quality: 0.5);
  if (smaller != null && smaller.length <= kMaxPhotoDataUrlChars) {
    return smaller;
  }
  if (context.mounted) showToast(context, 'התמונה גדולה מדי');
  return null;
}

/// Decodes the base64 payload of a data-URL back to bytes (for re-encoding);
/// null when the payload is not parseable base64.
Uint8List? _dataUrlBytes(String dataUrl) {
  final comma = dataUrl.indexOf(',');
  if (comma < 0) return null;
  try {
    return base64Decode(dataUrl.substring(comma + 1));
  } on FormatException catch (_) {
    return null;
  }
}
