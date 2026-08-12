// 🌉 מצב-מסונן · שלב D — מקור-אוסף (RemoteCollectionSource) מעל Firestore-REST.
//
// מחליף את `FirestoreCollectionSource` כשמצב-מסונן דלוק: כתיבות (set/delete)
// וקריאות (snapshots) עוברות דרך `fs.buildsmart-il.com` עם ה-idToken, במקום
// ה-SDK חסר-הטוקן בקו-מסונן.
//
// קריאה-חיה = **polling**: ל-REST אין long-poll כמו ל-SDK, אז מרעננים כל
// `pollInterval` (runQuery ממוקד-שדה כשיש scope — הצורה שה-Rules מתירים ללקוח;
// אחרת listDocs לאוסף-שלם). כתיבה-בלבד (roleRequests/users) עוברת בלי scope
// ו-snapshots לא-נצרך שם.

import 'package:buildsmart/data/edge/firestore_rest.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;

class EdgeRestCollectionSource implements RemoteCollectionSource {
  EdgeRestCollectionSource(
    this.collectionPath,
    this._rest, {
    this.scopeField,
    this.scopeValue,
    this.pollInterval = const Duration(seconds: 6),
  });

  final String collectionPath;
  final FirestoreRest _rest;

  /// שאילתה ממוקדת: `scopeField == scopeValue` (למשל `contractorUid == uid`).
  /// null ⇒ קריאת-אוסף-מלאה (listDocs) — רק לאוספים שה-Rules מתירים.
  final String? scopeField;
  final String? scopeValue;
  final Duration pollInterval;

  String _path(String id) => '$collectionPath/$id';

  Future<List<RemoteDoc>> _read() async {
    final field = scopeField;
    final value = scopeValue;
    final docs = (field != null && value != null)
        ? await _rest.runQuery(collectionPath, field: field, value: value)
        : await _rest.listDocs(collectionPath);
    return docs
        .map((d) => RemoteDoc(d.id, d.fields))
        .toList(growable: false);
  }

  @override
  Stream<List<RemoteDoc>> snapshots() async* {
    // קריאה מיידית ואז polling; כשל (רשת/הרשאה) ⇒ רשימה-ריקה, לא קריסה.
    while (true) {
      try {
        yield await _read();
      } on Object {
        yield const <RemoteDoc>[];
      }
      await Future<void>.delayed(pollInterval);
    }
  }

  @override
  Future<void> set(String id, Map<String, dynamic> data) =>
      _rest.setDoc(_path(id), data);

  @override
  Future<void> delete(String id) => _rest.deleteDoc(_path(id));

  // scoped ⇒ isScoped=true (ריק-סקופ = "אין דוקים אמיתי" ⇒ empty כנה, לא seed).
  @override
  bool get isScoped => scopeField != null;
}
