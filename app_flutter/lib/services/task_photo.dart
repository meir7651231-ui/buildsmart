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
// SERVER-SWAP (A14, GATED on `kCloudPhotos`): once the owner provisions R2 +
// deploys `getUploadUrl` + flips the flag, the captured bytes UPLOAD to R2 and
// the photo field becomes an `https://…` public URL instead of the base64
// data-URL — every caller is unchanged (the photo field stays a String). With
// the flag OFF (today, the default) this whole leg is skipped and the result is
// BYTE-IDENTICAL to the verbatim base64 data-URL the persist layer has always
// stored. The upload touches the network only through two injectable seams
// ([photoUploadGateway] + [photoHttpPut]) so it is fully unit-testable without
// hardware or a live backend.

import 'dart:convert';

import 'package:buildsmart/data/repositories/backend.dart' show kCloudPhotos;
import 'package:buildsmart/data/repositories/upload_functions.dart';
import 'package:buildsmart/screens/webcam_capture_sheet.dart';
import 'package:buildsmart/services/photo_downscale.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Hard ceiling for a photo data-URL (~1.5MB of base64 text) — beyond this
/// the localStorage persist layer is at real risk of a quota failure.
const int kMaxPhotoDataUrlChars = 1500 * 1024;

/// The single REAL-capture seam type: open a camera/picker flow and resolve to
/// the photo as a `data:image/...;base64,...` data-URL, or null on
/// cancel/failure. Mirrors [pickTaskPhoto]'s contract.
typedef TaskPhotoPicker = Future<String?> Function(BuildContext context);

// ── A14 photo-upload seams (gated on `kCloudPhotos`) ─────────────────────────
// Two injectable module-level seams let the ON-path upload to R2 be exercised
// WITHOUT the network or a `WidgetRef` (so the unchanged `pickTaskPhoto(context)`
// signature stays — none of its ~9 callers change). Production uses the real
// defaults below; a test swaps them for fakes and restores them in a tearDown.

/// The HTTP-PUT seam: PUT [bytes] to [url] with the `Content-Type` header and
/// resolve to the HTTP status code. Default is a real cross-platform
/// `http.put` (works on web via BrowserClient and on mobile via dart:io). Tests
/// override [photoHttpPut] with a fake that records the call and returns a
/// chosen status — so the suite never touches the network.
typedef PhotoHttpPut =
    Future<int> Function(Uri url, Uint8List bytes, String contentType);

/// Real HTTP PUT of the photo bytes to the presigned URL. Any transport failure
/// surfaces as a thrown exception (caught by the upload step → base64 fallback);
/// a non-2xx is returned as its status (also → fallback).
Future<int> _realHttpPut(Uri url, Uint8List bytes, String contentType) async {
  final res = await http.put(
    url,
    headers: {'Content-Type': contentType},
    body: bytes,
  );
  return res.statusCode;
}

/// Overridable HTTP-PUT seam (real by default). Reset in a test tearDown.
PhotoHttpPut photoHttpPut = _realHttpPut;

/// Overridable callable gateway (lazily the real Firebase adapter by default).
/// Only constructed/used when upload is enabled; tests inject a fake.
UploadFunctionsGateway photoUploadGateway = FirebaseUploadFunctionsGateway();

/// The upload GATE — defaults to the compile-time [kCloudPhotos] (OFF in
/// production today, so the capture path is byte-identical). Exposed as a
/// mutable seam (the A13 `serverCallables`-field idiom) ONLY so the define-less
/// test suite can flip the full `pickTaskPhoto`/[_guardAndDeliver] delivery path
/// ON without a `--dart-define`; a test restores it in a tearDown. Production
/// never writes it — it stays exactly `kCloudPhotos`.
bool photoUploadEnabled = kCloudPhotos;

/// Maps a data-URL's image MIME to the upload `kind` allowed by the server.
/// Every BuildSmart capture is operational proof (POD / before-after / profile /
/// cert), so `pod` is the single sanctioned kind here (the server only accepts
/// `pod` | `before-after`); the durable public URL is what differs, never the
/// bucket prefix's user meaning.
const String _kUploadKind = 'pod';

/// The R2 server's allowed image content types (functions/src/r2.ts). A data-URL
/// MIME outside this set is not uploadable → the capture keeps its base64 form.
const Set<String> _kUploadableContentTypes = {
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/heic',
  'image/heif',
};

/// Injectable capture seam (same idiom as `connectivityProbeProvider`). Defaults
/// to the REAL [pickTaskPhoto] chain (webcam/getUserMedia on web, the device
/// camera on mobile). Tests override this with a fake that returns a known
/// data-URL — so the capture→deliver wiring is unit-testable WITHOUT hardware.
final taskPhotoPickerProvider = Provider<TaskPhotoPicker>(
  (_) => pickTaskPhoto,
);

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
      return _guardAndDeliver(context, shot);
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
    return _guardAndDeliver(context, dataUrl);
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

/// The final delivery step: first the verbatim ~1.5MB persist-budget guard
/// ([_guardSize], unchanged), then — ONLY when `kCloudPhotos` is ON — an attempt
/// to UPLOAD the bytes to R2 and return the durable `https://…` public URL
/// instead of the base64 data-URL. With the flag OFF this is a transparent
/// passthrough of [_guardSize]'s result, so the stored string is BYTE-IDENTICAL
/// to today; the upload gateway is never even touched.
Future<String?> _guardAndDeliver(BuildContext context, String dataUrl) async {
  final guarded = await _guardSize(context, dataUrl);
  if (guarded == null) return null; // oversized & unshrinkable — already toasted
  // OFF (production default `kCloudPhotos`): byte-identical base64, the upload
  // gateway is never even touched. ON: upload + return the https public URL,
  // falling back to this exact base64 on any failure. (Single gate source:
  // [deliverGuardedPhoto].)
  return deliverGuardedPhoto(guarded);
}

/// A14 ON-path (module-seam wrapper): delegate to [uploadCapturedPhoto] using
/// the injectable module seams ([photoUploadGateway] + [photoHttpPut]). Kept
/// thin so the upload DECISION is testable as a pure function without a
/// `BuildContext`.
Future<String> _maybeUploadDataUrl(String dataUrl) => uploadCapturedPhoto(
  dataUrl,
  gateway: photoUploadGateway,
  put: photoHttpPut,
);

/// The exact GATE [_guardAndDeliver] applies AFTER the size-guard, exposed
/// BuildContext-free for the define-less suite: when [photoUploadEnabled] is OFF
/// (production default `kCloudPhotos`) the guarded [guardedDataUrl] is returned
/// VERBATIM and the upload gateway is never touched (byte-identical); when ON it
/// is uploaded via the module seams (https public URL on success, base64
/// fallback on any failure). Proves the gating + zero-regression lock without
/// hardware/Firebase.
@visibleForTesting
Future<String> deliverGuardedPhoto(String guardedDataUrl) async {
  if (!photoUploadEnabled) return guardedDataUrl;
  return _maybeUploadDataUrl(guardedDataUrl);
}

/// A14 ON-path CORE (pure, BuildContext-free, directly unit-testable): upload a
/// guarded base64 [dataUrl]'s bytes to R2 via the `getUploadUrl` callable
/// ([gateway]) + an HTTP PUT ([put]), and return the durable public URL on
/// success. GRACEFUL, HONEST failure: if the data-URL is not an uploadable image
/// MIME (or unparseable), or the callable throws (not-deployed / R2 unconfigured
/// → `failed-precondition`), or the PUT is non-2xx / errors, FALL BACK to the
/// original [dataUrl] (the photo is NOT lost — it persists locally exactly as
/// today) and log it honestly. A success is NEVER faked.
@visibleForTesting
Future<String> uploadCapturedPhoto(
  String dataUrl, {
  required UploadFunctionsGateway gateway,
  required PhotoHttpPut put,
}) async {
  final contentType = _dataUrlMime(dataUrl);
  final bytes = _dataUrlBytes(dataUrl);
  if (contentType == null ||
      bytes == null ||
      !_kUploadableContentTypes.contains(contentType)) {
    // Not an uploadable image (or unparseable) — keep the local base64 form.
    return dataUrl;
  }
  try {
    final target = await gateway.getUploadUrl(_kUploadKind, contentType);
    final status = await put(Uri.parse(target.uploadUrl), bytes, contentType);
    if (status >= 200 && status < 300) {
      return target.publicUrl; // uploaded — store the https URL
    }
    debugPrint(
      'task_photo: R2 upload PUT returned $status — keeping local base64 photo',
    );
    return dataUrl; // non-2xx → honest local fallback
  } on UploadFunctionsException catch (e) {
    // getUploadUrl failed (e.g. failed-precondition: R2 not configured, or
    // unavailable: function not deployed) — keep the photo locally, no fake.
    debugPrint('task_photo: getUploadUrl failed ($e) — keeping local base64');
    return dataUrl;
  } on Object catch (e) {
    // PUT transport error / any other failure — keep the photo locally.
    debugPrint('task_photo: R2 upload failed ($e) — keeping local base64');
    return dataUrl;
  }
}

/// The MIME of a `data:<mime>;base64,…` data-URL (e.g. `image/jpeg`), or null
/// when the prefix is malformed.
String? _dataUrlMime(String dataUrl) {
  if (!dataUrl.startsWith('data:')) return null;
  final semi = dataUrl.indexOf(';');
  final comma = dataUrl.indexOf(',');
  if (semi <= 5 || comma <= semi) return null;
  return dataUrl.substring(5, semi);
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
