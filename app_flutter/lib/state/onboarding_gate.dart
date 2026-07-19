import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// First-run welcome gate — distinct from `onboarding_progress.dart` (which
/// tracks per-feature *hint ids*). This gates the **first launch**: a new user
/// (e.g. arriving from Google Play) sees the welcome flow once, then never
/// again.
const String kWelcomeSeenKey = 'bs.welcome-seen.v1';

/// Whether the first-run welcome has been completed.
///
/// **Defaults to `true`** (skip the welcome) so any context that does NOT
/// override it — notably widget tests that pump the whole app — lands straight
/// on the home shell, exactly as before this feature existed. The real app
/// overrides it in `main()` with the persisted value (see [loadWelcomeSeen]),
/// so a genuine first-run user (`false`) sees the welcome. Synchronous, so the
/// gate decides on the first frame with no splash flash or async race.
final welcomeSeenProvider = StateProvider<bool>((ref) => true);

/// Current step of the first-run opening flow (ported from the prototype's
/// `showScreen` sequence): 0 = welcome / register · 1 = profession picker ·
/// 2 = onboarding slides. Advanced as the user proceeds; the flow ends by
/// flipping [welcomeSeenProvider] → home.
final startupStepProvider = StateProvider<int>((ref) => 0);

/// Read the persisted first-run flag — called once in `main()` to seed the
/// [welcomeSeenProvider] override. Absent key → `false` (a fresh install has
/// not yet seen the welcome).
Future<bool> loadWelcomeSeen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(kWelcomeSeenKey) ?? false;
}

/// Persist that the first-run welcome was completed. Survives restarts.
Future<void> persistWelcomeSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(kWelcomeSeenKey, true);
}

/// Re-arm the welcome gate, so the NEXT launch lands on the welcome/login
/// screen instead of the home shell.
///
/// The one caller is the inactivity auto-logout (`main.dart` `_AutoLogout`).
/// Signing out alone is not enough to keep an idle user out: the server-catalog
/// bootstrap signs every visitor back in ANONYMOUSLY before the first frame, so
/// with `welcomeSeen` still persisted `true` the `OnboardingGate` would route a
/// returning guest straight back to the home shell — the sign-out would be
/// invisible across a reload. Clearing the flag is what makes "log the idle user
/// out" survive a refresh.
Future<void> clearWelcomeSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(kWelcomeSeenKey, false);
}

/// The visitor EXPLICITLY chose "browse the catalog without an account".
const String kGuestBrowsingKey = 'bs.guest-browsing.v1';

/// Whether this visitor opted into guest browsing.
///
/// Deliberately SEPARATE from [welcomeSeenProvider], which only records that
/// the onboarding was shown. Conflating the two is what let a returning visitor
/// into the app with no sign-in at all: the anonymous catalog bootstrap makes
/// `auth.user` non-null for everyone, so `welcomeSeen` was the only thing left
/// gating entry — and it says nothing about identity. Anything such a visitor
/// created was bound to a throwaway anonymous uid that disappears when browser
/// storage is cleared.
///
/// So entry now needs one of two POSITIVE answers: a real signed-in person, or
/// this explicit choice. Defaults to `false` — a visitor is asked, never assumed.
final guestBrowsingProvider = StateProvider<bool>((ref) => false);

/// Read the persisted guest choice (absent → `false`, i.e. ask).
Future<bool> loadGuestBrowsing() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(kGuestBrowsingKey) ?? false;
}

/// Remember that the visitor chose to browse as a guest.
Future<void> persistGuestBrowsing() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(kGuestBrowsingKey, true);
}

/// Forget the guest choice — the next launch asks again.
///
/// Called on the inactivity auto-logout together with [clearWelcomeSeen]: an
/// expired session must not silently degrade into an anonymous guest session
/// that still browses the app.
Future<void> clearGuestBrowsing() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(kGuestBrowsingKey, false);
}
