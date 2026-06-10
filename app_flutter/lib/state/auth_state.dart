// ─────────────────────────────────────────────────────────────────────────────
// auth_state — S1 Authentication (server-connect): identity-truth instead of
// role-picker-as-identity.
//
// WHAT LIVES HERE (SPEC-server-connect §S1, MICRO rows S1.4–S1.7/S1.9):
//   • [authStateProvider] — the current Firebase user (uid/phone/email/name)
//     with the repo's `_loaded`-guard discipline;
//   • [roleProvider] — the EFFECTIVE role: server custom-claims when they are
//     decisive (signed-in, exactly one role), today's client persona pick
//     otherwise (zero regression for signed-out / Firebase-free runs);
//   • [roleSwitchLockedProvider] — S1.6: persona = identity. ONE claim role →
//     the role picker is locked (the server decides who you are);
//   • the sign-in / sign-out / delete-account flow methods the login sheet and
//     profile screen call, plus the S1.9 `setRole` callable call-site.
//
// THE SEAM ([AuthGateway]): every FirebaseAuth touch goes through this
// injectable port, which speaks in a NEUTRAL [AuthUser] + plain claim maps —
// NOT in `firebase_auth.User`. That keeps the providers (and their tests)
// Firebase-free: the real adapter ([FirebaseAuthGateway]) resolves
// `FirebaseAuth.instance` LAZILY (never at construction — same rule as
// [FirestoreCollectionSource] in firestore_cached_repo.dart), and a hand-rolled
// fake gateway drives the unit tests with zero new packages.
//
// HARD RULES (violating any of them breaks the S1 contract):
//   1. NOTHING here may touch `FirebaseAuth.instance` when Firebase is not
//      initialised — the whole existing suite must stay Firebase-free. The
//      provider switch is the same `Firebase.apps.isNotEmpty` gate the S2/S3
//      repos use (see the bottom of orders_local.dart).
//   2. Signed-out / gateway-less behavior is EXACTLY today's app: null user,
//      role = the client-side persona pick. Auth is additive.
//   3. A late async result (claims fetch, auth event) must never clobber a
//      newer state — the `_gen` guard below is the `_loaded` discipline of
//      orders_engine.dart adapted to a stream + fetch pipeline.
//
// Comment density/voice intentionally mirrors firestore_cached_repo.dart —
// this file is the auth foundation S5 (Security Rules) builds on.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Cloud Functions region the `setRole` callable (S1.9) is deployed to —
/// must match `functions/src/index.ts`. me-west1 (Tel Aviv) is the project's
/// Firestore region, so the callable lives next to the data.
const String kAuthFunctionsRegion = 'me-west1';

/// One signed-in user — the NEUTRAL shape the auth seam speaks in (instead of
/// `firebase_auth.User`). Keeping the seam in this shape is what lets the
/// providers + tests stay Firebase-free (a fake gateway emits these directly).
@immutable
class AuthUser {
  const AuthUser({
    required this.uid,
    this.phone,
    this.email,
    this.displayName,
  });

  /// The Firebase uid — the identity every Security Rule (S5) keys on.
  final String uid;

  /// E.164 phone (phone sign-in, the primary flow) — null for email users.
  final String? phone;

  /// Email (the S1.3 fallback flow) — null for phone-only users.
  final String? email;

  /// Display name, when the account carries one.
  final String? displayName;

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.uid == uid &&
      other.phone == phone &&
      other.email == email &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(uid, phone, email, displayName);
}

/// The neutral auth failure: a stable [code] (mirrors FirebaseAuthException
/// codes, e.g. `invalid-verification-code`) + optional raw message. The login
/// sheet maps codes → Hebrew toasts; nothing above the seam imports
/// firebase_auth exception types.
@immutable
class AuthGatewayException implements Exception {
  const AuthGatewayException(this.code, [this.message]);

  /// Stable error code (FirebaseAuthException.code verbatim, or `unavailable`
  /// when no gateway exists — Firebase-free runs).
  final String code;

  /// Raw (English) provider message — for logs, never shown to the user.
  final String? message;

  @override
  String toString() => 'AuthGatewayException($code${message == null ? '' : ': $message'})';
}

/// The injectable FirebaseAuth seam. Providers and flows touch auth ONLY
/// through this port, so a hand-rolled fake can drive every unit test and the
/// real impl ([FirebaseAuthGateway]) stays the only thing that resolves a live
/// `FirebaseAuth.instance`.
abstract class AuthGateway {
  /// The live user stream — one event per sign-in/sign-out. CONTRACT (the
  /// FirebaseAuth semantics fakes must honor): the CURRENT state is emitted
  /// to every new listener on subscribe, then changes follow. The notifier
  /// maps each event into an [AuthSnapshot] (claims fetched per signed-in
  /// event; duplicate events are idempotent under the generation guard).
  Stream<AuthUser?> authStateChanges();

  /// The user right now (null = signed out).
  AuthUser? get currentUser;

  /// S1.1 — begin phone sign-in: send the OTP SMS for [phone] (E.164).
  /// Completes with the verificationId once the code is SENT; throws
  /// [AuthGatewayException] on failure. On Android, instant/auto verification
  /// may sign the user in without a typed code — that lands on
  /// [authStateChanges] (the login sheet closes on it).
  Future<String> sendOtp(String phone);

  /// S1.2 — complete phone sign-in with the typed [smsCode] for
  /// [verificationId]. Success lands on [authStateChanges].
  Future<void> signInWithSmsCode(String verificationId, String smsCode);

  /// S1.3 — the email+password fallback flow.
  Future<void> signInWithEmailPassword(String email, String password);

  /// S1.5 — the current user's custom claims (via `getIdTokenResult`).
  /// `{}` when signed out. [forceRefresh] pulls a fresh token (claims changed
  /// server-side, e.g. right after `setRole`).
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false});

  /// S1.7 — sign out.
  Future<void> signOut();

  /// S1.8 — delete the signed-in account (`user.delete()`; Apple requirement).
  /// Throws `requires-recent-login` when the session is too old — the caller
  /// surfaces that in Hebrew and must NOT wipe local data.
  Future<void> deleteAccount();

  /// S1.9 — the in-app call-site of the `setRole` callable (admin assigns
  /// `{uid, role}` → custom claim; the Function verifies the CALLER's admin
  /// claim server-side — see functions/src/index.ts).
  Future<void> setRole({required String uid, required String role});
}

/// The REAL FirebaseAuth adapter. Resolves `FirebaseAuth.instance` (and the
/// Functions instance) LAZILY — never in the constructor — so merely
/// constructing the gateway (e.g. when a provider is read) does NOT require
/// Firebase to be initialised; the instance is only touched on the first call.
class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway({fb.FirebaseAuth? auth, FirebaseFunctions? functions})
      : _injectedAuth = auth,
        _injectedFunctions = functions;

  /// Optional pre-resolved instances (tests / DI). When null they are resolved
  /// lazily from the singletons on first use.
  final fb.FirebaseAuth? _injectedAuth;
  final FirebaseFunctions? _injectedFunctions;

  /// Lazily-resolved auth handle — `FirebaseAuth.instance` is read ONLY here,
  /// on demand, never at construction (so a Firebase-free app/test can
  /// construct the gateway without initialising Firebase).
  fb.FirebaseAuth get _auth => _injectedAuth ?? fb.FirebaseAuth.instance;

  FirebaseFunctions get _functions =>
      _injectedFunctions ??
      FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion);

  /// Pending WEB phone confirmations keyed by verificationId — on web the SDK
  /// has no `verifyPhoneNumber` (no SMS retriever); `signInWithPhoneNumber`
  /// returns a [fb.ConfirmationResult] that must complete the same flow.
  final Map<String, fb.ConfirmationResult> _webConfirmations = {};

  static AuthUser? _toAuthUser(fb.User? u) => u == null
      ? null
      : AuthUser(
          uid: u.uid,
          phone: u.phoneNumber,
          email: u.email,
          displayName: u.displayName,
        );

  /// Run one auth/functions call, translating provider exceptions into the
  /// neutral [AuthGatewayException] — the single choke-point that keeps
  /// firebase_auth types below the seam.
  Future<T> _guard<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthGatewayException(e.code, e.message);
    } on FirebaseFunctionsException catch (e) {
      throw AuthGatewayException(e.code, e.message);
    }
  }

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toAuthUser);

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Future<String> sendOtp(String phone) async {
    if (kIsWeb) {
      // Web flow: reCAPTCHA + ConfirmationResult (verifyPhoneNumber is
      // mobile-only). The pending confirmation is completed in
      // [signInWithSmsCode] under the same verificationId.
      final confirmation = await _guard(() => _auth.signInWithPhoneNumber(phone));
      _webConfirmations[confirmation.verificationId] = confirmation;
      return confirmation.verificationId;
    }
    final completer = Completer<String>();
    await _guard(
      () => _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (credential) async {
          // Android instant/auto verification — sign in silently; the user
          // then lands on authStateChanges and the login sheet closes on it.
          try {
            await _auth.signInWithCredential(credential);
          } on Object catch (e) {
            debugPrint('FirebaseAuthGateway: auto sign-in failed: $e');
          }
        },
        verificationFailed: (e) {
          if (!completer.isCompleted) {
            completer.completeError(AuthGatewayException(e.code, e.message));
          }
        },
        codeSent: (verificationId, _) {
          if (!completer.isCompleted) completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // Auto-retrieval gave up — manual code entry continues with the
          // same verificationId (only relevant if codeSent never fired).
          if (!completer.isCompleted) completer.complete(verificationId);
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<void> signInWithSmsCode(String verificationId, String smsCode) =>
      _guard(() async {
        final pending = _webConfirmations.remove(verificationId);
        if (pending != null) {
          await pending.confirm(smsCode);
          return;
        }
        await _auth.signInWithCredential(
          fb.PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          ),
        );
      });

  @override
  Future<void> signInWithEmailPassword(String email, String password) =>
      _guard(
        () => _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<Map<String, dynamic>> idTokenClaims({bool forceRefresh = false}) =>
      _guard(() async {
        final user = _auth.currentUser;
        if (user == null) return const <String, dynamic>{};
        final result = await user.getIdTokenResult(forceRefresh);
        return result.claims ?? const <String, dynamic>{};
      });

  @override
  Future<void> signOut() => _guard(() => _auth.signOut());

  @override
  Future<void> deleteAccount() => _guard(() async {
        final user = _auth.currentUser;
        if (user == null) {
          throw const AuthGatewayException('no-current-user');
        }
        await user.delete();
      });

  @override
  Future<void> setRole({required String uid, required String role}) =>
      _guard(() async {
        await _functions
            .httpsCallable('setRole')
            .call<dynamic>(<String, String>{'uid': uid, 'role': role});
      });
}

/// Parse server roles out of a custom-claims map (S1.5). A `roles` LIST claim
/// (multi-role user) wins; otherwise a single `role` string claim; otherwise
/// empty. Values are filtered to the known persona ids ([kPersonas]) so an
/// exotic/unknown claim (e.g. `admin`) can never lock or break the role UI —
/// the zero-regression-biased choice. Pure → unit-testable.
List<String> rolesFromClaims(Map<String, dynamic>? claims) {
  if (claims == null || claims.isEmpty) return const [];
  final known = {for (final p in kPersonas) p.id};
  final multi = claims['roles'];
  if (multi is List) {
    final out = <String>[];
    for (final r in multi) {
      if (r is String && known.contains(r) && !out.contains(r)) out.add(r);
    }
    if (out.isNotEmpty) return List.unmodifiable(out);
  }
  final single = claims['role'];
  if (single is String && known.contains(single)) {
    return List.unmodifiable([single]);
  }
  return const [];
}

/// The auth state every surface reads: user + server roles + the
/// `_loaded`-guard flag.
@immutable
class AuthSnapshot {
  const AuthSnapshot({this.user, this.roles = const [], this.loaded = false});

  /// The signed-in user (null = signed out — today's behavior).
  final AuthUser? user;

  /// Server roles from custom claims ([rolesFromClaims]); empty when signed
  /// out, claims-less, or Firebase-free.
  final List<String> roles;

  /// The `_loaded` guard (§S1 DoD): true once the FIRST auth event has fully
  /// resolved (user + claims) — or immediately when there is no gateway
  /// (Firebase-free run: there is nothing to wait for). Until then the UI
  /// must not treat "no user yet" as a decided "signed out".
  final bool loaded;

  bool get signedIn => user != null;

  /// S1.6 — persona = identity: exactly ONE server role. The role picker is
  /// locked; [roleProvider] serves that role unconditionally.
  bool get singleRole => signedIn && roles.length == 1;
}

/// The auth notifier — listens to the gateway's user stream, fetches claims
/// per signed-in event, and exposes the flow methods (login sheet / profile
/// screen / manager role-assign). Constructed WITHOUT a gateway (tests, the
/// Firebase-free sandbox) it is born `loaded` and signed-out, and every flow
/// method throws `unavailable` — the UI shows a Hebrew toast, nothing breaks.
class AuthStateNotifier extends StateNotifier<AuthSnapshot> {
  AuthStateNotifier(AuthGateway? gateway, {void Function()? onIdentityCleared})
      : _gateway = gateway,
        _onIdentityCleared = onIdentityCleared,
        super(
          gateway == null
              ? const AuthSnapshot(loaded: true)
              // Born seeded from the RESTORED session (FirebaseAuth restores
              // `currentUser` synchronously after init) so a cold-path sync
              // read — e.g. the role-picker gate on the very first tap —
              // already sees the user. Claims (and `loaded`) resolve async.
              : AuthSnapshot(user: gateway.currentUser),
        ) {
    final g = _gateway;
    if (g != null) {
      _sub = g.authStateChanges().listen(
        _onAuthEvent,
        onError: (Object e, StackTrace st) {
          // A stream error must never surface in the UI — settle signed-out.
          debugPrint('AuthStateNotifier: auth stream error: $e');
          if (mounted) state = const AuthSnapshot(loaded: true);
        },
      );
      // Kick the claims fetch for a restored session even if the stream's
      // on-subscribe emission is late/lost — idempotent under the gen guard.
      final restored = state.user;
      if (restored != null) unawaited(_onAuthEvent(restored));
    }
  }

  final AuthGateway? _gateway;

  /// Local wipe hook (S1.7/S1.8) — wired by [authStateProvider] to reset the
  /// on-device user profile + active persona. Injected so the notifier stays
  /// directly unit-testable with a recording callback.
  final void Function()? _onIdentityCleared;

  StreamSubscription<AuthUser?>? _sub;

  /// The `_loaded` discipline of orders_engine.dart adapted to a stream+fetch
  /// pipeline: every auth event (and every local sign-out/delete) bumps the
  /// generation; an awaited claims result only lands if its generation is
  /// still current — a SLOW `getIdTokenResult` can never clobber a newer
  /// event or resurrect a signed-out user.
  int _gen = 0;

  Future<void> _onAuthEvent(AuthUser? user) async {
    final gen = ++_gen;
    if (user == null) {
      state = const AuthSnapshot(loaded: true);
      return;
    }
    // The user lands immediately; `loaded` stays false until the claims fetch
    // settles, so the UI never acts on a half-resolved identity.
    state = AuthSnapshot(user: user);
    var roles = const <String>[];
    try {
      roles = rolesFromClaims(await _gateway!.idTokenClaims());
    } on Object catch (e) {
      // Claims failure (offline token refresh, etc.) — roles stay empty
      // (signed-out role behavior), never thrown into the UI.
      debugPrint('AuthStateNotifier: claims fetch failed (roles empty): $e');
    }
    if (!mounted || gen != _gen) return; // stale — a newer event won
    state = AuthSnapshot(user: user, roles: roles, loaded: true);
  }

  AuthGateway _required() {
    final g = _gateway;
    if (g == null) {
      throw const AuthGatewayException(
        'unavailable',
        'auth gateway not available (Firebase not initialised)',
      );
    }
    return g;
  }

  /// S1.1 — send the OTP SMS; resolves to the verificationId for
  /// [signInWithSmsCode]. Throws [AuthGatewayException] (Hebrew-toasted by the
  /// login sheet).
  Future<String> sendOtp(String phone) async => _required().sendOtp(phone);

  /// S1.2 — complete phone sign-in. Success arrives via the auth stream.
  Future<void> signInWithSmsCode(String verificationId, String smsCode) async =>
      _required().signInWithSmsCode(verificationId, smsCode);

  /// S1.3 — email+password fallback. Success arrives via the auth stream.
  Future<void> signInWithEmailPassword(String email, String password) async =>
      _required().signInWithEmailPassword(email, password);

  /// S1.7 — sign out + local cache clear. The LOCAL sign-out is optimistic and
  /// unconditional (clean exit even when the network call fails — same
  /// guarded-write spirit as the S2 cache base); the remote failure is logged,
  /// never thrown.
  Future<void> signOut() async {
    _gen++; // kill any in-flight claims apply
    state = const AuthSnapshot(loaded: true);
    _clearIdentityCache();
    try {
      await _gateway?.signOut();
    } on Object catch (e) {
      debugPrint('AuthStateNotifier: remote sign-out failed (ignored): $e');
    }
  }

  /// S1.8 — in-app account deletion (`user.delete()` — Apple requirement) +
  /// local user-data wipe. Unlike [signOut] the remote delete THROWS on
  /// failure (e.g. `requires-recent-login`) and the local wipe does NOT run —
  /// the account still exists, so the data must too. Server-side document
  /// wipe-out is a Functions/S5 concern (see functions/README.md).
  Future<void> deleteAccount() async {
    await _required().deleteAccount();
    _gen++;
    if (mounted) state = const AuthSnapshot(loaded: true);
    _clearIdentityCache();
  }

  /// S1.9 — the in-app call-site of the `setRole` callable: an ADMIN assigns
  /// [role] to the user [uid] (the Function verifies the caller's admin claim
  /// server-side). A manager surface (מנהל המערכת → ניהול) is where this gets
  /// wired into UI; until then it is reachable programmatically. The TARGET
  /// user sees the new role on their next token refresh / sign-in.
  Future<void> assignRole({required String uid, required String role}) async =>
      _required().setRole(uid: uid, role: role);

  /// The S1.7/S1.8 local wipe: identity-coupled state only (user profile +
  /// active persona, via the injected hook). Device preferences (theme,
  /// catalog settings, welcome-seen) are NOT account data and survive.
  void _clearIdentityCache() => _onIdentityCleared?.call();

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }
}

/// The auth gateway — null when Firebase is not initialised (the entire
/// Firebase-free test suite + this sandbox), so nothing can ever touch
/// `FirebaseAuth.instance` there. The same `Firebase.apps.isNotEmpty` switch
/// the S2/S3 repository providers use (bottom of orders_local.dart). Tests
/// override this with a hand-rolled fake.
final authGatewayProvider = Provider<AuthGateway?>((ref) {
  if (useFirebaseBackend) return FirebaseAuthGateway();
  return null;
});

/// S1.4 — the current user + server roles + `_loaded` guard. Without Firebase
/// (tests / sandbox): born loaded + signed-out → zero regression.
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthSnapshot>((ref) {
  return AuthStateNotifier(
    ref.watch(authGatewayProvider),
    onIdentityCleared: () {
      // S1.7/S1.8 — the identity-coupled local state: on-device profile
      // (name/contact, persisted under bs.profile.v1) + the picked persona.
      ref.read(userProfileProvider.notifier).reset();
      ref.read(activePersonaProvider.notifier).state = null;
    },
  );
});

/// S1.5/S1.6 — the EFFECTIVE role, in the [activePersonaProvider] dialect
/// (null = contractor / main app) so existing consumers can adopt it drop-in:
///   • signed-in with exactly ONE server role → that role, unconditionally
///     (persona = identity; the client pick is ignored);
///   • multi-role / signed-out / Firebase-free → today's client persona pick,
///     byte-for-byte (zero regression).
final roleProvider = Provider<String?>((ref) {
  final auth = ref.watch(authStateProvider);
  if (auth.singleRole) {
    final role = auth.roles.first;
    return role == 'contractor' ? null : role;
  }
  return ref.watch(activePersonaProvider);
});

/// S1.6 — true when the role picker must NOT be offered: the signed-in user's
/// claims carry exactly one role, so the persona IS the identity. Multi-role
/// and signed-out users keep today's picker. A signed-in user whose claims
/// are STILL RESOLVING (`!loaded`, ms-scale) might turn out single-role, so
/// the switcher holds until the snapshot is decided — the `_loaded` guard at
/// work; signed-out states are always decided, so today's behavior is intact.
final roleSwitchLockedProvider = Provider<bool>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.singleRole || (auth.signedIn && !auth.loaded);
});
