// rerouteThreadToDm must not read a disposed WidgetRef after its directory
// await. The caller (a chat-list row or the chats screen) can leave the tree
// while `uidsByRole` is in flight — the old code then did
// `ref.read(chatEngineProvider.notifier)` and threw
// "Cannot use ref after the widget was disposed" as an uncaught async error.

import 'dart:async';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/users_lookup.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A `directory` source whose single snapshot is held until the test emits it.
class _GatedSource implements RemoteCollectionSource {
  final ctrl = StreamController<List<RemoteDoc>>();

  @override
  Stream<List<RemoteDoc>> snapshots() => ctrl.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  bool get isScoped => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dispose during the directory lookup → no throw, dm id returned',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final src = _GatedSource();
    final container = ProviderContainer(overrides: [
      currentUidProvider.overrideWithValue('uid-worker'),
      usersLookupProvider.overrideWithValue(UsersLookup(src)),
    ]);
    addTearDown(container.dispose);

    late Future<String> pending;
    final show = ValueNotifier<bool>(true);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: show,
            builder: (_, on, __) => on
                ? Consumer(builder: (_, ref, __) {
                    return TextButton(
                      onPressed: () => pending = rerouteThreadToDm(
                        ref,
                        'th-worker-manager',
                        BsRole.worker,
                      ),
                      child: const Text('open'),
                    );
                  })
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();

    // The row leaves the tree while the directory read is still in flight.
    show.value = false;
    await tester.pump();

    // The directory answers: exactly one manager.
    src.ctrl.add(const [
      RemoteDoc('uid-mgr', {kUsersRoleField: 'manager'}),
    ]);
    final id = await pending;

    expect(id, dmThreadId(const ['uid-worker', 'uid-mgr']));
    expect(container.read(chatEngineProvider).any((t) => t.id == id), isTrue);
    expect(tester.takeException(), isNull);
  });
}
