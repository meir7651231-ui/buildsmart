// Persistent storage for saved install-studio projects.
// A project = list of anchor SKUs + line temperature + accessories selected +
// optional user-chosen name. Stored as JSON in SharedPreferences under one key
// so the user can reopen yesterday's design without rebuilding it from scratch.

import 'dart:convert';

import 'package:buildsmart/data/repositories/saved_projects_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kStorageKey = 'bs.saved_projects.v1';

class SavedProject {
  SavedProject({
    required this.id,
    required this.name,
    required this.anchorSkus,
    required this.tempC,
    required this.accessories,
    required this.savedAt,
    this.branchSkus = const [],
  });

  /// Stable identifier (timestamp at creation).
  final String id;
  String name;
  final List<String> anchorSkus;
  final List<String> branchSkus;
  final int tempC;
  final Set<String> accessories;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'anchorSkus': anchorSkus,
        'branchSkus': branchSkus,
        'tempC': tempC,
        'accessories': accessories.toList(),
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedProject.fromJson(Map<String, dynamic> j) => SavedProject(
        id: j['id'] as String,
        name: j['name'] as String,
        anchorSkus: (j['anchorSkus'] as List).cast<String>(),
        branchSkus: ((j['branchSkus'] ?? const []) as List).cast<String>(),
        tempC: (j['tempC'] as num).toInt(),
        accessories: ((j['accessories'] ?? const []) as List)
            .cast<String>()
            .toSet(),
        savedAt: DateTime.parse(j['savedAt'] as String),
      );
}

class SavedProjectsNotifier extends StateNotifier<List<SavedProject>> {
  SavedProjectsNotifier([this._repo]) : super(const []) {
    _load();
  }

  /// The server store for the saved projects (`savedProjects/{uid}`) when
  /// USER_DATA_SERVER is on for a real signed-in user; null (the default) ⇒ the
  /// SharedPreferences path below, byte-identical to before. Injected by
  /// [savedProjectsProvider].
  final SavedProjectsRepository? _repo;

  /// True once any mutation has been applied (or _load completes).
  /// Guards against _load clobbering a mutation that arrived before prefs.
  bool _loaded = false;

  /// Monotonic id suffix — web DateTime is ~1ms-precise, so two saves in the
  /// same millisecond would collide on a timestamp-only id, and `remove(id)` /
  /// `rename(id)` would then hit BOTH. Mirrors worker_notifs / worker_trainings.
  int _seq = 0;

  @override
  set state(List<SavedProject> value) {
    _loaded = true; // mutation happened — block any pending _load
    super.state = value;
  }

  Future<void> _load() async {
    final repo = _repo;
    if (repo != null) {
      // Server path (USER_DATA_SERVER): the projects live at `savedProjects/{uid}`.
      // Same shape as the local path — one 0-or-1 doc read, sorted savedAt desc,
      // seeded via super.state (bypass the setter so load never re-persists); the
      // _loaded latch still blocks a load from clobbering an in-flight mutation.
      // List.of makes it growable+sortable (repo.load returns const [] when empty).
      try {
        final list = List.of(await repo.load(repo.currentUid))
          ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
        if (!_loaded) {
          super.state = list;
          _loaded = true;
        }
      } catch (_) {
        _loaded = true;
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    if (raw == null) {
      _loaded = true;
      return;
    }
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => SavedProject.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      if (!_loaded) {
        super.state = list; // bypass setter so we don't re-persist on load
        _loaded = true;
      }
    } catch (_) {
      // corrupted entry — ignore
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    final repo = _repo;
    if (repo != null) {
      // Server path: mirror the whole list to `savedProjects/{uid}`.
      try {
        await repo.save(repo.currentUid, state);
      } catch (_) {
        // write failure — swallow (do not surface as unhandled async error)
      }
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kStorageKey, jsonEncode(state.map((p) => p.toJson()).toList()));
    } catch (_) {
      // write failure — swallow (do not surface as unhandled async error)
    }
  }

  Future<SavedProject> save({
    required String name,
    required List<String> anchorSkus,
    required int tempC,
    required Set<String> accessories,
    List<String> branchSkus = const [],
  }) async {
    final p = SavedProject(
      id: '${DateTime.now().microsecondsSinceEpoch}-${_seq++}',
      name: name,
      anchorSkus: List.of(anchorSkus),
      branchSkus: List.of(branchSkus),
      tempC: tempC,
      accessories: Set.of(accessories),
      savedAt: DateTime.now(),
    );
    state = [p, ...state];
    await _persist();
    return p;
  }

  Future<void> remove(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _persist();
  }

  Future<void> rename(String id, String newName) async {
    state = [
      for (final p in state)
        if (p.id == id)
          SavedProject(
            id: p.id,
            name: newName,
            anchorSkus: p.anchorSkus,
            branchSkus: p.branchSkus,
            tempC: p.tempC,
            accessories: p.accessories,
            savedAt: p.savedAt,
          )
        else
          p,
    ];
    await _persist();
  }
}

final savedProjectsProvider =
    StateNotifierProvider<SavedProjectsNotifier, List<SavedProject>>(
  // Injects the server store (`savedProjects/{uid}`) when USER_DATA_SERVER is on
  // for a real signed-in user; null (the default) ⇒ the SharedPreferences path,
  // byte-identical to before (the provider value stays null → no rebuild).
  (ref) => SavedProjectsNotifier(ref.watch(savedProjectsRepositoryProvider)),
);
