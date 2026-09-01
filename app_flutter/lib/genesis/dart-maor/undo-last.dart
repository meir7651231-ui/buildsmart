/// חוט · undo-last — ביטול הסיווג-האחרון בקמפיין-שיחות (חזרה לחזית-התור).
/// הומר זהה-ביט מ-new/atoms/undo-last.mjs (חוזה: undo-last.contract.md).
/// השכן REQUEUE_OUTCOMES מוזרק כשקע (חוק-1 — אפס import של אטום אחר).

/// חוק-7 — truthiness של JS: '' / 0 / -0 / NaN / null / false כוזבים.
bool _falsy(dynamic v) =>
    v == null ||
    v == false ||
    (v is num && (v == 0 || v.isNaN)) ||
    v == '';

dynamic undoLast(dynamic c, dynamic requeueOutcomes) {
  final List log = c['log'] as List;
  final dynamic last = log.isEmpty ? null : log[log.length - 1];
  if (_falsy(last)) return c;
  List queue = c['queue'] as List;
  if ((requeueOutcomes as List).contains(last['outcome'])) {
    final int at = queue.lastIndexOf(last['id']);
    queue = at >= 0
        ? [...queue.sublist(0, at), ...queue.sublist(at + 1)]
        : queue;
  }
  return {
    ...(c as Map),
    'queue': [last['id'], ...queue],
    'log': log.sublist(0, log.length - 1),
  };
}
