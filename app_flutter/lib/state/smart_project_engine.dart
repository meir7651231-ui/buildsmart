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
import 'package:buildsmart/data/projects.dart';
import 'package:buildsmart/state/projects_engine.dart';
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
///
/// Scoped PER PROJECT: every project runs the same seed day-stages, so the
/// done-set must be keyed by project or a day marked in PRJ-1 would show as
/// done in PRJ-2 too. The seed-active project ([kActiveProjectId]) keeps the
/// original prefs key, so marks saved before the scoping stay where they were
/// (no migration); every other project gets `<v1 key>.<projectId>`.
class SmartProjectNotifier extends StateNotifier<Set<String>> {
  SmartProjectNotifier({this.persist = true, this.projectId = kActiveProjectId})
      : super(const {}) {
    if (persist) _load();
  }

  final bool persist;

  /// The project whose done-set this notifier holds.
  final String projectId;

  static const _baseKey = 'bs.smart-project.v1';

  /// Prefs key for [projectId] — legacy key for the seed-active project.
  static String prefsKeyFor(String projectId) =>
      projectId == kActiveProjectId ? _baseKey : '$_baseKey.$projectId';

  String get _key => prefsKeyFor(projectId);

  /// True once any mutation has been applied (or _load completes).
  /// Guards against _load clobbering a mutation that arrived before prefs.
  bool _loaded = false;

  // Setter does NOT persist — the mutators (toggle/reset) persist explicitly
  // (the cart_lists shape; `_persist` is also a no-op when `persist` is false),
  // so we only flag the load-guard here.
  @override
  set state(Set<String> value) {
    _loaded = true; // mutation happened — block any pending _load
    super.state = value;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key);
      if (list != null && !_loaded) {
        super.state = list.toSet(); // bypass setter so we don't re-persist on load
        _loaded = true;
      } else {
        _loaded = true;
      }
    } on Object catch (_) {
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    if (!persist) return;
    // Snapshot BEFORE the await: switching project disposes this notifier, and
    // reading `state` after dispose would throw and drop the write.
    final snapshot = state.toList();
    final key = _key;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, snapshot);
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

/// The ACTIVE project's done-set. Rebuilt on project switch (watches only the
/// active id), so every consumer — the §7 screen, the progress bar, the
/// worker's today strip — reads and toggles the current project's marks.
final smartProjectProvider =
    StateNotifierProvider<SmartProjectNotifier, Set<String>>(
  (ref) => SmartProjectNotifier(
    projectId: ref.watch(activeProjectProvider.select((p) => p.id)),
  ),
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
