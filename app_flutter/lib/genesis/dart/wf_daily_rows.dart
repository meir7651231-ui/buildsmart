// ⚛️ אטום-Dart · wfDailyRows
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:266-304 (חצב-בינה · מפל-מינימום · חוק-4).

/// קונפיג-ארגון — אטום (עובר רק לשקעי-התוויות; לא נקרא כאן).
class OrgConfig {
  const OrgConfig();
}

/// שלב-workflow — טיפוס-אטום לשדה `stage` (עובר לשקע `wfStageLabel` בלבד).
enum WfStage { newq, done }

/// רשומת-log של כמות ליום. (מוטבע-מינימום.)
class WfLog {
  const WfLog({required this.date, required this.units});
  final String date;
  final int units;
}

/// שם תחת מקרה. (מוטבע-מינימום.)
class WfName {
  const WfName({required this.name, this.units, this.done = false});
  final String name;
  final int? units;
  final bool done;
}

/// מקרה-workflow (מוטבע-מינימום — רק השדות שהדוח נוגע בהם).
class WfCase {
  const WfCase({
    required this.stage,
    required this.lastTouch,
    required this.nextTouch,
    required this.note,
    this.log = const [],
    this.names = const [],
  });
  final WfStage stage;
  final String lastTouch;
  final String nextTouch;
  final String note;
  final List<WfLog> log;
  final List<WfName> names;
}

/// דוח "טופל-היום": שורות-כותרת + מקרה-לכל-מי-שנגע-היום (lastTouch או log-היום).
/// שקעים (תלויי-קונפיג): [unitLabel]/[itemLabel] תוויות · [stageLabel] שם-שלב ·
/// [unitsTotal] סך-יחידות-המקרה.
List<List<Object>> wfDailyRows(
  OrgConfig cfg,
  List<({String name, String phone, WfCase? wf})> entities,
  String todayIso, {required String Function(String) term, 
  required String Function(OrgConfig) unitLabel,
  required String Function(OrgConfig) itemLabel,
  required String Function(OrgConfig, WfStage) stageLabel,
  required int Function(WfCase) unitsTotal,
}) {
  final unit = unitLabel(cfg);
  final item = itemLabel(cfg);
  final rows = <List<Object>>[
    [term('shm'), term('tlpvn'), '$unit${term('xi_hyvm')}', term('shlb'), item, term('mty-ldbr-shvb'), term('harh')],
  ];
  for (final e in entities) {
    final a = e.wf;
    if (a == null) continue;
    final touched =
        a.lastTouch == todayIso || a.log.any((l) => l.date == todayIso);
    if (!touched) continue;
    final logToday = a.log.where((l) => l.date == todayIso).toList();
    final unitsToday = logToday.isNotEmpty
        ? logToday.fold<int>(0, (t, l) => t + l.units)
        : (unitsTotal(a) == 0 ? '' : unitsTotal(a));
    final namesLine = a.names
        .map((n) =>
            n.name + (n.units != null ? ' ·${n.units}' : '') + (n.done ? ' ✓' : ''))
        .join(' · ');
    rows.add([
      e.name,
      e.phone,
      unitsToday,
      stageLabel(cfg, a.stage),
      namesLine,
      a.nextTouch,
      a.note,
    ]);
  }
  return rows;
}
