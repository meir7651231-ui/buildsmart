// REAL signature pad — coverage for the on-device capture (widgets/
// signature_pad.dart) that replaced the honest "(הדגמה)" POD placeholder.
//
// The pad is a hand-built CustomPaint + GestureDetector: strokes are recorded
// as polylines and rasterized to a PNG data-URL via a ui.PictureRecorder →
// ui.Picture.toImage → toByteData(png) (works headless in flutter test, unlike
// RepaintBoundary.toImage). The tests prove:
//  • a DRAWN pad → a non-empty `data:image/png;base64,…` with real PNG bytes;
//  • an EMPTY pad → null (no fake signature is ever produced) AND the שמור
//    button is disabled (a no-op);
//  • the captured signature renders as a preview.

import 'package:buildsmart/widgets/signature_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The 8-byte PNG file signature — proves the encoder produced a real PNG, not
/// an arbitrary blob.
final List<int> _pngMagic = <int>[137, 80, 78, 71, 13, 10, 26, 10];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('strokesToPngDataUrl — pure rasterizer', () {
    test('real strokes → a non-empty PNG data-URL with the PNG magic', () async {
      final url = await strokesToPngDataUrl(<List<Offset>>[
        <Offset>[const Offset(10, 20), const Offset(80, 120), const Offset(200, 60)],
        <Offset>[const Offset(300, 40), const Offset(420, 200)],
      ]);
      expect(url, isNotNull);
      expect(url, startsWith('data:image/png;base64,'));
      final bytes = decodeSignatureBytes(url);
      expect(bytes, isNotNull);
      expect(bytes!.isNotEmpty, isTrue);
      expect(
        bytes.sublist(0, 8),
        _pngMagic,
        reason: 'the encoded payload must be a genuine PNG image',
      );
    });

    test('a single-point (dot) stroke still produces a real signature', () async {
      final url = await strokesToPngDataUrl(<List<Offset>>[
        <Offset>[const Offset(50, 50)],
      ]);
      expect(url, isNotNull);
      expect(decodeSignatureBytes(url)!.sublist(0, 8), _pngMagic);
    });

    test('an EMPTY pad → null (no fake signature is ever fabricated)', () async {
      expect(await strokesToPngDataUrl(<List<Offset>>[]), isNull);
      // Strokes present but all empty (no points) → still nothing real to draw.
      expect(
        await strokesToPngDataUrl(<List<Offset>>[<Offset>[], <Offset>[]]),
        isNull,
        reason: 'no points = no ink = honest null, never a blank fake',
      );
    });
  });

  group('SignaturePadController — ink gating', () {
    test('starts empty; recording points flips isEmpty false', () {
      final c = SignaturePadController();
      addTearDown(c.dispose);
      expect(c.isEmpty, isTrue);
      c.startStroke(const Offset(5, 5));
      expect(c.isEmpty, isFalse);
      c.extendStroke(const Offset(6, 6));
      expect(c.strokes.first.length, 2);
      c.clear();
      expect(c.isEmpty, isTrue, reason: 'clear wipes the ink back to empty');
    });

    test('strokes snapshot is an immutable copy (mutating it never leaks back)',
        () {
      final c = SignaturePadController();
      addTearDown(c.dispose);
      c.startStroke(const Offset(1, 1));
      final snap = c.strokes;
      expect(() => snap.add(<Offset>[]), throwsUnsupportedError);
    });
  });

  group('SignaturePadSheet widget — DRAW → save', () {
    testWidgets('drawing strokes then שמור pops a non-empty PNG data-URL',
        (tester) async {
      String? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      captured = await openSignaturePad(context);
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(
        find.byType(SignaturePad),
        findsOneWidget,
        reason: 'the pad sheet is open',
      );

      // Before drawing, שמור is disabled (no empty/fake save).
      final saveFinder = find.widgetWithText(FilledButton, 'שמור חתימה ✍️');
      expect(
        tester.widget<FilledButton>(saveFinder).onPressed,
        isNull,
        reason: 'an empty pad cannot save — honest, no fake signature',
      );

      // DRAW a few strokes directly on the pad surface (finger/mouse path).
      final padRect = tester.getRect(find.byType(SignaturePad));
      final g1 = await tester.startGesture(padRect.centerLeft + const Offset(20, 0));
      await g1.moveBy(const Offset(40, -30));
      await g1.moveBy(const Offset(60, 50));
      await g1.moveBy(const Offset(50, -20));
      await g1.up();
      await tester.pump();

      final g2 = await tester.startGesture(padRect.center);
      await g2.moveBy(const Offset(30, 40));
      await g2.moveBy(const Offset(40, -60));
      await g2.up();
      await tester.pump();

      // Now שמור is enabled.
      expect(
        tester.widget<FilledButton>(saveFinder).onPressed,
        isNotNull,
        reason: 'real ink enables the save action',
      );

      // The drawn gesture produced real ink in the pad's controller.
      final pad = tester.widget<SignaturePad>(find.byType(SignaturePad));
      expect(
        pad.controller.isEmpty,
        isFalse,
        reason: 'the dragged strokes were recorded as real ink',
      );
      final drawnStrokes = pad.controller.strokes;
      expect(
        drawnStrokes.expand((s) => s).length,
        greaterThan(3),
        reason: 'multiple captured points across the two strokes',
      );

      // The PNG encode (ui.Image.toByteData(png)) needs a real async turn — the
      // Skia codec runs off the fake test clock, so drive it through runAsync
      // (the standard flutter_test escape hatch for real async). Encoding the
      // EXACT strokes the gesture recorded proves the drawn path → a real PNG.
      final encoded = await tester.runAsync(
        () => strokesToPngDataUrl(drawnStrokes),
      );
      expect(encoded, isNotNull);
      expect(encoded, startsWith('data:image/png;base64,'));
      final bytes = decodeSignatureBytes(encoded);
      expect(bytes, isNotNull);
      expect(bytes!.isNotEmpty, isTrue);
      expect(
        bytes.sublist(0, 8),
        _pngMagic,
        reason: 'the drawn strokes produced a genuine PNG',
      );

      // And tapping שמור drives the sheet's own save → it pops the data-URL
      // back to the caller (driven under runAsync so the codec completes).
      await tester.runAsync(() async {
        await tester.tap(saveFinder);
        // Let the async encode + Navigator.pop settle in real time.
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(
        captured,
        isNotNull,
        reason: 'the שמור action returned the real captured signature',
      );
      expect(captured, startsWith('data:image/png;base64,'));
      expect(decodeSignatureBytes(captured)!.sublist(0, 8), _pngMagic);
    });

    testWidgets('an empty pad: שמור stays disabled — closing yields no signature',
        (tester) async {
      String? captured = 'sentinel';
      var returned = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      captured = await openSignaturePad(context);
                      returned = true;
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final saveFinder = find.widgetWithText(FilledButton, 'שמור חתימה ✍️');
      expect(tester.widget<FilledButton>(saveFinder).onPressed, isNull);
      // Tapping the disabled button does nothing — no capture, sheet stays open.
      await tester.tap(saveFinder, warnIfMissed: false);
      await tester.pump();
      expect(returned, isFalse, reason: 'a disabled save never closes the sheet');
      expect(find.byType(SignaturePad), findsOneWidget);

      // Dismiss via the back button (cancel) → null, never a fake.
      Navigator.of(tester.element(find.byType(SignaturePad))).pop();
      await tester.pumpAndSettle();
      expect(returned, isTrue);
      expect(captured, isNull, reason: 'cancel stores nothing — no demo');
    });
  });

  group('signature preview renders', () {
    testWidgets('a captured signature data-URL renders as a real Image widget',
        (tester) async {
      // Produce a real capture first, then render it (the POD-sheet preview
      // path routes a data-URL through Image.memory of the decoded bytes). The
      // PNG encode + image decode need real async (the Skia codec runs off the
      // fake test clock), so drive both through runAsync.
      final bytes = await tester.runAsync(() async {
        final url = await strokesToPngDataUrl(<List<Offset>>[
          <Offset>[const Offset(10, 10), const Offset(100, 100)],
        ]);
        return decodeSignatureBytes(url);
      });
      expect(bytes, isNotNull);
      expect(
        bytes!.sublist(0, 8),
        _pngMagic,
        reason: 'the preview is fed genuine PNG bytes',
      );

      final image = Image.memory(bytes);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: image)));
      // Let the real image-codec decode complete (off the fake clock).
      await tester.runAsync(
        () => precacheImage(image.image, tester.element(find.byType(Image))),
      );
      await tester.pump();
      expect(
        find.byType(Image),
        findsOneWidget,
        reason: 'the captured signature shows as an Image preview',
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'the captured PNG decodes and renders without error',
      );
    });
  });
}
