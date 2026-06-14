import 'dart:convert';

import 'package:buildsmart/state/board_auth.dart' show kDemoContractorId;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// cluster #85ח · תיק בטיחות → הדרכות — the worker's safety-training log:
/// each [WorkerTraining] is a course the worker took (title / by / date), with
/// an optional uploaded certificate [WorkerTraining.doc] and a [WorkerTraining.status]
/// lifecycle (נרשם → ממתין-לאישור → אושר). The worker records a training and
/// can send it for the safety officer's approval; the approval flip is a
/// SERVER-SWAP placeholder until the backend's training registry lands.
///
/// HONEST: there is no server-side training registry yet, so a FRESH (empty)
/// store is seeded with 3 clearly-tagged DEMO rows (the screen labels them as
/// a demo); they stay removable. אין המצאות beyond that explicit demo seed.
///
/// Persisted under [kWorkerTrainingsKey] with the `board_auth.dart` idiom
/// (lazy `_load()` + one-shot `_userTouched` guard + `bool _persist()` with
/// in-memory rollback on a failed write — the F-8 idiom).

/// SharedPreferences key (versioned like the other `bs.*.v1` keys).
const String kWorkerTrainingsKey = 'bs.worker-trainings.v1';

/// Training lifecycle statuses.
const String kTrainingRecorded = 'recorded';
const String kTrainingPending = 'pending';
const String kTrainingApproved = 'approved';
const String kTrainingRejected = 'rejected'; // נדחה

/// The username the DEMO-SEED rows are filed under. The seed is shared across
/// boards exactly like the other `demo`-keyed seeds, and screens filter by the
/// logged username (#66) so each board sees only its own + the demo rows.
const String kTrainingDemoUser = 'demo';

class WorkerTraining {
  const WorkerTraining({
    required this.id,
    required this.username,
    required this.title,
    required this.by,
    required this.date,
    this.doc,
    this.status = kTrainingRecorded,
    this.employerId = '',
  });

  final String id;

  /// Board login username (`ran` / `omer` / `demo`).
  final String username;

  /// Id of the contractor who EMPLOYS the worker (the worker→contractor LINK,
  /// `session.employerId`) — lets the contractor's view scope to THEIR workers
  /// (see [trainingsForEmployer]). Default `''` (field-economy: only serialised
  /// when non-empty). Back-compat: old persisted records carry no 'employerId'
  /// and decode as `''` (and are excluded from any non-empty employer query).
  final String employerId;

  /// e.g. "הדרכת בטיחות כללית באתר".
  final String title;

  /// המדריך/המנפיק — e.g. "ממונה בטיחות".
  final String by;

  /// Date the training took place (date-only semantics).
  final DateTime date;

  /// Optional certificate reference — a photo/PDF data-URL from the camera
  /// seam (`pickTaskPhoto`). Null until a document is attached.
  final String? doc;

  /// [kTrainingRecorded] · [kTrainingPending] · [kTrainingApproved] ·
  /// [kTrainingRejected].
  final String status;

  WorkerTraining copyWith({
    String? id,
    String? username,
    String? title,
    String? by,
    DateTime? date,
    String? doc,
    bool clearDoc = false,
    String? status,
    String? employerId,
  }) =>
      WorkerTraining(
        id: id ?? this.id,
        username: username ?? this.username,
        title: title ?? this.title,
        by: by ?? this.by,
        date: date ?? this.date,
        doc: clearDoc ? null : (doc ?? this.doc),
        status: status ?? this.status,
        employerId: employerId ?? this.employerId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'title': title,
        'by': by,
        'date': date.toIso8601String(),
        'doc': doc,
        'status': status,
        if (employerId.isNotEmpty) 'employerId': employerId,
      };

  /// Defensive decode — a malformed entry is dropped, never crashes the load.
  static WorkerTraining? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final username = raw['username'];
    final title = raw['title'];
    final date = DateTime.tryParse('${raw['date']}');
    if (id is! String || username is! String || title is! String || date == null) {
      return null;
    }
    return WorkerTraining(
      id: id,
      username: username,
      title: title,
      by: raw['by'] is String ? raw['by'] as String : '',
      date: date,
      doc: raw['doc'] is String ? raw['doc'] as String : null,
      status: raw['status'] is String ? raw['status'] as String : kTrainingRecorded,
      employerId: raw['employerId'] is String ? raw['employerId'] as String : '',
    );
  }
}

/// The DEMO-SEED rows for a fresh store — mirrors the original
/// `worker_safety_screen.dart` demo list (כללי / עבודה בגובה / ציוד מגן),
/// all by 'ממונה בטיחות', status recorded, and kept removable. Stamped with
/// [kDemoContractorId] so the DEMO contractor (the demo worker's
/// `session.employerId`) sees them in [trainingsForEmployer] — clearly a
/// demo seed, not fabricated server data.
List<WorkerTraining> demoSeedTrainings() => [
      WorkerTraining(
        id: 'train-demo-1',
        username: kTrainingDemoUser,
        title: 'הדרכת בטיחות כללית באתר',
        by: 'ממונה בטיחות',
        date: DateTime(2026, 1, 5),
        employerId: kDemoContractorId,
      ),
      WorkerTraining(
        id: 'train-demo-2',
        username: kTrainingDemoUser,
        title: 'עבודה בגובה',
        by: 'ממונה בטיחות',
        date: DateTime(2026, 3, 12),
        employerId: kDemoContractorId,
      ),
      WorkerTraining(
        id: 'train-demo-3',
        username: kTrainingDemoUser,
        title: 'ציוד מגן אישי',
        by: 'ממונה בטיחות',
        date: DateTime(2026, 6, 2),
        employerId: kDemoContractorId,
      ),
    ];

class WorkerTrainingsNotifier extends StateNotifier<List<WorkerTraining>> {
  WorkerTrainingsNotifier({this.storageKey = kWorkerTrainingsKey, this.persist = true})
      : super(const []) {
    if (persist) _load();
  }

  /// The SharedPreferences key this notifier reads/writes.
  final String storageKey;

  /// When false (tests), SharedPreferences is skipped entirely so the
  /// in-memory behavior can be asserted in isolation (the engines' pattern).
  /// A `persist:false` notifier starts EMPTY (no demo seed) — drive it with
  /// [add]/[remove] directly, or call [debugSeedDemo] to load the demo rows.
  final bool persist;

  /// Test seam (F-9): when set, [_persist] delegates here instead of touching
  /// SharedPreferences — return `false` to exercise the REAL rollback path
  /// (state restored to `before`).
  @visibleForTesting
  Future<bool> Function()? debugPersistOverride;

  /// One-shot guard (the board_auth idiom, ticket #24): once an add/remove/
  /// attach has written state, a late async `_load()` becomes non-destructive.
  bool _userTouched = false;

  /// Monotonic id suffix — on web DateTime precision is ~1ms, so two rapid adds
  /// could collide on a timestamp-only id (a later remove/attach would then hit
  /// BOTH rows). Mirrors the vacation_requests notifier's `_seq` guard.
  int _seq = 0;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted || _userTouched) return;
    final raw = prefs.getString(storageKey);
    if (raw == null) {
      // FIRST load with no persisted store → seed the DEMO rows (and persist
      // them so they survive a reload until the worker edits the list).
      _userTouched = true;
      state = demoSeedTrainings();
      await _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      if (!mounted || _userTouched) return;
      state = [
        for (final e in list)
          if (WorkerTraining.tryFromJson(e) case final t?) t,
      ];
    } on Object catch (_) {
      // Corrupt payload — keep the empty log.
    }
  }

  /// Seed the demo rows into an in-memory (`persist:false`) notifier — the
  /// hermetic equivalent of the empty-store seed that [_load] performs.
  @visibleForTesting
  void debugSeedDemo() {
    _userTouched = true;
    state = demoSeedTrainings();
  }

  /// True when the write actually landed; false on a storage failure — most
  /// commonly the web localStorage quota rejecting a too-large document
  /// data-URL. Honest: callers must NOT pretend the data was saved.
  Future<bool> _persist() async {
    final override = debugPersistOverride;
    if (override != null) return override();
    if (!persist) return true; // tests: in-memory only, nothing can fail
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        storageKey,
        jsonEncode([for (final t in state) t.toJson()]),
      );
    } on Object catch (_) {
      return false; // quota exceeded / platform failure — nothing persisted
    }
  }

  /// [username]'s trainings, newest first.
  List<WorkerTraining> forUser(String username) =>
      state.where((t) => t.username == username).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  /// Record a new training (status [kTrainingRecorded]). Returns the created
  /// row, or null when the persist FAILED (e.g. the localStorage quota
  /// rejected an oversized document data-URL) — the in-memory state is rolled
  /// back so the UI never shows a row that would not survive a reload.
  Future<WorkerTraining?> add({
    required String username,
    required String title,
    required String by,
    required DateTime date,
    String? doc,
    String employerId = '',
  }) async {
    _userTouched = true;
    final t = WorkerTraining(
      id: 'train-${DateTime.now().microsecondsSinceEpoch}-${_seq++}',
      username: username,
      title: title.trim(),
      by: by.trim(),
      date: date,
      doc: doc,
      employerId: employerId,
    );
    final before = state;
    state = [...state, t];
    final ok = await _persist();
    if (!ok) {
      if (mounted) state = before;
      return null;
    }
    return t;
  }

  /// Remove a training (confirmed destructive in the UI). Demo rows are
  /// removable just like the real ones.
  void remove(String id) {
    _userTouched = true;
    state = [
      for (final t in state)
        if (t.id != id) t,
    ];
    _persist();
  }

  /// Attach (or replace) a document on a training. Returns false and rolls the
  /// in-memory state back when the persist FAILED (web quota) — the F-8 idiom,
  /// so the UI never shows a document that would not survive a reload. Returns
  /// false too when the id is unknown (nothing to attach to).
  Future<bool> attachDoc(String id, String dataUrl) async {
    final before = state;
    if (!before.any((t) => t.id == id)) return false; // nothing to attach to
    _userTouched = true;
    state = [
      for (final t in before)
        if (t.id == id) t.copyWith(doc: dataUrl) else t,
    ];
    final ok = await _persist();
    if (!ok) {
      if (mounted) state = before;
      return false;
    }
    return true;
  }

  /// Send a recorded training for the safety officer's approval
  /// ([kTrainingRecorded] → [kTrainingPending]). No-op on an already
  /// pending/approved row.
  void sendForApproval(String id) {
    _userTouched = true;
    state = [
      for (final t in state)
        if (t.id == id && t.status == kTrainingRecorded)
          t.copyWith(status: kTrainingPending)
        else
          t,
    ];
    _persist();
  }

  /// CONTRACTOR write — approve a pending training (no-op once decided).
  void approve(String id) => _decide(id, kTrainingApproved);

  /// CONTRACTOR write — reject a pending training (no-op once decided).
  void reject(String id) => _decide(id, kTrainingRejected);

  void _decide(String id, String status) {
    _userTouched = true;
    state = [
      for (final t in state)
        if (t.id == id && t.status == kTrainingPending) t.copyWith(status: status) else t,
    ];
    _persist();
  }
}

/// The safety-training log — screens filter by the logged username (#66).
final workerTrainingsProvider =
    StateNotifierProvider<WorkerTrainingsNotifier, List<WorkerTraining>>(
  (ref) => WorkerTrainingsNotifier(),
);

/// The CONTRACTOR's view of their workers' trainings — newest-first.
/// Pending ones are the approve/reject queue; decisions flip the worker's
/// own list live (shared provider).
final trainingsForEmployer = Provider.family<List<WorkerTraining>, String>((ref, employerId) {
  final all = ref.watch(workerTrainingsProvider);
  return [for (final t in all.reversed) if (t.employerId == employerId) t];
});
