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

  @override
  Widget build(BuildContext context) {
    final mode = _kModes[_mode];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ── Camera feed ─────────────────────────────────────────────────
          MobileScanner(controller: _scanner, onDetect: _onDetect),

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
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.flash_off, color: Colors.black54, size: 24),
                    onPressed: () => showToast(context, 'פלאש — בבנייה'),
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

                    // Capture button row (non-barcode)
                    if (_mode != 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 4),
                        child: GestureDetector(
                          onTap: () => showToast(context, '${mode.label} — בבנייה'),
                          child: Container(
                            width: 68, height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Center(
                              child: Container(
                                width: 54, height: 54,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
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
                              onTap: () => showToast(context, 'גלריה מלאה — בבנייה'),
                            );
                          }
                          final g = _kGallery[i];
                          return _GalleryThumb(
                            bg: g.bg,
                            icon: g.icon,
                            label: g.label,
                            onTap: () => showToast(context, '${g.label} — בבנייה'),
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
                            padding: const EdgeInsets.only(left: 8),
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _mode = i;
                                _scanned = false;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
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
    return GestureDetector(
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
    );
  }
}

class _GalleryAllBtn extends StatelessWidget {
  const _GalleryAllBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
