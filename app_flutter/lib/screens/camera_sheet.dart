import 'dart:convert';
import 'dart:typed_data';

import 'package:buildsmart/data/related_info.dart' show catalogProductForSku;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/camera_error_view.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Opens the fullscreen camera screen. Resolves to the captured photo as a
/// `data:image/...;base64,...` data-URL when the user shoots/picks a real photo
/// in a non-barcode mode, or null when they close without capturing (the
/// barcode mode delivers its result via a toast and also resolves null).
/// Fire-and-forget callers may ignore the result.
Future<String?> openCameraSheet(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute<String>(
      builder: (_) => const CameraScreen(),
      fullscreenDialog: true,
    ),
  );
}

// ─── modes ────────────────────────────────────────────────────────────────────

const _kModes = [
  (key: 'barcode',     emoji: '📷', label: 'ברקוד',        hint: 'כוון לברקוד'),
  (key: 'before',      emoji: '📸', label: 'לפני/אחרי',    hint: 'כוון לאזור הצילום'),
  (key: 'pod',         emoji: '📸', label: 'אישור מסירה',  hint: 'צלם הוכחת מסירה'),
  (key: 'gen_barcode', emoji: '🏷️', label: 'הפקת ברקוד',   hint: 'כוון לפריט'),
  (key: 'task',        emoji: '📸', label: 'צילום משימה',  hint: 'צלם את המשימה'),
];

// ─── mock gallery photos ──────────────────────────────────────────────────────

const _kGallery = [
  (bg: Color(0xFF1A2E1A), icon: Icons.construction,      label: 'אתר A'),
  (bg: Color(0xFF2E1A1A), icon: Icons.inventory_2,       label: 'מלאי'),
  (bg: Color(0xFF1A1A2E), icon: Icons.local_shipping,    label: 'משלוח'),
  (bg: Color(0xFF2E2A1A), icon: Icons.handyman,          label: 'כלים'),
  (bg: Color(0xFF1A2E2E), icon: Icons.assignment_turned_in, label: 'משימה'),
  (bg: Color(0xFF2A1A2E), icon: Icons.storefront,        label: 'חנות'),
  (bg: Color(0xFF2E1A2A), icon: Icons.engineering,       label: 'מהנדס'),
  (bg: Color(0xFF1A2A1A), icon: Icons.home_work,         label: 'פרויקט'),
];

// ─── screen ───────────────────────────────────────────────────────────────────

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  int _mode = 0;
  final MobileScannerController _scanner = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  /// True while the injected picker is open — blocks double-taps on both the
  /// shutter and the gallery button.
  bool _capturing = false;

  void _onDetect(BarcodeCapture cap) {
    if (_mode != 0 || _scanned) return;
    final code = cap.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _scanned = true;
    Navigator.pop(context);
    // #barcode-plus — resolve the scanned code to a catalog product (catalog SKUs
    // ARE the internal codes, so a self-printed SKU/Code-128 label round-trips
    // here). Found → open the product card (it carries add-to-cart / reorder +
    // the compatibility strip). Not found → the honest fallback (the EAN→SKU map
    // is owner-supplied data, deferred — until then a real EAN just reports).
    final product = catalogProductForSku(code);
    if (product != null) {
      showLipskeyProductSheet(context, product, const []);
    } else {
      showToast(context, 'נקלט: $code');
    }
  }

  /// REAL capture for the non-barcode modes AND the "כל הגלריה" button — opens
  /// the injected [taskPhotoPickerProvider] seam (the live getUserMedia webcam
  /// on web / the device camera+gallery on mobile via `pickTaskPhoto`). On a
  /// real photo: a preview/confirm dialog, then DELIVER it by popping the screen
  /// with the data-URL result + a toast. On user cancel / picker failure: a
  /// graceful no-op (we stay on the camera screen — no fake photo is invented).
  Future<void> _capture() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      final picker = ref.read(taskPhotoPickerProvider);
      final dataUrl = await picker(context);
      if (!mounted) return;
      if (dataUrl == null) return; // cancelled / unavailable — honest no-op
      final confirmed = await _confirmCapture(context, dataUrl);
      if (!confirmed || !mounted) return;
      Navigator.of(context).pop(dataUrl); // deliver the REAL capture
      showToast(context, '📸 התמונה נקלטה');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = _kModes[_mode];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ── Camera feed ─────────────────────────────────────────────────
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) =>
                cameraPermissionErrorView(context),
          ),

          // ── Dim for non-barcode modes ───────────────────────────────────
          if (_mode != 0)
            Container(color: Colors.black.withValues(alpha: 0.45)),

          // ── Top bar ─────────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'סגור',
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // Flash — wired to the real device torch via the scanner
                  // controller. Reflects live torch state; honest-disabled
                  // when the device reports no flash unit.
                  ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _scanner,
                    builder: (ctx, state, __) {
                      final torch = state.torchState;
                      final available = torch != TorchState.unavailable;
                      final on = torch == TorchState.on;
                      return IconButton(
                        tooltip: 'פלאש',
                        icon: Icon(
                          on ? Icons.flash_on : Icons.flash_off,
                          color: !available
                              ? Colors.white24
                              : on
                                  ? BsTokens.brand
                                  : Colors.white,
                          size: 24,
                        ),
                        onPressed: !available
                            ? () => showToast(ctx, 'אין פלאש במכשיר')
                            : () => _scanner.toggleTorch(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Center reticle / frame ──────────────────────────────────────
          Center(
            child: _mode == 0
                ? _BarcodeReticle()
                : _ModeFrame(emoji: mode.emoji, hint: mode.hint),
          ),

          // ── Bottom panel ────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Capture button row — barcode (mode 0) uses the scanner
                    // flow and shows no shutter; non-barcode modes get a REAL
                    // shutter wired to the injected capture seam.
                    if (_mode != 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 4),
                        child: _ShutterButton(
                          label: mode.label,
                          busy: _capturing,
                          onTap: _capture,
                        ),
                      ),

                    // ── Gallery strip ────────────────────────────────────
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _kGallery.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (ctx, i) {
                          if (i == _kGallery.length) {
                            return _GalleryAllBtn(
                              // REAL device gallery / file picker via the
                              // injected capture seam (image_picker on mobile,
                              // the browser file input on web).
                              onTap: _capturing ? null : _capture,
                            );
                          }
                          final g = _kGallery[i];
                          return _GalleryThumb(
                            bg: g.bg,
                            icon: g.icon,
                            label: g.label,
                            // Simulated preview of the demo photo (the gallery
                            // is mock data — no device photo access here).
                            onTap: () => _showGalleryPreview(
                              context,
                              bg: g.bg,
                              icon: g.icon,
                              label: g.label,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Filter chips ─────────────────────────────────────
                    const Divider(color: Colors.white12, height: 1),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        children: _kModes.asMap().entries.map((e) {
                          final i = e.key;
                          final m = e.value;
                          final sel = _mode == i;
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _mode = i;
                                _scanned = false;
                              }),
                              child: AnimatedContainer(
                                duration: ref.read(catalogSettingsProvider).reducedMotion
                                    ? Duration.zero
                                    : const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? BsTokens.brand
                                      : Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(m.emoji,
                                        style: const TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      m.label,
                                      style: TextStyle(
                                        color: sel ? Colors.white : Colors.black54,
                                        fontSize: 13,
                                        fontWeight: sel
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── gallery preview (simulated) ────────────────────────────────────────────────

/// Simulated full-screen preview of a demo gallery photo. The gallery strip is
/// mock data, so this shows the same placeholder enlarged rather than a real
/// image — an honest demo, not a toast.
void _showGalleryPreview(
  BuildContext context, {
  required Color bg,
  required IconData icon,
  required String label,
}) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (ctx, _, __) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: ColoredBox(
                color: bg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white24, size: 96),
                    const SizedBox(height: 16),
                    Text(
                      label,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'תצוגה מדומה — תמונת דמו',
                      style: TextStyle(color: Colors.white30, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'סגור',
                    icon: const Icon(Icons.close,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Preview/confirm dialog for a freshly-captured REAL photo — the user SEES the
/// thumbnail before it is delivered. Returns true only on confirm. A decode
/// failure still shows the dialog (text-only) so the flow never crashes on an
/// odd data-URL.
Future<bool> _confirmCapture(BuildContext context, String dataUrl) async {
  final bytes = _dataUrlBytes(dataUrl);
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('📸 תצוגה מקדימה'),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (bytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  child: Image.memory(
                    bytes,
                    height: 180,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 180,
                      child: Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
                ),
              const SizedBox(height: BsTokens.space3),
              const Text(
                'להשתמש בתמונה הזו?',
                style: TextStyle(color: Colors.black54, fontSize: 13.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('ביטול'),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('אישור'),
          ),
        ],
      ),
    ),
  );
  return ok ?? false;
}

/// Decodes the base64 payload of a `data:...;base64,...` URL to bytes for the
/// preview; null when there is no comma or the payload is not valid base64.
Uint8List? _dataUrlBytes(String dataUrl) {
  final comma = dataUrl.indexOf(',');
  if (comma < 0) return null;
  try {
    return base64Decode(dataUrl.substring(comma + 1));
  } on FormatException catch (_) {
    return null;
  }
}

// ─── shutter button ────────────────────────────────────────────────────────────

/// The REAL capture shutter shown for non-barcode modes. A pill that reflects
/// the [busy] state (greyed while the picker is open) and the active mode label.
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({
    required this.label,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'צלם $label',
      child: Material(
        color: busy ? const Color(0xFF555555) : BsTokens.brand,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: busy ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (busy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Text('📸', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  busy ? 'פותח…' : 'צלם $label',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── gallery thumbnail ────────────────────────────────────────────────────────

class _GalleryThumb extends StatelessWidget {
  const _GalleryThumb({
    required this.bg,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color bg;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'תצוגה מקדימה: $label',
      child: Tooltip(
        message: 'תצוגה מקדימה: $label',
        child: GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 72, height: 72,
              color: bg,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.black38, size: 26),
                  const SizedBox(height: 4),
                  Text(label,
                      style: const TextStyle(color: Colors.white38, fontSize: 9)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryAllBtn extends StatelessWidget {
  const _GalleryAllBtn({required this.onTap});

  /// Null while a capture is already in flight (the button is disabled).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'כל הגלריה',
      child: Tooltip(
        message: 'כל הגלריה',
        child: GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 72, height: 72,
              color: const Color(0xFF222222),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      color: BsTokens.brand, size: 26),
                  SizedBox(height: 4),
                  Text('כל\nהגלריה',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: BsTokens.brand, fontSize: 9, height: 1.3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── barcode reticle ─────────────────────────────────────────────────────────

class _BarcodeReticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240, height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: BsTokens.brand, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ─── non-barcode frame ────────────────────────────────────────────────────────

class _ModeFrame extends StatelessWidget {
  const _ModeFrame({required this.emoji, required this.hint});
  final String emoji;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 260, height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black38, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 52)),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(hint,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }
}
