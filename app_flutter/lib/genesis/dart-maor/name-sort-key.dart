// ⚛️ אטום-Dart · nameSortKey — מפתח-שם חסין-סדר (normSearch+nameTitles שקעים). מקור: validate.ts.
String nameSortKey(dynamic t, String Function(dynamic) normSearch, Set<String> nameTitles) {
  final tokens = normSearch(t)
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !nameTitles.contains(w))
      .toList();
  tokens.sort();
  return tokens.join(' ');
}
