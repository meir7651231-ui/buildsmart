// ⚛️ אטום-Dart (דרגת-חוזה) · amountInWords — סכום-בעברית-במילים
// מוצא: maor/src/lib/hebrewNumber.ts:101-136 · המקור-הטהור: new/atoms/amount-in-words.mjs
//        (חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת; המקור קדוש).
// טוהר: פונקציות top-level עצמאיות, אפס import (רק dart-core). השכנים הטהורים
//        (integerInWords · agorotPhrase + עוזריהם) מוטמעים כפונקציות-מודול פרטיות
//        (חוק-1, כמו במקור-ה-JS) — אינם מיוצאים.
//
// תיקוני-המרה (המנוע פספס — תוקנו מול המקור):
//   • truthiness: JS `if (h)`/`if (rem)`/`u ? …` ⇒ Dart `if (h != 0)` (0 אינו falsy ב-Dart).
//   • Number.isFinite: ב-JS false לכל לא-מספר ⇒ `_isFinite = n is num && n.isFinite`.
//   • String(amount): fallback לא-מספרי ⇒ `amount.toString()` (מחרוזת חוזרת כמות-שהיא).
//   • spread groups.push(...) ⇒ addAll; words.filter(Boolean) ⇒ where(ריק/undefined יוצא).
//   • slice(0,-1) ⇒ sublist(0, len-1); object.key ⇒ Map['key'].
//   • THOUSAND_CONSTRUCT מפתחות-int ⇒ Map<int,String> (JS מקהה index מספרי למחרוזת).
//   • toLocaleString('he-IL') (ענף בלתי-נגיש: whole>999,999,999) ⇒ קיבוץ-פסיקים בסיסי.
//   • מוטביליות: whole/agorot = משתני-var (מוקצים-מחדש); הקבועים = final.

const List<String> _ONES = ['', 'אחד', 'שניים', 'שלושה', 'ארבעה', 'חמישה', 'שישה', 'שבעה', 'שמונה', 'תשעה'];
const List<String> _TEENS = ['עשרה', 'אחד עשר', 'שנים עשר', 'שלושה עשר', 'ארבעה עשר', 'חמישה עשר', 'שישה עשר', 'שבעה עשר', 'שמונה עשר', 'תשעה עשר'];
const List<String> _TENS = ['', '', 'עשרים', 'שלושים', 'ארבעים', 'חמישים', 'שישים', 'שבעים', 'שמונים', 'תשעים'];
const List<String> _HUNDREDS = ['', 'מאה', 'מאתיים', 'שלוש מאות', 'ארבע מאות', 'חמש מאות', 'שש מאות', 'שבע מאות', 'שמונה מאות', 'תשע מאות'];
const List<String> _ONES_F = ['', 'אחת', 'שתיים', 'שלוש', 'ארבע', 'חמש', 'שש', 'שבע', 'שמונה', 'תשע'];
const List<String> _TEENS_F = ['עשר', 'אחת עשרה', 'שתים עשרה', 'שלוש עשרה', 'ארבע עשרה', 'חמש עשרה', 'שש עשרה', 'שבע עשרה', 'שמונה עשרה', 'תשע עשרה'];
const Map<int, String> _THOUSAND_CONSTRUCT = {
  3: 'שלושת', 4: 'ארבעת', 5: 'חמשת', 6: 'ששת', 7: 'שבעת', 8: 'שמונת', 9: 'תשעת', 10: 'עשרת',
};

/// מילות המספר 1..999 כמערך (בלי ו׳ חיברת — מתווספת בסוף).
List<String> _words0_999(int n) {
  final out = <String>[];
  final h = (n / 100).floor();
  final rem = n % 100;
  if (h != 0) out.add(_HUNDREDS[h]);
  if (rem != 0) {
    if (rem < 10) {
      out.add(_ONES[rem]);
    } else if (rem < 20) {
      out.add(_TEENS[rem - 10]);
    } else {
      final t = (rem / 10).floor();
      final u = rem % 10;
      out.add(_TENS[t]);
      if (u != 0) out.add(_ONES[u]);
    }
  }
  return out;
}

/// מילות האלפים (מספר האלפים 1..999) — סמיכות ל-3..10, אחרת מספר + "אלף/אלפים".
List<String> _thousandWords(int th) {
  if (th == 1) return ['אלף'];
  if (th == 2) return ['אלפיים'];
  final c = _THOUSAND_CONSTRUCT[th];
  if (c != null) return ['$c אלפים'];
  return ['${_joinHeb(_words0_999(th))} אלף'];
}

/// מילות אגורות 1..99 בצורת-נקבה (סמיכות עשרות+יחידות; היחידה במין נקבה).
String _agorotWords(int n) {
  if (n < 10) return _ONES_F[n];
  if (n < 20) return _TEENS_F[n - 10];
  final t = (n / 10).floor();
  final u = n % 10;
  return u != 0 ? '${_TENS[t]} ו${_ONES_F[u]}' : _TENS[t];
}

/// ביטוי האגורות המלא (נקבה): "אגורה אחת" / "שתי אגורות" / "<מספר> אגורות".
String _agorotPhrase(int n) {
  if (n == 1) return 'אגורה אחת';
  if (n == 2) return 'שתי אגורות';
  return '${_agorotWords(n)} אגורות';
}

/// מחבר רשימת מילים עם ו׳ חיברת לפני האחרונה (אם יש ≥2).
String _joinHeb(List<String> words) {
  final w = words.where((x) => x.isNotEmpty).toList();
  if (w.length == 0) return '';
  if (w.length == 1) return w[0];
  return '${w.sublist(0, w.length - 1).join(' ')} ו${w[w.length - 1]}';
}

/// המספר השלם במילים (0..999,999,999). null אם מחוץ לטווח.
String? _integerInWords(num n) {
  if (!n.isFinite || n < 0 || n > 999999999 || n.floor() != n) return null;
  if (n == 0) return 'אפס';
  final ni = n.toInt();
  final millions = (ni / 1000000).floor();
  final thousands = ((ni % 1000000) / 1000).floor();
  final rest = ni % 1000;
  final groups = <String>[];
  if (millions != 0) {
    if (millions == 1) {
      groups.add('מיליון');
    } else if (millions == 2) {
      groups.add('שני מיליון');
    } else {
      groups.add('${_joinHeb(_words0_999(millions))} מיליון');
    }
  }
  if (thousands != 0) groups.addAll(_thousandWords(thousands));
  if (rest != 0) groups.addAll(_words0_999(rest));
  return _joinHeb(groups);
}

/// קיבוץ-פסיקים בסיסי (תחליף toLocaleString('he-IL') — ענף-נפילה בלתי-נגיש בטווח-הזהב).
String _localeGroup(num amount) {
  final neg = amount < 0;
  final abs = neg ? -amount : amount;
  final whole = abs.floor();
  final digits = whole.toString();
  final buf = StringBuffer();
  final len = digits.length;
  for (var i = 0; i < len; i++) {
    if (i != 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  var out = buf.toString();
  final frac = abs - whole;
  if (frac != 0) {
    var f = (frac * 1000).round().toString().padLeft(3, '0');
    f = f.replaceFirst(RegExp(r'0+$'), '');
    if (f.isNotEmpty) out = '$out.$f';
  }
  return neg ? '-$out' : out;
}

/// סכום במילים בעברית. התנהגות זהה-ביט למקור new/atoms/amount-in-words.mjs.
/// [amount] דינמי (מספר מטופל; לא-מספר/שלילי ⇒ toString כמות-שהוא — כמו Number.isFinite ב-JS).
/// [currency] '₪' (ברירת-מחדל) או '$'.
String amountInWords(dynamic amount, [dynamic currency = '₪']) {
  if (!(amount is num && amount.isFinite) || amount < 0) return amount.toString();
  final num amt = amount;
  final Map<String, String> shekelWord = currency == '\$'
      ? {'one': 'דולר אחד', 'many': 'דולרים', 'agName': 'סנט'}
      : {'one': 'שקל אחד', 'many': 'שקלים', 'agName': 'אגורות'};
  var whole = amt.floor();
  var agorot = ((amt - whole) * 100).round();
  // 🐛 נחיל-9×9 (13.8): גלישת-עיגול — שבר ≥.995 עיגל אגורות ל-100. נשיאה לשקל השלם.
  if (agorot == 100) {
    whole += 1;
    agorot = 0;
  }
  final wholeWords = _integerInWords(whole);
  if (wholeWords == null) {
    // fallback בטוח לספרות
    return '$currency${_localeGroup(amt)}';
  }
  String s;
  if (whole == 1) {
    s = shekelWord['one']!;
  } else if (whole == 0) {
    s = 'אפס ${shekelWord['many']}';
  }
  // 🐛 נחיל-עמוק (13.8): 2 בצורת-סמיכות "שני שקלים"/"שני דולרים" (הכרעת-בעלים).
  else if (whole == 2) {
    s = 'שני ${shekelWord['many']}';
  } else {
    s = '$wholeWords ${shekelWord['many']}';
  }
  if (agorot > 0) {
    if (currency == '₪') {
      // אגורה נקבה — מספר בצורת-נקבה + יחיד/סמיכות ("שתי אגורות").
      s += ' ו-${_agorotPhrase(agorot)}';
    } else {
      // סנט זכר — צורת-הזכר של integerInWords מתאימה.
      final agWords = _integerInWords(agorot);
      s += ' ו-${agWords ?? agorot} ${shekelWord['agName']}';
    }
  }
  return s;
}
