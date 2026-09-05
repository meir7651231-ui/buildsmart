/// חוט · collection-score-delta — דלתת-ניקוד על ריקון קופת-צדקה.
/// המרה נאמנה מ-new/atoms/collection-score-delta.mjs (חוק-4: המקור קדוש).
/// השכן lastCollectionIso הוזרק כשקע (חוק-1 — אפס import). אפס import חיצוני.
///
/// כללי-המרה שהוחלו (DART-PORTING-RULES):
///  • truthiness (#7): JS `if(prev)` על מחרוזת ⇒ `prev.isNotEmpty` (‏'' = falsy).
///  • Math.floor על חילוק-double: `(amount / ilsPerPoint).floor()`.
///  • Math.round נאמן: `(x + 0.5).floor()` = Math.round גם לשליליים.
num collectionScoreDelta(
  dynamic box,
  String date,
  num amount,
  String Function(dynamic) lastCollectionIso, [
  Map<String, num>? rules,
]) {
  final r = rules ??
      const {'emptyPts': 10, 'ilsPerPoint': 50, 'streakDays': 60, 'streakPts': 5};
  var pts = r['emptyPts']! + (amount / r['ilsPerPoint']!).floor();
  final prev = lastCollectionIso(box);
  if (prev.isNotEmpty) {
    final ms = DateTime.parse('${date}T12:00:00').millisecondsSinceEpoch -
        DateTime.parse('${prev}T12:00:00').millisecondsSinceEpoch;
    final days = (ms / 86400000 + 0.5).floor(); // Math.round נאמן
    if (days >= 0 && days <= r['streakDays']!) pts += r['streakPts']!;
  }
  return pts;
}
