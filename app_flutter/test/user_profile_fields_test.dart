// Cluster-4 guard (9×9 fleet, autonomous run 2026-06-09 · task #55):
// UserProfile gained optional address (כתובת/אזור) + businessId (ח.פ./עוסק).
// These pure-model tests lock the round-trip, legacy-JSON defaults, and that
// editing them does NOT disturb name/contact or the registered-flip logic.
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toJson/fromJson round-trips address + businessId', () {
    const p = UserProfile(
      name: 'אבי כהן',
      contact: '0500000000',
      profession: 'אינסטלטור',
      address: 'תל אביב',
      businessId: '514999999',
      registered: true,
    );
    final back = UserProfile.fromJson(p.toJson());
    expect(back.address, 'תל אביב');
    expect(back.businessId, '514999999');
    expect(back.name, 'אבי כהן');
    expect(back.registered, isTrue);
  });

  test('legacy JSON without the new keys defaults them to empty', () {
    final legacy = UserProfile.fromJson(const {
      'name': 'דנה',
      'contact': 'dana@x.com',
      'profession': 'אינסטלטור',
      'registered': true,
    });
    expect(legacy.address, '');
    expect(legacy.businessId, '');
    expect(legacy.name, 'דנה');
  });

  test('copyWith sets address/businessId without clearing other fields', () {
    const base = UserProfile(name: 'א', contact: 'b', profession: 'אינסטלטור');
    final next = base.copyWith(address: 'חיפה', businessId: '123');
    expect(next.address, 'חיפה');
    expect(next.businessId, '123');
    expect(next.name, 'א');
    expect(next.contact, 'b');
    expect(next.profession, 'אינסטלטור');
  });

  test('registered flips only on name+contact (not on address/businessId)', () {
    // address/businessId alone must NOT mark a guest registered.
    expect(registrationValid('', ''), isFalse);
    expect(registrationValid('שם', ''), isFalse);
    expect(registrationValid('שם', '050'), isTrue);
  });
}
