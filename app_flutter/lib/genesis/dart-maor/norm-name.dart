// ⚛️ אטום-Dart · normName — נירמול-שם (normSearch כשקע, חוק-3). מקור: validate.ts.
String normName(dynamic t, String Function(dynamic) normSearch) =>
    normSearch(t).replaceAll(RegExp(r'\s'), '');
