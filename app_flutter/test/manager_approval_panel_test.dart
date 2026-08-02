// #reg-approval — pure, widget-free coverage of the registration-approval CLIENT
// logic that the Manager Customers approval panel runs: the pending-filter and
// the all / selected / all-except target resolution (directory.dart), plus the
// userApproverProvider OFF-gate (null Firebase-free ⇒ byte-identical when off).
// The server authorizes the callable; these are the client's checklist mechanics.

import 'package:buildsmart/state/directory.dart';
import 'package:buildsmart/state/role_requests.dart' show userApproverProvider;
import 'package:buildsmart/state/sys_chat.dart' show BsRole;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

DirectoryEntry _e(
  String uid,
  String name, {
  required String status,
  BsRole? role,
}) =>
    DirectoryEntry(uid: uid, displayName: name, role: role, status: status);

void main() {
  group('#reg-approval pendingDirectoryEntries', () {
    test('keeps only status==pending, in input order', () {
      final entries = [
        _e('a', 'אבי', status: kDirectoryStatusPending),
        _e('b', 'בני', status: kDirectoryStatusActive),
        _e('c', 'גדי', status: kDirectoryStatusPending),
        _e('d', 'דנה', status: ''), // unknown/absent status → not pending
      ];
      expect(pendingDirectoryEntries(entries).map((e) => e.uid), ['a', 'c']);
    });

    test('empty when nobody is pending', () {
      expect(
        pendingDirectoryEntries([_e('b', 'בני', status: kDirectoryStatusActive)]),
        isEmpty,
      );
    });
  });

  group('#reg-approval resolveApproveTargets', () {
    final pending = ['a', 'b', 'c'];

    test('all:true approves EVERY pending uid ("אשר הכל"), ignoring ticks', () {
      expect(
        resolveApproveTargets(
            all: true, pendingUids: pending, checked: const {'a'}),
        ['a', 'b', 'c'],
      );
    });

    test('all:false approves only the ticked ("אשר מסומנים"), pending order', () {
      expect(
        resolveApproveTargets(
            all: false, pendingUids: pending, checked: const {'c', 'a'}),
        ['a', 'c'],
      );
    });

    test('"אשר הכל חוץ מ-b": untick b ⇒ b is excluded from the selected approve',
        () {
      final checked = {'a', 'c'}; // b unticked
      expect(
        resolveApproveTargets(
            all: false, pendingUids: pending, checked: checked),
        ['a', 'c'],
      );
    });

    test('nothing ticked ⇒ empty (the "אשר מסומנים" button is disabled on this)',
        () {
      expect(
        resolveApproveTargets(
            all: false, pendingUids: pending, checked: const {}),
        isEmpty,
      );
    });

    test('a ticked uid no longer pending is ignored (stale-exclusion safety)',
        () {
      expect(
        resolveApproveTargets(
            all: false, pendingUids: pending, checked: const {'a', 'zz'}),
        ['a'],
      );
    });
  });

  group('#reg-approval userApproverProvider gate', () {
    test('OFF (Firebase-free) ⇒ null — byte-identical when off, panel inert', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(userApproverProvider), isNull);
    });
  });
}
