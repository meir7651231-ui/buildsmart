// ⚛️ אטום-Dart · validIsraeliId — ספרת-ביקורת ת"ז ישראלי (Luhn). מקור: validate.ts, חוק-4.
bool validIsraeliId(dynamic id) {
  final s = id.toString().trim();
  if (!RegExp(r'^\d{5,9}$').hasMatch(s)) return false;
  if (!RegExp(r'[1-9]').hasMatch(s)) return false; // אפסים-בלבד לא-תקין
  final p = s.padLeft(9, '0');
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    var d = int.parse(p[i]) * (i % 2 == 0 ? 1 : 2);
    if (d > 9) d -= 9;
    sum += d;
  }
  return sum % 10 == 0;
}
