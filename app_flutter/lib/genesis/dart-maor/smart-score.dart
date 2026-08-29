// ⚛️ אטום-Dart (דרגת-חוזה) · smartScore — ניקוד רב-מילתי עם AND והרחבת-תעתיקים
// מוצא: maor/src/lib/search.ts (חולץ כלשונו); המקור: new/atoms/smart-score.mjs.
// חוזה: new/atoms/smart-score.contract.md · חוק-4 — התנהגות זהה-ביט ל-JS, לא-משופרת.
// טוהר: פונקציית top-level עצמאית, אפס import של אטום אחר — כל התלויות שקעי-פרמטר
//        (norm · expand(q,norm) · score(q,term)), בדיוק כמו במקור.
//
// תפקיד: מנקד רשימת-מונחים מול שאילתה רב-מילתית — כל מילה חייבת להתאים למונח
//        כלשהו (AND: מילה בלי התאמה ⇒ 0); הציון = סכום הטובות-ביותר פר-מילה, או
//        ציון-הביטוי-השלם (על שאילתה רב-מילתית) — הגבוה מביניהם. כל מילה (וגם
//        הביטוי-השלם) עוברת הרחבת-תעתיקים דרך שקע-expand.
// קלט:  q — שאילתה (String) · terms — מערך-מונחים (Iterable) · שלושת-השקעים.
// פלט:  מספר ≥ 0 (num).
//
// הערות-המרה (מקור→Dart):
// • `split(/\s+/)` ⇒ `split(RegExp(r'\s+'))` — סמנטיקה זהה (כולל '' מוביל על רווח-פותח);
//   `filter(Boolean)` על מחרוזות ⇒ סינון '' בלבד (truthiness-מחרוזת, חוק-7 של הכללים).
// • `if(!toks.length)` / `if(!best)` — truthiness-JS על מספר: falsy ⇔ 0/-0/NaN ⇒
//   עוזר `_falsyNum` מפורש (כלל-7).
// • `Math.max` ⇒ עוזר `_jsMax` נאמן-JS: NaN מדביק, ‎+0 גובר על ‎-0 (dart:math max
//   מחזיר את b בשוויון — סטייה-פוטנציאלית, לכן עוזר מקומי).
// • שרשרת-הקיצור `>= 100` (break כפול) שוכפלה אחד-לאחד — סדר-הקריאות לשקעים זהה.

/// Multi-word AND scoring with transliteration expansion. Verbatim behaviour of
/// the JS source new/atoms/smart-score.mjs (extracted from maor/src/lib/search.ts).
/// Sockets: [norm] (query normaliser), [expand] `(q, norm) => Iterable`
/// (transliteration expansion), [score] `(q, term) => num` (single-pair score).
dynamic smartScore(dynamic q, dynamic terms, dynamic norm, dynamic expand, dynamic score) {
  final toks = (norm(q) as String)
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty) // filter(Boolean) על מחרוזות-split — מסנן '' בלבד
      .toList();
  if (toks.isEmpty) return 0; // if (!toks.length) return 0;
  num phrase = 0;
  if (toks.length > 1) {
    outerPhrase:
    for (final exp in expand(q.trim(), norm)) {
      for (final term in terms) {
        phrase = _jsMax(phrase, score(exp, term));
        if (phrase >= 100) break outerPhrase; // break כפול כמו במקור
      }
    }
  }
  num total = 0;
  for (final tok in toks) {
    num best = 0;
    outerTok:
    for (final exp in expand(tok, norm)) {
      for (final term in terms) {
        best = _jsMax(best, score(exp, term));
        if (best >= 100) break outerTok; // break כפול כמו במקור
      }
    }
    if (_falsyNum(best)) { // if (!best) — truthiness-JS על מספר
      total = 0;
      break;
    }
    total += best;
  }
  return _jsMax(total, phrase);
}

/// JS `Math.max(a,b)` faithful: NaN is contagious; +0 beats -0.
num _jsMax(num a, num b) {
  if (a.isNaN || b.isNaN) return double.nan;
  if (a > b) return a;
  if (b > a) return b;
  // שוויון: JS מעדיף ‎+0 על ‎-0 (Math.max(0,-0) === +0)
  if (a == 0 && a.isNegative && !b.isNegative) return b;
  return a;
}

/// JS number truthiness: falsy ⇔ 0, -0, NaN.
bool _falsyNum(num v) => v == 0 || v.isNaN;
