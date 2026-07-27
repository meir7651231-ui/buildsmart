// REAL client-side signature pad — the courier/recipient signs with a finger
// (mobile) or the mouse (web) directly on the canvas; the strokes are rendered
// to a PNG and returned as a `data:image/png;base64,…` data-URL, the SAME shape
// the POD photo already uses (state/persona_fulfillment.dart `podPhoto`). No
// backend, no key, no fake: an empty pad cannot "save" a signature.
//
// Honest (אין חצי-עבודה): the שמור action is DISABLED until at least one real
// stroke exists, so there is no way to capture an empty/fake signature. A
// cancel returns null and NOTHING is stored. The capture is fully on-device —
// strokes → ui.Picture → ui.Image → PNG bytes → base64 data-URL — so it works
// identically on iOS, Android and Web with no network.
//
// SERVER-SWAP: the produced data-URL is a real PNG image, so when the owner
// flips `kCloudPhotos` ON it can flow through the EXACT same R2 upload path the
// POD photo uses (kind `pod`); with the flag OFF (today) it is stored verbatim
// as the data-URL, byte-identical to how podPhoto is stored OFF.

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:flutter/material.dart';

/// One continuous pen stroke — the ordered points from pen-down to pen-up.
typedef _Stroke = List<Offset>;

/// The PNG canvas the strokes are rasterized onto (logical px). Fixed so the
/// stored image is predictable in size regardless of the on-screen pad size.
const Size kSignatureCanvasSize = Size(600, 280);

/// The pen color baked into the PNG (dark ink on a white card) — a plain RGB so
/// the rendered signature is legible on any background the previews use.
const Color _kInkColor = BsTokens.inkLight;
const double _kStrokeWidth = 3;

/// Rasterizes [strokes] (each a polyline of [Offset]s, in [size]'s coordinate
/// space) to an opaque-white PNG and returns it as a `data:image/png;base64,…`
/// data-URL — or null when there is nothing real to draw (no stroke carries ≥1
/// point), so an empty pad can NEVER produce a fake signature. Pure and
/// `BuildContext`-free: it draws through a [ui.PictureRecorder] →
/// [ui.Picture.toImage] (works headless in `flutter test`, unlike
/// `RepaintBoundary.toImage` which needs a live layer) so the encode is
/// directly unit-testable.
Future<String?> strokesToPngDataUrl(
  List<List<Offset>> strokes, {
  Size size = kSignatureCanvasSize,
}) async {
  final hasInk = strokes.any((s) => s.isNotEmpty);
  if (!hasInk) return null; // empty pad → honest null, no fake image

  final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
  final recorder = ui.PictureRecorder();
  // Opaque white background so the PNG reads as a real signed slip (not a
  // transparent ghost) in every preview surface, then the strokes on top.
  final canvas = Canvas(recorder, bounds)
    ..drawRect(bounds, Paint()..color = const Color(0xFFFFFFFF));
  paintSignatureStrokes(canvas, strokes);

  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(size.width.round(), size.height.round());
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return null; // encode failed — honest null, no fake
      final bytes = data.buffer.asUint8List();
      return 'data:image/png;base64,${base64Encode(bytes)}';
    } finally {
      image.dispose();
    }
  } finally {
    picture.dispose();
  }
}

/// Shared stroke renderer — used both by the live pad's [CustomPainter] and by
/// [strokesToPngDataUrl] so the captured PNG matches exactly what the user saw.
/// A single-point stroke (a tap/dot) is drawn as a small filled circle so a
/// quick dot still registers as visible ink.
void paintSignatureStrokes(Canvas canvas, List<List<Offset>> strokes) {
  final stroke = Paint()
    ..color = _kInkColor
    ..strokeWidth = _kStrokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;
  final dot = Paint()
    ..color = _kInkColor
    ..style = PaintingStyle.fill;
  for (final s in strokes) {
    if (s.isEmpty) continue;
    if (s.length == 1) {
      canvas.drawCircle(s.first, _kStrokeWidth / 2, dot);
      continue;
    }
    final path = Path()..moveTo(s.first.dx, s.first.dy);
    for (var i = 1; i < s.length; i++) {
      path.lineTo(s[i].dx, s[i].dy);
    }
    canvas.drawPath(path, stroke);
  }
}

/// Opens the signature pad as a modal bottom sheet (RTL) and resolves to the
/// captured signature as a `data:image/png;base64,…` data-URL, or null on
/// cancel / an empty pad. Mirrors the `pickTaskPhoto(context)` contract so the
/// POD sheet wires it the same way it wires the photo capture.
Future<String?> openSignaturePad(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BsTokens.cardLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const Directionality(
      textDirection: TextDirection.rtl,
      child: SignaturePadSheet(),
    ),
  );
}

/// The signature pad sheet body: a draw area ([SignaturePad]) plus נקה (clear)
/// and שמור (save — disabled until there is real ink) actions. On save it pops
/// the sheet with the PNG data-URL; on cancel/close it pops with null.
class SignaturePadSheet extends StatefulWidget {
  const SignaturePadSheet({super.key});

  @override
  State<SignaturePadSheet> createState() => _SignaturePadSheetState();
}

class _SignaturePadSheetState extends State<SignaturePadSheet> {
  final SignaturePadController _controller = SignaturePadController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.isEmpty || _saving) return; // honest: no empty save
    setState(() => _saving = true);
    final dataUrl = await strokesToPngDataUrl(_controller.strokes);
    if (!mounted) return;
    // A null encode (nothing drawn / platform refusal) never closes with a
    // fake — keep the pad open so the user can try again.
    if (dataUrl == null) {
      setState(() => _saving = false);
      return;
    }
    Navigator.of(context).pop(dataUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space3,
        BsTokens.space4,
        BsTokens.space5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8D8D8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          const CfgText(
            'signature_pad.pod_title',
            '✍️ חתימת הלקוח',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          const CfgText(
            'signature_pad.pod_hint',
            'חתמו באצבע או בעכבר במסגרת',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          ),
          const SizedBox(height: BsTokens.space3),
          // The draw surface — fixed aspect (matches the stored canvas ratio)
          // so on-screen strokes map cleanly onto the PNG coordinate space.
          AspectRatio(
            aspectRatio: kSignatureCanvasSize.width / kSignatureCanvasSize.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                border: Border.all(color: const Color(0xFFD8D8D8)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                child: SignaturePad(controller: _controller),
              ),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Row(
            children: [
              Expanded(
                // composite-hide: whole נקה button gone when the org hides this
                // element (clear action → critical:false).
                child: CfgVisible(
                  'signature_pad.clear_btn',
                  child: OutlinedButton(
                  onPressed: _saving ? null : _controller.clear,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    ),
                  ),
                  child: const CfgText(
                    'signature_pad.clear_btn',
                    'נקה',
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                ),
              ),
              const SizedBox(width: BsTokens.space3),
              Expanded(
                child: AnimatedBuilder(
                  // Rebuild the save button's enabled state as ink is added /
                  // cleared — disabled while empty keeps the capture honest.
                  animation: _controller,
                  builder: (context, _) {
                    final canSave = !_controller.isEmpty && !_saving;
                    // composite-hide: whole שמור button gone when the org hides
                    // this element (save action → critical:false).
                    return CfgVisible(
                      'signature_pad.save_btn',
                      child: FilledButton(
                      onPressed: canSave ? _save : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: BsTokens.successDark,
                        foregroundColor: bsOnAccent(context),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                        ),
                      ),
                      child: const CfgText(
                        'signature_pad.save_btn',
                        'שמור חתימה ✍️',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Drives a [SignaturePad]: holds the recorded [strokes] and notifies listeners
/// when ink changes so the save button can enable/disable. [isEmpty] is true
/// until the first real point lands.
class SignaturePadController extends ChangeNotifier {
  final List<_Stroke> _strokes = <_Stroke>[];

  /// An immutable snapshot of the recorded strokes (for rasterizing).
  List<List<Offset>> get strokes =>
      List<List<Offset>>.unmodifiable(_strokes.map(List<Offset>.from));

  /// True until at least one point has been drawn — gates the save action.
  bool get isEmpty => _strokes.every((s) => s.isEmpty);

  void startStroke(Offset p) {
    _strokes.add(<Offset>[p]);
    notifyListeners();
  }

  void extendStroke(Offset p) {
    if (_strokes.isEmpty) {
      _strokes.add(<Offset>[p]);
    } else {
      _strokes.last.add(p);
    }
    notifyListeners();
  }

  void clear() {
    if (_strokes.isEmpty) return;
    _strokes.clear();
    notifyListeners();
  }
}

/// The raw draw surface: a [GestureDetector] over a [CustomPaint] that records
/// the pointer path into [controller] and repaints live. Finger (mobile) and
/// mouse (web) both drive the same pan callbacks.
class SignaturePad extends StatelessWidget {
  const SignaturePad({required this.controller, super.key});

  final SignaturePadController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) => controller.startStroke(d.localPosition),
      onPanUpdate: (d) => controller.extendStroke(d.localPosition),
      child: CustomPaint(
        painter: _SignaturePainter(controller),
        size: Size.infinite,
        // A non-empty hint so the CustomPaint claims the AspectRatio's box.
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.controller) : super(repaint: controller);

  final SignaturePadController controller;

  @override
  void paint(Canvas canvas, Size size) =>
      paintSignatureStrokes(canvas, controller.strokes);

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}

/// Decodes a `data:image/png;base64,…` signature data-URL back to bytes — used
/// by tests / callers that need to assert the capture produced real PNG bytes.
/// Null for a non-data-URL ref (e.g. an uploaded https URL — use
/// `imageProviderForRef` to render that) or a malformed payload.
Uint8List? decodeSignatureBytes(String? ref) {
  if (ref == null || !ref.startsWith('data:image')) return null;
  final comma = ref.indexOf(',');
  if (comma <= 0) return null;
  try {
    return base64Decode(ref.substring(comma + 1));
  } on FormatException {
    return null;
  }
}

/// Worker-forms signature entry (#106/#107) — a richer RTL sheet (✕ close · נקה ·
/// ביטול · אישור, all ≥48dp, the sheet-rule F-46) built on the SHARED internals
/// above (the SAME [SignaturePadController] / [SignaturePad] / [strokesToPngDataUrl]
/// the POD [openSignaturePad] uses). Resolves to the signature as a
/// `data:image/png;base64,…` data-URL, or **null** on cancel / an empty pad. The
/// worker signs THEIR own form, so the title is caller-supplied (not the fixed
/// "חתימת הלקוח" of the POD sheet).
Future<String?> showSignatureSheet(
  BuildContext context, {
  required String title,
}) {
  final controller = SignaturePadController();
  // The pad's pixel box, captured from layout, so the exported PNG matches the
  // size the user actually signed at.
  final padKey = GlobalKey();
  const padHeight = 180.0;

  return showModalBottomSheet<String?>(
    context: context,
    backgroundColor: BsTokens.cardLight,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
    ),
    // Explicit RTL on every modal sheet (the sheets convention, F-46).
    builder: (sheetCtx) => Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space3,
            BsTokens.space4,
            BsTokens.space4 + MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // Explicit X close (sheet rule) — IconButton is 48dp.
                  IconButton(
                    tooltip: 'סגור',
                    icon: const Icon(Icons.close, color: BsTokens.mutedLight),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: BsTokens.space2),
              // The signing canvas, framed so the white pad reads as an input.
              Container(
                key: padKey,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E2E2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: padHeight,
                    width: double.infinity,
                    child: SignaturePad(controller: controller),
                  ),
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              const CfgText(
                'signature_pad.form_hint',
                'חתום/חתמי באצבע בתוך המסגרת.',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              ),
              const SizedBox(height: BsTokens.space3),
              Row(
                children: [
                  // 'נקה' — wipe the pad without closing the sheet.
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'נקה חתימה',
                      excludeSemantics: true,
                      // composite-hide: whole נקה pill gone when the org hides
                      // this element (clear action → critical:false).
                      child: CfgVisible(
                        'signature_pad.clear2',
                        child: Material(
                        color: BsTokens.surfaceMid,
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                          onTap: controller.clear,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            alignment: Alignment.center,
                            child: const CfgText(
                              'signature_pad.clear2',
                              '🧽 נקה',
                              style: TextStyle(
                                color: BsTokens.inkLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  // 'ביטול' — discard and return null.
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'ביטול',
                      excludeSemantics: true,
                      // composite-hide: whole ביטול pill gone when the org hides
                      // this element (cancel → critical:false).
                      child: CfgVisible(
                        'signature_pad.cancel_btn',
                        child: Material(
                        color: BsTokens.surfaceMid,
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                          onTap: () => Navigator.of(sheetCtx).pop(),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            alignment: Alignment.center,
                            child: const CfgText(
                              'signature_pad.cancel_btn',
                              'ביטול',
                              style: TextStyle(
                                color: BsTokens.inkLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
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
              const SizedBox(height: BsTokens.space2),
              // 'אישור' — empty pad → null; else rasterize at the pad's actual
              // on-screen size and return the data-URL. bsOnAccent on the brand
              // fill (F-28).
              Semantics(
                button: true,
                label: 'אישור חתימה',
                excludeSemantics: true,
                // composite-hide: whole אישור pill gone when the org hides this
                // element (confirm action → critical:false).
                child: CfgVisible(
                  'signature_pad.confirm_btn',
                  child: Material(
                  color: BsTokens.brand,
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    onTap: () async {
                      if (controller.isEmpty) {
                        Navigator.of(sheetCtx).pop();
                        return;
                      }
                      final box = padKey.currentContext?.findRenderObject()
                          as RenderBox?;
                      final size = (box != null && box.hasSize)
                          ? box.size
                          : const Size(360, padHeight);
                      final dataUrl = await strokesToPngDataUrl(
                        controller.strokes,
                        size: size,
                      );
                      if (!sheetCtx.mounted) return;
                      Navigator.of(sheetCtx).pop(dataUrl);
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      alignment: Alignment.center,
                      child: CfgText(
                        'signature_pad.confirm_btn',
                        '✓ אישור',
                        style: TextStyle(
                          color: bsOnAccent(sheetCtx),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
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
      ),
    ),
  );
}
