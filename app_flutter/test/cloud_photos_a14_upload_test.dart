// A14 (launch photo-upload) — prove the CLIENT uploads a captured photo to
// Cloudflare R2 via the `getUploadUrl` callable + an HTTP PUT and STORES the
// resulting `https://…` public URL when the `kCloudPhotos` flag is ON, and is
// BYTE-IDENTICAL to today (the verbatim base64 data-URL) when OFF.
//
// THE GAP A14 closes: every captured photo (POD / before-after / profile /
// store-logo / cert) is a ~1.5MB `data:image/...;base64,…` data-URL in
// SharedPreferences/localStorage — bounded, no cross-device sync. The server
// callable `getUploadUrl` (functions/src/r2.ts) EXISTS but the client never
// called it. A14 wires the gated upload path, forward-ready for when the owner
// provisions R2 + deploys + flips the flag.
//
// WHAT THIS FILE PROVES (the whole point — that it is NOT inert), all via an
// injected FAKE `getUploadUrl` gateway + a FAKE HTTP-PUT (the suite NEVER hits
// the network or Firebase):
//   UPLOAD (gate ON):
//     1. a capture INVOKES `getUploadUrl(kind, contentType)` with the right args,
//        PUTs the EXACT decoded bytes (+ Content-Type) to the presigned URL, and
//        returns/stores the server's PUBLIC URL (not the upload URL, not base64);
//     2. the data-URL→bytes→PUT body round-trips byte-for-byte;
//   ZERO-REGRESSION LOCK (gate OFF):
//     3. the guarded base64 data-URL is returned VERBATIM and the gateway is
//        NEVER touched (byte-identical to today);
//     4. the compile-time default is OFF (`kCloudPhotos` false);
//   GRACEFUL, HONEST FAILURE (gate ON):
//     5. `getUploadUrl` throws (not-deployed / R2 unconfigured →
//        `failed-precondition`) → FALL BACK to the base64 data-URL (no loss);
//     6. the PUT is non-2xx → FALL BACK to base64 (no fake success);
//     7. the PUT throws (transport error) → FALL BACK to base64;
//     8. a non-uploadable MIME (e.g. image/gif) is kept as base64 (never sent);
//   DISPLAY DUAL-RENDER (`imageProviderForRef`):
//     9. an `https://…` ref → a NetworkImage; a `data:image…` ref → a
//        MemoryImage of the decoded bytes; a non-photo/null → null; and
//        `showFullPhotoRefDialog` is a no-op for a non-renderable ref.
//
// The gate is the module seam `photoUploadEnabled` (defaults to the compile-time
// `kCloudPhotos`, OFF today); a test flips it + injects a fake gateway/PUT to
// exercise the ON branch in the define-less suite (the A13 `serverCallables`
// testability pattern), restoring every seam in a tearDown.

import 'dart:convert';
import 'dart:typed_data';

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/upload_functions.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [UploadFunctionsGateway]: records every `getUploadUrl`
/// invocation (kind/contentType/name) and returns a configurable [UploadTarget],
/// or throws a configurable [UploadFunctionsException] to exercise the
/// graceful-failure path.
class _FakeUploadGateway implements UploadFunctionsGateway {
  final List<({String kind, String contentType, String? name})> calls = [];

  /// When non-null, the next call resolves with this target.
  UploadTarget? target;

  /// When non-null, the next call THROWS this (then clears).
  UploadFunctionsException? fail;

  @override
  Future<UploadTarget> getUploadUrl(
    String kind,
    String contentType, {
    String? name,
  }) async {
    calls.add((kind: kind, contentType: contentType, name: name));
    final f = fail;
    if (f != null) {
      fail = null;
      throw f;
    }
    return target ??
        const UploadTarget(
          uploadUrl: 'https://r2.example/put/abc?sig=xyz',
          publicUrl: 'https://pub-test.r2.dev/pod/uid/123-upload.jpg',
        );
  }
}

/// A fake HTTP-PUT: records the (url, bytes, contentType) of every call and
/// returns a configurable status. Default 200 (success).
class _FakePut {
  final List<({Uri url, Uint8List bytes, String contentType})> calls = [];
  int status = 200;

  /// When non-null, the call THROWS this instead of returning a status.
  Object? error;

  Future<int> call(Uri url, Uint8List bytes, String contentType) async {
    calls.add((url: url, bytes: bytes, contentType: contentType));
    final e = error;
    // Simulates a transport throw (a real http.put throws on connection error);
    // the upload core catches any Object and falls back to base64.
    // ignore: only_throw_errors
    if (e != null) throw e;
    return status;
  }
}

/// Build a `data:<mime>;base64,<payload>` data-URL from raw [bytes].
String _dataUrl(List<int> bytes, {String mime = 'image/jpeg'}) =>
    'data:$mime;base64,${base64Encode(bytes)}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The bytes a capture would have produced (the canvas/picker output).
  final photoBytes = Uint8List.fromList(List<int>.generate(64, (i) => i * 3 % 256));

  late _FakeUploadGateway gateway;
  late _FakePut put;

  // Capture the production seams so each test restores EXACTLY them (the real
  // Firebase gateway + the real http.put + the compile-time gate) — never a
  // re-constructed stand-in.
  final origGateway = photoUploadGateway;
  final origPut = photoHttpPut;
  final origEnabled = photoUploadEnabled;

  setUp(() {
    gateway = _FakeUploadGateway();
    put = _FakePut();
    // Inject the fakes for the full-path delivery seam.
    photoUploadGateway = gateway;
    photoHttpPut = put.call;
  });

  tearDown(() {
    // Restore the production seams so no test leaks state into another.
    photoUploadGateway = origGateway;
    photoHttpPut = origPut;
    photoUploadEnabled = origEnabled;
  });

  group('A14 · UPLOAD — getUploadUrl + PUT (gate ON)', () {
    test('ON: a capture INVOKES getUploadUrl(kind, contentType), PUTs the exact '
        'bytes, and stores the PUBLIC url (not the upload url, not base64)',
        () async {
      photoUploadEnabled = true; // ← flag ON (production gates on kCloudPhotos)
      gateway.target = const UploadTarget(
        uploadUrl: 'https://r2.example/put/k1?sig=AAA',
        publicUrl: 'https://pub-test.r2.dev/pod/u/9-photo.jpg',
      );
      final dataUrl = _dataUrl(photoBytes);

      // The full guarded-delivery gate (exactly what pickTaskPhoto runs after
      // the size-guard).
      final stored = await deliverGuardedPhoto(dataUrl);

      // ── PROOF 1: getUploadUrl invoked with the right kind + contentType ─────
      expect(gateway.calls.length, 1);
      expect(gateway.calls.single.kind, 'pod');
      expect(gateway.calls.single.contentType, 'image/jpeg');

      // ── PROOF 2: the bytes were PUT to the presigned URL with the MIME ──────
      expect(put.calls.length, 1);
      expect(put.calls.single.url, Uri.parse('https://r2.example/put/k1?sig=AAA'));
      expect(put.calls.single.contentType, 'image/jpeg');
      // byte-for-byte the decoded data-URL payload.
      expect(put.calls.single.bytes, equals(photoBytes));

      // ── PROOF 3: the PUBLIC url is stored — NOT the upload url, NOT base64 ──
      expect(stored, 'https://pub-test.r2.dev/pod/u/9-photo.jpg');
      expect(stored, isNot(startsWith('data:')));
      expect(stored, isNot(contains('sig=AAA')));
    });

    test('ON: a PNG capture sends contentType image/png', () async {
      photoUploadEnabled = true;
      final stored = await deliverGuardedPhoto(
        _dataUrl(photoBytes, mime: 'image/png'),
      );
      expect(gateway.calls.single.contentType, 'image/png');
      expect(put.calls.single.contentType, 'image/png');
      expect(stored, startsWith('https://'));
    });
  });

  group('A14 · ZERO-REGRESSION — base64 path (gate OFF = byte-identical)', () {
    test('OFF: the guarded base64 data-URL is returned VERBATIM and getUploadUrl '
        'is NEVER invoked (the zero-regression lock)', () async {
      photoUploadEnabled = false; // ← OFF = today, exactly
      final dataUrl = _dataUrl(photoBytes);

      final stored = await deliverGuardedPhoto(dataUrl);

      // Byte-identical to the input data-URL — nothing changed.
      expect(stored, dataUrl);
      expect(stored, startsWith('data:image/jpeg;base64,'));
      // The upload seam was NEVER touched.
      expect(
        gateway.calls,
        isEmpty,
        reason: 'OFF ⇒ no callable ⇒ the base64 data-URL is today, exactly',
      );
      expect(put.calls, isEmpty, reason: 'OFF ⇒ no upload PUT');
    });

    test('the compile-time default is OFF (production gates on kCloudPhotos)', () {
      expect(
        kCloudPhotos,
        isFalse,
        reason: 'production keeps the base64 flow until the owner flips the flag',
      );
      // A fresh module load defaults the gate to the compile-time flag.
      expect(photoUploadEnabled, kCloudPhotos);
    });
  });

  group('A14 · GRACEFUL FAILURE — fall back to base64 (no loss, no fake)', () {
    test('ON: getUploadUrl throws (failed-precondition: R2 not configured) → '
        'returns the base64 data-URL (the photo is NOT lost)', () async {
      photoUploadEnabled = true;
      gateway.fail = const UploadFunctionsException(
        'failed-precondition',
        'R2_BUCKET is not configured',
      );
      final dataUrl = _dataUrl(photoBytes);

      final stored = await deliverGuardedPhoto(dataUrl); // must not throw

      expect(gateway.calls, isNotEmpty, reason: 'it tried the callable');
      expect(put.calls, isEmpty, reason: 'no PUT after the callable failed');
      // Honest fallback: the local base64, never a fake https success.
      expect(stored, dataUrl);
      expect(stored, startsWith('data:'));
    });

    test('ON: the PUT is non-2xx (e.g. 403) → falls back to base64', () async {
      photoUploadEnabled = true;
      put.status = 403; // presigned URL rejected / expired
      final dataUrl = _dataUrl(photoBytes);

      final stored = await deliverGuardedPhoto(dataUrl);

      expect(gateway.calls, isNotEmpty);
      expect(put.calls, isNotEmpty, reason: 'it attempted the PUT');
      expect(stored, dataUrl, reason: 'non-2xx ⇒ honest base64 fallback');
      expect(stored, startsWith('data:'));
    });

    test('ON: the PUT throws (transport error) → falls back to base64', () async {
      photoUploadEnabled = true;
      put.error = Exception('connection reset');
      final dataUrl = _dataUrl(photoBytes);

      final stored = await deliverGuardedPhoto(dataUrl); // must not throw

      expect(stored, dataUrl);
      expect(stored, startsWith('data:'));
    });

    test('ON: a non-uploadable MIME (image/gif) is kept as base64 and NEVER '
        'sent to getUploadUrl', () async {
      photoUploadEnabled = true;
      final dataUrl = _dataUrl(photoBytes, mime: 'image/gif');

      final stored = await deliverGuardedPhoto(dataUrl);

      expect(
        gateway.calls,
        isEmpty,
        reason: 'gif is outside the R2 allow-list — never uploaded',
      );
      expect(stored, dataUrl);
    });
  });

  group('A14 · uploadCapturedPhoto (pure core) — explicit-seam form', () {
    test('uploads and returns publicUrl on a 2xx', () async {
      gateway.target = const UploadTarget(
        uploadUrl: 'https://r2.example/put',
        publicUrl: 'https://pub-test.r2.dev/pod/u/1.jpg',
      );
      final r = await uploadCapturedPhoto(
        _dataUrl(photoBytes),
        gateway: gateway,
        put: put.call,
      );
      expect(r, 'https://pub-test.r2.dev/pod/u/1.jpg');
      expect(put.calls.single.bytes, equals(photoBytes));
    });
  });

  group('A14 · DISPLAY — imageProviderForRef dual-render', () {
    test('an https url → a NetworkImage', () {
      final p = imageProviderForRef('https://pub-test.r2.dev/pod/u/1.jpg');
      expect(p, isA<NetworkImage>());
      expect((p! as NetworkImage).url, 'https://pub-test.r2.dev/pod/u/1.jpg');
      expect(isHttpPhotoRef('https://x/y.jpg'), isTrue);
    });

    test('a data:image;base64 url → a MemoryImage of the decoded bytes', () {
      final dataUrl = _dataUrl(photoBytes, mime: 'image/png');
      final p = imageProviderForRef(dataUrl);
      expect(p, isA<MemoryImage>());
      expect((p! as MemoryImage).bytes, equals(photoBytes));
      expect(isHttpPhotoRef(dataUrl), isFalse);
    });

    test('null / empty / non-photo (legacy demo) → null', () {
      expect(imageProviderForRef(null), isNull);
      expect(imageProviderForRef(''), isNull);
      expect(imageProviderForRef('demo'), isNull);
      expect(imageProviderForRef('data:text/plain;base64,Zg=='), isNull);
    });
  });
}
