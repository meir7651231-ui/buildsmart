// 🌉 מצב-מסונן · שלב D — לקוח Firestore ב-REST דרך המתווך.
//
// בקו-מסונן אין סשן Auth-SDK ⇒ ל-Firestore-SDK אין טוקן ⇒ הקריאות נדחות ב-
// Rules. כאן: קריאות/כתיבות ל-Firestore דרך `fs.buildsmart-il.com` (המתווך)
// עם `Authorization: Bearer {idToken}` מ-FilteredSession. הסנן רואה רק את
// הדומיין המאושר.
//
// טהור-כמה-שאפשר: קידוד/פענוח הערכים (values-typed של Firestore-REST) מופרד
// מהרשת, ה-HTTP + מקור-הטוקן מוזרקים ⇒ נבדק ביחידה בלי HTTP אמיתי.

import 'dart:convert';

import 'package:buildsmart/data/edge/edge_http.dart';
import 'package:buildsmart/state/feature_flags.dart' show kEdgeFsHost;

/// שגיאת-Firestore-REST — סטטוס + גוף (ללוג/מיפוי).
class FirestoreRestException implements Exception {
  const FirestoreRestException(this.status, this.body);
  final int status;
  final String body;
  @override
  String toString() => 'FirestoreRestException($status): $body';
}

/// מקודד ערך-Dart בודד ל-value-typed של Firestore-REST.
/// (מספר-שלם ⇒ integerValue כמחרוזת — חוזה ה-API.)
Map<String, dynamic> encodeValue(Object? v) {
  if (v == null) return {'nullValue': null};
  if (v is bool) return {'booleanValue': v};
  if (v is int) return {'integerValue': v.toString()};
  if (v is double) return {'doubleValue': v};
  if (v is String) return {'stringValue': v};
  if (v is DateTime) return {'timestampValue': v.toUtc().toIso8601String()};
  if (v is List) {
    return {
      'arrayValue': {'values': v.map(encodeValue).toList()},
    };
  }
  if (v is Map) {
    return {
      'mapValue': {'fields': encodeFields(v.cast<String, Object?>())},
    };
  }
  // סוג לא-נתמך (bytes/geo/ref) ⇒ מחרוזת, לא זריקה (שמרני — עדיף שדה מנוון).
  return {'stringValue': v.toString()};
}

/// מפענח value-typed בודד חזרה לערך-Dart.
Object? decodeValue(Map<String, dynamic> value) {
  if (value.containsKey('nullValue')) return null;
  if (value.containsKey('booleanValue')) return value['booleanValue'] as bool;
  if (value.containsKey('integerValue')) {
    return int.tryParse('${value['integerValue']}') ?? 0;
  }
  if (value.containsKey('doubleValue')) {
    return (value['doubleValue'] as num).toDouble();
  }
  if (value.containsKey('stringValue')) return value['stringValue'] as String;
  if (value.containsKey('timestampValue')) {
    return DateTime.tryParse('${value['timestampValue']}');
  }
  if (value.containsKey('arrayValue')) {
    final arr = value['arrayValue'] as Map<String, dynamic>?;
    final values = (arr?['values'] as List?) ?? const [];
    return values
        .map((e) => decodeValue((e as Map).cast<String, dynamic>()))
        .toList();
  }
  if (value.containsKey('mapValue')) {
    final mv = value['mapValue'] as Map<String, dynamic>?;
    return decodeFields((mv?['fields'] as Map?)?.cast<String, dynamic>() ?? {});
  }
  return null; // סוג לא-מוכר
}

/// מקודד מפת-שדות (`{k: value-typed}`) — גוף ה-PATCH/החזרה.
Map<String, dynamic> encodeFields(Map<String, Object?> data) {
  return data.map((k, v) => MapEntry(k, encodeValue(v)));
}

/// מפענח מפת-שדות של מסמך חזרה ל-`Map<String,dynamic>`.
Map<String, dynamic> decodeFields(Map<String, dynamic> fields) {
  return fields.map(
    (k, v) => MapEntry(k, decodeValue((v as Map).cast<String, dynamic>())),
  );
}

/// לקוח Firestore-REST דרך המתווך. ה-idToken נמשך פר-קריאה (המקור מרענן אם
/// צריך — FilteredSession.validIdToken).
class FirestoreRest {
  FirestoreRest({
    required this.projectId,
    required this.request,
    required this.idToken,
    this.host = kEdgeFsHost,
  });

  final String projectId;
  final EdgeHttpRequest request;
  final Future<String?> Function() idToken;
  final String host;

  Uri _docUri(String path) => Uri.parse(
        'https://$host/v1/projects/$projectId/databases/(default)/documents/$path',
      );

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  /// קורא מסמך יחיד. null אם לא-קיים (404). זורק על סטטוס-שגיאה אחר.
  Future<Map<String, dynamic>?> getDoc(String path) async {
    final res =
        await request('GET', _docUri(path), _headers(await idToken()), null);
    if (res.status == 404) return null;
    if (res.status != 200) throw FirestoreRestException(res.status, res.body);
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return decodeFields((map['fields'] as Map?)?.cast<String, dynamic>() ?? {});
  }

  /// כותב/מחליף מסמך (PATCH ללא field-mask ⇒ מציב את כל השדות שנשלחו).
  Future<void> setDoc(String path, Map<String, Object?> data) async {
    final res = await request(
      'PATCH',
      _docUri(path),
      _headers(await idToken()),
      jsonEncode({'fields': encodeFields(data)}),
    );
    if (res.status != 200) throw FirestoreRestException(res.status, res.body);
  }

  /// מוחק מסמך. ‏404 (כבר לא-קיים) נחשב הצלחה (idempotent — כמו delete של ה-SDK).
  Future<void> deleteDoc(String path) async {
    final res =
        await request('DELETE', _docUri(path), _headers(await idToken()), null);
    if (res.status != 200 && res.status != 404) {
      throw FirestoreRestException(res.status, res.body);
    }
  }

  Uri _queryUri() => Uri.parse(
        'https://$host/v1/projects/$projectId/databases/(default)/documents:runQuery',
      );

  /// מריץ שאילתה ממוקדת-שדה (`field == value`) על אוסף — הצורה שה-Rules של
  /// לקוח-מסונן מאשרים (למשל הזמנות `contractorUid == uid`). מחזיר `{id, fields}`.
  Future<List<FirestoreRestDoc>> runQuery(
    String collectionId, {
    required String field,
    required String value,
  }) async {
    final body = jsonEncode({
      'structuredQuery': {
        'from': [
          {'collectionId': collectionId},
        ],
        'where': {
          'fieldFilter': {
            'field': {'fieldPath': field},
            'op': 'EQUAL',
            'value': {'stringValue': value},
          },
        },
      },
    });
    final res =
        await request('POST', _queryUri(), _headers(await idToken()), body);
    if (res.status != 200) throw FirestoreRestException(res.status, res.body);
    return _docsFromRunQuery(res.body);
  }

  /// רשימת כל מסמכי-אוסף (GET) — לאוספים שה-Rules מתירים קריאה-מלאה. מחזיר
  /// `{id, fields}` (עמוד ראשון · ‏pageSize).
  Future<List<FirestoreRestDoc>> listDocs(
    String collectionId, {
    int pageSize = 300,
  }) async {
    final uri = Uri.parse(
      'https://$host/v1/projects/$projectId/databases/(default)/documents/'
      '$collectionId?pageSize=$pageSize',
    );
    final res = await request('GET', uri, _headers(await idToken()), null);
    if (res.status == 404) return const [];
    if (res.status != 200) throw FirestoreRestException(res.status, res.body);
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final docs = (map['documents'] as List?) ?? const [];
    return docs
        .map((d) => _docFrom((d as Map).cast<String, dynamic>()))
        .whereType<FirestoreRestDoc>()
        .toList();
  }

  List<FirestoreRestDoc> _docsFromRunQuery(String body) {
    final decoded = jsonDecode(body.isEmpty ? '[]' : body);
    if (decoded is! List) return const [];
    final out = <FirestoreRestDoc>[];
    for (final row in decoded) {
      if (row is Map && row['document'] is Map) {
        final d = _docFrom((row['document'] as Map).cast<String, dynamic>());
        if (d != null) out.add(d);
      }
    }
    return out;
  }

  /// חילוץ `{id, fields}` ממסמך-REST (`name` = הנתיב המלא; ה-id = הסגמנט האחרון).
  FirestoreRestDoc? _docFrom(Map<String, dynamic> doc) {
    final name = (doc['name'] ?? '').toString();
    if (name.isEmpty) return null;
    final id = name.split('/').last;
    final fields =
        decodeFields((doc['fields'] as Map?)?.cast<String, dynamic>() ?? {});
    return FirestoreRestDoc(id, fields);
  }
}

/// מסמך-REST מפוענח — id + שדות (מקביל ל-RemoteDoc של שכבת-המאגרים).
class FirestoreRestDoc {
  const FirestoreRestDoc(this.id, this.fields);
  final String id;
  final Map<String, dynamic> fields;
}
