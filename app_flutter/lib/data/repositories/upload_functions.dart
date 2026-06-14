// ─────────────────────────────────────────────────────────────────────────────
// upload_functions — A14 (launch photo-upload): the injectable CALLABLE seam for
// the `getUploadUrl` Cloud Function (`functions/src/r2.ts`, re-exported by
// `functions/src/index.ts`) that mints a presigned PUT URL against the
// Cloudflare R2 bucket. The client never touches `FirebaseFunctions` directly —
// it goes through this port, exactly like [OrderFunctionsGateway] (A13) and
// [AuthGateway].
//
// THE SERVER CONTRACT (verbatim from functions/src/r2.ts):
//   • Input  `{ kind: 'pod'|'before-after', contentType, fileName? }` — the
//     OBJECT KEY IS SERVER-OWNED (`{kind}/{uid}/{ts}-{sanitized-fileName}`); the
//     client only chooses the upload `kind` + image `contentType` (+ an optional
//     basename), NEVER the path. `contentType` ∈ image/jpeg·png·webp·heic·heif.
//   • Output `{ ok, url, key, method:'PUT', headers:{'Content-Type':…}, expiresIn }`
//     — `url` is the presigned PUT URL (expires in 10 min); `key` is the
//     server-owned object key. There is NO public-URL field on the wire: the
//     PUBLIC URL is composed client-side as `{kImageBaseUrl}/{key}` — the SAME
//     R2 public base (`https://pub-…r2.dev`) the catalog images already serve
//     from ([kImageBaseUrl] in data/product_images.dart). The upload itself is a
//     plain HTTP `PUT` of the bytes to `url` with that exact `Content-Type`.
//
// THE SEAM: the gateway speaks in a NEUTRAL plain-Dart [UploadTarget] and a
// neutral [UploadFunctionsException] — NOT `HttpsCallableResult` /
// `FirebaseFunctionsException` — so the capture path (and its tests) stay
// Firebase-free. The real adapter ([FirebaseUploadFunctionsGateway]) resolves
// `FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion)` LAZILY (never at
// construction — the `FirebaseOrderFunctionsGateway` rule), translating every
// provider failure into the neutral exception (e.g. `failed-precondition` when
// R2 is not configured, `unauthenticated` when signed-out, `unavailable` when
// the function is not deployed). The region is reused from [kAuthFunctionsRegion]
// (me-west1, Tel Aviv) — the callable lives next to `setRole` / `getUploadUrl`.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/product_images.dart' show kImageBaseUrl;
import 'package:buildsmart/state/auth_state.dart' show kAuthFunctionsRegion;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// The result of a successful `getUploadUrl` call — the two URLs the caller
/// needs: [uploadUrl] (the presigned PUT target, 10-min TTL) and [publicUrl]
/// (the `https://…` object URL composed from the server-owned key + the R2
/// public base), which is what gets STORED in place of the base64 data-URL.
@immutable
class UploadTarget {
  const UploadTarget({required this.uploadUrl, required this.publicUrl});

  /// The presigned URL the bytes are PUT to (private, single-use, expires).
  final String uploadUrl;

  /// The durable public `https://…` URL the photo is reachable at AFTER the PUT
  /// — `{kImageBaseUrl}/{key}`. This is the string stored in place of the
  /// base64 data-URL (every render site decodes both forms).
  final String publicUrl;
}

/// The neutral callable failure: a stable [code] (mirrors
/// `FirebaseFunctionsException.code`, e.g. `unauthenticated`,
/// `failed-precondition` when R2 is not configured, `invalid-argument`, or
/// `unavailable` when the function is not deployed) + optional raw message.
/// Nothing above the seam imports cloud_functions exception types — the caller
/// maps a failure to a graceful fallback (the base64 data-URL), never a faked
/// upload.
@immutable
class UploadFunctionsException implements Exception {
  const UploadFunctionsException(this.code, [this.message]);

  /// Stable error code (`FirebaseFunctionsException.code` verbatim, or
  /// `unavailable` when no gateway exists / the function is unreachable).
  final String code;

  /// Raw (English) provider message — for logs, never shown to the user.
  final String? message;

  @override
  String toString() =>
      'UploadFunctionsException($code${message == null ? '' : ': $message'})';
}

/// The injectable Cloud Functions seam for the A14 `getUploadUrl` callable. The
/// capture path touches functions ONLY through this port, so a hand-rolled fake
/// drives every unit test and the real impl ([FirebaseUploadFunctionsGateway])
/// stays the only thing that resolves a live `FirebaseFunctions` instance.
// A deliberate one-member port (the seam idiom of [OrderFunctionsGateway]) —
// kept abstract so tests inject a fake instead of a real Functions instance.
// ignore: one_member_abstracts
abstract class UploadFunctionsGateway {
  /// Call `getUploadUrl({kind, contentType, fileName})` — the server mints a
  /// presigned PUT URL for a SERVER-OWNED key and returns it; we also compose
  /// the durable public URL. [kind] is `'pod'` or `'before-after'`;
  /// [contentType] is one of the allowed image MIME types; [name] is an optional
  /// basename hint (the server sanitises it — no path is ever honoured). Throws
  /// [UploadFunctionsException] on any failure (sign-in required / R2 not
  /// configured / not deployed / bad argument).
  Future<UploadTarget> getUploadUrl(
    String kind,
    String contentType, {
    String? name,
  });
}

/// The REAL FirebaseFunctions adapter. Resolves the Functions instance LAZILY —
/// never in the constructor — so merely constructing the gateway does NOT
/// require Firebase to be initialised; the instance is only touched on the first
/// call. Translates `FirebaseFunctionsException` (and any other failure) into
/// the neutral [UploadFunctionsException] — the single choke-point that keeps
/// cloud_functions types below the seam (the `FirebaseOrderFunctionsGateway`
/// shape).
class FirebaseUploadFunctionsGateway implements UploadFunctionsGateway {
  FirebaseUploadFunctionsGateway({FirebaseFunctions? functions})
    : _injectedFunctions = functions;

  /// Optional pre-resolved instance (tests / DI). When null it is resolved
  /// lazily from the singleton on first use.
  final FirebaseFunctions? _injectedFunctions;

  FirebaseFunctions get _functions =>
      _injectedFunctions ??
      FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion);

  @override
  Future<UploadTarget> getUploadUrl(
    String kind,
    String contentType, {
    String? name,
  }) async {
    try {
      final res = await _functions.httpsCallable('getUploadUrl').call<dynamic>(
        <String, String>{
          'kind': kind,
          'contentType': contentType,
          if (name != null && name.isNotEmpty) 'fileName': name,
        },
      );
      final m = _asMap(res.data);
      final url = _str(m['url']);
      final key = _str(m['key']);
      if (url == null || key == null) {
        // A well-formed server always returns both; a missing field is an
        // honest failure (never an empty/faked upload target).
        throw const UploadFunctionsException(
          'internal',
          'getUploadUrl response missing url/key',
        );
      }
      return UploadTarget(uploadUrl: url, publicUrl: _publicUrlFor(key));
    } on FirebaseFunctionsException catch (e) {
      throw UploadFunctionsException(e.code, e.message);
    } on UploadFunctionsException {
      rethrow;
    } on Object catch (e) {
      throw UploadFunctionsException('unavailable', e.toString());
    }
  }

  /// Compose the durable public object URL from the server-owned [key] and the
  /// R2 public base (`kImageBaseUrl`). The key never starts with a slash (the
  /// server builds `{kind}/{uid}/…`), so a single join is correct.
  static String _publicUrlFor(String key) {
    final base = kImageBaseUrl.endsWith('/')
        ? kImageBaseUrl.substring(0, kImageBaseUrl.length - 1)
        : kImageBaseUrl;
    final k = key.startsWith('/') ? key.substring(1) : key;
    return '$base/$k';
  }

  /// The callable payload arrives as a JSON map, but the platform channel may
  /// decode nested maps as `Map<Object?, Object?>` — normalise to a string-keyed
  /// map tolerantly so field reads never throw.
  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return const <String, dynamic>{};
  }

  static String? _str(dynamic v) =>
      v is String && v.isNotEmpty ? v : null;
}
