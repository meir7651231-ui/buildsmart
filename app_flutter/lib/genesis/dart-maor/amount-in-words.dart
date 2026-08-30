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


/// מילות המספר 1..999 כמערך (בלי ו׳ חיברת — מתווספת בסוף).
List<String> _words0_999(int n, List<String> ONES, List<String> TEENS, List<String> TENS, List<String> HUNDREDS) {
  final out = <String>[];
  final h = (n / 100).floor();
  final rem = n % 100;
  if (h != 0) out.add(HUNDREDS[h]);
  if (rem != 0) {
    if (rem < 10) {
      out.add(ONES[rem]);
    } else if (rem < 20) {
      out.add(TEENS[rem - 10]);
    } else {
      final t = (rem / 10).floor();
      final u = rem % 10;
      out.add(TENS[t]);
      if (u != 0) out.add(ONES[u]);
    }
  }
  return out;
}

/// מילות האלפים (מספר האלפים 1..999) — סמיכות ל-3..10, אחרת מספר + "אלף/אלפים".
List<String> _thousandWords(int th, List<String> ONES, List<String> TEENS, List<String> TENS, List<String> HUNDREDS, Map<String, String> THOUSAND_CONSTRUCT, Map<String, dynamic> T) {
  final Map<int, String> _THOUSAND_CONSTRUCT = {
  3: THOUSAND_CONSTRUCT['3']!, 4: THOUSAND_CONSTRUCT['4']!, 5: THOUSAND_CONSTRUCT['5']!, 6: THOUSAND_CONSTRUCT['6']!, 7: THOUSAND_CONSTRUCT['7']!, 8: THOUSAND_CONSTRUCT['8']!, 9: THOUSAND_CONSTRUCT['9']!, 10: THOUSAND_CONSTRUCT['10']!,
};
  if (th == 1) return [(T['k1'] as String)];
  if (th == 2) return [(T['k2'] as String)];
  final c = _THOUSAND_CONSTRUCT[th];
  if (c != null) return ['$c${(T['k3'] as String)}'];
  return ['${_joinHeb(_words0_999(th, ONES, TEENS, TENS, HUNDREDS), T)}${(T['k4'] as String)}'];
}

/// מילות אגורות 1..99 בצורת-נקבה (סמיכות עשרות+יחידות; היחידה במין נקבה).
String _agorotWords(int n, List<String> TENS, List<String> ONES_F, List<String> TEENS_F, Map<String, dynamic> T) {
  if (n < 10) return ONES_F[n];
  if (n < 20) return TEENS_F[n - 10];
  final t = (n / 10).floor();
  final u = n % 10;
  return u != 0 ? '${TENS[t]}${(T['k5'] as String)}${ONES_F[u]}' : TENS[t];
}

/// ביטוי האגורות המלא (נקבה): "אגורה אחת" / "שתי אגורות" / "<מספר> אגורות".
String _agorotPhrase(int n, List<String> TENS, List<String> ONES_F, List<String> TEENS_F, Map<String, dynamic> T) {
  if (n == 1) return (T['k6'] as String);
  if (n == 2) return (T['k7'] as String);
  return '${_agorotWords(n, TENS, ONES_F, TEENS_F, T)}${(T['k8'] as String)}';
}

/// מחבר רשימת מילים עם ו׳ חיברת לפני האחרונה (אם יש ≥2).
String _joinHeb(List<String> words, Map<String, dynamic> T) {
  final w = words.where((x) => x.isNotEmpty).toList();
  if (w.length == 0) return '';
  if (w.length == 1) return w[0];
  return '${w.sublist(0, w.length - 1).join(' ')}${(T['k5'] as String)}${w[w.length - 1]}';
}

/// המספר השלם במילים (0..999,999,999). null אם מחוץ לטווח.
String? _integerInWords(num n, List<String> ONES, List<String> TEENS, List<String> TENS, List<String> HUNDREDS, Map<String, String> THOUSAND_CONSTRUCT, Map<String, dynamic> T) {
  if (!n.isFinite || n < 0 || n > 999999999 || n.floor() != n) return null;
  if (n == 0) return (T['k9'] as String);
  final ni = n.toInt();
  final millions = (ni / 1000000).floor();
  final thousands = ((ni % 1000000) / 1000).floor();
  final rest = ni % 1000;
  final groups = <String>[];
  if (millions != 0) {
    if (millions == 1) {
      groups.add((T['k10'] as String));
    } else if (millions == 2) {
      groups.add((T['k11'] as String));
    } else {
      groups.add('${_joinHeb(_words0_999(millions, ONES, TEENS, TENS, HUNDREDS), T)}${(T['k12'] as String)}');
    }
  }
  if (thousands != 0) groups.addAll(_thousandWords(thousands, ONES, TEENS, TENS, HUNDREDS, THOUSAND_CONSTRUCT, T));
  if (rest != 0) groups.addAll(_words0_999(rest, ONES, TEENS, TENS, HUNDREDS));
  return _joinHeb(groups, T);
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
String amountInWords(dynamic amount, List<String> ONES, List<String> TEENS, List<String> TENS, List<String> HUNDREDS, List<String> ONES_F, List<String> TEENS_F, Map<String, String> THOUSAND_CONSTRUCT, Map<String, dynamic> T, [dynamic currency = '₪']) {
  if (!(amount is num && amount.isFinite) || amount < 0) return amount.toString();
  final num amt = amount;
  final Map<String, String> shekelWord = currency == '\$'
      ? {'one': (T['k13'] as String), 'many': (T['k14'] as String), 'agName': (T['k15'] as String)}
      : {'one': (T['k16'] as String), 'many': (T['k17'] as String), 'agName': (T['k18'] as String)};
  var whole = amt.floor();
  var agorot = ((amt - whole) * 100).round();
  // 🐛 נחיל-9×9 (13.8): גלישת-עיגול — שבר ≥.995 עיגל אגורות ל-100. נשיאה לשקל השלם.
  if (agorot == 100) {
    whole += 1;
    agorot = 0;
  }
  final wholeWords = _integerInWords(whole, ONES, TEENS, TENS, HUNDREDS, THOUSAND_CONSTRUCT, T);
  if (wholeWords == null) {
    // fallback בטוח לספרות
    return '$currency${_localeGroup(amt)}';
  }
  String s;
  if (whole == 1) {
    s = shekelWord['one']!;
  } else if (whole == 0) {
    s = '${(T['k19'] as String)}${shekelWord['many']}';
  }
  // 🐛 נחיל-עמוק (13.8): 2 בצורת-סמיכות "שני שקלים"/"שני דולרים" (הכרעת-בעלים).
  else if (whole == 2) {
    s = '${(T['k20'] as String)}${shekelWord['many']}';
  } else {
    s = '$wholeWords ${shekelWord['many']}';
  }
  if (agorot > 0) {
    if (currency == '₪') {
      // אגורה נקבה — מספר בצורת-נקבה + יחיד/סמיכות ("שתי אגורות").
      s += '${(T['k21'] as String)}${_agorotPhrase(agorot, TENS, ONES_F, TEENS_F, T)}';
    } else {
      // סנט זכר — צורת-הזכר של integerInWords מתאימה.
      final agWords = _integerInWords(agorot, ONES, TEENS, TENS, HUNDREDS, THOUSAND_CONSTRUCT, T);
      s += '${(T['k21'] as String)}${agWords ?? agorot} ${shekelWord['agName']}';
    }
  }
  return s;
}
