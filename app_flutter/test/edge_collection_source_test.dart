// ratchet — מצב-מסונן שלב D: RemoteCollectionSource מעל Firestore-REST.
import 'dart:convert';

import 'package:buildsmart/data/edge/edge_collection_source.dart';
import 'package:buildsmart/data/edge/firestore_rest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<({String method, Uri url, String? body})> calls;
  FirestoreRest rest({int status = 200}) {
    calls = [];
    return FirestoreRest(
      projectId: 'buildsmart-b0b78',
      idToken: () async => 'TOK',
      request: (method, url, headers, body) async {
        calls.add((method: method, url: url, body: body));
        return (status: status, body: '{}');
      },
    );
  }

  test('set ⇒ PATCH ל-collection/id דרך fs. עם השדות המקודדים', () async {
    final src = EdgeRestCollectionSource('roleRequests', rest());
    await src.set('uid-1', {'status': 'pending', 'requestedRole': 'worker'});
    expect(calls.single.method, 'PATCH');
    expect(calls.single.url.host, 'fs.buildsmart-il.com');
    expect(calls.single.url.path, contains('/documents/roleRequests/uid-1'));
    final fields =
        (jsonDecode(calls.single.body!) as Map<String, dynamic>)['fields'];
    expect(fields, {
      'status': {'stringValue': 'pending'},
      'requestedRole': {'stringValue': 'worker'},
    });
  });

  test('delete ⇒ DELETE ל-collection/id', () async {
    final src = EdgeRestCollectionSource('roleRequests', rest());
    await src.delete('uid-1');
    expect(calls.single.method, 'DELETE');
    expect(calls.single.url.path, contains('/documents/roleRequests/uid-1'));
  });

  test('delete על מסמך לא-קיים (404) ⇒ ללא-שגיאה (idempotent)', () async {
    final src = EdgeRestCollectionSource('roleRequests', rest(status: 404));
    await src.delete('missing'); // לא זורק
    expect(calls.single.method, 'DELETE');
  });

  test('snapshots בלי scope ⇒ polling ל-listDocs (GET) · isScoped=false',
      () async {
    final src = EdgeRestCollectionSource('roleRequests', rest());
    expect(src.isScoped, isFalse);
    expect(await src.snapshots().first, isEmpty); // listDocs ריק (fake '{}')
    expect(calls.first.method, 'GET');
    expect(calls.first.url.path, contains('/documents/roleRequests'));
  });

  test('snapshots עם scope ⇒ runQuery (POST :runQuery) ממוקד-שדה · isScoped',
      () async {
    final src = EdgeRestCollectionSource(
      'orders',
      rest(),
      scopeField: 'contractorUid',
      scopeValue: 'U',
    );
    expect(src.isScoped, isTrue);
    await src.snapshots().first;
    expect(calls.first.method, 'POST');
    expect(calls.first.url.path, contains(':runQuery'));
    final q = (jsonDecode(calls.first.body!) as Map)['structuredQuery'] as Map;
    expect((q['from'] as List).single, {'collectionId': 'orders'});
    final ff = (q['where'] as Map)['fieldFilter'] as Map;
    expect((ff['field'] as Map)['fieldPath'], 'contractorUid');
    expect((ff['value'] as Map)['stringValue'], 'U');
  });

  test('scopeOp ARRAY_CONTAINS (צ׳אט participantUids מכיל uid)', () async {
    final src = EdgeRestCollectionSource(
      'chatThreads',
      rest(),
      scopeField: 'participantUids',
      scopeValue: 'U',
      scopeOp: 'ARRAY_CONTAINS',
    );
    await src.snapshots().first;
    final q = (jsonDecode(calls.first.body!) as Map)['structuredQuery'] as Map;
    final ff = (q['where'] as Map)['fieldFilter'] as Map;
    expect(ff['op'], 'ARRAY_CONTAINS');
    expect((ff['field'] as Map)['fieldPath'], 'participantUids');
  });
}
