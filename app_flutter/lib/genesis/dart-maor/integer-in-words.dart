// חוט · integer-in-words — מספר שלם 0..999,999,999 במילים עבריות (זכר — לקבלת §46).
// חוזה: integer-in-words.contract.md
// המרה מ-JS (new/atoms/integer-in-words.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// שלושת השכנים — joinHeb · words0_999 · thousandWords — מוזרקים כשקעים (חוק-1 — אפס import פנימי).
// אפס-import (dart-core בלבד). null מוחזר על קלט לא-חוקי (מקביל ל-return null של JS).
String? integerInWords(
  num n,
  String Function(List<String>) joinHeb,
  List<String> Function(int) words0_999,
  List<String> Function(int) thousandWords,
 {required String Function(String) term}) {
  // !Number.isFinite(n) || n < 0 || n > 999_999_999 || Math.floor(n) !== n ⇒ null
  if (!n.isFinite || n < 0 || n > 999999999 || n.floor() != n) return null;
  final v = n.toInt();
  if (v == 0) return term('aps');
  final millions = v ~/ 1000000;
  final thousands = (v % 1000000) ~/ 1000;
  final rest = v % 1000;
  final groups = <String>[];
  if (millions != 0) {
    if (millions == 1) {
      groups.add(term('mylyvn'));
    } else if (millions == 2) {
      groups.add(term('shny-mylyvn'));
    } else {
      // איבר אחד — אותו באג-דפוס כמו באלפים ("שמונה עשר ומיליון")
      groups.add('${joinHeb(words0_999(millions))}${term('xi_mylyvn')}');
    }
  }
  if (thousands != 0) groups.addAll(thousandWords(thousands));
  if (rest != 0) groups.addAll(words0_999(rest));
  return joinHeb(groups);
}
