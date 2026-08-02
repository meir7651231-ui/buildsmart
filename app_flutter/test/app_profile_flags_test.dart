// STAGE-3.4 — the APP_PROFILE contract (DoD: no profile ≡ today, byte-for-byte).
//
// Four locks:
//   a. the define-less build (this whole suite) IS profile 'demo', and every
//      profile-derived default equals today's literal;
//   b. the per-profile matrix (demo · buildsmart · clean) is pinned via the
//      pure [profileDefaultsFor] mirror — the buildsmart column restates the
//      live-web workflow define-set, the clean column the stage-4 spec;
//   c. mirror ↔ const self-consistency (the mirror can't drift from the real
//      compile-time consts);
//   d. a CLOSED-SET sweep: every `fromEnvironment` define in lib/ must be
//      classified in exactly one documented layer (profile-owned / arming /
//      passthrough / meta) — a future flag added unclassified fails here and
//      forces a conscious decision (the boundedness-sweep idiom).

import 'dart:io';

import 'package:buildsmart/state/app_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// The 13 PROFILE-OWNED defines (profile supplies their defaults).
const Set<String> kProfileOwned = {
  'ENABLE_WORD_FINDER',
  'ENABLE_RING_DIVE',
  'SMART_INPUT',
  'APP_KB_ONLY',
  'KB_GLOBAL',
  'KB_LIVE_MIRROR',
  'GLOBAL_SEARCH',
  'PLAIN_DIVE',
  'AXIS_DIVE',
  'STORE_COMPARISON_UI',
  'STUDIO_SHARED_SYNC',
  'CATALOG_BASE_URL',
  'IMAGE_BASE_URL',
};

/// The ARMING layer — staged one-by-one by the owner's runbook with per-flag
/// rollback; deliberately NEVER expanded by a profile (governance:
/// STUDIO_GA §3 + studio_gating_test forbids baking them into workflows).
const Set<String> kArmingLayer = {
  'USE_FIREBASE_BACKEND',
  'UID_SCOPED_QUERIES',
  'ORG_SCOPED_QUERIES',
  'SERVER_CALLABLES',
  'CLOUD_PHOTOS',
  'SEED_FRESH_BACKEND',
  'CLAUDE_AI',
  'APP_CHECK_PROD',
  'FS_DIAG',
  'STUDIO',
  'STUDIO_LIVE',
  'CATALOG_SERVER_SEARCH',
  'STUDIO_CO_EDITOR',
  'INTEL_LIVE',
  'USER_SYSTEM',
  // giant-system Phase 1: arms the runtime OrgConfig layer (owner-staged,
  // per-flag rollback = drop the define — the STUDIO/USER_SYSTEM shape).
  'ORG_CONFIG',
  // order-confirmation email (DIRECTIVE-order-confirmation-email): owner-staged
  // in lock-step with its SERVER twin — the client define is inert until the
  // owner also sets the ORDER_EMAIL functions param + the RESEND_API_KEY secret,
  // so BOTH must be armed and per-flag rollback = drop the define (the
  // CLOUD_PHOTOS / APP_CHECK_PROD backend-coordinated shape, never a profile).
  'ORDER_EMAIL',
};

/// Passthrough — experiments, launch dials, and secret values a profile must
/// not own.
const Set<String> kPassthrough = {
  'ENABLE_CARD_KEYBOARD',
  'KB_BUTTONS_V2',
  'FINDER_FRONT',
  'EMAIL_PASSWORD_AUTH',
  'CATALOG_SOURCE',
  'SERVER_CATALOG_ROLLOUT',
  'APP_CHECK_RECAPTCHA_SITE_KEY',
  // giant-system V6: the deploy-baked company config slice — a per-channel
  // VALUE (inert without ORG_CONFIG, which stays arming-classified above).
  'ORG_CONFIG_JSON',
};

/// The profile define itself.
const Set<String> kMeta = {'APP_PROFILE'};

void main() {
  group('a · define-less build IS demo, derived defaults = today', () {
    test('profile resolves to demo and is a known profile', () {
      expect(kAppProfile, 'demo');
      expect(kAppProfileKnown, isTrue);
    });

    test('every demo default equals today\'s literal', () {
      expect(kProfileWordFinder, isFalse);
      expect(kProfileKbLiveMirror, isFalse);
      expect(kProfileKbGlobal, isFalse);
      expect(kProfileRingDive, isFalse);
      expect(kProfilePlainDive, isFalse);
      expect(kProfileAxisDive, isFalse);
      expect(kProfileGlobalSearch, isFalse);
      expect(kProfileStoreComparisonUi, isFalse);
      expect(kProfileSmartInput, isFalse);
      expect(kProfileAppKbOnly, isFalse);
      expect(kProfileStudioSharedSync, isFalse);
      expect(kProfileCatalogBaseUrl, '',
          reason: 'empty is load-bearing (gate_123): server catalog OFF');
      expect(kProfileImageBaseUrl,
          'https://pub-51f8c6ddf2de47e6b63e0f9588211cba.r2.dev',
          reason: 'demo keeps today\'s CDN — byte-identical');
    });
  });

  group('b · the per-profile matrix is pinned', () {
    test('demo column: everything off, today\'s CDN', () {
      final d = profileDefaultsFor('demo');
      expect(d.values.whereType<bool>().any((v) => v), isFalse);
      expect(d['CATALOG_BASE_URL'], '');
      expect(d['IMAGE_BASE_URL'],
          'https://pub-51f8c6ddf2de47e6b63e0f9588211cba.r2.dev');
    });

    test('buildsmart column: the live-web define-set (workflow parity)', () {
      final b = profileDefaultsFor('buildsmart');
      for (final f in [
        'ENABLE_WORD_FINDER',
        'KB_LIVE_MIRROR',
        'KB_GLOBAL',
        'ENABLE_RING_DIVE',
        'PLAIN_DIVE',
        'AXIS_DIVE',
        'GLOBAL_SEARCH',
        'STORE_COMPARISON_UI',
        'SMART_INPUT',
        'APP_KB_ONLY',
        'STUDIO_SHARED_SYNC',
      ]) {
        expect(b[f], isTrue, reason: '$f is ON in the buildsmart profile');
      }
      expect(b['CATALOG_BASE_URL'], 'https://buildsmart-b0b78.firebaseapp.com');
      expect(b['IMAGE_BASE_URL'],
          'https://pub-51f8c6ddf2de47e6b63e0f9588211cba.r2.dev');
    });

    test('clean column: capabilities ON, company values EMPTY', () {
      final c = profileDefaultsFor('clean');
      expect(c['ENABLE_WORD_FINDER'], isTrue);
      expect(c['GLOBAL_SEARCH'], isTrue);
      expect(c['SMART_INPUT'], isTrue);
      expect(c['STUDIO_SHARED_SYNC'], isFalse,
          reason: 'the owner-config mirror is buildsmart-specific');
      expect(c['CATALOG_BASE_URL'], '', reason: 'no company server baked in');
      expect(c['IMAGE_BASE_URL'], '', reason: 'no company CDN baked in');
    });

    test('company2 column (stage-5): capabilities ON, no company values', () {
      final c2 = profileDefaultsFor('company2');
      expect(c2['ENABLE_WORD_FINDER'], isTrue);
      expect(c2['GLOBAL_SEARCH'], isTrue);
      expect(c2['STUDIO_SHARED_SYNC'], isFalse);
      expect(c2['CATALOG_BASE_URL'], '');
      expect(c2['IMAGE_BASE_URL'], '',
          reason: 'company #2 brings its own CDN (bundled until then)');
    });
  });

  group('c · mirror ↔ const self-consistency', () {
    test('profileDefaultsFor(kAppProfile) equals the compile-time consts', () {
      final m = profileDefaultsFor(kAppProfile);
      expect(m['ENABLE_WORD_FINDER'], kProfileWordFinder);
      expect(m['KB_LIVE_MIRROR'], kProfileKbLiveMirror);
      expect(m['KB_GLOBAL'], kProfileKbGlobal);
      expect(m['ENABLE_RING_DIVE'], kProfileRingDive);
      expect(m['PLAIN_DIVE'], kProfilePlainDive);
      expect(m['AXIS_DIVE'], kProfileAxisDive);
      expect(m['GLOBAL_SEARCH'], kProfileGlobalSearch);
      expect(m['STORE_COMPARISON_UI'], kProfileStoreComparisonUi);
      expect(m['SMART_INPUT'], kProfileSmartInput);
      expect(m['APP_KB_ONLY'], kProfileAppKbOnly);
      expect(m['STUDIO_SHARED_SYNC'], kProfileStudioSharedSync);
      expect(m['CATALOG_BASE_URL'], kProfileCatalogBaseUrl);
      expect(m['IMAGE_BASE_URL'], kProfileImageBaseUrl);
      expect(m.keys.toSet(), kProfileOwned,
          reason: 'the mirror covers exactly the profile-owned set');
    });
  });

  group('d · closed-set sweep — every define is classified', () {
    test('every fromEnvironment define in lib/ belongs to exactly one layer',
        () {
      final re = RegExp("fromEnvironment\\(\\s*'([A-Z0-9_]+)'");
      final found = <String>{};
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        for (final m in re.allMatches(f.readAsStringSync())) {
          found.add(m.group(1)!);
        }
      }
      final classified = {
        ...kProfileOwned,
        ...kArmingLayer,
        ...kPassthrough,
        ...kMeta,
      };
      expect(
        kProfileOwned.intersection(kArmingLayer), isEmpty,
        reason: 'layers are disjoint',
      );
      final unclassified = found.difference(classified);
      expect(unclassified, isEmpty,
          reason: 'a NEW define must be consciously classified '
              '(profile-owned / arming / passthrough) in this test');
      final stale = classified.difference(found);
      expect(stale, isEmpty,
          reason: 'a classified define no longer exists in lib/ — '
              'remove it from the sets above');
    });
  });
}
