import 'dart:convert';

import 'package:buildsmart/data/legal_texts.dart' show kCurrentPolicyVersion;
import 'package:buildsmart/data/repositories/backend.dart' show kIntelLive;
import 'package:buildsmart/screens/consent_modal.dart'
    show consentPolicyExcerpt, recordConsent;
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/intel/consent_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Studio Pillar 3 · step 86 — the consent flow + version-gate + default-DENY.
/// Since [kIntelLive] and `useFirebaseBackend` are BOTH false in tests, the FULL
/// [analyticsForwardEnabled] AND is always false here; so we assert the
/// version+consent CONDITION PIECES (`analyticsConsentCurrent` /
/// `needsConsentPrompt`) plus the atomic settings write — not the whole AND.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Let the notifier's async _load/_persist microtasks settle.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 60));

  const storageKey = 'bs.settings.v1';

  group('byte-identical / default-DENY invariants', () {
    test('kIntelLive defaults OFF (modal never shown in a normal build)', () {
      expect(kIntelLive, isFalse);
    });

    test('privacy defaults are DENY (privAnalytics + privPresence false)', () {
      expect(AppSettings.defaults.privAnalytics, isFalse);
      expect(AppSettings.defaults.privPresence, isFalse);
      expect(AppSettings.defaults.consentedPolicyVersion, 0);
    });

    test('the whole forward gate is inert on the defaults', () {
      // kIntelLive && useFirebaseBackend are both false → inert regardless.
      expect(analyticsForwardEnabled(AppSettings.defaults), isFalse);
    });
  });

  group('fromJson default-DENY (THE privacy bug fix)', () {
    test('absent analytics key ⇒ false (old users default to DENY)', () {
      // The bug: `!= false` read absent-as-TRUE → forward-on for every legacy
      // user who never saw a consent screen. Now absent/null ⇒ false.
      expect(AppSettings.fromJson(const {}).privAnalytics, isFalse);
      expect(AppSettings.fromJson(const {}).privPresence, isFalse);
      expect(AppSettings.fromJson(const {}).consentedPolicyVersion, 0);
    });

    test('explicit analytics:true ⇒ true (opt-in survives a reload)', () {
      final j = {
        'security': {
          'privacy': {'analytics': true, 'consentedPolicyVersion': 1},
        },
      };
      expect(AppSettings.fromJson(j).privAnalytics, isTrue);
      expect(AppSettings.fromJson(j).consentedPolicyVersion, 1);
    });
  });

  group('version-gate (before / after consent / after bump)', () {
    test('BEFORE consent → prompt needed, gate inert', () {
      const s = AppSettings.defaults; // version 0 < kCurrentPolicyVersion
      expect(needsConsentPrompt(s), isTrue);
      expect(analyticsConsentCurrent(s), isFalse);
      expect(analyticsForwardEnabled(s), isFalse);
    });

    test('AFTER "אני מסכים" → version+consent condition satisfied', () {
      final s = AppSettings.defaults.copyWith(
        privAnalytics: true,
        consentedPolicyVersion: kCurrentPolicyVersion,
      );
      // The CONDITION PIECES (not the whole AND, which stays false in tests).
      expect(analyticsConsentCurrent(s), isTrue);
      expect(needsConsentPrompt(s), isFalse);
      // The full AND is STILL inert here (kIntelLive/backend off) — proves the
      // demo/test build never forwards even after consent.
      expect(analyticsForwardEnabled(s), isFalse);
    });

    test('AFTER a version bump → consent goes stale (de-facto DENY)', () {
      final consented = AppSettings.defaults.copyWith(
        privAnalytics: true,
        consentedPolicyVersion: kCurrentPolicyVersion,
      );
      // Simulate a policy bump: the required version moves ahead of the
      // recorded consent → prompt re-opens, condition falls false.
      const bumped = kCurrentPolicyVersion + 1;
      expect(consented.consentedPolicyVersion >= bumped, isFalse);
      expect(consented.consentedPolicyVersion < bumped, isTrue);

      // And the version-gate is load-bearing EVEN with the toggle on: a stale
      // recorded version defeats privAnalytics=true (analyticsConsentCurrent
      // uses `>= kCurrentPolicyVersion`).
      final stale = AppSettings.defaults
          .copyWith(privAnalytics: true, consentedPolicyVersion: 0);
      expect(stale.privAnalytics, isTrue);
      expect(analyticsConsentCurrent(stale), isFalse);
      expect(needsConsentPrompt(stale), isTrue);
    });
  });

  group('recordConsent writes the pair ATOMICALLY', () {
    test('one update flips privAnalytics AND stamps the version together',
        () async {
      SharedPreferences.setMockInitialValues(const {});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(appSettingsProvider.notifier);
      await settle();

      // Before: private default-DENY.
      expect(c.read(appSettingsProvider).privAnalytics, isFalse);
      expect(c.read(appSettingsProvider).consentedPolicyVersion, 0);

      recordConsent(n); // the "אני מסכים" action

      final after = c.read(appSettingsProvider);
      expect(after.privAnalytics, isTrue);
      expect(after.consentedPolicyVersion, kCurrentPolicyVersion);
      // The toggle is NEVER written without the version (no half-consent).
      expect(analyticsConsentCurrent(after), isTrue);

      // …and the pair persists together (survives a restart).
      await settle();
      final prefs = await SharedPreferences.getInstance();
      final priv = ((jsonDecode(prefs.getString(storageKey)!)
          as Map<String, dynamic>)['security']
          as Map<String, dynamic>)['privacy'] as Map<String, dynamic>;
      expect(priv['analytics'], true);
      expect(priv['consentedPolicyVersion'], kCurrentPolicyVersion);
    });
  });

  group('consent copy is sourced from the policy (no drift)', () {
    test('the excerpt is the honest §5 analytics paragraph', () {
      final excerpt = consentPolicyExcerpt();
      // §5 was rewritten (launch-v2, policy version 2) to the ACCURATE
      // disclosure: GA4/Crashlytics ARE active when connected, while the
      // detailed usage/presence/intel analytics stay OFF. The excerpt is pulled
      // verbatim from that §5, so the no-drift assertions track the CURRENT
      // honest wording (policy = source of truth): the collector that IS named…
      expect(excerpt, contains('Google Analytics (GA4)'));
      // …and the honest "the expanded analytics are off at this stage" claim.
      expect(excerpt, contains('כבויות בשלב זה'));
    });
  });
}
