// 🌉 מצב-מסונן · שלב D — מקור-אוסף (RemoteCollectionSource) מעל Firestore-REST.
//
// מחליף את `FirestoreCollectionSource` כשמצב-מסונן דלוק: כתיבות/מחיקות עוברות
// דרך `fs.buildsmart-il.com` עם ה-idToken (במקום ה-SDK חסר-הטוקן בקו-מסונן).
// כתיבה = set/delete (השער שהמשתמש פגע בו: בקשת-הצטרפות). קריאה-חיה (snapshots)
// אינה זמינה ב-REST פשוט — מוחזר זרם-ריק (הנתיבים הקוראים נשארים על ה-SDK עד
// שנחווט polling; הכתיבות הן מה שנחסם ראשון).

import 'package:buildsmart/data/edge/firestore_rest.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;

class EdgeRestCollectionSource implements RemoteCollectionSource {
  EdgeRestCollectionSource(this.collectionPath, this._rest);

  final String collectionPath;
  final FirestoreRest _rest;

  String _path(String id) => '$collectionPath/$id';

  @override
  Future<void> set(String id, Map<String, dynamic> data) =>
      _rest.setDoc(_path(id), data);

  @override
  Future<void> delete(String id) => _rest.deleteDoc(_path(id));

  // קריאה-חיה אינה נתמכת ב-REST הבסיסי ⇒ זרם-ריק (הכתיבות הן החסם הראשון;
  // ה-snapshots יחווטו ב-polling בשלב הבא). isScoped=false ⇒ מדיניות
  // ה-first-empty לא משתנה (זרם-ריק לא מאותת "אפס-דוקים אמיתי").
  @override
  Stream<List<RemoteDoc>> snapshots() => const Stream<List<RemoteDoc>>.empty();

  @override
  bool get isScoped => false;
}
