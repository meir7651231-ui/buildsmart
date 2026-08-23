import 'package:buildsmart/data/legal_texts.dart';
import 'package:flutter_test/flutter_test.dart';

// Launch-v2 accuracy guards for the binding legal documents. These assertions
// FAIL if the pre-launch inaccuracy ("no server / on-device only / Firebase is
// future") is ever reintroduced, or if the material-change re-notice is dropped.
void main() {
  group('legal texts — launch-v2 accuracy guards', () {
    test('both documents are non-empty', () {
      expect(kTermsOfUse.trim(), isNotEmpty);
      expect(kPrivacyPolicy.trim(), isNotEmpty);
    });

    test('policy version bumped to 2 (Amendment-13 re-notice for the change)', () {
      expect(kCurrentPolicyVersion, 2);
    });

    test('privacy policy discloses the live Firebase backend (not "no server")', () {
      expect(kPrivacyPolicy, contains('Firestore'));
      expect(kPrivacyPolicy, contains('me-west1'));
      expect(kPrivacyPolicy, contains('חשבון רשום')); // registered-account sync
      expect(kPrivacyPolicy, contains('Google Analytics')); // GA4 disclosed
      expect(kPrivacyPolicy, contains('Crashlytics'));
    });

    test('terms dropped the stale "development & demo mode" self-description', () {
      expect(kTermsOfUse, isNot(contains('פועלת במתכונת פיתוח והדגמה')));
    });

    test('company-identity placeholders remain (owner-only, never invented)', () {
      for (final ph in const [
        '[שם החברה]',
        '[מספר רישום]',
        '[כתובת רשומה]',
        '[כתובת דוא"ל]',
      ]) {
        expect(
          kPrivacyPolicy.contains(ph) || kTermsOfUse.contains(ph),
          isTrue,
          reason: 'placeholder $ph must remain until the owner fills it',
        );
      }
    });

    test('privacy policy still cites Amendment 13 (Israeli privacy law)', () {
      expect(kPrivacyPolicy, contains("תיקון מס' 13"));
    });
  });
}
