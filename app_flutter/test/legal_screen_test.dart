import 'package:buildsmart/data/legal_texts.dart';
import 'package:flutter_test/flutter_test.dart';

/// Studio Pillar 3 · step 86 — HONESTY guard for the privacy-policy analytics
/// wording. The policy must describe analytics as GATED / default-OFF /
/// consent-first (an honest precise-superset of the dormant behaviour) and must
/// NOT over-claim "no analytics at all" now that a consent-gated forward exists
/// in the codebase.
///
/// Pinned to the CURRENT policy (`73e14ed5` — "match the live backend"), which
/// is the more honest revision: it explicitly discloses the GA4/Firebase usage
/// that a server-connected build performs, states those detailed transfers are
/// off at this stage, and promises consent-first activation with withdrawal.
/// (The earlier `541184e9` wording this test used no longer matches — and MUST
/// NOT be restored, as it hid the GA4/Firebase disclosure.)
void main() {
  group('step 86 · legal-text honesty', () {
    test('privacy policy states analytics is gated + default-OFF', () {
      // Honest disclosure: GA4 is named as what a server-connected build uses…
      expect(kPrivacyPolicy.contains('Google Analytics (GA4)'), isTrue,
          reason: 'the honest GA4 disclosure is missing');
      // …and the detailed usage transfer is off (gated) at this stage.
      expect(kPrivacyPolicy.contains('כבויות בשלב זה'), isTrue,
          reason: 'the default-OFF / gated promise is missing');
    });

    test('remote forward is described as consent-first (informed opt-in)', () {
      expect(kPrivacyPolicy.contains('בכפוף להסכמתך המדעת'), isTrue,
          reason: 'the consent-first forward wording is missing');
      // The user must be told they can withdraw and return to the OFF state.
      expect(kPrivacyPolicy.contains('ניתן למשוך את ההסכמה'), isTrue);
    });

    test('does NOT over-claim "no analytics tool" any more', () {
      // The old blanket claim (אין כלי אנליטיקה) would be dishonest now that a
      // consent-gated forward is built, so it must be gone.
      expect(kPrivacyPolicy.contains('אין כלי אנליטיקה'), isFalse,
          reason: 'stale over-claim "no analytics tool" still present');
      // The truthful claims stay: no ads, no third-party ad tracking, no sale.
      expect(kPrivacyPolicy.contains('אין באפליקציה פרסומות'), isTrue);
      expect(kPrivacyPolicy.contains('אין מעקב צד-שלישי'), isTrue);
    });

    test('Amendment-13 duties (§11/§13/§14) still cited', () {
      expect(kPrivacyPolicy.contains('סעיף 11'), isTrue);
      expect(kPrivacyPolicy.contains('סעיף 13'), isTrue);
      expect(kPrivacyPolicy.contains('סעיף 14'), isTrue);
    });

    test('policy version + revision date pinned', () {
      expect(kCurrentPolicyVersion, 2);
      expect(kLegalLastUpdated, '1 באוגוסט 2026');
    });
  });
}
