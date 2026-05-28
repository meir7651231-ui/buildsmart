// Persistent storage for saved install-studio projects.
// A project = list of anchor SKUs + line temperature + accessories selected +
// optional user-chosen name. Stored as JSON in SharedPreferences under one key
// so the user can reopen yesterday's design without rebuilding it from scratch.

import 'dart:convert';

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
        tempC: j['tempC'] as int,
        accessories: ((j['accessories'] ?? const []) as List)
            .cast<String>()
            .toSet(),
        savedAt: DateTime.parse(j['savedAt'] as String),
      );
}

class SavedProjectsNotifier extends StateNotifier<List<SavedProject>> {
  SavedProjectsNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => SavedProject.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      state = list;
    } catch (_) {
      // corrupted entry — ignore
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kStorageKey, jsonEncode(state.map((p) => p.toJson()).toList()));
  }

  Future<SavedProject> save({
    required String name,
    required List<String> anchorSkus,
    required int tempC,
    required Set<String> accessories,
    List<String> branchSkus = const [],
  }) async {
    final p = SavedProject(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
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
        (_) => SavedProjectsNotifier());
