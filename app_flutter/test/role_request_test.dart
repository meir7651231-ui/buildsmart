// #6 — role-request (client) coverage: submitting from the sheet writes a
// pending roleRequests/{uid} doc through the seam. Firebase is never touched —
// a fake RemoteCollectionSource records the writes, and currentUidProvider is
// overridden so submit has an identity (the same discipline as the auth tests).

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/screens/role_request_sheet.dart';
import 'package:buildsmart/screens/role_requests_inbox_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/role_requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records set/delete; never touches Firebase.
class _FakeSource implements RemoteCollectionSource {
  final List<({String id, Map<String, dynamic> data})> sets = [];
  final List<String> deletes = [];

  @override
  Future<void> set(String id, Map<String, dynamic> data) async =>
      sets.add((id: id, data: data));

  @override
  Future<void> delete(String id) async => deletes.add(id);

  @override
  Stream<List<RemoteDoc>> snapshots() => const Stream<List<RemoteDoc>>.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the request sheet writes a pending roleRequests/{uid} doc',
      (t) async {
    final src = _FakeSource();
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          roleRequestWriterProvider.overrideWithValue(src),
          currentUidProvider.overrideWithValue('u-1'),
        ],
        child: MaterialApp(
          locale: const Locale('he'),
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showRoleRequestSheet(ctx),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('🪪 בקשת תפקיד'), findsOneWidget);

    // Pick "שליח" (courier) via its unique purpose line, then verify the write.
    await t.tap(find.text('משלוחים ועדכוני סטטוס'));
    await t.pumpAndSettle();

    expect(src.deletes, ['u-1']); // prior request cleared first
    expect(src.sets.length, 1);
    expect(src.sets.first.id, 'u-1');
    expect(src.sets.first.data['requestedRole'], 'courier');
    expect(src.sets.first.data['status'], 'pending');
    expect(find.text('🪪 בקשת תפקיד'), findsNothing); // sheet closed
  });

  test('Firebase-free → the roleRequests writer is null (no Firebase touch)',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // useFirebaseBackend is a const false in tests → the seam is null, so
    // submitRoleRequest short-circuits and nothing ever reaches Firestore.
    expect(container.read(roleRequestWriterProvider), isNull);
  });

  // ── inc.3 — approval matrix + inbox ────────────────────────────────────────
  test('approvableRolesForClaims mirrors the server matrix', () {
    expect(approvableRolesForClaims(['contractor']), ['worker']);
    expect(approvableRolesForClaims(['store']), ['courier']);
    expect(approvableRolesForClaims(['manager']), ['store', 'contractor']);
    expect(approvableRolesForClaims(['admin']), kRequestableRoles);
    expect(approvableRolesForClaims(['worker']), isEmpty);
    expect(approvableRolesForClaims(['courier']), isEmpty);
    expect(approvableRolesForClaims(<String>[]), isEmpty);
  });

  testWidgets('the inbox approves a pending request via the reviewer',
      (t) async {
    final calls = <({String uid, bool approve})>[];
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          pendingRoleRequestsProvider.overrideWith(
            (ref) => Stream<List<RemoteDoc>>.value([
              RemoteDoc('u-w1', <String, dynamic>{
                'requestedRole': 'worker',
                'displayName': 'דנה',
                'status': 'pending',
              }),
              RemoteDoc('u-w2', <String, dynamic>{
                'requestedRole': 'worker',
                'displayName': 'רון',
                'status': 'pending',
              }),
            ]),
          ),
          roleReviewerProvider.overrideWithValue(
            (String uid, {required bool approve}) async =>
                calls.add((uid: uid, approve: approve)),
          ),
        ],
        child: const MaterialApp(home: RoleRequestsInboxScreen()),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('דנה'), findsOneWidget);
    expect(find.text('רון'), findsOneWidget);

    // Approve the first card → the reviewer is called for that uid.
    await t.tap(find.text('אישור').first);
    await t.pumpAndSettle(const Duration(seconds: 3));
    expect(calls.length, 1);
    expect(calls.first.uid, 'u-w1');
    expect(calls.first.approve, true);
  });
}
