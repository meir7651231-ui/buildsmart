// Builder-2 (Wave 0 employerId spine) · employer resolver —
// lib/state/employer_link.dart. The provider maps a worker's `employerId` (the
// link minted in board_auth.dart) to the employing contractor's
// EmployerProfile. SERVER-SWAP seam: today the single-device demo holds ONE
// contractor (the device's userProfileProvider, key bs.profile.v1), so:
//   • empty employerId        → const EmployerProfile() (isEmpty, honest gap);
//   • any non-empty employerId → that one device contractor's
//                                name/businessId/address/contact (no fabrication).
import 'dart:convert';

import 'package:buildsmart/state/employer_link.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The lazy userProfileProvider runs its async `_load()` on first read; let it
/// resolve before asserting (the worker_profile_store_test idiom).
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('employerProfileProvider', () {
    test('empty employerId → an isEmpty EmployerProfile (no fabrication)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final employer = container.read(employerProfileProvider(''));

      expect(employer.isEmpty, isTrue);
      expect(employer.name, '');
      expect(employer.businessId, '');
      expect(employer.address, '');
      expect(employer.contact, '');
    });

    test(
        'non-empty employerId → resolves the device contractor '
        '(name/businessId/address/contact)', () async {
      // Seed the device contractor through the real notifier's own prefs key.
      SharedPreferences.setMockInitialValues({
        kUserProfileKey: jsonEncode(const UserProfile(
          name: 'אבי הקבלן',
          contact: '050-1234567',
          profession: 'קבלן שיפוצים',
          address: 'רחוב הבנאים 7, תל אביב',
          businessId: '514999999',
          registered: true,
        ).toJson()),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Providers are lazy — touch userProfileProvider so its _load() starts,
      // then settle so the persisted contractor is in memory before resolving.
      container.read(userProfileProvider);
      await _settle();

      final employer =
          container.read(employerProfileProvider('contractor-demo'));

      expect(employer.isEmpty, isFalse);
      expect(employer.name, 'אבי הקבלן');
      expect(employer.businessId, '514999999');
      expect(employer.address, 'רחוב הבנאים 7, תל אביב');
      expect(employer.contact, '050-1234567');
    });

    test(
        'the employerId is a server-swap key, not a local selector — any '
        'non-empty id resolves to the SAME one device contractor', () async {
      SharedPreferences.setMockInitialValues({
        kUserProfileKey: jsonEncode(const UserProfile(
          name: 'דנה קבלנית',
          contact: 'dana@build.co.il',
          address: 'הברזל 12, חיפה',
          businessId: '301122334',
          registered: true,
        ).toJson()),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(userProfileProvider);
      await _settle();

      final a = container.read(employerProfileProvider('contractor-demo'));
      final b = container.read(employerProfileProvider('some-other-id'));

      // Both ids land on the one device contractor (one contractor per device).
      expect(a.name, 'דנה קבלנית');
      expect(b.name, a.name);
      expect(b.businessId, a.businessId);
      expect(b.address, a.address);
      expect(b.contact, a.contact);
    });
  });
}
