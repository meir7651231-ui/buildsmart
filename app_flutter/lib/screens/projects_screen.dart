// פרויקטים SCREEN (T3.F · proto §2 [L6447-7620]) — the contractor's site list:
// each site card shows name/addr/foreman + a cart/tree count, switches the
// active project (switchProject), opens a full status snapshot, and edits the
// site inline (saveSiteEdit). A "+ פרויקט חדש" sheet adds sites (saveProject).
// All state is the live `projectsProvider` (active id + per-project cart
// snapshot, see state/projects_engine.dart) — the orders-engine pattern.
// Strings/numbers verbatim from the prototype (R6/R8).
//
// Entry: openProjects (the leaf action) → ProjectsScreen.route().
//
// CART-PER-PROJECT: switching stashes the outgoing project's live cart and
// loads the incoming one. To stay anti-collision this screen drives the
// engine's switchProject (which keeps the snapshots) and exposes the live-cart
// swap as a wire hook — see the build report WIRE notes.

import 'package:buildsmart/screens/budget_screen.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbProjectsNodes;
import 'package:buildsmart/screens/smart_project_screen.dart';
import 'package:buildsmart/screens/tasks_screen.dart';
import 'package:buildsmart/state/keyboard_overlay.dart' show kKbGlobal;
import 'package:buildsmart/state/keyboard_screen_tools.dart' show KbScreen;
import 'package:buildsmart/state/projects_engine.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open the פרויקטים screen — the wire target for `openProjects`.
void openProjects(BuildContext context) =>
    Navigator.of(context).push(ProjectsScreen.route());

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ProjectsScreen());

  static final List<KbToolNode> _kbNodes = kbProjectsNodes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectsProvider);
    final Widget body = Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          title: const CfgText('projects_screen.title', '🏗️ הפרויקטים שלי',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          actions: [
            // composite hide: whole button gone when the org hides this element
            CfgVisible(
              'projects_screen.exit',
              critical: true, // exit/back — never hideable (don't trap the user)
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const CfgText('projects_screen.exit', '‹ יציאה',
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 14)),
              ),
            ),
          ],
        ),
        // composite hide: whole FAB gone when the org hides this element
        floatingActionButton: CfgVisible(
          'projects_screen.new_project',
          child: FloatingActionButton.extended(
            backgroundColor: BsTokens.brand,
            onPressed: () => _addSheet(context, ref),
            icon: Icon(Icons.add, color: bsOnAccent(context)),
            label: CfgText('projects_screen.new_project', 'פרויקט חדש',
                style: TextStyle(
                    color: bsOnAccent(context), fontWeight: FontWeight.w800)),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(BsTokens.space4, BsTokens.space4,
              BsTokens.space4, 96),
          children: [
            // Project tools — budget · tasks · smart-project (chained here, no
            // standalone menu leaf; they apply to the active project).
            Row(children: [
              _LinkBtn(
                label: '💰 תקציב',
                onTap: () => Navigator.of(context).push(BudgetScreen.route()),
              ),
              const SizedBox(width: BsTokens.space2),
              _LinkBtn(
                label: '📋 משימות',
                onTap: () => Navigator.of(context).push(TasksScreen.route()),
              ),
              const SizedBox(width: BsTokens.space2),
              _LinkBtn(
                label: '🏗️ פרויקט חכם',
                onTap: () =>
                    Navigator.of(context).push(SmartProjectScreen.route()),
              ),
            ]),
            const SizedBox(height: BsTokens.space3),
            if (state.projects.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    const Text('🏗️', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const CfgText(
                      'projects_screen.empty_title',
                      'אין פרויקטים עדיין',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const CfgText(
                      'projects_screen.empty_sub',
                      'צרו פרויקט חדש כדי לנהל סל, תקציב ומשימות לכל אתר',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                    ),
                    const SizedBox(height: BsTokens.space3),
                    // composite hide: whole button gone when the org hides this element
                    CfgVisible(
                      'projects_screen.empty_cta',
                      child: TextButton.icon(
                        onPressed: () => _addSheet(context, ref),
                        icon: const Icon(Icons.add,
                            size: 18, color: BsTokens.brand),
                        label: const CfgText(
                          'projects_screen.empty_cta',
                          'פרויקט חדש',
                          style: TextStyle(
                              color: BsTokens.brand,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final p in state.projects)
                _SiteCard(
                  project: p,
                  isActive: p.id == state.activeId,
                  onSwitch: () => _switch(context, ref, p.id),
                  onStatus: () => _statusSheet(context, ref, p.id),
                  onCart: () {
                    _switch(context, ref, p.id, silent: true);
                    showToast(context, '🛒 סל הפרויקט: ${p.cart.length} פריטים');
                  },
                ),
          ],
        ),
      ),
    );
    return kKbGlobal ? KbScreen(tools: _kbNodes, child: body) : body;
  }

  // switchProject — proto :7584. Stash the outgoing live cart + load the
  // incoming one: read the current shared cart, hand it to the engine as the
  // outgoing snapshot, then load the returned incoming snapshot back into the
  // live shared cart. cart-per-project, end to end.
  void _switch(BuildContext context, WidgetRef ref, String id,
      {bool silent = false}) {
    final state = ref.read(projectsProvider);
    if (id == state.activeId) {
      if (!silent) Navigator.of(context).maybePop();
      return;
    }
    // Stash the outgoing project's live cart, switch, then load the incoming
    // project's stashed snapshot into the shared cart. switchProject returns
    // null only on a no-op (already-active / unknown id) — guarded above, but we
    // keep the null-check so a stray no-op never clears the live cart.
    final outgoing = ref.read(smartCartProvider);
    final incoming =
        ref.read(projectsProvider.notifier).switchProject(id, outgoingCart: outgoing);
    if (incoming != null) {
      ref.read(smartCartProvider.notifier).loadSnapshot(incoming);
    }
    final p = ref.read(projectsProvider).active;
    if (!silent) showToast(context, 'עברת לפרויקט: ${p.name}');
  }

  void _statusSheet(BuildContext context, WidgetRef ref, String id) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _StatusSheet(projectId: id),
    );
  }

  void _addSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _EditSheet(projectId: null),
    );
  }
}

class _SiteCard extends StatelessWidget {
  const _SiteCard({
    required this.project,
    required this.isActive,
    required this.onSwitch,
    required this.onStatus,
    required this.onCart,
  });
  final LiveProject project;
  final bool isActive;
  final VoidCallback onSwitch;
  final VoidCallback onStatus;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space3),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        elevation: 1,
        shadowColor: Colors.black26,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            border: isActive
                ? Border.all(color: BsTokens.brand, width: 1.5)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onStatus,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(project.name,
                                style: const TextStyle(
                                    color: BsTokens.inkLight,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(project.addr,
                                style: const TextStyle(
                                    color: BsTokens.mutedLight, fontSize: 12.5)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: BsTokens.space2),
                    Material(
                      color: isActive
                          ? const Color(0xFFE9F7EE)
                          : const Color(0xFFFFF0E3),
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      child: InkWell(
                        key: ValueKey('switch-${project.id}'),
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        onTap: onSwitch,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Text(
                            isActive ? 'פעיל עכשיו' : 'החלף ›',
                            style: TextStyle(
                                color: isActive
                                    ? const Color(0xFF1f8a4c)
                                    : BsTokens.brandDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BsTokens.space2),
                GestureDetector(
                  onTap: onStatus,
                  child: Text('👷 מנהל עבודה: ${project.manager}',
                      style: const TextStyle(
                          color: BsTokens.mutedLight, fontSize: 13)),
                ),
                const SizedBox(height: BsTokens.space2),
                Row(children: [
                  _LinkBtn(
                    label: '🛒 ${project.cart.length} פריטים בעגלה ›',
                    onTap: onCart,
                  ),
                  const SizedBox(width: BsTokens.space2),
                  _LinkBtn(
                    label: '🌳 ${project.treeCount} עצי מוצרים ›',
                    onTap: onStatus,
                  ),
                ]),
                const SizedBox(height: BsTokens.space2),
                // composite hide: whole tappable gone when the org hides this element
                CfgVisible(
                  'projects_screen.status_hint',
                  child: GestureDetector(
                    onTap: onStatus,
                    child: const CfgText('projects_screen.status_hint', '📊 הקש לסטטוס האתר המלא',
                        style: TextStyle(
                            color: BsTokens.brandDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkBtn extends StatelessWidget {
  const _LinkBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          child: InkWell(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: BsTokens.inkLight, fontSize: 12)),
            ),
          ),
        ),
      );
}

// ── status snapshot sheet (proto openSiteStatus :7502) ──────────────────────
class _StatusSheet extends ConsumerWidget {
  const _StatusSheet({required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectsProvider);
    final p = state.projects.firstWhere((x) => x.id == projectId,
        orElse: () => state.active);
    final isActive = p.id == state.activeId;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scroll) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(BsTokens.radiusCard)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.all(BsTokens.space4),
            children: [
              Text(p.name,
                  style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
              const SizedBox(height: BsTokens.space3),
              // active state — tap to switch
              Material(
                color: isActive
                    ? const Color(0xFFE9F7EE)
                    : const Color(0xFFF2F3F5),
                borderRadius: BorderRadius.circular(cfgRadius(context)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(cfgRadius(context)),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (!isActive) {
                      // Same cart-per-project swap as _switch: stash the
                      // outgoing live cart, load the incoming snapshot.
                      final outgoing = ref.read(smartCartProvider);
                      final incoming = ref
                          .read(projectsProvider.notifier)
                          .switchProject(p.id, outgoingCart: outgoing);
                      if (incoming != null) {
                        ref
                            .read(smartCartProvider.notifier)
                            .loadSnapshot(incoming);
                      }
                      showToast(context, 'עברת לפרויקט: ${p.name}');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(BsTokens.space3),
                    child: Text(
                      isActive
                          ? '🟢 אתר פעיל עכשיו'
                          : '⚪ לא פעיל — הקש כדי להפעיל',
                      style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              // details — tap to edit
              Material(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(cfgRadius(context)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(cfgRadius(context)),
                  onTap: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => _EditSheet(projectId: p.id),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(BsTokens.space3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('📍 כתובת', p.addr.isEmpty ? '—' : p.addr),
                        const SizedBox(height: 6),
                        _kv('👷 מנהל עבודה',
                            p.manager.isEmpty ? '—' : p.manager),
                        const SizedBox(height: 6),
                        const CfgText('projects_screen.edit_hint', '✏️ הקש לעריכת הפרטים',
                            style: TextStyle(
                                color: BsTokens.brandDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              _kvTile('🛒 ${p.cart.length} פריטים בעגלה'),
              _kvTile('🌳 ${p.treeCount} עצי מוצרים בעבודה'),
              const SizedBox(height: BsTokens.space3),
              // composite hide: whole pill button gone when the org hides this element
              CfgVisible(
                'projects_screen.edit_site',
                child: Material(
                  color: BsTokens.brand,
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    onTap: () {
                      Navigator.of(context).pop();
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => _EditSheet(projectId: p.id),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CfgText('projects_screen.edit_site', '✏️ עריכת פרטי האתר',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Row(children: [
        Text(k,
            style:
                const TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
        const Spacer(),
        Text(v,
            style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ]);

  // (context-less helper — keeps the fixed radius; adopt when context is threaded.)
  Widget _kvTile(String label) => Container(
        margin: const EdgeInsets.only(bottom: BsTokens.space2),
        padding: const EdgeInsets.all(BsTokens.space3),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        ),
        child: Text(label,
            style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5)),
      );
}

// ── edit / add sheet (proto openSiteEditor :7557 / openProjectModal :7611) ──
class _EditSheet extends ConsumerStatefulWidget {
  const _EditSheet({required this.projectId});
  final String? projectId; // null = add new
  @override
  ConsumerState<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends ConsumerState<_EditSheet> {
  late final TextEditingController _name;
  late final TextEditingController _addr;
  late final TextEditingController _mgr;
  // A field edit flips this so a back-swipe / drag-dismiss / scrim-tap CONFIRMS
  // before discarding typed input (PopScope in build); a direct Save bypasses it.
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    LiveProject? p;
    if (widget.projectId != null) {
      final list = ref.read(projectsProvider).projects;
      final i = list.indexWhere((x) => x.id == widget.projectId);
      if (i >= 0) p = list[i];
    }
    _name = TextEditingController(text: p?.name ?? '');
    _addr = TextEditingController(text: p?.addr ?? '');
    _mgr = TextEditingController(text: p?.manager ?? '');
    // Listen AFTER seeding initial text, so hydration doesn't mark dirty.
    for (final c in [_name, _addr, _mgr]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  /// PopScope back / drag / scrim handler: with unsaved edits (canPop:false ⇒
  /// didPop:false), confirm before discarding; on confirm, pop directly (a
  /// direct pop bypasses PopScope's gate).
  Future<void> _onPop(bool didPop, Object? result) async {
    if (didPop) return;
    final discard = await confirmDestructive(
      context,
      title: 'לבטל את השינויים?',
      message: 'השינויים שהזנת לא יישמרו.',
      confirmLabel: 'בטל שינויים',
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _name.dispose();
    _addr.dispose();
    _mgr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.projectId == null;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: _onPop,
      child: Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(BsTokens.radiusCard)),
          ),
          padding: const EdgeInsets.all(BsTokens.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(isNew ? 'פרויקט חדש' : 'עריכת פרטי האתר',
                  style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
              const SizedBox(height: BsTokens.space3),
              TextField(
                key: const ValueKey('edit-name'),
                controller: _name,
                decoration: const InputDecoration(
                    labelText: 'שם האתר', border: OutlineInputBorder()),
              ),
              const SizedBox(height: BsTokens.space2),
              TextField(
                controller: _addr,
                decoration: const InputDecoration(
                    labelText: 'כתובת', border: OutlineInputBorder()),
              ),
              const SizedBox(height: BsTokens.space2),
              TextField(
                controller: _mgr,
                decoration: const InputDecoration(
                    labelText: 'מנהל עבודה', border: OutlineInputBorder()),
              ),
              const SizedBox(height: BsTokens.space3),
              Material(
                color: BsTokens.brand,
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                child: InkWell(
                  key: const ValueKey('edit-save'),
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  onTap: _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(isNew ? 'הוסף פרויקט' : 'שמור',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showToast(context,
          widget.projectId == null ? 'יש להזין שם פרויקט' : 'יש להזין שם אתר');
      return;
    }
    final n = ref.read(projectsProvider.notifier);
    if (widget.projectId == null) {
      n.addProject(name: name, addr: _addr.text, manager: _mgr.text);
      Navigator.of(context).pop();
      showToast(context, 'הפרויקט נוסף');
    } else {
      n.editProject(widget.projectId!,
          name: name, addr: _addr.text, manager: _mgr.text);
      Navigator.of(context).pop();
      showToast(context, 'פרטי האתר עודכנו');
    }
  }
}
