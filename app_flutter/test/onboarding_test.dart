import 'package:buildsmart/screens/onboarding_screen.dart';
import 'package:buildsmart/screens/profession_screen.dart';
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('onboarding slides', () {
    test('has >=3 well-formed slides (non-empty title + body)', () {
      expect(kOnboardingSlides.length, greaterThanOrEqualTo(3));
      for (final slide in kOnboardingSlides) {
        expect(slide.title.trim(), isNotEmpty);
        expect(slide.body.trim(), isNotEmpty);
      }
    });
  });

  group('welcome gate', () {
    test('provider defaults to true so full-app tests skip onboarding', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(welcomeSeenProvider), isTrue);
    });

    test('loadWelcomeSeen: false on a fresh install, true after persist',
        () async {
      SharedPreferences.setMockInitialValues({});
      expect(await loadWelcomeSeen(), isFalse);

      await persistWelcomeSeen();
      expect(await loadWelcomeSeen(), isTrue);
    });
  });

  group('registration', () {
    test('valid only when both name and contact are filled', () {
      expect(registrationValid('שלמה', '050-1234567'), isTrue);
      expect(registrationValid('', '050-1234567'), isFalse);
      expect(registrationValid('שלמה', '   '), isFalse);
      expect(registrationValid('  ', '  '), isFalse);
    });
  });

  group('profession options', () {
    test('has >=3 well-formed trades', () {
      expect(kTradeOptions.length, greaterThanOrEqualTo(3));
      for (final t in kTradeOptions) {
        expect(t.name.trim(), isNotEmpty);
        expect(t.desc.trim(), isNotEmpty);
      }
    });
  });

  group('user profile', () {
    test('register sets name/contact/registered + round-trips through JSON', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c
          .read(userProfileProvider.notifier)
          .register(name: 'שלמה', contact: '050-1');
      final p = c.read(userProfileProvider);
      expect(p.name, 'שלמה');
      expect(p.contact, '050-1');
      expect(p.registered, isTrue);
      expect(UserProfile.fromJson(p.toJson()).name, 'שלמה');
    });

    test('continueAsDemo leaves registered false; setProfession stores trade',
        () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(userProfileProvider.notifier)..continueAsDemo();
      expect(c.read(userProfileProvider).registered, isFalse);
      n.setProfession('אינסטלטור');
      expect(c.read(userProfileProvider).profession, 'אינסטלטור');
    });
  });
}
