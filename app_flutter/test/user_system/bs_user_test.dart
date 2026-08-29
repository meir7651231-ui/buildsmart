// U0.1 — the unified [BsUser] model: guarded decode, the UserProfile bridge, and
// the all-by-approval `pending` default. Pure — zero backend.

import 'package:buildsmart/data/bs_user.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserStatus.fromWire', () {
    test('maps the known wire values', () {
      expect(UserStatus.fromWire('active'), UserStatus.active);
      expect(UserStatus.fromWire('suspended'), UserStatus.suspended);
      expect(UserStatus.fromWire('pending'), UserStatus.pending);
    });

    test('defaults to pending for anything unknown/missing (all-by-approval)', () {
      expect(UserStatus.fromWire(null), UserStatus.pending);
      expect(UserStatus.fromWire(''), UserStatus.pending);
      expect(UserStatus.fromWire('ACTIVE'), UserStatus.pending); // case-sensitive
      expect(UserStatus.fromWire(42), UserStatus.pending);
      expect(UserStatus.fromWire('approved'), UserStatus.pending);
    });
  });

  group('BsUser defaults', () {
    test('a fresh user is born pending with an empty role', () {
      const u = BsUser(uid: 'u1');
      expect(u.status, UserStatus.pending);
      expect(u.role, '');
      expect(u.phone, isNull);
      expect(u.storeUid, isNull);
    });
  });

  group('BsUser.fromProfile bridge', () {
    test('routes a mobile contact to phone (never email)', () {
      const p = UserProfile(name: 'משה בונה', contact: '050-123 4567');
      final u = BsUser.fromProfile(p, uid: 'uid-1');
      expect(u.name, 'משה בונה');
      expect(u.phone, '050-123 4567');
      expect(u.email, isNull);
      expect(u.status, UserStatus.pending);
      expect(u.role, ''); // role is a server/claim concern — never from profile
    });

    test('routes an email contact to email (never phone)', () {
      const p = UserProfile(name: 'דנה', contact: 'dana@example.com');
      final u = BsUser.fromProfile(p, uid: 'uid-2');
      expect(u.email, 'dana@example.com');
      expect(u.phone, isNull);
    });

    test('a junk contact lands in neither field', () {
      const p = UserProfile(name: 'x', contact: 'not-a-contact');
      final u = BsUser.fromProfile(p, uid: 'uid-3');
      expect(u.phone, isNull);
      expect(u.email, isNull);
    });
  });

  group('toDoc / fromJson round-trip', () {
    test('a full record survives serialise → decode (uid from doc-id)', () {
      final created = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      final seen = DateTime.fromMillisecondsSinceEpoch(1710000000000);
      final u = BsUser(
        uid: 'uid-9',
        name: 'בעל חנות',
        phone: '0501112222',
        email: 'store@x.co.il',
        role: 'store',
        storeUid: 'store-abc',
        orgId: 'org-1',
        status: UserStatus.active,
        createdAt: created,
        lastSeen: seen,
      );
      final doc = u.toDoc();
      final back = BsUser.fromJson('uid-9', doc);
      expect(back, u);
    });

    test('toDoc omits empty/null optionals and always writes a status', () {
      const u = BsUser(uid: 'uid-x', name: 'רק שם');
      final doc = u.toDoc();
      expect(doc.containsKey('phone'), isFalse);
      expect(doc.containsKey('email'), isFalse);
      expect(doc.containsKey('role'), isFalse);
      expect(doc.containsKey('storeUid'), isFalse);
      expect(doc['status'], 'pending');
    });
  });

  group('fromJson is guarded', () {
    test('missing status → pending; empty optionals → null', () {
      final u = BsUser.fromJson('uid', const {'displayName': 'n', 'phone': ''});
      expect(u.status, UserStatus.pending);
      expect(u.phone, isNull); // empty string decodes to null (optional contract)
      expect(u.name, 'n');
    });

    test('accepts an ISO-8601 string timestamp', () {
      final u =
          BsUser.fromJson('uid', const {'createdAt': '2023-11-14T00:00:00.000Z'});
      expect(u.createdAt, DateTime.parse('2023-11-14T00:00:00.000Z'));
    });

    test('a garbage timestamp decodes to null, never throws', () {
      final u = BsUser.fromJson(
          'uid', const {'createdAt': 'not-a-date', 'lastSeen': <int>[]});
      expect(u.createdAt, isNull);
      expect(u.lastSeen, isNull);
    });
  });

  group('isValid', () {
    test('requires a non-empty uid', () {
      expect(const BsUser(uid: '').isValid, isFalse);
      expect(const BsUser(uid: 'u').isValid, isTrue);
    });

    test('rejects a malformed phone / email but allows absent ones', () {
      expect(const BsUser(uid: 'u', phone: '123').isValid, isFalse);
      expect(const BsUser(uid: 'u', email: 'nope').isValid, isFalse);
      expect(const BsUser(uid: 'u', phone: '0501234567').isValid, isTrue);
      expect(const BsUser(uid: 'u').isValid, isTrue); // no contact = fine
    });
  });

  test('copyWith replaces only the given fields', () {
    const u = BsUser(uid: 'u', name: 'a'); // status defaults to pending
    final v = u.copyWith(status: UserStatus.active);
    expect(v.status, UserStatus.active);
    expect(v.name, 'a');
    expect(v.uid, 'u');
  });
}
