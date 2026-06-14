// Guard tests for lib/widgets/signature_pad.dart · strokesToPngDataUrl (Wave-3
// contract · Builder-1 A). The encoder is PURE dart:ui (PictureRecorder →
// Picture.toImage → toByteData(png) → base64), so it runs directly on the
// native test VM — no widget pump, no package:web. We assert the two contract
// guarantees:
//   • EMPTY strokes (and all-empty strokes) → null — an unsigned pad never
//     produces a blank image;
//   • a NON-EMPTY stroke → a 'data:image/png;base64,…' data-URL whose decoded
//     body is > 0 bytes (a real PNG was rasterized on the VM).
import 'dart:convert';

import 'package:buildsmart/widgets/signature_pad.dart';
import 'package:flutter/material.dart' show Offset, Size;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // toImage/toByteData need the Flutter engine bindings even on the VM.
  TestWidgetsFlutterBinding.ensureInitialized();

  const size = Size(200, 120);

  group('strokesToPngDataUrl — empty input', () {
    test('an empty stroke list returns null (no signature → no image)',
        () async {
      final url = await strokesToPngDataUrl(const <List<Offset>>[], size: size);
      expect(url, isNull);
    });

    test('strokes that contain only empty strokes also return null', () async {
      // e.g. a controller that opened strokes but captured no points.
      final url = await strokesToPngDataUrl(
        const <List<Offset>>[<Offset>[], <Offset>[]],
        size: size,
      );
      expect(url, isNull, reason: 'every stroke empty ⇒ honest null');
    });
  });

  group('strokesToPngDataUrl — a real stroke', () {
    test(
        'a non-empty stroke yields a data:image/png;base64 URL with a >0-byte '
        'decoded body', () async {
      final strokes = <List<Offset>>[
        <Offset>[
          const Offset(10, 10),
          const Offset(40, 60),
          const Offset(90, 30),
        ],
      ];
      final url = await strokesToPngDataUrl(strokes, size: size);

      expect(url, isNotNull, reason: 'a drawn stroke rasterizes to a PNG');
      expect(url!, startsWith('data:image/png;base64,'),
          reason: 'the contract data-URL prefix');

      // The base64 body after the comma decodes to actual PNG bytes.
      final body = url.substring('data:image/png;base64,'.length);
      final bytes = base64Decode(body);
      expect(bytes.length, greaterThan(0),
          reason: 'the decoded PNG payload is non-empty');
      // PNG magic number (\x89 P N G) — confirms it really is a PNG, not just
      // some non-empty blob.
      expect(bytes.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47],
          reason: 'the bytes carry the PNG signature');
    });

    test('a single-point stroke (a tap dot) still rasterizes to a PNG',
        () async {
      // The lone-point branch draws a dot rather than nothing — it must still
      // count as a signature.
      final url = await strokesToPngDataUrl(
        <List<Offset>>[
          <Offset>[const Offset(50, 50)],
        ],
        size: size,
      );
      expect(url, isNotNull);
      expect(url!, startsWith('data:image/png;base64,'));
      expect(base64Decode(url.substring('data:image/png;base64,'.length)),
          isNotEmpty);
    });
  });
}
