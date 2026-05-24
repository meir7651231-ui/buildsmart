import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void openCameraSheet(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const CameraScreen(),
      fullscreenDialog: true,
    ),
  );
}

// ─── modes ────────────────────────────────────────────────────────────────────

const _kModes = [
  (key: 'barcode',     emoji: '📷', label: 'ברקוד',         hint: 'כוון לברקוד'),
  (key: 'before',      emoji: '📸', label: 'לפני/אחרי',     hint: 'כוון לאזור הצילום'),
  (key: 'pod',         emoji: '📸', label: 'אישור מסירה',   hint: 'צלם הוכחת מסירה'),
  (key: 'gen_barcode', emoji: '🏷️', label: 'הפקת ברקוד',    hint: 'כוון לפריט'),
  (key: 'task',        emoji: '📸', label: 'צילום משימה',   hint: 'צלם את המשימה'),
];

// ─── screen ───────────────────────────────────────────────────────────────────

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int _mode = 0;
  final MobileScannerController _scanner = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture cap) {
    if (_mode != 0 || _scanned) return;
    final code = cap.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _scanned = true;
    Navigator.pop(context);
    showToast(context, 'נקלט: $code');
  }

  void _onCapture() {
    showToast(context, '${_kModes[_mode].label} — בבנייה');
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
          ),

          // ── Dim overlay for non-barcode modes ───────────────────────────
          if (_mode != 0)
            Container(color: Colors.black.withValues(alpha: 0.45)),

          // ── Top bar ─────────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.flash_off,
                        color: Colors.white70, size: 24),
                    onPressed: () =>
                        showToast(context, 'פלאש — בבנייה'),
                  ),
                ],
              ),
            ),
          ),

          // ── Center viewfinder / reticle ─────────────────────────────────
          Center(
            child: _mode == 0
                ? _BarcodeReticle()
                : _ModeFrame(emoji: mode.emoji, hint: mode.hint),
          ),

          // ── Bottom: capture + filter strip ──────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Capture button (non-barcode modes)
                  if (_mode != 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: _onCapture,
                        child: Container(
                          width: 70, height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Center(
                            child: Container(
                              width: 56, height: 56,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Filter strip
                  Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: _kModes.asMap().entries.map((e) {
                          final i = e.key;
                          final m = e.value;
                          final sel = _mode == i;
                          return Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _mode = i;
                                  _scanned = false;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? BsTokens.brand
                                      : Colors.white
                                          .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(m.emoji,
                                        style:
                                            const TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      m.label,
                                      style: TextStyle(
                                        color: sel
                                            ? Colors.white
                                            : Colors.white70,
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
                  ),
                ],
              ),
            ),
          ),
        ],
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
            border: Border.all(color: Colors.white54, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 52)),
        ),
        const SizedBox(height: 14),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            hint,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
