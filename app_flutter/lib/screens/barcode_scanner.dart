import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/camera_error_view.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Native barcode scanner — opens a camera view, on first detected
/// code closes itself with the value. Allowed under R2 because it's
/// a primary device modal (like a file picker), not a feature view.
class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final MobileScannerController _ctl = MobileScannerController();
  final TextEditingController _manualCtl = TextEditingController();
  bool _done = false;

  @override
  void dispose() {
    _ctl.dispose();
    _manualCtl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture cap) {
    if (_done) return;
    final code = cap.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _done = true;
    Navigator.of(context).pop(code);
  }

  /// #1 — manual fallback: a typed מק"ט pops through the SAME path as a
  /// scanned barcode ([Navigator.pop] with the code String), so every caller
  /// of [openBarcodeScanner] is unchanged. Critical on desktop web / denied
  /// camera permission, where the camera feed never starts.
  void _submitManual() {
    if (_done) return;
    final code = _manualCtl.text.trim();
    if (code.isEmpty) return;
    _done = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: CfgText('barcode_scanner.scan_title', 'סריקת ברקוד'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _ctl,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) =>
                cameraPermissionErrorView(context),
          ),
          // Centered reticle.
          Center(
            child: Container(
              width: 240,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: BsTokens.brand, width: 3),
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              ),
            ),
          ),
        ],
      ),
      // #1 — ALWAYS-visible manual fallback bar (it lives outside the
      // MobileScanner subtree, so it stays reachable when `errorBuilder`
      // shows `cameraPermissionErrorView` — denied permission / no camera /
      // desktop web). Typing a מק"ט pops through the same path as a scan.
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space3,
            BsTokens.space2,
            BsTokens.space3,
            BsTokens.space3,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualCtl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submitManual(),
                  decoration: InputDecoration(
                    hintText: 'הקלד מק"ט ידנית',
                    hintStyle: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13.5,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white10,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: BsTokens.space3,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusPill),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: BsTokens.space2),
              // ≥48dp confirm — same pop as a scanned code.
              Semantics(
                button: true,
                label: 'חפש לפי מק"ט',
                child: Material(
                  color: BsTokens.brand,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _submitManual,
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(Icons.check, color: Colors.white),
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
}

/// Convenience launcher — opens the scanner and RETURNS the scanned code (or
/// null if cancelled), so callers can route it into the live search query.
Future<String?> openBarcodeScanner(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute<String>(
      builder: (_) => const BarcodeScanner(),
      fullscreenDialog: true,
    ),
  );
}
