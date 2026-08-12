import 'package:buildsmart/state/app_profile.dart'
    show kProfileAppKbOnly, kProfileRingDive, kProfileSmartInput,
        kProfileWordFinder;
import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// True iff the build passed `--dart-define=ENABLE_WORD_FINDER=true` (the
/// buildsmart-il.com demo build). A top-level build-time const — the SAME idiom
/// as `kUseFirebaseBackendFlag` in `data/repositories/backend.dart`, which ships
/// via this mechanism in production. NOTE: `flutter test` does NOT forward
/// --dart-define to library consts (the repo drives such ON branches
/// explicitly), so the ON path is not unit-testable here; `flutter build web`
/// DOES forward it — that is what the deploy uses.
// stage-3.4: profile-aware default (explicit define still wins).
const bool kEnableWordFinderDemo = bool.fromEnvironment('ENABLE_WORD_FINDER',
    defaultValue: kProfileWordFinder);

/// True iff the build passed `--dart-define=ORDER_EMAIL=true` — the owner's
/// order-confirmation-email switch (SSOT: DIRECTIVE-order-confirmation-email).
/// Default false ⇒ the checkout does NOT stamp `customerEmail` on the order ⇒
/// byte-identical order docs. The server-side send is separately gated by the
/// `ORDER_EMAIL` functions param + `RESEND_API_KEY` secret, so both must be on.
const bool kOrderEmail = bool.fromEnvironment('ORDER_EMAIL');

/// True iff the build passed `--dart-define=ENABLE_CARD_KEYBOARD=true` — the
/// A/B demo build for the unified card-keyboard (#38). SAME idiom as
/// [kEnableWordFinderDemo]: default false → 'kCardKeyboard' stays off → the new
/// 'מקלדת חכמה' catalog pill never renders → byte-identical. The live deploy
/// workflows do NOT pass it (the cut-over stays owner-gated); a demo build (or
/// _app_cardkeyboard_demo.dart) flips it to A/B the new finder beside the old.
const bool kEnableCardKeyboardDemo =
    bool.fromEnvironment('ENABLE_CARD_KEYBOARD');

/// True iff the build passed `--dart-define=ENABLE_RING_DIVE=true` — the demo
/// build for the RingDive rotary product-finder (צלילת-טבעות, owner handoff).
/// SAME idiom as [kEnableWordFinderDemo] / [kEnableCardKeyboardDemo]: default
/// false → 'kRingDive' stays off → the dial never renders (a zero-height
/// `SizedBox.shrink`) → byte-identical. The live deploy workflows do NOT pass it
/// (the cut-over stays owner-gated); a demo build flips it on to A/B the dial
/// beside the smart keyboard.
// stage-3.4: profile-aware default (explicit define still wins).
const bool kEnableRingDiveDemo =
    bool.fromEnvironment('ENABLE_RING_DIVE', defaultValue: kProfileRingDive);

/// True iff the build passed `--dart-define=SMART_INPUT=true` — the owner's
/// "APP KEYBOARD ONLY" switch: our in-app `BsKeyboard` REPLACES the device's
/// native keyboard on every wired field.
///
/// SAME idiom as [kEnableWordFinderDemo] / [kEnableCardKeyboardDemo] /
/// [kEnableRingDiveDemo]: default false → 'kSmartInput' stays absent from
/// [FeatureFlagsNotifier._forcedOnFlags] → every consumer keeps today's
/// behaviour → BYTE-IDENTICAL. The live deploy workflows do NOT pass it (the
/// cut-over stays owner-gated, flipped via the STUDIO_DART_DEFINES repo
/// variable like USER_SYSTEM).
///
/// ⚠️ WHAT IT TURNS ON (one flag, four consumers — all already built + wired):
///   • `useCustomKeyboard` (keyboard/kb_field_mode.dart) — the SHARED gate that
///     BOTH sets a wired field's `readOnly:true` (so the OS keyboard never
///     appears) AND shows `BsKeyboardHost`. The two must flip together or the
///     field becomes untypable — that split-brain is exactly why the predicate
///     is one shared function, and why this flag must never be read directly.
///   • the suggestion strips (smart_suggestion_strip / category_suggestion_strip
///     / smart_input_scaffold) — they self-gate on the same flag.
///
/// A11Y: `useCustomKeyboard` ALSO requires `!accessibleNavigation`, so a screen
/// reader keeps the OS keyboard even with this ON — the fallback is preserved.
// stage-3.4: profile-aware default (explicit define still wins).
const bool kSmartInputDemo =
    bool.fromEnvironment('SMART_INPUT', defaultValue: kProfileSmartInput);

/// True iff the build passed `--dart-define=APP_KB_ONLY=true` — the SECOND half
/// of the owner's "app keyboard only" demand, and the one that actually makes it
/// true everywhere.
///
/// [kSmartInputDemo] converts fields ONE BY ONE (`readOnly:true` + a docked host
/// per field); 10 of ~109 are done, so on the other 99 the device keyboard still
/// appears. THIS flag mounts `AppKeyboardOnlyLayer` instead — a
/// `TextInputControl` the framework routes EVERY field through — so coverage is
/// complete by construction and cannot drift as screens are added.
///
/// Kept SEPARATE from [kSmartInputDemo] on purpose. That one is already ON in the
/// live build, and a global input-control swap is not something to turn on by
/// side effect: it changes how text input works on every screen at once. Default
/// false ⇒ the layer is never added to the tree ⇒ BYTE-IDENTICAL. Flipping it on
/// is the same one-line edit to the STUDIO_DART_DEFINES repo variable as
/// SMART_INPUT and USER_SYSTEM were, and removing it is the whole rollback.
///
/// A11Y: the layer ALSO gates on `useCustomKeyboard`, so a screen reader keeps
/// the platform keyboard even with this on — the control is never installed.
// stage-3.4: profile-aware default (explicit define still wins).
const bool kAppKbOnly =
    bool.fromEnvironment('APP_KB_ONLY', defaultValue: kProfileAppKbOnly);

/// 🌉 EDGE_PROXY (12.8) — route Firestore (and later Auth/Functions) through the
/// approved custom domain so a filtered network (Netfree etc.) only ever sees
/// `*.buildsmart-il.com`, never `*.googleapis.com`. A Cloudflare Worker on
/// [kEdgeFsHost] forwards to firestore.googleapis.com behind the scenes.
///
/// Default OFF ⇒ the SDK's official host ⇒ shipped build BYTE-IDENTICAL to today
/// (zero regression, same invariant as every flag above). Flip ON at build time
/// AFTER the Worker + the `fs.` custom domain are deployed:
///   flutter build web --release --dart-define=EDGE_PROXY=true
const bool kEdgeProxy = bool.fromEnvironment('EDGE_PROXY');

/// The approved-domain host the Firestore SDK points at when [kEdgeProxy] is ON.
/// A hostname (no path) — the Firestore `Settings.host` contract; the Worker
/// routes this subdomain to firestore.googleapis.com.
const String kEdgeFsHost = 'fs.buildsmart-il.com';

/// Whether the app offers EMAIL + PASSWORD sign-in at all.
///
/// ⚠️ THIS FLAG IS INVERTED relative to every other flag in this file. The
/// others default false = "nothing changes"; this one defaults false =
/// "the email+password door is CLOSED", which is a deliberate behaviour change.
/// The owner chose Google + SMS only, and a flag that defaulted to the old
/// behaviour would leave the decision unimplemented on every build that forgot
/// to pass it. Restoring the door is `--dart-define=EMAIL_PASSWORD_AUTH=true`.
///
/// WHY NO PASSWORDS: a password is a secret this project would then have to
/// hold — resets, weak choices, breach exposure. Google and phone-OTP push that
/// onto Google and the carrier, which is the whole reason they were chosen.
///
/// 🛑 THE CLIENT IS NOT THE LOCK. Firebase Auth is a public HTTPS API and the
/// web API key ships inside main.dart.js, so `accounts:signUp` accepts
/// email+password from anyone who reads it — verified against the live project,
/// which answered WEAK_PASSWORD (i.e. it processed the request and only
/// objected to the value). Hiding the UI removes the door people can SEE.
/// The actual lock is the Email/Password provider being DISABLED in the
/// Firebase console; this flag exists so the app stops offering a door the
/// server is about to refuse.
const bool kEmailPasswordAuth = bool.fromEnvironment('EMAIL_PASSWORD_AUTH');

/// Runtime tier name for the עדכונים LIVE-MIRROR keyboard (plan Q4). The floating
/// keyboard's mirror branch is guarded by `kKbLiveMirror ||
/// featureFlagsProvider.isOn(kKbLiveMirrorFlag)`, so the orchestrator can stage
/// the feature ON for a demo WITHOUT a rebuild — `ref.read(
/// featureFlagsProvider.notifier).enable(kKbLiveMirrorFlag)` — exactly like the
/// 'kWordFinder' demo tier. Default OFF (the flag is absent from the persisted
/// set and is not in [FeatureFlagsNotifier._forcedOnFlags]), so a normal build is
/// byte-identical; the compile-time `kKbLiveMirror` const is the other, also-OFF,
/// path. Naming it here keeps callers from stringly-typing the flag.
const String kKbLiveMirrorFlag = 'kKbLiveMirror';

/// PHASE 0 — HR relocation (owner governance ruling #84, 2026-06-14). When this
/// runtime flag is enabled the manager board goes OVERSIGHT-ONLY on worker HR:
/// the contractor/store boards own the actual approvals, the manager sees a
/// read-only count. Default OFF — INTENTIONALLY absent from
/// [FeatureFlagsNotifier._forcedOnFlags], so a normal build/test is
/// byte-identical (the manager keeps its live action sections). Staged ON at
/// runtime via `ref.read(featureFlagsProvider.notifier).enable(kHrRelocationFlag)`,
/// exactly like [kKbLiveMirrorFlag].
const String kHrRelocationFlag = 'kHrRelocation';

// ── No-Code Studio master gate (studio plan, steps 4–5) ──────────────────────
// The Studio's runtime flag-name is `kStudioFlagName` ('kStudio', in
// `state/studio/studio_flags.dart`), with the compile-time twin `kStudioFlag`
// (`bool.fromEnvironment('STUDIO')`). Like [kKbLiveMirrorFlag], 'kStudio' is
// INTENTIONALLY absent from [FeatureFlagsNotifier._forcedOnFlags] below — the only
// runtime path is the owner-staged `enable('kStudio')`, so a normal build stays
// default-OFF / answer-equivalent. (studio_flags_test pins it absent from a fresh
// notifier.) OWNER-REVIEW: the Studio is owner-gated — never force-enable 'kStudio'.

/// Feature-flag infrastructure (ROADMAP step 10).
///
/// A persisted `Set<String>` of *enabled* flag names. The set survives a refresh
/// / app restart via SharedPreferences (`bs.feature-flags.v1`). Mirrors the
/// `HiddenCatalogSectionsNotifier` pattern: async `_load()` in the ctor and
/// `_persist()` after each mutation. Mutations are idempotent — no state churn
/// (and no extra `_persist`) when the flag is already in the desired state.
///
/// Intent: lets us toggle a new-vs-old card path (and any future A/B surface)
/// safely without touching consumer code — call `isOn('<flag>')` at the branch
/// point.
class FeatureFlagsNotifier extends StateNotifier<Set<String>> {
  FeatureFlagsNotifier() : super(_forcedOnFlags) {
    _load();
  }

  static const _key = 'bs.feature-flags.v1';

  /// Flags FORCE-ENABLED at build time, for scoped demo deploys. Empty by
  /// default, so a normal build (the app, Android, the real site) is
  /// byte-identical — flags stay prefs-driven and default-off. The
  /// buildsmart-il.com web build (firebase-hosting.yml) passes
  /// `--dart-define=ENABLE_WORD_FINDER=true` → [kEnableWordFinderDemo] is true →
  /// 'kWordFinder' (== kWordFinderFlag) turns ON, so the 'מאתר חכם' demo is
  /// visible THERE ONLY. Reversible: drop the dart-define → back to default-off.
  // OWNER-REVIEW: build-time demo enablement of the word-finder.
  //
  // The two A/B DEMO surfaces (word-finder + card-keyboard #38), each behind its
  // own dart-define. [kKbLiveMirrorFlag] ('kKbLiveMirror') is intentionally NOT
  // force-enabled here even under a demo define (plan Q4):
  // its compile-time twin is the separate `kKbLiveMirror` const
  // (== bool.fromEnvironment('KB_LIVE_MIRROR'), in
  // widgets/smart_input/keyboard/bs_keyboard_host.dart), and the live-mirror
  // guard is `kKbLiveMirror || featureFlags.isOn(kKbLiveMirrorFlag)`. So the
  // two OFF-by-default paths stay distinct: the compile-only const (its own
  // dart-define) and the runtime tier reached SOLELY via a no-rebuild
  // `enable(kKbLiveMirrorFlag)`. Adding it to this set would conflate the two
  // and break the default-OFF assumption that
  // test/screens/keyboard_updates_deriver_test.dart relies on.
  static const Set<String> _forcedOnFlags = <String>{
    if (kEnableWordFinderDemo) 'kWordFinder',
    if (kEnableCardKeyboardDemo) 'kCardKeyboard',
    if (kEnableRingDiveDemo) 'kRingDive',
    // APP-KEYBOARD-ONLY (owner): our keyboard replaces the device keyboard on
    // every wired field. Literal 'kSmartInput' == `kSmartInputFlag`
    // (widgets/smart_input/models.dart) — kept literal like its three siblings
    // so this const set stays import-free. Default OFF ⇒ byte-identical.
    if (kSmartInputDemo) 'kSmartInput',
  };

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final list = prefs.getStringList(_key);
    final loaded = list?.toSet() ?? <String>{};
    // Build-time forced flags always win — even over a returning visitor's
    // saved prefs — so the demo deploy reliably shows the feature.
    final next = {...loaded, ..._forcedOnFlags};
    // Emit ONLY on a real content change. `state = {...}` always makes a fresh
    // Set identity; when the content is unchanged (e.g. empty→empty) Riverpod
    // still sees a "change" and rebuilds every dependent provider. That
    // spuriously recreated productFavoritesProvider mid-flight and clobbered a
    // just-toggled SKU (the load-race the guard tests assert against). No-op
    // when equal → no needless rebuild.
    if (setEquals(next, state)) return;
    state = next;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    await prefs.setStringList(_key, state.toList());
  }

  bool isOn(String flag) => state.contains(flag);

  void enable(String flag) {
    if (state.contains(flag)) return; // idempotent
    state = {...state, flag};
    _persist();
  }

  void disable(String flag) {
    if (!state.contains(flag)) return; // idempotent
    state = {...state}..remove(flag);
    _persist();
  }

  void toggle(String flag) =>
      state.contains(flag) ? disable(flag) : enable(flag);
}

final featureFlagsProvider =
    StateNotifierProvider<FeatureFlagsNotifier, Set<String>>(
  (_) => FeatureFlagsNotifier(),
);
