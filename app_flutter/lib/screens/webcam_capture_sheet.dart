// #85ב WEB · REAL webcam capture — a fullscreen getUserMedia camera dialog
// (the `camera`/`camera_web` plugin), the proof that real camera access works
// on desktop browsers exactly like the barcode scanner already does.
//
// Contract (consumed by services/task_photo.dart):
//   • a captured photo  → a small JPEG data-URL (maxWidth 800 / q60 via the
//     photo_downscale canvas seam; raw bytes only if the canvas is
//     unavailable — אין המצאות, the pixels are always the real frame);
//   • user closed (X / esc / browser-back) → [kWebcamCancelled] — the caller
//     treats it as an intentional cancel and does NOT open a second picker;
//   • no camera / permission denied / init failure → null, after an honest
//     'אין גישה למצלמה' toast — the caller may fall back to a file picker.

import 'dart:convert';

import 'package:buildsmart/services/photo_downscale.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Sentinel returned by [openWebcamCapture] when the USER closed the capture
/// screen (X / esc / back) — distinct from null, which means the webcam
/// errored (no camera / permission denied / init failure).
const String kWebcamCancelled = 'CANCEL';

/// Internal route result for "the webcam errored" — normalized to null by
/// [openWebcamCapture] (a plain route pop without a result is a user close).
const String _kWebcamError = '__WEBCAM_ERROR__';

/// Opens the fullscreen webcam capture dialog. Resolves to:
///  • a `data:image/jpeg;base64,…` data-URL of the REAL capture;
///  • [kWebcamCancelled] when the user closed without shooting;
///  • null when the webcam could not deliver (an honest 'אין גישה למצלמה'
///    toast was already shown) — callers may fall back to a file picker.
Future<String?> openWebcamCapture(BuildContext context) async {
  final result = await Navigator.of(context).push<String>(
    MaterialPageRoute<String>(
      builder: (_) => const WebcamCaptureScreen(),
      fullscreenDialog: true,
    ),
  );
  if (result == _kWebcamError) return null;
  // esc / browser-back pops without a result — an intentional user close.
  return result ?? kWebcamCancelled;
}

/// The fullscreen capture UI — live [CameraPreview] + big '📸 צלם' shutter +
/// X close + switch-camera (only when >1 camera is reported). Black chrome,
/// the barcode-scanner idiom.
class WebcamCaptureScreen extends StatefulWidget {
  const WebcamCaptureScreen({super.key});

  @override
  State<WebcamCaptureScreen> createState() => _WebcamCaptureScreenState();
}

class _WebcamCaptureScreenState extends State<WebcamCaptureScreen> {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _camIndex = 0;

  /// True while shooting or switching — blocks double-taps.
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    List<CameraDescription> cams;
    try {
      // On web this triggers the browser's getUserMedia permission prompt.
      cams = await availableCameras();
    } on Object catch (_) {
      _fail();
      return;
    }
    if (cams.isEmpty) {
      _fail();
      return;
    }
    if (!mounted) return;
    _cameras = cams;
    await _start(0);
  }

  /// (Re)starts the controller on camera [index]; an init failure closes the
  /// dialog with the error result (honest — no frozen fake preview).
  Future<void> _start(int index) async {
    final previous = _controller;
    if (mounted) setState(() => _controller = null);
    await previous?.dispose();
    final ctl = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: false, // photo-only: never ask for the microphone
    );
    try {
      await ctl.initialize();
    } on Object catch (_) {
      await ctl.dispose();
      _fail();
      return;
    }
    if (!mounted) {
      await ctl.dispose();
      return;
    }
    setState(() {
      _camIndex = index;
      _controller = ctl;
      _busy = false;
    });
  }

  /// Honest failure exit — toast + pop the error result (the caller falls
  /// back to the file picker; no simulated capture is ever returned).
  void _fail() {
    if (!mounted) return;
    showToast(context, 'אין גישה למצלמה');
    Navigator.of(context).pop(_kWebcamError);
  }

  Future<void> _shoot() async {
    final ctl = _controller;
    if (ctl == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await ctl.takePicture();
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) throw StateError('empty capture');
      // Downscale + JPEG re-encode via the canvas seam (maxWidth 800 / q60);
      // when the canvas is unavailable keep the REAL raw frame bytes.
      final dataUrl = await downscaleToJpegDataUrl(bytes) ??
          'data:${_sniffMime(bytes)};base64,${base64Encode(bytes)}';
      if (!mounted) return;
      Navigator.of(context).pop(dataUrl);
    } on Object catch (_) {
      _fail();
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _busy) return;
    setState(() => _busy = true);
    await _start((_camIndex + 1) % _cameras.length);
  }

  /// Honest mime for the raw-bytes fallback — read the magic numbers instead
  /// of guessing (camera_web may hand back PNG frames).
  static String _sniffMime(List<int> bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final ctl = _controller;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── live preview / init spinner ─────────────────────────────
            Center(
              child: ctl != null && ctl.value.isInitialized
                  ? CameraPreview(ctl)
                  : const CircularProgressIndicator(color: BsTokens.brand),
            ),

            // ── top bar: X close + switch-camera ────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'סגור',
                      child: IconButton(
                        tooltip: 'סגור',
                        iconSize: 28,
                        padding: const EdgeInsets.all(12),
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () =>
                            Navigator.of(context).pop(kWebcamCancelled),
                      ),
                    ),
                    const Spacer(),
                    // Only when the device honestly reports >1 camera.
                    if (_cameras.length > 1)
                      Semantics(
                        button: true,
                        label: 'החלף מצלמה',
                        child: IconButton(
                          tooltip: 'החלף מצלמה',
                          iconSize: 26,
                          padding: const EdgeInsets.all(12),
                          icon: const Icon(
                            Icons.cameraswitch_outlined,
                            color: Colors.white,
                          ),
                          onPressed: _busy ? null : _switchCamera,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── bottom: the big shutter ─────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: BsTokens.space4),
                  child: Center(
                    child: Semantics(
                      button: true,
                      label: 'צלם',
                      child: Material(
                        color: ctl == null || _busy
                            ? const Color(0xFF555555)
                            : BsTokens.brand,
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                          onTap: ctl == null || _busy ? null : _shoot,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 16,
                            ),
                            child: CfgText(
                              'webcam_capture_sheet.shoot',
                              '📸 צלם',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
