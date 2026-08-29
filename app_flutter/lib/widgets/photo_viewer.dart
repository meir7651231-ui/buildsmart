import 'dart:convert';

import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shared full-photo viewing (#11/#15/#16) — a proof/sick-note/cert photo
/// reference is EITHER a camera-seam data-URL ('data:image/...;base64,…', the
/// default/today) OR, when the A14 `kCloudPhotos` flag is ON, an uploaded
/// `https://…` R2 URL. This file is the single place that turns either form into
/// a renderable image (mirroring the lipskey `_openFullscreenAsset` idiom).

/// Decodes a camera-seam data-URL to raw image bytes. Returns null for the
/// legacy `'demo'` marker, an `https://…` URL (no local bytes — use
/// [imageProviderForRef]), null input or a malformed payload — callers keep
/// their honest placeholder and simply don't offer a bytes-only viewer.
Uint8List? decodeDataUrlPhoto(String? photo) {
  if (photo == null || !photo.startsWith('data:image')) return null;
  final comma = photo.indexOf(',');
  if (comma <= 0) return null;
  try {
    return base64Decode(photo.substring(comma + 1));
  } on FormatException {
    return null;
  }
}

/// True when [ref] is an uploaded photo URL (`http://` / `https://`) rather than
/// a base64 data-URL — i.e. the A14 ON-path form. Render sites that decide
/// "is there a real photo to show/tap?" must treat BOTH an https URL AND a
/// decodable data-URL as a present photo.
bool isHttpPhotoRef(String? ref) =>
    ref != null && (ref.startsWith('https://') || ref.startsWith('http://'));

/// THE DUAL-RENDER HELPER (A14). Turns a stored photo reference — EITHER a
/// `data:image/...;base64,…` data-URL (today) OR an `https://…` uploaded URL
/// (`kCloudPhotos` ON) — into an [ImageProvider], or null when there is no
/// renderable photo (the legacy `'demo'` marker, null, or a malformed payload).
///
///  • `http(s)://…`        → [NetworkImage] (streamed from R2).
///  • `data:image…;base64` → [MemoryImage] of the decoded bytes (today's path,
///                           byte-identical).
///
/// Every photo render site routes through this so it transparently shows both
/// forms; a caller that needs raw bytes (a thumbnail `cacheWidth`, or the
/// bytes-based [showFullPhotoDialog]) uses [decodeDataUrlPhoto] for the data-URL
/// leg and this for the network leg (see [showFullPhotoRefDialog]).
ImageProvider? imageProviderForRef(String? ref) {
  if (ref == null || ref.isEmpty) return null;
  if (isHttpPhotoRef(ref)) return NetworkImage(ref);
  final bytes = decodeDataUrlPhoto(ref);
  return bytes == null ? null : MemoryImage(bytes);
}

/// Full-screen photo dialog: [InteractiveViewer] (pinch/zoom, web scroll-zoom)
/// over the full-resolution [Image.memory], near-black scrim, tap-anywhere to
/// close + an explicit 48dp X (the lipskey fullscreen idiom).
void showFullPhotoDialog(
  BuildContext context,
  Uint8List bytes, {
  String? label,
}) {
  _showFullPhoto(
    context,
    Image.memory(
      bytes,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      // A corrupt payload renders an honest message, never a crash.
      errorBuilder: (_, __, ___) => CfgText(
        'photo_viewer.t01',
        'לא ניתן להציג את התמונה',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    ),
    label: label,
  );
}

/// The dual-form full-screen viewer (A14): opens [ref] full-screen whether it is
/// a base64 data-URL (today) or an uploaded `https://…` URL — routing through
/// [imageProviderForRef]. A null/undecodable ref is a graceful no-op (the caller
/// simply doesn't offer the viewer). Use this at the photo-thumb tap sites so an
/// uploaded photo zooms exactly like a local one.
void showFullPhotoRefDialog(
  BuildContext context,
  String? ref, {
  String? label,
}) {
  final provider = imageProviderForRef(ref);
  if (provider == null) return; // nothing renderable — honest no-op
  _showFullPhoto(
    context,
    Image(
      image: provider,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => CfgText(
        'photo_viewer.t02',
        'לא ניתן להציג את התמונה',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    ),
    label: label,
  );
}

/// Shared full-screen chrome: the [imageChild] under a pinch/zoom
/// [InteractiveViewer], near-black scrim, tap-anywhere to close + the 48dp X.
void _showFullPhoto(
  BuildContext context,
  Widget imageChild, {
  String? label,
}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (dialogCtx) => Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(dialogCtx).pop(),
          child: InteractiveViewer(
            maxScale: 5,
            child: Center(child: imageChild),
          ),
        ),
        // Explicit 48dp X close (sheet/dialog rule).
        Positioned(
          top: 40,
          left: 16,
          child: Material(
            color: Colors.white12,
            shape: const CircleBorder(),
            child: Semantics(
              button: true,
              label: 'סגור',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(dialogCtx).pop(),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 36,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null && label.isNotEmpty)
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              CfgText(
                'photo_viewer.t03',
                'צבוט להגדלה · הקש לסגירה',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
