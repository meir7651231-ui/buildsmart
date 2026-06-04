// Verbatim worker-persona demo data (role-app T9).
//
// Source of truth: app_flutter/knowledge/port/proto/06-personas-engine-selftest.md
// §4.1 TASKS [L8023] + WORKERS [L8021] + taskStatusInfo [L8048], mirrored in
// knowledge/port/preact/03-persona-dashboards.md §3.2. Every Hebrew string and
// number is verbatim from the prototype — do NOT invent (R6/R8).

/// One field-crew task — mirrors the prototype `TASKS[i]`
/// `{id, name, worker, status, days, steps, note}`.
class PersonaTask {
  const PersonaTask({
    required this.id,
    required this.name,
    required this.worker,
    required this.status,
    required this.days,
    required this.steps,
    this.note = '',
    this.orderId,
  });

  final int id;
  final String name;

  /// Index into [kWorkers].
  final int worker;

  /// pending · active · review · done · rejected (taskStatusInfo keys).
  final String status;
  final int days;
  final int steps;
  final String note;

  /// Optional link to a shared-engine order (`Order.id`, e.g. `BS-1040`). When a
  /// linked task is APPROVED by the manager, the bound order is advanced one
  /// stage on the shared `ordersEngineProvider` — so a completed install also
  /// moves that order live. Null for tasks with no order binding (the default).
  final String? orderId;

  /// Copy with a changed [status] (the only field the live worker-tasks engine
  /// mutates) — mirrors the `Order.copyWith` shape used by the orders engine.
  PersonaTask copyWith({String? status}) => PersonaTask(
        id: id,
        name: name,
        worker: worker,
        status: status ?? this.status,
        days: days,
        steps: steps,
        note: note,
        orderId: orderId,
      );
}

/// @source proto 06 [L8021].
const List<String> kWorkers = ['רן (עובד)', 'עומר (עובד)'];

/// @source proto 06 §4.1 TASKS [L8023] — 5 demo tasks, verbatim.
const List<PersonaTask> kPersonaTasks = [
  PersonaTask(
    id: 1,
    name: 'התקנת קו מים חם — חדר רחצה',
    worker: 0,
    status: 'active',
    days: 2,
    steps: 4,
  ),
  PersonaTask(
    id: 2,
    name: 'הרכבת מיכל הדחה סמוי',
    worker: 0,
    status: 'pending',
    days: 1,
    steps: 4,
  ),
  PersonaTask(
    id: 3,
    name: 'איטום רצפת מקלחת',
    worker: 1,
    status: 'review',
    days: 3,
    steps: 6,
    note: 'בוצע — שכבה שנייה תתייבש מחר',
    // Bound to the seed order BS-1040 (stage `ready`): approving this install
    // also advances that order one stage on the shared engine (ready → pickup).
    orderId: 'BS-1040',
  ),
  PersonaTask(
    id: 4,
    name: 'התקנת נקזון רצפה',
    worker: 1,
    status: 'done',
    days: 1,
    steps: 3,
    note: 'הושלם ונבדק',
  ),
  PersonaTask(
    id: 5,
    name: 'חיבור ברז כיור + ברזי ניל',
    worker: 0,
    status: 'pending',
    days: 2,
    steps: 4,
  ),
];

/// Verbatim status badge (emoji + label) — `taskStatusInfo` [L8048].
const Map<String, String> kTaskStatusLabel = {
  'pending': '⏳ ממתינה',
  'active': '🔨 בביצוע',
  'review': '📸 ממתין לאישור',
  'done': '✅ אושר ✓',
  'rejected': '↩️ נדחה — לתקן',
};

/// All tasks assigned to [worker].
List<PersonaTask> tasksForWorker(int worker) =>
    kPersonaTasks.where((t) => t.worker == worker).toList();

/// Tasks of [worker] whose status is in [statuses] — the bucket filter
/// (current = active|rejected · queue = pending · submitted = review|done).
List<PersonaTask> tasksFor(int worker, Set<String> statuses) =>
    kPersonaTasks
        .where((t) => t.worker == worker && statuses.contains(t.status))
        .toList();

/// Display name — `שלום, {name}` strips the trailing ` (עובד)` (§4.2).
String workerShortName(int worker) =>
    kWorkers[worker].replaceAll(' (עובד)', '');
