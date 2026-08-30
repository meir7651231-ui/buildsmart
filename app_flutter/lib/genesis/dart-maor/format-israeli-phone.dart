// ⚛️ אטום-Dart · formatIsraeliPhone — עיצוב טלפון ישראלי. מקור: validate.ts, חוק-4.
String formatIsraeliPhone(dynamic raw) {
  final s = (raw ?? '').toString().trim();
  var d = s.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('00972')) d = '0' + d.substring(5);
  else if (d.startsWith('972')) d = '0' + d.substring(3);
  if (d.isEmpty) return s;
  if (d[0] == '0') {
    if (d.length == 10) return d.substring(0, 3) + '-' + d.substring(3);
    if (d.length == 9) return d.substring(0, 2) + '-' + d.substring(2);
    return d;
  }
  if (d.length == 9) return '0' + d.substring(0, 2) + '-' + d.substring(2);
  if (d.length == 8) return '0' + d[0] + '-' + d.substring(1);
  return s;
}
