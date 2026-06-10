import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shared full-photo viewing (#11/#15/#16) — every proof/sick-note/cert photo
/// in the app is a camera-seam data-URL ('data:image/...;base64,…'); this file
/// is the single place that decodes one and shows it full-screen with
/// pinch/zoom, mirroring the lipskey `_openFullscreenAsset` idiom.

/// Decodes a camera-seam data-URL to raw image bytes. Returns null for the
/// legacy `'demo'` marker, null input or a malformed payload — callers keep
/// their honest placeholder and simply don't offer the viewer.
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

/// Full-screen photo dialog: [InteractiveViewer] (pinch/zoom, web scroll-zoom)
/// over the full-resolution [Image.memory], near-black scrim, tap-anywhere to
/// close + an explicit 48dp X (the lipskey fullscreen idiom).
void showFullPhotoDialog(
  BuildContext context,
  Uint8List bytes, {
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
            child: Center(
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                // A corrupt payload renders an honest message, never a crash.
                errorBuilder: (_, __, ___) => const Text(
                  'לא ניתן להציג את התמונה',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
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
              const Text(
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
