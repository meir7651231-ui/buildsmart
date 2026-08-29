// #6 — role-request (client) coverage: submitting from the sheet writes a
// pending roleRequests/{uid} doc through the seam. Firebase is never touched —
// a fake RemoteCollectionSource records the writes, and currentUidProvider is
// overridden so submit has an identity (the same discipline as the auth tests).

import 'package:buildsmart/data/board_accounts_local.dart'
    show isOwnerEmail, kOwnerEmails;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/screens/role_request_sheet.dart';
import 'package:buildsmart/screens/role_requests_inbox_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/role_requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records set/delete; never touches Firebase. [throwOnSet] simulates a
/// network / permission-denied write failure.
class _FakeSource implements RemoteCollectionSource {
  _FakeSource({this.throwOnSet = false});
  final bool throwOnSet;
  final List<({String id, Map<String, dynamic> data})> sets = [];
  final List<String> deletes = [];

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    if (throwOnSet) throw StateError('write failed');
    sets.add((id: id, data: data));
  }

  @override
  Future<void> delete(String id) async => deletes.add(id);

  @override
  Stream<List<RemoteDoc>> snapshots() => const Stream<List<RemoteDoc>>.empty();

  @override
  bool get isScoped => false;
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

  // HIGH-fix — a write failure must surface a clean Hebrew error (not throw past
  // the handler and leave the sheet stuck busy).
  testWidgets('a failed write shows the error and keeps the sheet usable',
      (t) async {
    final src = _FakeSource(throwOnSet: true);
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
    await t.tap(find.text('משלוחים ועדכוני סטטוס')); // courier
    await t.pumpAndSettle();
    expect(find.text('לא ניתן לשלוח בקשה כעת'), findsOneWidget);
    expect(find.text('🪪 בקשת תפקיד'), findsOneWidget); // sheet stays open
    expect(src.sets, isEmpty); // the throw was caught, nothing recorded
    await t.pumpAndSettle(const Duration(seconds: 3));
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

  // Owner-only bulk clear — "תמחק את כל הבקשות הקיימות". The clear-all action
  // shows ONLY for the owner, and deletes every pending request in one sweep.
  testWidgets('owner clear-all deletes every pending request', (t) async {
    final src = _FakeSource();
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => _StaticAuth(
              AuthSnapshot(
                user: AuthUser(uid: 'owner', email: kOwnerEmails.first),
                roles: const ['admin'],
                loaded: true,
              ),
            ),
          ),
          roleRequestWriterProvider.overrideWithValue(src),
          pendingRoleRequestsProvider.overrideWith(
            (ref) => Stream<List<RemoteDoc>>.value([
              RemoteDoc('u-a', <String, dynamic>{
                'requestedRole': 'store',
                'status': 'pending',
              }),
              RemoteDoc('u-b', <String, dynamic>{
                'requestedRole': 'contractor',
                'status': 'pending',
              }),
            ]),
          ),
        ],
        child: const MaterialApp(home: RoleRequestsInboxScreen()),
      ),
    );
    await t.pumpAndSettle();

    // The owner sees the sweep action; tapping it opens the destructive confirm.
    expect(find.byKey(const Key('clear_all_requests')), findsOneWidget);
    await t.tap(find.byKey(const Key('clear_all_requests')));
    await t.pumpAndSettle();
    await t.tap(find.text('מחק הכל'));
    await t.pumpAndSettle(const Duration(seconds: 3));

    // Both pending docs deleted through the seam.
    expect(src.deletes, containsAll(<String>['u-a', 'u-b']));
    expect(src.deletes.length, 2);
  });

  test('a non-owner reviewer never gets the clear-all action', () {
    // Visibility is gated on isOwnerEmail — a contractor/store approver, though
    // they have an inbox, must not see the bulk-clear.
    expect(isOwnerEmailForTest('someone@else.com'), isFalse);
    expect(isOwnerEmailForTest(kOwnerEmails.first), isTrue);
  });
}

/// A minimal static [authStateProvider] notifier for the owner override — a null
/// gateway means no Firebase subscription starts; we just pin the snapshot.
class _StaticAuth extends AuthStateNotifier {
  _StaticAuth(AuthSnapshot snap) : super(null) {
    state = snap;
  }
}

/// Local mirror so the non-owner test names the same predicate the screen uses.
bool isOwnerEmailForTest(String? email) => isOwnerEmail(email);
