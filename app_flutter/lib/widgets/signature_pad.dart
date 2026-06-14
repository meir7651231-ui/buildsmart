// ✍️ Handwritten-signature capture (Wave-3 contract · Builder-1 A) — a reusable
// pad + a pure PNG encoder + an RTL confirm sheet, used by 101 / חופשה / מחלה.
//
// PURE dart:ui — NO new pub deps, NO `package:web`, NO `dart:js_interop`. Unlike
// geo.dart this needs NO conditional-import seam: the whole surface is plain
// dart:ui (PictureRecorder → Picture.toImage → toByteData(png)) + dart:convert
// (base64) + material, which compiles AND runs on the native test VM. flutter
// test exercises [strokesToPngDataUrl] directly — see signature_pad_test.dart.
//
// SERVER-SWAP: the produced `data:image/png;base64,…` data-URL is the same shape
// the cert/photo wallet already persists, so the screens store it verbatim and
// the backend can later file it unchanged.
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Holds the in-progress strokes of a [SignaturePad] and notifies listeners as
/// the user draws. A stroke is an ordered list of [Offset]s (one polyline); the
/// signature is the list of those strokes. Lift-and-redraw appends a new stroke,
/// so disjoint pen-downs render as separate lines (never auto-joined).
class SignatureController extends ChangeNotifier {
  final List<List<Offset>> _strokes = <List<Offset>>[];

  /// Read-only view of the captured strokes (outer + inner lists are
  /// unmodifiable, so callers cannot mutate the controller's state behind its
  /// back — they go through [startStroke]/[extend]/[endStroke]/[clear]).
  List<List<Offset>> get strokes => List<List<Offset>>.unmodifiable(
        _strokes.map(List<Offset>.unmodifiable),
      );

  /// True until at least one point has been captured — drives the confirm
  /// button (an empty pad confirms to null, never a blank image).
  bool get isEmpty => _strokes.every((s) => s.isEmpty);

  /// Begin a new stroke at [p] (pen-down). Subsequent [extend] calls append to
  /// this stroke until the next [startStroke].
  void startStroke(Offset p) {
    _strokes.add(<Offset>[p]);
    notifyListeners();
  }

  /// Append [p] to the current stroke (pen-move). No-op before the first
  /// [startStroke] (defensive — the pad always opens a stroke on pan-start).
  void extend(Offset p) {
    if (_strokes.isEmpty) return;
    _strokes.last.add(p);
    notifyListeners();
  }

  /// End the current stroke (pen-up). Kept for symmetry / future hooks; the
  /// next [startStroke] already begins a fresh line.
  void endStroke() {}

  /// Wipe all strokes — the 'נקה' action.
  void clear() {
    if (_strokes.isEmpty) return;
    _strokes.clear();
    notifyListeners();
  }
}

/// A white rounded canvas the user signs on. Pan gestures feed [controller];
/// a [CustomPainter] strokes the captured polylines in [BsTokens.inkLight].
class SignaturePad extends StatefulWidget {
  const SignaturePad({required this.controller, this.height = 180, super.key});

  final SignatureController controller;
  final double height;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: widget.height,
        width: double.infinity,
        // Always WHITE — the signature is captured/printed on white, regardless
        // of the surrounding theme.
        color: Colors.white,
        child: GestureDetector(
          // Localize the global drag position to the pad's own coordinate space
          // so the painted line tracks the finger exactly.
          onPanStart: (d) =>
              widget.controller.startStroke(_local(context, d.globalPosition)),
          onPanUpdate: (d) =>
              widget.controller.extend(_local(context, d.globalPosition)),
          onPanEnd: (_) => widget.controller.endStroke(),
          child: CustomPaint(
            painter: _SignaturePainter(widget.controller),
            // Fill the available box so the gesture area == the visible canvas.
            size: Size.infinite,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  /// Map a global pointer position into this widget's local coordinates.
  Offset _local(BuildContext context, Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    return box?.globalToLocal(global) ?? global;
  }
}

/// Strokes the controller's polylines. Repaints whenever the controller
/// notifies (it is wired in as the [Listenable] so every captured point shows
/// up live).
class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.controller) : super(repaint: controller);

  final SignatureController controller;

  @override
  void paint(Canvas canvas, Size size) {
    _paintStrokes(canvas, controller.strokes,
        color: BsTokens.inkLight, strokeWidth: 2.5);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => false;
}

/// Shared ink renderer for both the live pad and the off-screen PNG export, so
/// what the user sees is byte-for-byte what gets encoded. Round caps/joins give
/// a smooth pen look; a lone point (a tap with no drag) is drawn as a dot.
void _paintStrokes(
  Canvas canvas,
  List<List<Offset>> strokes, {
  required Color color,
  required double strokeWidth,
}) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;
  // A separate fill paint for lone-point dots — keeps `paint` immutably a
  // stroke so a tap-dot can't leak its fill style into the next polyline.
  final dotPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  for (final stroke in strokes) {
    if (stroke.isEmpty) continue;
    if (stroke.length == 1) {
      // A single tap → a round dot (drawPath would render nothing for 1 point).
      canvas.drawCircle(stroke.first, strokeWidth / 2, dotPaint);
      continue;
    }
    final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
    for (var i = 1; i < stroke.length; i++) {
      path.lineTo(stroke[i].dx, stroke[i].dy);
    }
    canvas.drawPath(path, paint);
  }
}

/// Rasterizes [strokes] to a PNG and returns it as a `data:image/png;base64,…`
/// data-URL, or **null** when there is nothing to draw (every stroke empty).
///
/// PURE: dart:ui [ui.PictureRecorder] → [Canvas] → [ui.Picture.toImage] →
/// [ui.Image.toByteData] (PNG) → base64. This path runs on the native test VM
/// (the Flutter engine's image codec is available under flutter test), so it is
/// unit-tested directly with no widget pump.
Future<String?> strokesToPngDataUrl(
  List<List<Offset>> strokes, {
  required Size size,
  double strokeWidth = 2.5,
}) async {
  // Honest empty: no points → no image (the caller treats null as "unsigned").
  if (strokes.every((s) => s.isEmpty)) return null;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.width, size.height),
  );
  // White background so the PNG is self-contained on any viewer (matches the
  // pad's white canvas; an alpha-only signature would vanish on white paper).
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.width, size.height),
    Paint()..color = Colors.white,
  );
  _paintStrokes(canvas, strokes,
      color: BsTokens.inkLight, strokeWidth: strokeWidth);

  final picture = recorder.endRecording();
  // Guard against a zero-sized canvas (defensive — the sheet always passes the
  // laid-out pad size). Round up so a sub-pixel size still yields ≥1px.
  // (`num.clamp` is statically `num`, so coerce back to int for toImage.)
  final w = size.width.ceil().clamp(1, 1 << 16).toInt();
  final h = size.height.ceil().clamp(1, 1 << 16).toInt();
  final image = await picture.toImage(w, h);
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return null;
    final b64 = base64Encode(bytes.buffer.asUint8List());
    return 'data:image/png;base64,$b64';
  } finally {
    // Release the GPU/CPU image handle promptly (it is no longer needed once
    // encoded).
    image.dispose();
  }
}

/// RTL modal sheet that captures a signature and returns it as a PNG data-URL,
/// or **null** on cancel / when nothing was drawn. Buttons are ≥48dp; the
/// filled 'אישור' uses [bsOnAccent] on the brand fill.
///
/// Flow: 'נקה' wipes the pad · ✕ / 'ביטול' → null · 'אישור' → null when the pad
/// is empty, else the rasterized signature at the pad's on-screen size (so the
/// exported pixels match what was drawn).
Future<String?> showSignatureSheet(
  BuildContext context, {
  required String title,
}) {
  final controller = SignatureController();
  // The pad's pixel size, captured from its layout, so the exported PNG is the
  // same dimensions the user signed at.
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
                    icon:
                        const Icon(Icons.close, color: BsTokens.mutedLight),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: BsTokens.space2),
              // The signing canvas, framed so the white pad reads as an input.
              Container(
                key: padKey,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E2E2)),
                ),
                child: SignaturePad(controller: controller, height: padHeight),
              ),
              const SizedBox(height: BsTokens.space2),
              const Text(
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
                      child: Material(
                        color: BsTokens.surfaceMid,
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                          onTap: controller.clear,
                          child: Container(
                            constraints:
                                const BoxConstraints(minHeight: 48),
                            alignment: Alignment.center,
                            child: const Text(
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
                  const SizedBox(width: BsTokens.space2),
                  // 'ביטול' — discard and return null.
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'ביטול',
                      excludeSemantics: true,
                      child: Material(
                        color: BsTokens.surfaceMid,
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                          onTap: () => Navigator.of(sheetCtx).pop(),
                          child: Container(
                            constraints:
                                const BoxConstraints(minHeight: 48),
                            alignment: Alignment.center,
                            child: const Text(
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
                      // Export at the pad's laid-out pixel size when available
                      // (falls back to the known height/full width).
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
                      child: Text(
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
            ],
          ),
        ),
      ),
    ),
  );
}
