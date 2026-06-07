// SMART-PROJECT ENGINE (T3.B · proto §7 [L7348-7600]) — the "מאפס עד מסירה"
// day-by-day project view. Each task is flattened into `task.days` day-stages
// (key `<taskId>-<day>`), each independently markable done (no locking — proto
// :7372 "every day is independent"); progress = doneDays / totalDays. With the
// verbatim seed (days 2+1+3+1+2) → 9 day-stages, so progress = done/9.
//
// REUSE: this is the same done-marking pattern as `state/stage_progress.dart`
// (a persisted Set<String> of done keys, toggled per item). stage_progress keys
// install stages per PRODUCT (`<productKey>#<idx>`); this keys day-stages per
// TASK-DAY (`<taskId>-<day>`) and adds the per-step marking (`<taskId>-step<i>`)
// the §7 expandable card needs. Same toggle/doneCount shape, separate prefs key
// so the two never collide.
//
// VERBATIM data: task names/days from `data/persona_data.dart` (`kPersonaTasks`),
// step strings from `data/phaseb_seeds.dart` (`kTaskSteps`), details from
// `state/tasks_engine.dart` (`kTaskDetail`). No string invented (R6/R8).

import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One flattened day-stage — proto `stages.push({task,day,totalDays,key})`
/// (:7384). `key = "<taskId>-<day>"`.
class DayStage {
  const DayStage({
    required this.taskId,
    required this.name,
    required this.detail,
    required this.worker,
    required this.day,
    required this.totalDays,
    required this.steps,
  });

  final int taskId;
  final String name;
  final String detail;
  final int worker;
  final int day;
  final int totalDays;
  final List<String> steps;

  String get key => '$taskId-$day';

  /// Day tag — proto :7397 `totalDays>1 ? 'יום D מתוך N' : 'יום עבודה'`.
  String get dayTag => totalDays > 1 ? 'יום $day מתוך $totalDays' : 'יום עבודה';

  /// Per-step done-key — proto :7349-ish `t.id+'-step'+si`.
  String stepKey(int stepIndex) => '$taskId-step$stepIndex';
}

/// The verbatim flat day-stage list — `TASKS.forEach(... for d in 1..days)`
/// (proto :7382-7388). Built from the existing seeds (R6 reuse). Length = Σdays
/// = 9 with the seed.
List<DayStage> buildDayStages() => [
      for (final t in kPersonaTasks)
        for (var d = 1; d <= (t.days < 1 ? 1 : t.days); d++)
          DayStage(
            taskId: t.id,
            name: t.name,
            detail: kTaskDetail[t.id] ?? '',
            worker: t.worker,
            day: d,
            totalDays: t.days < 1 ? 1 : t.days,
            steps: kTaskSteps[t.id] ?? const [],
          ),
    ];

/// The marked-done keys — day-stage keys (`<taskId>-<day>`) AND step keys
/// (`<taskId>-step<i>`) share one persisted Set (distinct namespaces). Mirrors
/// `stage_progress.dart` exactly, separate prefs key.
class SmartProjectNotifier extends StateNotifier<Set<String>> {
  SmartProjectNotifier({this.persist = true}) : super(const {}) {
    if (persist) _load();
  }

  final bool persist;
  static const _key = 'bs.smart-project.v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key);
      if (list != null) state = list.toSet();
    } on Object catch (_) {}
  }

  Future<void> _persist() async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, state.toList());
    } on Object catch (_) {}
  }

  bool isDone(String key) => state.contains(key);

  /// toggleSmartDay / toggleSmartStep (proto :7430 / :7435) — flip a key.
  void toggle(String key) {
    state = state.contains(key)
        ? ({...state}..remove(key))
        : {...state, key};
    _persist();
  }

  void reset() {
    state = const {};
    _persist();
  }
}

final smartProjectProvider =
    StateNotifierProvider<SmartProjectNotifier, Set<String>>(
  (ref) => SmartProjectNotifier(),
);

/// Project progress — `{done, total, pct}` over the day-stages (proto
/// :7390-7392). pct = round(done/total*100). Derived LIVE off the done set.
final smartProjectProgressProvider =
    Provider<({int done, int total, int pct})>((ref) {
  final done = ref.watch(smartProjectProvider);
  final stages = buildDayStages();
  final total = stages.length;
  final doneCount = stages.where((s) => done.contains(s.key)).length;
  final pct = total == 0 ? 0 : (doneCount / total * 100).round();
  return (done: doneCount, total: total, pct: pct);
});

/// Pure progress helper (testable without the provider) — done/total/pct over
/// [doneKeys]. Mirrors proto :7390-7392.
({int done, int total, int pct}) smartProjectProgress(Set<String> doneKeys) {
  final stages = buildDayStages();
  final total = stages.length;
  final done = stages.where((s) => doneKeys.contains(s.key)).length;
  final pct = total == 0 ? 0 : (done / total * 100).round();
  return (done: done, total: total, pct: pct);
}
