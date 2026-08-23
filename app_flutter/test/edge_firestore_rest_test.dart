// ratchet — מצב-מסונן שלב D: לקוח Firestore-REST דרך המתווך (codec + get/set).
import 'dart:convert';

import 'package:buildsmart/data/edge/firestore_rest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('שלב D — קידוד/פענוח values-typed', () {
    test('round-trip לכל הסוגים (כולל מקונן)', () {
      final data = <String, Object?>{
        's': 'שלום',
        'i': 42,
        'd': 3.5,
        'b': true,
        'n': null,
        'list': [1, 'x', false],
        'map': {'inner': 'y', 'k': 7},
      };
      final encoded = encodeFields(data);
      // מספר-שלם ⇒ integerValue כמחרוזת (חוזה ה-API):
      expect(encoded['i'], {'integerValue': '42'});
      expect(encoded['s'], {'stringValue': 'שלום'});
      expect(encoded['b'], {'booleanValue': true});
      expect(encoded['n'], {'nullValue': null});

      final decoded = decodeFields(encoded);
      expect(decoded['s'], 'שלום');
      expect(decoded['i'], 42);
      expect(decoded['d'], 3.5);
      expect(decoded['b'], true);
      expect(decoded['n'], isNull);
      expect(decoded['list'], [1, 'x', false]);
      expect(decoded['map'], {'inner': 'y', 'k': 7});
    });

    test('timestamp ⇒ ISO ⇒ DateTime', () {
      final t = DateTime.utc(2026, 8, 12, 9);
      final enc = encodeValue(t);
      expect(enc.keys.single, 'timestampValue');
      expect(decodeValue(enc), t);
    });
  });

  group('שלב D — FirestoreRest get/set דרך המתווך', () {
    late List<({String method, Uri url, Map<String, String> headers, String? body})>
        calls;
    FirestoreRest client({int status = 200, String body = '{}'}) {
      calls = [];
      return FirestoreRest(
        projectId: 'buildsmart-b0b78',
        idToken: () async => 'TOK',
        request: (method, url, headers, reqBody) async {
          calls.add((method: method, url: url, headers: headers, body: reqBody));
          return (status: status, body: body);
        },
      );
    }

    test('getDoc — פונה ל-fs. עם Bearer, מפענח שדות', () async {
      final c = client(
        body: jsonEncode({
          'name': 'projects/buildsmart-b0b78/databases/(default)/documents/users/u1',
          'fields': {
            'displayName': {'stringValue': 'דנה'},
            'pending': {'booleanValue': true},
          },
        }),
      );
      final doc = await c.getDoc('users/u1');
      expect(doc, {'displayName': 'דנה', 'pending': true});
      expect(calls.single.method, 'GET');
      expect(calls.single.url.host, 'fs.buildsmart-il.com'); // המתווך, לא גוגל
      expect(calls.single.url.path, contains('/documents/users/u1'));
      expect(calls.single.headers['Authorization'], 'Bearer TOK');
    });

    test('getDoc — 404 ⇒ null (מסמך לא-קיים)', () async {
      final c = client(status: 404);
      expect(await c.getDoc('users/missing'), isNull);
    });

    test('setDoc — PATCH עם שדות מקודדים + updateMask (מיזוג, לא דריסה)',
        () async {
      final c = client();
      await c.setDoc('users/u1', {'displayName': 'רון', 'age': 30});
      expect(calls.single.method, 'PATCH');
      final sent = jsonDecode(calls.single.body!) as Map<String, dynamic>;
      expect(sent['fields'], {
        'displayName': {'stringValue': 'רון'},
        'age': {'integerValue': '30'},
      });
      // updateMask מונה בדיוק את השדות הנשלחים ⇒ מיזוג (שדות אחרים נשמרים),
      // כמו set(merge:true) של ה-SDK — מונע דריסת participantUids בעדכון-שרשור.
      final mask = calls.single.url.queryParametersAll['updateMask.fieldPaths'];
      expect(mask, containsAll(<String>['displayName', 'age']));
    });

    test('סטטוס-שגיאה ⇒ FirestoreRestException', () async {
      final c = client(status: 403, body: 'PERMISSION_DENIED');
      await expectLater(
        c.getDoc('users/u1'),
        throwsA(isA<FirestoreRestException>()),
      );
    });
  });
}
