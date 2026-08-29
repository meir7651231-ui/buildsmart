// ⚛️ אטום-Dart · decodeValue
// מוצא: buildsmart/app_flutter/lib/data/edge/firestore_rest.dart:49-76 (חצב-בינה · מפל-מינימום · חוק-4).

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

/// מפענח מפת-שדות של מסמך חזרה ל-`Map<String,dynamic>`. (מוטבע verbatim.)
Map<String, dynamic> decodeFields(Map<String, dynamic> fields) {
  return fields.map(
    (k, v) => MapEntry(k, decodeValue((v as Map).cast<String, dynamic>())),
  );
}
