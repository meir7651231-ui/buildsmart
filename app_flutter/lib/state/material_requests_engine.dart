import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wave E3 · material request (worker → contractor) — a STRUCTURED request,
/// NOT a stock edit. The worker files what materials they need; the employing
/// contractor sees it live in an inbox and advances its status
/// (requested → ordered → supplied / declined); the worker watches the status
/// flip live. Mirrors the cross-persona shared-queue pattern of
/// `vacation_requests.dart` (one provider, two boards read it; a contractor
/// decision flips the worker's own list live).
///
/// CRITICAL: this engine NEVER touches `stockProvider`. A material request is
/// a separate REQUEST entity — the worker stays read-only on the employer's
/// stock (`employer_stock.dart`). אין-המצאות: no fabricated items/prices; the
/// worker types the items themselves, empty lines are dropped.
///
/// Persisted to SharedPreferences under [kMaterialRequestsKey] with the
/// `board_auth.dart` / `vacation_requests.dart` idiom (lazy `_load()` +
/// `_userTouched` guard, `mounted` re-checks, best-effort `_persist`).
/// SERVER-SWAP Z: [MaterialRequestsNotifier.bindRemote] becomes the firebase
/// repo binding — until then it is an empty seam.

/// SharedPreferences key (versioned like the other `bs.*.v1` keys).
const String kMaterialRequestsKey = 'bs.material-requests.v1';

/// Request lifecycle. `requested` until the contractor acts; `ordered` once the
/// contractor has placed the order; `supplied` when delivered; `declined` if
/// the contractor rejects it. The worker writes only [kMatReqRequested]; the
/// contractor advances via [MaterialRequestsNotifier.setStatus].
const String kMatReqRequested = 'requested';
const String kMatReqOrdered = 'ordered';
const String kMatReqSupplied = 'supplied';
const String kMatReqDeclined = 'declined';

/// Every known status — `setStatus` guards against writing anything else, so a
/// typo or a stale server value never lands an invalid status on a request.
const Set<String> kMatReqStatuses = {
  kMatReqRequested,
  kMatReqOrdered,
  kMatReqSupplied,
  kMatReqDeclined,
};

class MaterialRequest {
  const MaterialRequest({
    required this.id,
    required this.employerId,
    required this.workerUid,
    required this.username,
    required this.workerName,
    required this.items,
    required this.createdTs,
    this.note = '',
    this.status = kMatReqRequested,
  });

  /// Unique id — `mat-${micros}-${_seq}` (collision-safe on rapid submit; see
  /// the `_seq` note on the notifier and [[buildsmart-flutter-test-gotchas]]).
  final String id;

  /// The contractor this request is addressed to — `session.employerId`
  /// (the Wave-0 link in `board_auth.dart`). The contractor inbox filters on
  /// this via [requestsForEmployer].
  final String employerId;

  /// The requesting worker's uid (`session.uid`) — the SERVER-READY identity,
  /// '' on the local/seed path (only the Firebase-bind mints it). KEPT for the
  /// SERVER-SWAP; do NOT scope on it — it collides at '' for every seed worker
  /// (that was the cross-user leak). Scope on [username] instead.
  final String workerUid;

  /// The requesting worker's board username (`session.username`) — the LOCAL
  /// scope key, populated for every seed/demo worker. [requestsForWorker]
  /// filters on THIS (the #66 per-username idiom shared by VacationRequest /
  /// AttendanceDay / WorkerCert), so each worker sees only their own requests.
  final String username;

  /// Hebrew display name of the requester (straight off the BoardSession) — so
  /// the contractor inbox shows who asked without a second lookup.
  final String workerName;

  /// The requested materials, one item per entry. Free text the worker typed —
  /// empty lines are dropped on [MaterialRequestsNotifier.submit]. אין-המצאות:
  /// nothing here is seeded or fabricated.
  final List<String> items;

  /// Free-text note — may be empty (e.g. "דחוף, נגמר באתר").
  final String note;

  /// Epoch micros at creation — newest-first ordering key for the derived
  /// providers. An int (not DateTime) so the JSON stays tiny and exact.
  final int createdTs;

  /// One of [kMatReqStatuses]. [kMatReqRequested] on submit; the contractor
  /// advances it.
  final String status;

  MaterialRequest copyWith({
    String? employerId,
    String? workerUid,
    String? username,
    String? workerName,
    List<String>? items,
    String? note,
    int? createdTs,
    String? status,
  }) =>
      MaterialRequest(
        id: id,
        employerId: employerId ?? this.employerId,
        workerUid: workerUid ?? this.workerUid,
        username: username ?? this.username,
        workerName: workerName ?? this.workerName,
        items: items ?? this.items,
        note: note ?? this.note,
        createdTs: createdTs ?? this.createdTs,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employerId': employerId,
        'workerUid': workerUid,
        'username': username,
        'workerName': workerName,
        'items': items,
        'note': note,
        'createdTs': createdTs,
        'status': status,
      };

  /// Defensive decode — a malformed entry is dropped, never crashes the load
  /// (mirrors `VacationRequest.tryFromJson`). Back-compat: an unknown/missing
  /// status decodes as [kMatReqRequested]; a missing note as ''.
  static MaterialRequest? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final employerId = raw['employerId'];
    final workerUid = raw['workerUid'];
    final workerName = raw['workerName'];
    final createdTs = raw['createdTs'];
    if (id is! String ||
        employerId is! String ||
        workerUid is! String ||
        workerName is! String ||
        createdTs is! int) {
      return null;
    }
    final rawItems = raw['items'];
    final items = rawItems is List
        ? [for (final e in rawItems) if (e is String) e]
        : const <String>[];
    final status = raw['status'];
    return MaterialRequest(
      id: id,
      employerId: employerId,
      workerUid: workerUid,
      // Back-compat: a pre-username payload has no key → '' (those old seed
      // records carried workerUid '' anyway, so they correctly fall out of the
      // per-username scope — that empty-key collision WAS the leak).
      username: raw['username'] is String ? raw['username'] as String : '',
      workerName: workerName,
      items: items,
      note: raw['note'] is String ? raw['note'] as String : '',
      createdTs: createdTs,
      status: status is String && kMatReqStatuses.contains(status)
          ? status
          : kMatReqRequested,
    );
  }
}

class MaterialRequestsNotifier extends StateNotifier<List<MaterialRequest>> {
  MaterialRequestsNotifier() : super(const []) {
    _load();
  }

  /// One-shot guard (the board_auth idiom): once a submit/setStatus has written
  /// state, a late `_load()` becomes non-destructive.
  bool _userTouched = false;

  /// Monotonic id suffix — on web DateTime precision is ~1ms, so two rapid
  /// submits could collide on a timestamp-only id (a later `setStatus` would
  /// then hit BOTH requests). Mirrors `vacation_requests.dart`.
  int _seq = 0;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final raw = prefs.getString(kMaterialRequestsKey);
    if (raw == null || _userTouched) return;
    try {
      final list = jsonDecode(raw) as List;
      if (!mounted || _userTouched) return;
      state = [
        for (final e in list)
          if (MaterialRequest.tryFromJson(e) case final r?) r,
      ];
    } on Object catch (_) {
      // Corrupt payload — keep the empty queue.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kMaterialRequestsKey,
        jsonEncode([for (final r in state) r.toJson()]),
      );
    } on Object catch (_) {
      // Storage failure (e.g. web quota) — the in-memory queue stays live;
      // best-effort persist, never an unhandled async error.
    }
  }

  /// WORKER write — file a new material request. Empty/whitespace-only item
  /// lines are dropped (אין-המצאות: only what the worker actually typed). The
  /// id is minted via micros+[_seq] (collision-safe on rapid submit). Status
  /// starts at [kMatReqRequested]. Returns the new request's id.
  String submit({
    required String employerId,
    required String workerUid,
    required String username,
    required String workerName,
    required List<String> items,
    String note = '',
  }) {
    _userTouched = true;
    _seq++;
    final cleaned = [
      for (final raw in items)
        if (raw.trim().isNotEmpty) raw.trim(),
    ];
    final id = 'mat-${DateTime.now().microsecondsSinceEpoch}-$_seq';
    final r = MaterialRequest(
      id: id,
      employerId: employerId,
      workerUid: workerUid,
      username: username,
      workerName: workerName,
      items: cleaned,
      note: note.trim(),
      createdTs: DateTime.now().microsecondsSinceEpoch,
      status: kMatReqRequested,
    );
    state = [...state, r];
    _persist();
    return id;
  }

  /// CONTRACTOR write — advance a request's status. Guarded: [status] must be a
  /// known [kMatReqStatuses] value, and a request that is already terminal
  /// ([kMatReqSupplied] / [kMatReqDeclined]) is not re-opened — only a
  /// non-terminal request moves (requested/ordered → ordered/supplied/declined).
  /// A no-op (unknown status, missing id, or terminal request) leaves state
  /// untouched.
  void setStatus(String id, String status) {
    if (!kMatReqStatuses.contains(status)) return;
    _userTouched = true;
    state = [
      for (final r in state)
        if (r.id == id && !_isTerminal(r.status))
          r.copyWith(status: status)
        else
          r,
    ];
    _persist();
  }

  static bool _isTerminal(String status) =>
      status == kMatReqSupplied || status == kMatReqDeclined;

  /// SERVER-SWAP Z — bind a firebase repo so this queue mirrors a server-side
  /// `material_requests` collection (the worker writes, the contractor advances,
  /// both watch live). Empty seam today; the firebase repo lands here without
  /// touching any consumer of [materialRequestsProvider].
  void bindRemote(dynamic repo) {
    /* SERVER-SWAP Z */
  }
}

/// The shared material-request queue — the worker board writes (submit), the
/// contractor board advances (setStatus), both watch the same list.
final materialRequestsProvider =
    StateNotifierProvider<MaterialRequestsNotifier, List<MaterialRequest>>(
  (ref) => MaterialRequestsNotifier(),
);

/// CONTRACTOR inbox — every request addressed to [employerId], newest-first.
/// (E3b reads this for the contractor's inbox sheet.)
final requestsForEmployer =
    Provider.family<List<MaterialRequest>, String>((ref, employerId) {
  final all = ref.watch(materialRequestsProvider);
  final mine = [
    for (final r in all)
      if (r.employerId == employerId) r,
  ]..sort((a, b) => b.createdTs.compareTo(a.createdTs));
  return mine;
});

/// WORKER view — every request this [username] filed, newest-first. The worker
/// stock sheet renders this so the worker sees their own requests + live status.
/// Scopes on the board USERNAME (not workerUid): session.uid is '' for every
/// seed/demo worker, so keying on it collided at '' and leaked every worker's
/// requests to every other (the #66 per-username idiom — mirrors how the worker
/// forms/attendance/certs stores scope — fixes that).
final requestsForWorker =
    Provider.family<List<MaterialRequest>, String>((ref, username) {
  final all = ref.watch(materialRequestsProvider);
  final mine = [
    for (final r in all)
      if (r.username == username) r,
  ]..sort((a, b) => b.createdTs.compareTo(a.createdTs));
  return mine;
});
