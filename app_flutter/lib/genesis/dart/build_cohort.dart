// ⚛️ אטום-Dart (דרגת-חוזה) · buildCohort
// תפקיד: בונה RetentionCohort ליום-בסיס — סופר כמה חברים חזרו בכל offset-ימים קדימה.
// מוצא: buildsmart/app_flutter/lib/logic/intel/segments.dart:222-248 (‏_buildCohort; פרטי-במקור; חוק-4).
// אחים: טיפוס-התוצאה RetentionCohort הוטבע inline verbatim (cohortDay/size/returningByDay).
//       אפס שקע — כל החישוב על DateTime/Set/Map סטנדרטיים.
// טוהר: dart:core בלבד.

/// לכל n מ-0 עד maxOffset (=מרחק-הימים הגדול-ביותר של חבר כלשהו מ-[day]),
/// returningByDay[n] = מס' קבוצות-החברים שמכילות את היום day+n.
/// verbatim segments.dart:222-248.
RetentionCohort buildCohort(DateTime day, List<Set<DateTime>> members) {
  var maxOffset = 0;
  for (final days in members) {
    for (final d in days) {
      final offset = d.difference(day).inDays;
      if (offset > maxOffset) maxOffset = offset;
    }
  }
  final returningByDay = <int, int>{};
  for (var n = 0; n <= maxOffset; n++) {
    final target = day.add(Duration(days: n));
    var count = 0;
    for (final days in members) {
      if (days.contains(target)) count++;
    }
    returningByDay[n] = count;
  }
  return RetentionCohort(
    cohortDay: day,
    size: members.length,
    returningByDay: returningByDay,
  );
}

// — טיפוס-התוצאה מוטבע verbatim —
class RetentionCohort {
  const RetentionCohort({
    required this.cohortDay,
    required this.size,
    required this.returningByDay,
  });

  final DateTime cohortDay;
  final int size;
  final Map<int, int> returningByDay;
}
