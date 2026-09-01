// ⚛️ אטום-Dart · encodeValue
// מוצא: buildsmart/app_flutter/lib/data/edge/firestore_rest.dart:27-48 (חצב-בינה · מפל-מינימום · חוק-4).

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

/// מקודד מפת-שדות (`{k: value-typed}`) — גוף ה-PATCH/החזרה. (מוטבע verbatim.)
Map<String, dynamic> encodeFields(Map<String, Object?> data) {
  return data.map((k, v) => MapEntry(k, encodeValue(v)));
}
