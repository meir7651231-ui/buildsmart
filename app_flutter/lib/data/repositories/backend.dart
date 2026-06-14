import 'package:firebase_core/firebase_core.dart' show Firebase;

/// Master switch for the LIVE Firebase backend. Repository providers route to
/// their `_firebase` impls only when this is true; otherwise everything stays
/// on the in-memory/demo `_local` path the app shipped with.
///
/// Default OFF: the live web build serves demo data even though S0 initialises
/// Firebase, until the backend is explicitly enabled (Firestore deployed +
/// Rules live + seeded). Flip on at build time:
///   flutter build web --dart-define=USE_FIREBASE_BACKEND=true
/// Tests never initialise Firebase, so they stay on `_local` regardless.
const bool kUseFirebaseBackendFlag =
    bool.fromEnvironment('USE_FIREBASE_BACKEND');

/// True only when the flag is set AND Firebase actually initialised.
bool get useFirebaseBackend =>
    kUseFirebaseBackendFlag && Firebase.apps.isNotEmpty;

/// A5 (launch uid-migration) — master switch for UID-SCOPED Firestore queries.
/// Default OFF: the orders listen stays the WHOLE-collection listen every
/// caller relies on today, so flipping this flag is the ONLY thing that changes
/// behaviour — with it OFF the build is BYTE-IDENTICAL to today (zero
/// regression, the A5 invariant). Flip on at build time once the rules +
/// indexes are deployed and existing docs are backfilled with storeUid/
/// courierUid:
///   flutter build web --dart-define=UID_SCOPED_QUERIES=true
/// When ON (and a uid + role are known) `ordersRepositoryProvider` scopes the
/// orders listen to what the Security Rules can prove per role:
///   • contractor → contractorUid == uid
///   • store      → the shared pool (storeUid=='' & a store-stage) ∪ own
///                  (storeUid == uid)
///   • courier    → analogous on courierUid
///   • manager/admin → no scope (the whole collection — the god view).
/// Tests never initialise Firebase, so the local path ignores this flag.
const bool kUidScopedQueries = bool.fromEnvironment('UID_SCOPED_QUERIES');

/// A13 (launch server-connect) — master switch for ROUTING the canonical
/// order-stage advance + contractor-credit through their Cloud Functions
/// CALLABLES (`advanceOrderStage` / `computeCredit`, region [me-west1]) instead
/// of direct optimistic Firestore writes / the client-side credit hash.
///
/// Default OFF: with it OFF the build is BYTE-IDENTICAL to today —
///   • `advance` keeps the direct optimistic `upsert` (cache + background
///     `set`) verbatim, and
///   • `creditLimit(name)` stays the deterministic `contractorCredit(name)`
///     client hash —
/// so flipping this flag is the ONLY thing that changes behaviour (the same
/// zero-regression invariant as [kUidScopedQueries] / [kUseFirebaseBackendFlag]).
///
/// Flip on at build time ONCE the owner has deployed the functions
/// (`functions/src/index.ts` re-exports both) + the S5 rules are live:
///   flutter build web --dart-define=SERVER_CALLABLES=true
///
/// When ON (and a callable gateway is bound — only under the live Firebase
/// backend) the server performs the canonical write/computation; the client
/// keeps an OPTIMISTIC LOCAL update for UX but does NOT also fire a direct
/// PERSISTENT write — the `orders` direct-write would otherwise be reverted by
/// the `revertIllegalOrderStageWrite` trigger, since the callable IS the
/// sanctioned stage-advance path. A `FirebaseFunctionsException` (function
/// not-deployed / permission-denied) is surfaced honestly, never faked.
///
/// Tests never initialise Firebase + bind no gateway, so the local path is
/// unaffected; an injected fake gateway + the per-notifier `serverCallables`
/// field exercise the ON branch in the standard define-less suite (the
/// `kUidScopedQueries` / `uidScoped` testability pattern).
const bool kServerCallables = bool.fromEnvironment('SERVER_CALLABLES');

/// A14 (launch photo-upload) — master switch for UPLOADING captured photos to
/// Cloudflare R2 via the `getUploadUrl` callable (region [me-west1]) and storing
/// the resulting `https://…` public URL, instead of inlining the image as a
/// ~1.5MB `data:image/...;base64,…` data-URL in SharedPreferences/localStorage.
///
/// Default OFF: with it OFF the capture path is BYTE-IDENTICAL to today — every
/// photo (POD / before-after / profile / store-logo / cert) stays the verbatim
/// base64 data-URL the persist layer has always stored, the `getUploadUrl`
/// callable is NEVER called, and the ~1.5MB persist-budget guard
/// (`kMaxPhotoDataUrlChars`) is untouched. So flipping this flag is the ONLY
/// thing that changes behaviour (the same zero-regression invariant as
/// [kServerCallables] / [kUidScopedQueries] / [kUseFirebaseBackendFlag]).
///
/// Separate from [kServerCallables] so photo-upload can activate INDEPENDENTLY
/// of the order/credit callables. Flip on at build time ONCE the owner has
/// provisioned R2 (bucket + `R2_*` secrets/params) and deployed the function
/// (`functions/src/r2.ts` is re-exported by `functions/src/index.ts`):
///   flutter build web --dart-define=CLOUD_PHOTOS=true
///
/// When ON, the single capture seam (`services/task_photo.dart`) — after it has
/// the downscaled image bytes — calls `getUploadUrl({kind, contentType})`, does
/// an HTTP `PUT` of the bytes to the returned presigned URL, and on a 2xx
/// returns the public object URL (`{IMAGE_BASE_URL}/{server-owned key}`). If the
/// callable throws (not-deployed / R2 unconfigured → `failed-precondition`) or
/// the PUT is non-2xx, it FALLS BACK to the base64 data-URL (the photo is NOT
/// lost — saved locally exactly as today) and logs it honestly; a success is
/// NEVER faked. Both forms are plain strings stored the same way, and every
/// render site decodes BOTH (an `https://…` to a network image, a `data:…` to
/// the current base64 decode — see `imageProviderForRef` in
/// widgets/photo_viewer.dart).
///
/// Tests never initialise Firebase; the upload seams (`UploadFunctionsGateway` +
/// the HTTP-PUT function) are injected as fakes, so the ON branch is exercised in
/// the standard define-less suite without touching the network.
const bool kCloudPhotos = bool.fromEnvironment('CLOUD_PHOTOS');

/// F2 (launch App-Check-native) — master switch for the PRODUCTION App Check
/// attestation providers at `FirebaseAppCheck.instance.activate` time
/// (`lib/main.dart`).
///
/// Default OFF: with it OFF the `activate` call is BYTE-IDENTICAL to today —
/// `AndroidProvider.debug` + `AppleProvider.debug` (the dev/demo attestation the
/// app shipped with), web still skipped. So flipping this flag is the ONLY thing
/// that changes the providers selected (the same zero-regression invariant as
/// [kCloudPhotos] / [kServerCallables] / [kUidScopedQueries] /
/// [kUseFirebaseBackendFlag]). App Check does NOT enforce client-side — the
/// `activate` call only makes the Firebase SDKs ATTACH the attestation token;
/// rejecting un-tokened requests is a Firebase console toggle (owner's). So a
/// failure to activate must never block app start (the call stays inside
/// `main`'s `Firebase.apps.isNotEmpty` gate, wrapped in a non-fatal try).
///
/// Flip on at build time ONCE the owner has (F1) supplied the real mobile
/// `firebase_options` AND registered the App Check attestation keys in the
/// console (Play Integrity for Android, App Attest/DeviceCheck for Apple):
///   flutter build … --dart-define=APP_CHECK_PROD=true
///
/// When ON the native providers become `AndroidProvider.playIntegrity` +
/// `AppleProvider.appAttestWithDeviceCheckFallback` (App Attest on iOS 14+/
/// macOS 14+, DeviceCheck fallback otherwise). Web stays skipped unless a
/// reCAPTCHA site key is supplied at build time (`--dart-define=APP_CHECK_RECAPTCHA_SITE_KEY=…`),
/// matching today's web-skipped behaviour when none is set.
///
/// Tests never initialise Firebase; the provider SELECTION is a pure helper
/// (`appCheckProvidersFor` in `lib/main.dart`) asserted in the standard
/// define-less suite (this flag pinned false), so the ON branch is proven
/// WITHOUT calling `activate`.
const bool kAppCheckProd = bool.fromEnvironment('APP_CHECK_PROD');

/// F2 — the web reCAPTCHA v3 site key for App Check. Empty (default) → the web
/// App Check path stays SKIPPED exactly as today; supply it at build time to
/// activate web attestation alongside the native [kAppCheckProd] providers:
///   flutter build web --dart-define=APP_CHECK_PROD=true \
///       --dart-define=APP_CHECK_RECAPTCHA_SITE_KEY=6Lc…
const String kAppCheckRecaptchaSiteKey =
    String.fromEnvironment('APP_CHECK_RECAPTCHA_SITE_KEY');
