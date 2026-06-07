// PROJECTS ENGINE (T3.F · proto §2 [L6447-7620]) — the live "active project"
// + the per-project cart snapshot. This is the Flutter/Riverpod lift of the
// prototype's `PROJECTS`/`activeProjectId` globals and `switchProject` /
// `saveSiteEdit` / `saveProject` mutators (index.html:6447-7620) from mutable
// JS globals into a single live StateNotifier both the projects list and the
// app-bar site label read & write — exactly the orders-engine pattern.
//
// The verbatim seed (3 sites + active = PRJ-1) comes from `data/projects.dart`
// (`kProjects` / `kActiveProjectId`) — NOT re-declared here (R6/R8 reuse).
//
// CART-PER-PROJECT (proto `switchProject` :7584-7607 + `switchProjectSilent`
// :7491-7500): switching projects stashes the OUTGOING project's cart and loads
// the INCOMING one. The live shopping cart is the shared `smartCartProvider`;
// to stay anti-collision this engine keeps the per-project snapshots and exposes
// the swap as a callback the shell wires to `smartCartProvider` (see WIRE notes
// in the build report). The snapshots themselves are LIVE here and survive a
// switch, so "cart-per-project" is provable without touching the shared cart.

import 'dart:convert';

import 'package:buildsmart/data/projects.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A live project row — mirrors the prototype `PROJECTS[i]`
/// `{id, name, addr, manager, cart, treeProgress}`. Starts from the verbatim
/// [Project] seed; `name`/`addr`/`manager` become editable (T3.F inline edit),
/// and `cart` holds this project's stashed cart snapshot (cart-per-project).
class LiveProject {
  const LiveProject({
    required this.id,
    required this.name,
    required this.addr,
    required this.manager,
    this.cart = const [],
    this.treeCount = 0,
  });

  final String id;
  final String name;
  final String addr;
  final String manager;

  /// This project's stashed cart snapshot (loaded into / saved from the live
  /// shared cart on switch). `(p.cart||[]).length` in the prototype.
  final List<SmartCartLine> cart;

  /// `Object.keys(p.treeProgress).length` in the prototype — the count of
  /// product-trees worked on this site. Demo-seeded 0 until trees attach.
  final int treeCount;

  /// Seed an in-memory project from the verbatim [Project] const.
  factory LiveProject.fromSeed(Project p) => LiveProject(
        id: p.id,
        name: p.name,
        addr: p.addr,
        manager: p.manager,
      );

  LiveProject copyWith({
    String? name,
    String? addr,
    String? manager,
    List<SmartCartLine>? cart,
    int? treeCount,
  }) =>
      LiveProject(
        id: id,
        name: name ?? this.name,
        addr: addr ?? this.addr,
        manager: manager ?? this.manager,
        cart: cart ?? this.cart,
        treeCount: treeCount ?? this.treeCount,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'addr': addr,
        'manager': manager,
        'cart': [for (final l in cart) l.toJson()],
        'treeCount': treeCount,
      };

  factory LiveProject.fromJson(Map<String, dynamic> j) => LiveProject(
        id: j['id'] as String,
        name: j['name'] as String,
        addr: j['addr'] as String? ?? '',
        manager: j['manager'] as String? ?? '',
        cart: [
          for (final c in (j['cart'] as List? ?? const []))
            SmartCartLine.fromJson(c as Map<String, dynamic>),
        ],
        treeCount: (j['treeCount'] as num?)?.toInt() ?? 0,
      );
}

/// The whole projects state — the live list + which one is active. Mirrors the
/// prototype's `PROJECTS` + `activeProjectId` + `projSeq` globals as one value.
class ProjectsState {
  const ProjectsState({
    required this.projects,
    required this.activeId,
    required this.seq,
  });

  final List<LiveProject> projects;
  final String activeId;

  /// Next project sequence number — `projSeq` (starts at 4; PRJ-1..3 seeded).
  final int seq;

  LiveProject get active =>
      projects.firstWhere((p) => p.id == activeId, orElse: () => projects.first);

  ProjectsState copyWith({
    List<LiveProject>? projects,
    String? activeId,
    int? seq,
  }) =>
      ProjectsState(
        projects: projects ?? this.projects,
        activeId: activeId ?? this.activeId,
        seq: seq ?? this.seq,
      );
}

const String kProjectsKey = 'bs.projects.v1';

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  ProjectsNotifier({this.persist = true})
      : super(ProjectsState(
          projects: [for (final p in kProjects) LiveProject.fromSeed(p)],
          activeId: kActiveProjectId,
          seq: 4, // proto `projSeq=4`
        )) {
    if (persist) _load();
  }

  final bool persist;
  bool _loaded = false;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kProjectsKey);
      if (raw == null || raw.isEmpty) {
        _loaded = true;
        return;
      }
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if (!_loaded) {
        final list = [
          for (final p in (m['projects'] as List? ?? const []))
            LiveProject.fromJson(p as Map<String, dynamic>),
        ];
        if (list.isNotEmpty) {
          super.state = ProjectsState(
            projects: list,
            activeId: m['activeId'] as String? ?? list.first.id,
            seq: (m['seq'] as num?)?.toInt() ?? list.length + 1,
          );
        }
        _loaded = true;
      }
    } on Object catch (_) {
      _loaded = true; // corrupt payload — keep the seed
    }
  }

  Future<void> _persist() async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kProjectsKey,
        jsonEncode({
          'projects': [for (final p in state.projects) p.toJson()],
          'activeId': state.activeId,
          'seq': state.seq,
        }),
      );
    } on Object catch (_) {}
  }

  @override
  set state(ProjectsState value) {
    _loaded = true;
    super.state = value;
    _persist();
  }

  /// switchProject (proto :7584) — make [id] active. Before switching, the
  /// OUTGOING project keeps [outgoingCart] (the current live cart); the INCOMING
  /// project's stashed cart is returned so the caller can load it into the live
  /// shared cart. A no-op (returns null) if [id] is already active or unknown.
  List<SmartCartLine>? switchProject(
    String id, {
    List<SmartCartLine> outgoingCart = const [],
  }) {
    if (id == state.activeId) return null;
    if (!state.projects.any((p) => p.id == id)) return null;
    final updated = [
      for (final p in state.projects)
        if (p.id == state.activeId) p.copyWith(cart: outgoingCart) else p,
    ];
    state = state.copyWith(projects: updated, activeId: id);
    return state.active.cart;
  }

  /// saveSiteEdit (proto :7569) — inline edit of name/addr/manager. Name is
  /// required (the prototype toasts "יש להזין שם אתר" on empty); callers should
  /// validate before calling. A no-op on an unknown id or an empty name.
  void editProject(
    String id, {
    required String name,
    required String addr,
    required String manager,
  }) {
    final n = name.trim();
    if (n.isEmpty) return;
    state = state.copyWith(projects: [
      for (final p in state.projects)
        if (p.id == id)
          p.copyWith(name: n, addr: addr.trim(), manager: manager.trim())
        else
          p,
    ]);
  }

  /// saveProject (proto :7613) — add a new site. `PRJ-<seq>` id; addr/manager
  /// default to "—" exactly like the prototype. Returns the new id (or null on
  /// an empty name).
  String? addProject({
    required String name,
    String addr = '',
    String manager = '',
  }) {
    final n = name.trim();
    if (n.isEmpty) return null;
    final id = 'PRJ-${state.seq}';
    state = state.copyWith(
      projects: [
        ...state.projects,
        LiveProject(
          id: id,
          name: n,
          addr: addr.trim().isEmpty ? '—' : addr.trim(),
          manager: manager.trim().isEmpty ? '—' : manager.trim(),
        ),
      ],
      seq: state.seq + 1,
    );
    return id;
  }

  /// Stash [cart] onto the currently-active project WITHOUT switching — keeps a
  /// project's cart snapshot current as the live cart changes (so a later switch
  /// restores the right snapshot). The "save the current cart back to the
  /// outgoing project" half of the prototype switch, callable independently.
  void stashActiveCart(List<SmartCartLine> cart) {
    state = state.copyWith(projects: [
      for (final p in state.projects)
        if (p.id == state.activeId) p.copyWith(cart: cart) else p,
    ]);
  }

  void resetToSeed() => state = ProjectsState(
        projects: [for (final p in kProjects) LiveProject.fromSeed(p)],
        activeId: kActiveProjectId,
        seq: 4,
      );
}

/// The shared projects provider — the single live list the projects screen, the
/// app-bar site label and the smart-project title all read.
final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, ProjectsState>(
  (ref) => ProjectsNotifier(),
);

/// The active project, derived live off [projectsProvider] — the app-bar site
/// label (`activeProject()` in the prototype).
final activeProjectProvider = Provider<LiveProject>(
  (ref) => ref.watch(projectsProvider).active,
);
