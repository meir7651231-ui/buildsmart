import 'package:buildsmart/data/legal_texts.dart';
import 'package:flutter_test/flutter_test.dart';

/// Studio Pillar 3 · step 86 — HONESTY guard for the privacy-policy analytics
/// wording. The policy must describe analytics as GATED / default-OFF /
/// consent-first (an honest precise-superset of the dormant behaviour) and must
/// NOT over-claim "no analytics at all" now that a consent-gated forward exists
/// in the codebase. Also pins the new policy-version constant + revision date.
void main() {
  group('step 86 · legal-text honesty', () {
    test('privacy policy states analytics is gated + default-OFF', () {
      expect(kPrivacyPolicy.contains('אנליטיקת השימוש מגודרת'), isTrue,
          reason: 'the honest "gated analytics" wording is missing');
      expect(kPrivacyPolicy.contains('ברירת-המחדל כבויה'), isTrue,
          reason: 'the default-OFF promise is missing');
    });

    test('remote forward is described as consent-first (informed opt-in)', () {
      expect(kPrivacyPolicy.contains('לאחר קבלת הסכמתך המדעת'), isTrue,
          reason: 'the consent-first forward wording is missing');
      // The user must be told they can withdraw and return to the OFF state.
      expect(kPrivacyPolicy.contains('ניתן למשוך את ההסכמה'), isTrue);
    });

    test('does NOT over-claim "no analytics tool" any more', () {
      // The old blanket claim (אין כלי אנליטיקה) would be dishonest now that a
      // consent-gated forward is built, so it must be gone.
      expect(kPrivacyPolicy.contains('אין כלי אנליטיקה'), isFalse,
          reason: 'stale over-claim "no analytics tool" still present');
      // The truthful claims stay: no ads, no third-party tracking, no sale.
      expect(kPrivacyPolicy.contains('אין באפליקציה פרסומות'), isTrue);
      expect(kPrivacyPolicy.contains('אין מעקב של צד שלישי'), isTrue);
    });

    test('Amendment-13 duties (§11/§13/§14) still cited', () {
      expect(kPrivacyPolicy.contains('סעיף 11'), isTrue);
      expect(kPrivacyPolicy.contains('סעיף 13'), isTrue);
      expect(kPrivacyPolicy.contains('סעיף 14'), isTrue);
    });

    test('policy version + revision date pinned', () {
      expect(kCurrentPolicyVersion, 1);
      expect(kLegalLastUpdated, '7 ביולי 2026');
    });
  });
}
