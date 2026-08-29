/// חוט · weighted-quote — תמחור-משוקלל: שיעורים×מחיר-לשיעור, עיגול חצי-שיעור/שקל.
/// חוזה: weighted-quote.contract.md · מקור-אמת: new/atoms/weighted-quote.mjs
/// השכנים lessonPriceForTier/lessonsInTerm הוזרקו כשקעים (חוק-1 — אפס import פנימי).

/// שיקוף Math.round של JS: הקרוב-ביותר, חצי-בדיוק ⇒ כלפי +אינסוף
/// (בשונה מ-round() של Dart שמעגל חצי הרחק-מאפס).
num _jsRound(num x) {
  final d = x.toDouble();
  if (d.isNaN || d.isInfinite) return d;
  final f = d.floorToDouble();
  final diff = d - f;
  if (diff < 0.5) return f;
  return f + 1; // diff ≥ 0.5 ⇒ מעלה (כולל שוויון-חצי)
}

Map<String, dynamic> weightedQuote(
    dynamic c, dynamic opts, dynamic lessonPriceForTier, dynamic lessonsInTerm) {
  final perLesson = lessonPriceForTier(c, opts['tier']);
  final raw = lessonsInTerm(opts['freq'], opts['unit'], opts['term'], opts['months']);
  return {
    'lessons': _jsRound(raw.toDouble() * 2) / 2,
    'perLesson': perLesson,
    'total': _jsRound(raw.toDouble() * perLesson.toDouble()),
  };
}
