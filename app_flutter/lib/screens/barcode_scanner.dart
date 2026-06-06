import 'package:buildsmart/theme/tokens.dart';
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
  bool _done = false;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture cap) {
    if (_done) return;
    final code = cap.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _done = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('סריקת ברקוד'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _ctl, onDetect: _onDetect),
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
