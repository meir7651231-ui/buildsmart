// #user-hub — pure coverage of the unified user-management hub's account-filter
// predicate (הכל / ממתינים / פעילים / לקוחות בלבד) that the 👥 tab's chips drive.
// Firebase-free, widget-free — the project's predicate-test shape (mirrors
// manager_approval_panel_test.dart). The chips are DATA-gated (shown only when a
// directory exists), so the OFF path never renders them; this pins the matcher.
import 'package:buildsmart/screens/manager_dashboard_screen.dart'
    show accountFilterMatch;
import 'package:buildsmart/state/directory.dart'
    show kDirectoryStatusPending, kDirectoryStatusActive;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('#user-hub accountFilterMatch', () {
    test('all → keeps every row (pending, active, and uid-less CRM/order rows)',
        () {
      for (final s in ['', kDirectoryStatusPending, kDirectoryStatusActive]) {
        for (final u in ['u1', '']) {
          expect(accountFilterMatch(accountStatus: s, uid: u, filter: 'all'),
              isTrue);
        }
      }
    });

    test('pending → only status==pending (app-users awaiting approval)', () {
      expect(
          accountFilterMatch(
              accountStatus: kDirectoryStatusPending,
              uid: 'u1',
              filter: 'pending'),
          isTrue);
      expect(
          accountFilterMatch(
              accountStatus: kDirectoryStatusActive,
              uid: 'u1',
              filter: 'pending'),
          isFalse);
      expect(
          accountFilterMatch(accountStatus: '', uid: '', filter: 'pending'),
          isFalse);
    });

    test('active → only status==active', () {
      expect(
          accountFilterMatch(
              accountStatus: kDirectoryStatusActive,
              uid: 'u1',
              filter: 'active'),
          isTrue);
      expect(
          accountFilterMatch(
              accountStatus: kDirectoryStatusPending,
              uid: 'u1',
              filter: 'active'),
          isFalse);
      expect(
          accountFilterMatch(accountStatus: '', uid: '', filter: 'active'),
          isFalse);
    });

    test('customers → only uid-less rows (CRM / order-derived, no app account)',
        () {
      expect(
          accountFilterMatch(accountStatus: '', uid: '', filter: 'customers'),
          isTrue);
      expect(
          accountFilterMatch(
              accountStatus: kDirectoryStatusActive,
              uid: 'u1',
              filter: 'customers'),
          isFalse);
      expect(
          accountFilterMatch(
              accountStatus: kDirectoryStatusPending,
              uid: 'u9',
              filter: 'customers'),
          isFalse);
    });
  });
}
