/// Maintenance module — screens (Hebrew, RTL, light, phone-first).
///
/// [MxHome] is the whole module: a role switch (manager / tech / home staff /
/// store) and per-role tabs. Drill-downs are pushed routes that watch
/// [mxDbProvider], so every screen updates live after any action.
///
/// UX rules applied everywhere (after the 3-designer critique):
/// * the main action of a page sits in a sticky bottom bar ([MxBottomBar]);
/// * safety faults are urgent: red banner, what to do now, a call button;
/// * nothing irreversible happens in one tap — local steps get "בטל" in the
///   toast, steps that reach the store / BuildSmart ask to confirm first;
/// * toasts stay 6 s and are announced to screen readers;
/// * no internal codes in the UI ("קריאה 1001", never "WO-1001").
library;

import 'package:buildsmart/features/maintenance/mx_brand.dart';
import 'package:buildsmart/features/maintenance/mx_bridge.dart';
import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_state.dart';
import 'package:buildsmart/features/maintenance/mx_store_link.dart';
import 'package:buildsmart/features/maintenance/mx_templates.dart';
import 'package:buildsmart/features/maintenance/mx_ui.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo identities (real auth maps users to these).
const String kMxTechName = 'יוסי – טכנאי';
const String kMxStaffUnit = 'jrs-3';
const String kMxStaffLabel = 'צוות הבית – דירה 3';
const String kMxStoreId = 'st-tambur';
const String kMxManagerName = 'מנהל האחזקה';

const Color _brand = kMxPrimary;
const Color _bad = kMxBad;
const Color _warn = kMxWarn;
const Color _ok = kMxOk;

ThemeData mxTheme() => mxBrandTheme();

/// A 6-second toast, announced to screen readers. [undo] adds "בטל".
void _toast(
  BuildContext context,
  String? error,
  String success, {
  VoidCallback? undo,
}) {
  final msg = error ?? success;
  if (msg.isEmpty) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 6),
        backgroundColor: error == null ? null : _bad,
        behavior: SnackBarBehavior.floating,
        action:
            error == null && undo != null
                ? SnackBarAction(
                  key: const Key('toast-undo'),
                  label: 'בטל',
                  onPressed: undo,
                )
                : null,
      ),
    );
  SemanticsService.announce(msg, TextDirection.rtl);
}

/// Toast for a local step that can be undone.
void _undoable(
  BuildContext context,
  WidgetRef ref,
  String? error,
  String success,
) => _toast(
  context,
  error,
  success,
  undo: () {
    if (ref.read(mxDbProvider.notifier).undo() && context.mounted) {
      _toast(context, null, 'הפעולה בוטלה');
    }
  },
);

/// Yes/no confirmation before a step that reaches outside the app.
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String ok,
  bool danger = false,
}) async =>
    await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(body, style: const TextStyle(fontSize: 16)),
            actions: [
              TextButton(
                key: const Key('confirm-no'),
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('ביטול'),
              ),
              FilledButton(
                key: const Key('confirm-yes'),
                style: FilledButton.styleFrom(
                  backgroundColor: danger ? _bad : _brand,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(ok),
              ),
            ],
          ),
    ) ??
    false;

Future<void> _call(WidgetRef ref, BuildContext context, String phone) async {
  final ok = await ref.read(urlLauncherProvider)(
    Uri(scheme: 'tel', path: phone.replaceAll(RegExp('[^0-9+]'), '')),
  );
  if (!ok && context.mounted) _toast(context, 'לא ניתן לחייג מהמכשיר', '');
}

Widget _listCard(List<Widget> tiles) => Container(
  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: kMxLine),
    boxShadow: kMxShadow,
  ),
  clipBehavior: Clip.antiAlias,
  child: Material(
    type: MaterialType.transparency,
    child: Column(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
          tiles[i],
        ],
      ],
    ),
  ),
);

/// Light page title for tab bodies (the dark hero lives only on the board).
Widget _pageTitle(String title, [String sub = '']) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
      ),
      if (sub.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            sub,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
    ],
  ),
);

/// Filter chips row (solid petrol when selected).
Widget _chips(
  String keyPrefix,
  List<(String key, String label)> items,
  String selected,
  ValueChanged<String> onSelect,
) => SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  child: Row(
    children: [
      for (final (k, label) in items)
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: ChoiceChip(
            key: Key('$keyPrefix-$k'),
            label: Text(label),
            selected: selected == k,
            showCheckmark: false,
            shape: const StadiumBorder(),
            selectedColor: kMxPrimary,
            backgroundColor: Colors.white,
            side: BorderSide(color: selected == k ? kMxPrimary : kMxLine),
            labelStyle: TextStyle(
              color: selected == k ? Colors.white : kMxInk,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => onSelect(k),
          ),
        ),
    ],
  ),
);

String _woStatus(MxWoStatus s) => switch (s) {
  MxWoStatus.open => 'חדשה',
  MxWoStatus.assigned => 'אצל טכנאי',
  MxWoStatus.waitingPart => 'ממתין לחלק',
  MxWoStatus.done => 'טופלה',
  MxWoStatus.cancelled => 'בוטלה',
};

Color _woColor(MxWoStatus s) => switch (s) {
  MxWoStatus.open => _bad,
  MxWoStatus.assigned || MxWoStatus.waitingPart => _warn,
  _ => _ok,
};

String _poStatus(MxPoStatus s) => switch (s) {
  MxPoStatus.pendingApproval => 'ממתין לאישור',
  MxPoStatus.approved => 'אושר – טרם נשלח',
  MxPoStatus.sent => 'נשלח לחנות',
  MxPoStatus.storeConfirmed => 'החנות אישרה',
  MxPoStatus.storePartial => 'חסרים פריטים',
  MxPoStatus.ready => 'מוכן',
  MxPoStatus.received => 'התקבל',
  MxPoStatus.rejected => 'נדחה',
};

Color _poColor(MxPoStatus s) => switch (s) {
  MxPoStatus.pendingApproval ||
  MxPoStatus.approved ||
  MxPoStatus.storePartial => _warn,
  MxPoStatus.received => _ok,
  MxPoStatus.rejected => _bad,
  _ => _brand,
};

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

String _time(DateTime d) =>
    '${_date(d)}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _byRole(MxRole role) => switch (role) {
  MxRole.staff => kMxStaffLabel,
  MxRole.tech => kMxTechName,
  _ => kMxManagerName,
};

// ── shell ────────────────────────────────────────────────────────────────────

class MxHome extends ConsumerStatefulWidget {
  const MxHome({super.key});
  @override
  ConsumerState<MxHome> createState() => _MxHomeState();
}

typedef _Tab = (String key, IconData icon, String label);

const List<MxRole> _roles = [
  MxRole.manager,
  MxRole.tech,
  MxRole.staff,
  MxRole.store,
];
const List<String> _roleLabels = ['מנהל', 'טכנאי', 'צוות בית', 'חנות'];

class _MxHomeState extends ConsumerState<MxHome> {
  int _tab = 0;

  List<_Tab> _tabs(MxRole role) => switch (role) {
    MxRole.manager => const [
      ('home', Icons.dashboard_outlined, 'לוח'),
      ('sites', Icons.apartment_outlined, 'מסגרות'),
      ('wo', Icons.build_outlined, 'קריאות'),
      ('pm', Icons.event_available_outlined, 'תחזוקה'),
      ('buy', Icons.shopping_cart_outlined, 'רכש'),
    ],
    MxRole.tech => const [
      ('wo', Icons.build_outlined, 'המשימות שלי'),
      ('sites', Icons.apartment_outlined, 'מסגרות'),
      ('buy', Icons.shopping_cart_outlined, 'רכש'),
    ],
    MxRole.staff => const [
      ('report', Icons.campaign_outlined, 'דיווח תקלה'),
      ('wo', Icons.list_alt_outlined, 'הדיווחים שלי'),
    ],
    MxRole.store => const [
      ('store', Icons.storefront_outlined, 'הזמנות לחנות'),
    ],
  };

  void _go(String key, {String? sub}) {
    final i = _tabs(ref.read(mxRoleProvider)).indexWhere((t) => t.$1 == key);
    if (sub != null) ref.read(_buySectionProvider.notifier).state = sub;
    if (i >= 0) setState(() => _tab = i);
  }

  /// Role-scoped badge: only what this person has to act on.
  int _badge(MxDb db, MxRole role, String key) => switch ((role, key)) {
    (MxRole.manager, 'wo') =>
      db.workOrders.where((w) => w.status == MxWoStatus.open).length,
    (MxRole.manager, 'buy') => db.pendingApproval.length,
    (MxRole.tech, 'wo') =>
      db.workOrders
          .where(
            (w) =>
                w.isOpen &&
                (w.assignee == kMxTechName ||
                    (w.status == MxWoStatus.open && w.urgent)),
          )
          .length,
    (MxRole.staff, 'wo') =>
      db.workOrders
          .where((w) => w.isOpen && w.reportedBy == kMxStaffLabel)
          .length,
    _ => 0,
  };

  Future<void> _reset() async {
    final yes = await _confirm(
      context,
      title: 'לאפס את ההדגמה?',
      body:
          'כל הקריאות, ההזמנות והשינויים שנעשו כאן יימחקו ויחזרו לנתוני הדוגמה.',
      ok: 'אפס',
      danger: true,
    );
    if (!yes || !mounted) return;
    ref.read(mxDbProvider.notifier).reset();
    _toast(context, null, 'ההדגמה אופסה');
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(mxRoleProvider);
    final db = ref.watch(mxDbProvider);
    final tabs = _tabs(role);
    final tab = _tab.clamp(0, tabs.length - 1);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(108),
        child: ColoredBox(
          color: _brand,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 4, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: kMxWordmark,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: '  $kMxSubtitle',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: kMxAccent,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          key: const Key('mx-reset'),
                          tooltip: 'איפוס הדגמה',
                          color: Colors.white70,
                          icon: const Icon(Icons.restart_alt),
                          onPressed: _reset,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
                  child: MxRolePill<MxRole>(
                    key: const Key('mx-roles'),
                    values: _roles,
                    labels: _roleLabels,
                    selected: role,
                    onChanged: (r) {
                      ref.read(mxRoleProvider.notifier).state = r;
                      setState(() => _tab = 0);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: switch (tabs[tab].$1) {
        'home' => _Dashboard(onGo: _go),
        'sites' => const _SitesPage(),
        'wo' => const _WorkOrdersPage(),
        'pm' => const _PmPage(),
        'buy' => const _BuyPage(),
        'report' => _ReportPage(onSent: () => _go('wo')),
        _ => const _StoreInbox(),
      },
      bottomNavigationBar:
          tabs.length < 2
              ? null
              : NavigationBar(
                selectedIndex: tab,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                height: 68,
                onDestinationSelected: (i) => setState(() => _tab = i),
                destinations: [
                  for (final t in tabs)
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: _badge(db, role, t.$1) > 0,
                        label: Text('${_badge(db, role, t.$1)}'),
                        child: Icon(t.$2),
                      ),
                      label: t.$3,
                    ),
                ],
              ),
    );
  }
}

/// Which section of the "רכש" tab is open ('orders' / 'stock').
final _buySectionProvider = StateProvider<String>((_) => 'orders');

// ── dashboard ────────────────────────────────────────────────────────────────

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.onGo});
  final void Function(String, {String? sub}) onGo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final now = ref.watch(mxClockProvider)();
    final due = db.pmDue(now);
    final overdue = due.where((d) => d.$2 == MxDue.overdue).length;
    final soon = due.where((d) => d.$2 == MxDue.soon).length;
    final openList = mxSortedOpen(db.openWorkOrders);
    final urgent = openList.where((w) => w.urgent).toList();
    final open = openList.length;
    final pending = db.pendingApproval.length;
    final parts = <String>[
      if (urgent.isNotEmpty)
        urgent.length == 1 ? 'תקלה דחופה אחת' : '${urgent.length} תקלות דחופות',
      if (open > 0) open == 1 ? 'קריאה פתוחה אחת' : '$open קריאות פתוחות',
      if (overdue > 0)
        overdue == 1 ? 'בדיקה אחת באיחור' : '$overdue בדיקות באיחור',
      if (pending > 0)
        pending == 1
            ? 'הזמנה אחת מחכה לאישורך'
            : '$pending הזמנות מחכות לאישורך',
    ];
    final summary =
        parts.isEmpty
            ? 'הכול תקין. אין משימות דחופות היום.'
            : '${parts.join(', ')}.';
    Widget stat(
      String key,
      int v,
      String label,
      IconData icon,
      Color c,
      VoidCallback go,
    ) => Expanded(
      child: MxStatCard(
        key: Key('kpi-$key'),
        value: v,
        label: label,
        icon: icon,
        color: c,
        onTap: go,
      ),
    );
    const gap = SizedBox(width: 10, height: 10);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        MxHero(
          eyebrow: mxDateLabel(now),
          title: mxGreeting(now),
          subtitle: summary,
        ),
        for (final w in urgent)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Material(
              color: kMxPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: _bad, width: 1.5),
              ),
              child: ListTile(
                key: Key('urgent-${w.id}'),
                minVerticalPadding: 12,
                leading: const Icon(Icons.warning_amber_rounded, color: _bad),
                title: Text(
                  'דחוף: ${w.desc}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _bad,
                  ),
                ),
                subtitle: Text(
                  '${db.pointPath(w.pointId)} · ${_woStatus(w.status)}',
                ),
                trailing: const Icon(Icons.chevron_left, color: _bad),
                onTap: () => _open(context, _WorkOrderPage(w.id)),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Row(
                children: [
                  stat(
                    'urgent',
                    urgent.length,
                    'תקלות דחופות',
                    Icons.warning_amber_rounded,
                    _bad,
                    () => onGo('wo'),
                  ),
                  gap,
                  stat(
                    'wo',
                    open,
                    'קריאות פתוחות',
                    Icons.build_outlined,
                    _bad,
                    () => onGo('wo'),
                  ),
                ],
              ),
              gap,
              Row(
                children: [
                  stat(
                    'overdue',
                    overdue,
                    'בדיקות באיחור',
                    Icons.event_busy_outlined,
                    _bad,
                    () => onGo('pm'),
                  ),
                  gap,
                  stat(
                    'soon',
                    soon,
                    'בדיקות השבוע',
                    Icons.event_outlined,
                    _warn,
                    () => onGo('pm'),
                  ),
                ],
              ),
              gap,
              Row(
                children: [
                  stat(
                    'po',
                    pending,
                    'הזמנות לאישור',
                    Icons.shopping_cart_outlined,
                    _warn,
                    () => onGo('buy', sub: 'orders'),
                  ),
                  gap,
                  stat(
                    'low',
                    db.lowStock.length,
                    'חלקים להזמין',
                    Icons.inventory_2_outlined,
                    _warn,
                    () => onGo('buy', sub: 'stock'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const MxSectionTitle('מה לטפל היום'),
        _listCard([
          for (final (r, d) in due.where((d) => d.$2 != MxDue.ok))
            ListTile(
              minVerticalPadding: 12,
              leading: Icon(
                r.isLegal ? Icons.gavel_outlined : Icons.event_outlined,
                color: d == MxDue.overdue ? _bad : _warn,
              ),
              title: Text(
                r.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${r.scope} · ${_date(r.nextDue)}'),
              trailing: MxTag(
                d == MxDue.overdue ? 'באיחור' : 'השבוע',
                d == MxDue.overdue ? _bad : _warn,
              ),
              onTap: () => onGo('pm'),
            ),
          for (final w in openList.where((w) => !w.urgent))
            ListTile(
              minVerticalPadding: 12,
              leading: Icon(
                mxPointIcon(db.point(w.pointId).type),
                color: _woColor(w.status),
              ),
              title: Text(
                w.desc,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(db.pointPath(w.pointId)),
              trailing: MxTag(_woStatus(w.status), _woColor(w.status)),
              onTap: () => _open(context, _WorkOrderPage(w.id)),
            ),
          if (open == 0 && overdue + soon == 0)
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: _ok),
              title: Text('אין משימות להיום'),
            ),
        ]),
      ],
    );
  }
}

void _open(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

/// A pushed page: light title bar, optional sticky bottom action bar.
Scaffold _page(String title, Widget body, {Widget? bottom, bool back = true}) =>
    Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: back,
        title: Text(title),
        toolbarHeight: 60,
        shape: const Border(bottom: BorderSide(color: kMxLine)),
      ),
      body: body,
      bottomNavigationBar: bottom,
    );

// ── sites → unit → room → point ──────────────────────────────────────────────

class _SitesPage extends ConsumerStatefulWidget {
  const _SitesPage();
  @override
  ConsumerState<_SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends ConsumerState<_SitesPage> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    int faulty(String siteId) => [
      for (final u in db.unitsOf(siteId)) db.faultyCountOfUnit(u.id),
    ].fold(0, (a, b) => a + b);
    final q = _q.trim();
    bool hit(String s) => q.isNotEmpty && s.contains(q);
    final sites =
        q.isEmpty
            ? db.sites
            : db.sites
                .where((s) => hit('${s.city} ${s.name} ${s.address}'))
                .toList();
    final points =
        q.isEmpty
            ? const <MxPoint>[]
            : db.points
                .where((p) => hit('${p.label} ${db.pointPath(p.id)}'))
                .take(40)
                .toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _pageTitle(
          'המסגרות',
          '${db.sites.length} מסגרות · ${db.points.length} נקודות במעקב',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
          child: TextField(
            key: const Key('site-search'),
            onChanged: (v) => setState(() => _q = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'חיפוש מסגרת, דירה או נקודה (למשל: שקע)',
            ),
          ),
        ),
        if (sites.isNotEmpty)
          MxTileGrid(
            children: [
              for (final s in sites)
                MxTile(
                  key: Key('site-${s.id}'),
                  icon: Icons.apartment_outlined,
                  label: '${s.city} – ${s.name}',
                  caption: '${db.unitsOf(s.id).length} דירות',
                  alert: faulty(s.id) > 0,
                  onTap: () => _open(context, _SitePage(s.id)),
                ),
            ],
          ),
        if (points.isNotEmpty) ...[
          MxSectionTitle('נקודות', count: points.length),
          _listCard([
            for (final p in points)
              ListTile(
                key: Key('find-${p.id}'),
                leading: Icon(
                  mxPointIcon(p.type),
                  color: p.status == MxPointStatus.faulty ? _bad : _brand,
                ),
                title: Text(p.label),
                subtitle: Text(db.pointPath(p.id)),
                onTap: () => _open(context, _PointPage(p.id)),
              ),
          ]),
        ],
        if (q.isNotEmpty && sites.isEmpty && points.isEmpty)
          const MxEmpty(icon: Icons.search_off, title: 'לא נמצא'),
      ],
    );
  }
}

class _SitePage extends ConsumerWidget {
  const _SitePage(this.siteId);
  final String siteId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final s = db.site(siteId);
    return _page(
      '${s.city} – ${s.name}',
      ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          MxSectionTitle('דירות', count: db.unitsOf(siteId).length),
          MxTileGrid(
            children: [
              for (final u in db.unitsOf(siteId))
                MxTile(
                  key: Key('unit-${u.id}'),
                  icon: Icons.door_front_door_outlined,
                  label: u.name,
                  caption:
                      db.faultyCountOfUnit(u.id) > 0
                          ? '${db.faultyCountOfUnit(u.id)} תקלות פתוחות'
                          : '${db.pointCountOfUnit(u.id)} נקודות, תקין',
                  alert: db.faultyCountOfUnit(u.id) > 0,
                  onTap: () => _open(context, _UnitPage(u.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitPage extends ConsumerWidget {
  const _UnitPage(this.unitId);
  final String unitId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final u = db.unit(unitId);
    return _page(
      '${db.site(u.siteId).city} · ${u.name}',
      ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          MxSectionTitle('חדרים', count: db.roomsOf(unitId).length),
          MxTileGrid(
            children: [
              for (final r in db.roomsOf(unitId))
                MxTile(
                  key: Key('room-${r.id}'),
                  icon: mxRoomIcon(r.name),
                  label: r.name,
                  caption: '${db.pointsOf(r.id).length} נקודות',
                  alert: db
                      .pointsOf(r.id)
                      .any((p) => p.status == MxPointStatus.faulty),
                  onTap: () => _open(context, _RoomPage(r.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A room's points as a compact list grouped by type (25 kitchen points fit
/// on two screens instead of six).
class _RoomPage extends ConsumerWidget {
  const _RoomPage(this.roomId);
  final String roomId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final r = db.room(roomId);
    final u = db.unit(r.unitId);
    final pts = db.pointsOf(roomId);
    final bad = pts.where((p) => p.status == MxPointStatus.faulty).length;
    final types = <String>{for (final p in pts) p.type}.toList();
    return _page(
      '${u.name} · ${r.name}',
      ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    bad == 0
                        ? '${pts.length} נקודות, הכול תקין'
                        : '${pts.length} נקודות, $bad תקולות',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: bad == 0 ? kMxInk : _bad,
                    ),
                  ),
                ),
                const Icon(
                  Icons.qr_code_2,
                  size: 32,
                  color: kMxPrimary,
                  semanticLabel: 'מדבקת QR של החדר',
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'מדבקת QR על דלת החדר פותחת את המסך הזה ישירות.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          for (final t in types) ...[
            MxSectionTitle(t, count: pts.where((p) => p.type == t).length),
            _listCard([
              for (final p in pts.where((p) => p.type == t))
                ListTile(
                  key: Key('pt-${p.id}'),
                  leading: Icon(
                    mxPointIcon(p.type),
                    color: p.status == MxPointStatus.faulty ? _bad : kMxPrimary,
                  ),
                  title: Text(
                    '${p.type} ${p.num}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(p.loc),
                  trailing:
                      p.status == MxPointStatus.faulty
                          ? const MxTag('תקול', _bad)
                          : const Icon(Icons.chevron_left, color: kMxLine),
                  onTap: () => _open(context, _PointPage(p.id)),
                ),
            ]),
          ],
        ],
      ),
    );
  }
}

/// After an urgent report: what to do right now + call the manager.
Future<void> _showSafety(
  BuildContext context,
  WidgetRef ref,
  MxWorkOrder w,
  String type, {
  VoidCallback? onMine,
}) => mxShowSuccess(
  context,
  title: 'הדיווח נשלח כדחוף',
  body: mxSafetyInstruction(type, w.desc),
  urgent: true,
  actions: [
    (
      'התקשרו למנהל האחזקה',
      const Key('urgent-call'),
      () => _call(ref, context, kMxManagerPhone),
    ),
    ('הבנתי', const Key('success-mine'), onMine ?? () {}),
  ],
);

class _PointPage extends ConsumerWidget {
  const _PointPage(this.pointId);
  final String pointId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final p = db.point(pointId);
    final part = db.part(p.sku);
    final role = ref.watch(mxRoleProvider);
    final faulty = p.status == MxPointStatus.faulty;
    final low = db.qty(p.sku) < part.min;
    final openWo = mxOpenOnPoint(db, pointId);
    return _page(
      p.label,
      ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: faulty ? kMxPink : kMxTealTint,
                        child: Icon(
                          mxPointIcon(p.type),
                          size: 30,
                          color: faulty ? _bad : _brand,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.label,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              p.spec,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      if (faulty)
                        const MxTag('תקול', _bad)
                      else
                        const MxTag('תקין', _ok),
                    ],
                  ),
                  const Divider(height: 24),
                  MxInfoRow(
                    Icons.place_outlined,
                    'מיקום',
                    Text(db.pointPath(pointId)),
                  ),
                  MxInfoRow(
                    Icons.build_circle_outlined,
                    'חלק החלפה',
                    Text(part.name),
                  ),
                  MxInfoRow(
                    Icons.inventory_2_outlined,
                    'במלאי',
                    Wrap(
                      spacing: 8,
                      children: [
                        Text('${db.qty(p.sku)} יח׳'),
                        if (low) const MxTag('מתחת למינימום', _warn),
                      ],
                    ),
                  ),
                  MxInfoRow(
                    Icons.event_repeat_outlined,
                    'תחזוקה',
                    Text(p.pm.isEmpty ? 'אין' : p.pm),
                  ),
                ],
              ),
            ),
          ),
          if (openWo != null)
            _listCard([
              ListTile(
                key: const Key('point-open-wo'),
                leading: Icon(
                  openWo.urgent ? Icons.warning_amber_rounded : Icons.build,
                  color: _bad,
                ),
                title: Text(
                  '${mxWoLabel(openWo.id)} פתוחה: ${openWo.desc}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(_woStatus(openWo.status)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _open(context, _WorkOrderPage(openWo.id)),
              ),
            ]),
          MxSectionTitle('היסטוריה', count: p.history.length),
          if (p.history.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'עוד לא היו טיפולים בנקודה הזו.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            _listCard([
              for (final e in p.history)
                ListTile(
                  leading: const Icon(Icons.history, color: _brand),
                  title: Text(
                    e.text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${_date(e.at)} · ${e.by}${e.costAgorot > 0 ? ' · ${mxShekels(e.costAgorot)}' : ''}',
                  ),
                ),
            ]),
        ],
      ),
      bottom: MxBottomBar(
        children: [
          if (openWo != null)
            MxPrimaryButton(
              key: const Key('report-point'),
              label: 'כבר דווח – הוסיפו הערה לקריאה',
              icon: Icons.add_comment_outlined,
              color: kMxPrimary,
              onPressed: () async {
                final text = await _askText(
                  context,
                  'הערה ל${mxWoLabel(openWo.id)}',
                  'מה עוד חשוב לדעת?',
                );
                if (text == null || text.trim().isEmpty || !context.mounted) {
                  return;
                }
                _toast(
                  context,
                  ref
                      .read(mxDbProvider.notifier)
                      .comment(openWo.id, text, _byRole(role)),
                  'ההערה נוספה ל${mxWoLabel(openWo.id)}',
                );
              },
            )
          else
            MxPrimaryButton(
              key: const Key('report-point'),
              label: 'דווחו על תקלה בנקודה הזו',
              icon: Icons.campaign_outlined,
              onPressed: () async {
                final text = await _askFault(context, p.type);
                if (text == null || !context.mounted) return;
                final n = ref.read(mxDbProvider.notifier);
                final err = n.report(pointId, text, _byRole(role));
                if (err != null) return _toast(context, err, '');
                final w = ref.read(mxDbProvider).workOrder(n.lastCreatedId!);
                if (w.urgent) {
                  await _showSafety(context, ref, w, p.type);
                } else {
                  _toast(context, null, 'נפתחה ${mxWoLabel(w.id)}');
                }
              },
            ),
        ],
      ),
    );
  }
}

/// Same ready-made reasons as the staff report, in a sheet: tap a reason
/// (optionally add a word) instead of typing a free-text description.
Future<String?> _askFault(BuildContext context, String type) {
  final text = TextEditingController();
  var reason = '';
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (ctx) => StatefulBuilder(
          builder:
              (ctx, setSheet) => Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16 + MediaQuery.viewInsetsOf(ctx).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'מה קרה?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _reasonChips(
                      'fault-reason',
                      type,
                      reason,
                      (r) => setSheet(() => reason = reason == r ? '' : r),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('fault-text'),
                      controller: text,
                      onChanged: (_) => setSheet(() {}),
                      decoration: const InputDecoration(
                        labelText: 'פרטים נוספים (לא חובה)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        key: const Key('fault-send'),
                        onPressed:
                            reason.isEmpty && text.text.trim().isEmpty
                                ? null
                                : () => Navigator.pop(
                                  ctx,
                                  [
                                    reason,
                                    text.text.trim(),
                                  ].where((x) => x.isNotEmpty).join(' – '),
                                ),
                        child: const Text('פתחו קריאה'),
                      ),
                    ),
                  ],
                ),
              ),
        ),
  );
}

/// Ready-made fault reasons as chips; urgent ones carry a warning icon.
Widget _reasonChips(
  String keyPrefix,
  String type,
  String selected,
  ValueChanged<String> onTap,
) => Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    for (final (i, r) in mxQuickReasons(type).indexed)
      ChoiceChip(
        key: Key('$keyPrefix-$i'),
        avatar:
            mxIsUrgentText(r)
                ? Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: selected == r ? Colors.white : _bad,
                )
                : null,
        label: Text(r, style: const TextStyle(fontSize: 16)),
        selected: selected == r,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        selectedColor: kMxPrimary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected == r ? Colors.white : kMxInk,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: selected == r ? kMxPrimary : kMxLine),
        shape: const StadiumBorder(),
        onSelected: (_) => onTap(r),
      ),
  ],
);

/// Quantity for a part request: quick presets (one tap) or − / + and confirm.
Future<int?> _askQty(BuildContext context, String partName) {
  var q = 1;
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder:
        (ctx) => StatefulBuilder(
          builder:
              (ctx, setSheet) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'כמה להזמין?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        partName,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          for (final v in const [1, 2, 4, 10]) ...[
                            if (v != 1) const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  key: Key('qty-$v'),
                                  onPressed: () => Navigator.pop(ctx, v),
                                  child: Text(
                                    '$v',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'או כמות אחרת:',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          MxStepper(
                            keyPrefix: 'qty',
                            value: q,
                            min: 1,
                            onChanged: (v) => setSheet(() => q = v),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: FilledButton(
                                key: const Key('qty-ok'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: kMxPrimary,
                                ),
                                onPressed: () => Navigator.pop(ctx, q),
                                child: Text('הזמינו $q'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ),
  );
}

/// A short text question (comment, rejection reason, price list).
Future<String?> _askText(
  BuildContext context,
  String title,
  String hint, {
  String initial = '',
  List<String> quick = const [],
  String ok = 'אישור',
  int maxLines = 3,
}) {
  final c = TextEditingController(text: initial);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (quick.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (i, s) in quick.indexed)
                      ActionChip(
                        key: Key('ask-quick-$i'),
                        label: Text(s),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: kMxLine),
                        shape: const StadiumBorder(),
                        onPressed: () => c.text = s,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                key: const Key('ask-text'),
                controller: c,
                autofocus: quick.isEmpty,
                maxLines: maxLines,
                minLines: 1,
                decoration: InputDecoration(hintText: hint),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('ביטול'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        key: const Key('ask-ok'),
                        style: FilledButton.styleFrom(
                          backgroundColor: kMxPrimary,
                        ),
                        onPressed: () => Navigator.pop(ctx, c.text),
                        child: Text(ok),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
  );
}

String _load(int n) => switch (n) {
  0 => 'פנוי, אין קריאות פתוחות',
  1 => 'קריאה פתוחה אחת',
  _ => '$n קריאות פתוחות',
};

/// Pick a technician; each row shows how many open jobs they already hold.
Future<String?> _askTech(BuildContext context, MxDb db) =>
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'למי לשייך?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
                for (final (i, t) in kMxTechs.indexed)
                  ListTile(
                    key: Key('tech-$i'),
                    minVerticalPadding: 12,
                    leading: const CircleAvatar(
                      backgroundColor: kMxTealTint,
                      child: Icon(Icons.engineering_outlined, color: _brand),
                    ),
                    title: Text(
                      t,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(_load(mxOpenCountFor(db, t))),
                    onTap: () => Navigator.pop(ctx, t),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );

// ── work orders ──────────────────────────────────────────────────────────────

class _WorkOrdersPage extends ConsumerStatefulWidget {
  const _WorkOrdersPage();
  @override
  ConsumerState<_WorkOrdersPage> createState() => _WorkOrdersPageState();
}

class _WorkOrdersPageState extends ConsumerState<_WorkOrdersPage> {
  String _filter = 'open';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final mine = switch (role) {
      MxRole.staff => db.workOrders.where((w) => w.reportedBy == kMxStaffLabel),
      MxRole.tech => db.workOrders.where(
        (w) => w.assignee == kMxTechName || w.status == MxWoStatus.open,
      ),
      _ => db.workOrders,
    };
    final open = mxSortedOpen(mine.where((w) => w.isOpen));
    final closed = mine.where((w) => !w.isOpen).toList().reversed.toList();
    final list = switch (_filter) {
      'urgent' => open.where((w) => w.urgent).toList(),
      'new' => open.where((w) => w.status == MxWoStatus.open).toList(),
      'waiting' =>
        open.where((w) => w.status == MxWoStatus.waitingPart).toList(),
      'done' => closed,
      'all' => [...open, ...closed],
      _ => open,
    };
    final title = switch (role) {
      MxRole.tech => 'המשימות שלי',
      MxRole.staff => 'הדיווחים שלי',
      _ => 'קריאות שירות',
    };
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _pageTitle(
          title,
          open.isEmpty ? 'אין קריאות פתוחות' : '${open.length} פתוחות',
        ),
        _chips(
          'wo-filter',
          [
            ('open', 'פתוחות (${open.length})'),
            ('urgent', 'דחופות (${open.where((w) => w.urgent).length})'),
            if (role != MxRole.staff) ('new', 'חדשות'),
            ('waiting', 'ממתינות לחלק'),
            ('done', 'טופלו'),
            ('all', 'הכול'),
          ],
          _filter,
          (k) => setState(() => _filter = k),
        ),
        if (list.isEmpty)
          const MxEmpty(
            icon: Icons.check_circle_outline,
            title: 'אין כאן קריאות',
          )
        else
          _listCard([
            for (final w in list)
              ListTile(
                key: Key('wo-${w.id}'),
                minVerticalPadding: 12,
                leading: Icon(
                  w.urgent && w.isOpen
                      ? Icons.warning_amber_rounded
                      : mxPointIcon(db.point(w.pointId).type),
                  color: w.urgent && w.isOpen ? _bad : _woColor(w.status),
                ),
                title: Text(
                  w.desc,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${mxWoLabel(w.id)} · ${db.pointPath(w.pointId)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (w.urgent && w.isOpen) const MxTag('דחוף', _bad),
                    if (w.urgent && w.isOpen) const SizedBox(height: 4),
                    MxTag(_woStatus(w.status), _woColor(w.status)),
                  ],
                ),
                onTap: () => _open(context, _WorkOrderPage(w.id)),
              ),
          ]),
      ],
    );
  }
}

class _WorkOrderPage extends ConsumerWidget {
  const _WorkOrderPage(this.woId);
  final String woId;

  List<MxStep> _steps(MxWorkOrder w) {
    final s = w.status;
    final assignedOrLater = s != MxWoStatus.open;
    return [
      ('נפתחה', true, false),
      (
        s == MxWoStatus.open ? 'ממתין לטכנאי' : 'אצל טכנאי',
        assignedOrLater && s != MxWoStatus.assigned,
        s == MxWoStatus.open || s == MxWoStatus.assigned,
      ),
      if (s == MxWoStatus.waitingPart || w.poId.isNotEmpty)
        ('ממתין לחלק', s == MxWoStatus.done, s == MxWoStatus.waitingPart),
      ('טופלה', s == MxWoStatus.done, false),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final n = ref.read(mxDbProvider.notifier);
    final w = db.workOrder(woId);
    final p = db.point(w.pointId);
    final part = db.part(p.sku);
    final inStock = db.qty(p.sku);
    final po = w.poId.isEmpty ? null : db.po(w.poId);
    final worker = role == MxRole.tech || role == MxRole.manager;
    final canWork =
        role == MxRole.tech &&
        (w.status == MxWoStatus.open || w.status == MxWoStatus.assigned);
    final waiting = worker && w.status == MxWoStatus.waitingPart;
    final rejected =
        w.isOpen && w.status != MxWoStatus.waitingPart
            ? w.log
                .where((e) => e.text.startsWith('בקשת החלק נדחתה'))
                .firstOrNull
            : null;
    Widget info(IconData icon, String text, {Color? color}) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: color == null ? null : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    final actions = <Widget>[
      if (role == MxRole.manager && w.status == MxWoStatus.open)
        MxPrimaryButton(
          key: const Key('wo-assign'),
          label: 'שייכו לטכנאי',
          icon: Icons.engineering_outlined,
          color: kMxPrimary,
          onPressed: () async {
            final t = await _askTech(context, db);
            if (t == null || !context.mounted) return;
            _toast(context, n.assign(woId, t), 'שויך ל$t');
          },
        ),
      if (canWork) ...[
        MxPrimaryButton(
          key: const Key('wo-fix'),
          label:
              inStock < 1
                  ? 'החלק חסר במלאי – הזמינו חלק'
                  : 'תוקן, השתמשתי בחלק אחד',
          icon: Icons.check_circle_outline,
          color: kMxPrimary,
          onPressed:
              inStock < 1
                  ? null
                  : () => _undoable(
                    context,
                    ref,
                    n.closeWithPart(woId, kMxTechName),
                    'כל הכבוד! הקריאה נסגרה וירד חלק אחד מהמלאי',
                  ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    key: const Key('wo-fix-nopart'),
                    onPressed:
                        () => _undoable(
                          context,
                          ref,
                          n.closeNoPart(woId, kMxTechName),
                          'הקריאה נסגרה בלי חלק',
                        ),
                    child: const Text('תוקן בלי חלק'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    key: const Key('wo-need'),
                    onPressed: () async {
                      final qty = await _askQty(context, part.name);
                      if (qty == null || !context.mounted) return;
                      final err = n.requestPart(woId, qty, kMxTechName);
                      _toast(
                        context,
                        err,
                        'הבקשה נשלחה למנהל לאישור (${mxPoLabel(n.lastCreatedId ?? '')})',
                      );
                    },
                    child: const Text('צריך חלק'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      if (waiting)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    key: const Key('wo-found'),
                    style: FilledButton.styleFrom(backgroundColor: kMxPrimary),
                    onPressed: () async {
                      final yes = await _confirm(
                        context,
                        title: 'מצאתם את החלק?',
                        body:
                            'הקריאה תיסגר כמתוקנת, ובקשת החלק שעוד לא נשלחה לחנות תבוטל.',
                        ok: 'כן, תוקן',
                      );
                      if (!yes || !context.mounted) return;
                      _toast(
                        context,
                        n.foundPart(woId, _byRole(role)),
                        'הקריאה נסגרה',
                      );
                    },
                    child: const Text('מצאתי חלק ותיקנתי'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    key: const Key('wo-cancel-req'),
                    onPressed: () async {
                      final yes = await _confirm(
                        context,
                        title: 'לבטל את בקשת החלק?',
                        body: 'הקריאה תחזור לטכנאי, ובקשת החלק תבוטל.',
                        ok: 'בטלו בקשה',
                        danger: true,
                      );
                      if (!yes || !context.mounted) return;
                      _toast(
                        context,
                        n.cancelRequest(woId, _byRole(role)),
                        'בקשת החלק בוטלה',
                      );
                    },
                    child: const Text('בטל בקשה'),
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
    return _page(
      mxWoLabel(w.id),
      ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (w.urgent && w.isOpen)
            MxUrgentBanner(
              title: 'תקלה דחופה – בטיחות',
              body: mxSafetyInstruction(p.type, w.desc),
              onCall:
                  role == MxRole.manager
                      ? null
                      : () => _call(ref, context, kMxManagerPhone),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: kMxPink,
                        child: Icon(mxPointIcon(p.type), color: _bad, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          w.desc,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      MxTag(_woStatus(w.status), _woColor(w.status)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  info(Icons.place_outlined, db.pointPath(w.pointId)),
                  info(
                    Icons.person_outline,
                    'דיווח: ${w.reportedBy}, ${_date(w.createdAt)}',
                  ),
                  if (w.assignee.isNotEmpty)
                    info(Icons.engineering_outlined, 'טכנאי: ${w.assignee}'),
                  info(
                    Icons.inventory_2_outlined,
                    'חלק: ${part.name}, במלאי $inStock',
                  ),
                  if (po != null)
                    info(
                      Icons.local_shipping_outlined,
                      '${mxPoLabel(po.id)}: ${_poStatus(po.status)}',
                    ),
                  if (rejected != null)
                    info(Icons.info_outline, rejected.text, color: _bad),
                  if (w.hasPhoto)
                    info(Icons.photo_camera_outlined, 'צורפה תמונה מהדירה'),
                ],
              ),
            ),
          ),
          if (w.status == MxWoStatus.done)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined, color: _ok),
                  SizedBox(width: 8),
                  Text(
                    'הקריאה טופלה ונסגרה',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          MxTimeline(_steps(w)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 8, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'יומן הקריאה',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  key: const Key('wo-comment'),
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('הוספת הערה'),
                  onPressed: () async {
                    final text = await _askText(
                      context,
                      'הערה ל${mxWoLabel(w.id)}',
                      'מה חשוב לדעת?',
                    );
                    if (text == null ||
                        text.trim().isEmpty ||
                        !context.mounted) {
                      return;
                    }
                    _toast(
                      context,
                      n.comment(woId, text, _byRole(role)),
                      'ההערה נוספה',
                    );
                  },
                ),
              ],
            ),
          ),
          _listCard([
            for (final e in w.log)
              ListTile(
                dense: true,
                leading: const Icon(Icons.circle, size: 10, color: _brand),
                title: Text(e.text, style: const TextStyle(fontSize: 16)),
                subtitle: Text('${_time(e.at)} · ${e.by}'),
              ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.circle, size: 10, color: _brand),
              title: const Text('הקריאה נפתחה', style: TextStyle(fontSize: 16)),
              subtitle: Text('${_time(w.createdAt)} · ${w.reportedBy}'),
            ),
          ]),
        ],
      ),
      bottom: actions.isEmpty ? null : MxBottomBar(children: actions),
    );
  }
}

// ── home-staff report ────────────────────────────────────────────────────────

class _ReportPage extends ConsumerStatefulWidget {
  const _ReportPage({required this.onSent});
  final VoidCallback onSent;
  @override
  ConsumerState<_ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<_ReportPage> {
  String? _room;
  String? _point;
  String _reason = '';
  String _photo = '';
  final _text = TextEditingController();

  int get _step => _room == null ? 1 : (_point == null ? 2 : 3);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _back() => setState(() {
    if (_point != null) {
      _point = null;
      _reason = '';
    } else {
      _room = null;
    }
  });

  void _clear() => setState(() {
    _room = null;
    _point = null;
    _reason = '';
    _photo = '';
    _text.clear();
  });

  Future<void> _takePhoto() async {
    final shot = await ref.read(taskPhotoPickerProvider)(context);
    if (shot == null || shot.isEmpty || !mounted) return;
    setState(() => _photo = shot);
  }

  String get _desc =>
      [_reason, _text.text.trim()].where((s) => s.isNotEmpty).join(' – ');

  Future<void> _send() async {
    final n = ref.read(mxDbProvider.notifier);
    final existing = mxOpenOnPoint(ref.read(mxDbProvider), _point!);
    if (existing != null) {
      final err = n.comment(existing.id, _desc, kMxStaffLabel);
      if (err != null) return _toast(context, err, '');
      _clear();
      _toast(
        context,
        null,
        'נוסף ל${mxWoLabel(existing.id)} שכבר פתוחה על הנקודה הזו',
      );
      return;
    }
    final type = ref.read(mxDbProvider).point(_point!).type;
    final err = n.report(
      _point!,
      _desc,
      kMxStaffLabel,
      photo: _photo.isNotEmpty,
      photoData: _photo,
    );
    if (err != null) return _toast(context, err, '');
    final w = ref.read(mxDbProvider).workOrder(n.lastCreatedId!);
    _clear();
    if (w.urgent) {
      await _showSafety(context, ref, w, type, onMine: widget.onSent);
      return;
    }
    await mxShowSuccess(
      context,
      title: 'הדיווח נשלח',
      body:
          'מנהל האחזקה קיבל את ${mxWoLabel(w.id)} ויטפל בה.\nאפשר לעקוב ב"הדיווחים שלי".',
      actions: [
        ('לדיווחים שלי', const Key('success-mine'), widget.onSent),
        ('דיווח נוסף', const Key('success-again'), () {}),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final u = db.unit(kMxStaffUnit);
    final titles = ['איפה התקלה?', 'מה לא עובד?', 'מה קרה?'];
    final list = ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              if (_step > 1)
                IconButton(
                  key: const Key('rep-back'),
                  tooltip: 'חזרה',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _back,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titles[_step - 1],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'שלב $_step מתוך 3 · ${db.site(u.siteId).city} · ${u.name}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _step / 3,
              minHeight: 6,
              color: kMxPrimary,
              backgroundColor: kMxLine,
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder:
              (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
          child: Column(
            key: ValueKey(_step),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_step == 1)
                MxTileGrid(
                  children: [
                    for (final r in db.roomsOf(kMxStaffUnit))
                      MxTile(
                        key: Key('rep-room-${r.id}'),
                        icon: mxRoomIcon(r.name),
                        label: r.name,
                        caption: '${db.pointsOf(r.id).length} פריטים',
                        alert: db
                            .pointsOf(r.id)
                            .any((p) => p.status == MxPointStatus.faulty),
                        onTap: () => setState(() => _room = r.id),
                      ),
                  ],
                ),
              if (_step == 2)
                MxTileGrid(
                  children: [
                    for (final p in db.pointsOf(_room!))
                      MxTile(
                        key: Key('rep-point-${p.id}'),
                        icon: mxPointIcon(p.type),
                        label: '${p.type} ${p.num}',
                        caption:
                            mxOpenOnPoint(db, p.id) != null
                                ? 'כבר דווח'
                                : p.loc,
                        alert: p.status == MxPointStatus.faulty,
                        onTap: () => setState(() => _point = p.id),
                      ),
                  ],
                ),
              if (_step == 3) ..._details(db),
            ],
          ),
        ),
      ],
    );
    if (_step < 3) return list;
    final existing = mxOpenOnPoint(db, _point!);
    return Column(
      children: [
        Expanded(child: list),
        MxBottomBar(
          children: [
            MxPrimaryButton(
              key: const Key('rep-send'),
              label: existing == null ? 'שלחו דיווח' : 'הוסיפו לקריאה הקיימת',
              icon: Icons.send_rounded,
              onPressed: _desc.isEmpty ? null : _send,
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _details(MxDb db) {
    final p = db.point(_point!);
    final existing = mxOpenOnPoint(db, p.id);
    return [
      Card(
        child: ListTile(
          minVerticalPadding: 14,
          leading: CircleAvatar(
            backgroundColor: kMxTealTint,
            child: Icon(mxPointIcon(p.type), color: kMxPrimary),
          ),
          title: Text(
            p.label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Text(db.room(p.roomId).name),
        ),
      ),
      if (existing != null)
        Container(
          key: const Key('rep-existing'),
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kMxGoldTint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'כבר דווח על הנקודה הזו (${mxWoLabel(existing.id)}: ${existing.desc}). '
            'מה שתכתבו יתווסף לקריאה הקיימת.',
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: _reasonChips(
          'rep-reason',
          p.type,
          _reason,
          (r) => setState(() => _reason = _reason == r ? '' : r),
        ),
      ),
      if (mxIsUrgentText(_desc))
        MxUrgentBanner(
          title: 'זו תקלה דחופה',
          body: mxSafetyInstruction(p.type, _desc),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: TextField(
          key: const Key('rep-text'),
          controller: _text,
          maxLines: 2,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'פרטים נוספים (לא חובה)',
            hintText: 'לדוגמה: התחיל אתמול בערב',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        child: SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            key: const Key('rep-photo'),
            icon: Icon(
              _photo.isNotEmpty
                  ? Icons.check_circle
                  : Icons.photo_camera_outlined,
            ),
            label: Text(
              _photo.isNotEmpty
                  ? 'התמונה צורפה (לחצו לצילום מחדש)'
                  : 'צלמו תמונה (עוזר לטכנאי)',
            ),
            onPressed: _takePhoto,
          ),
        ),
      ),
    ];
  }
}

// ── preventive maintenance ───────────────────────────────────────────────────

class _PmPage extends ConsumerWidget {
  const _PmPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final now = ref.watch(mxClockProvider)();
    final all = db.pmDue(now);
    final groups = [
      ('באיחור', MxDue.overdue, _bad),
      ('השבוע', MxDue.soon, _warn),
      ('בהמשך', MxDue.ok, _ok),
    ];
    Widget card(MxPmRule r, MxDue d, Color c) => MxEdgeCard(
      key: Key('pm-${r.id}'),
      color: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              MxTag(mxDaysLabel(r.nextDue, now), c),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${r.scope} · יעד ${_date(r.nextDue)}',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          if (r.isLegal)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.gavel_outlined, size: 16, color: _brand),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'חובה: ${r.legalBasis}',
                      style: const TextStyle(
                        color: _brand,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (d != MxDue.ok)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  key: Key('pm-done-${r.id}'),
                  style: FilledButton.styleFrom(backgroundColor: _brand),
                  icon: const Icon(Icons.task_alt),
                  label: const Text('סמנו כבוצע'),
                  onPressed:
                      () => _undoable(
                        context,
                        ref,
                        ref.read(mxDbProvider.notifier).completePm(r.id),
                        'נרשם כבוצע, והמועד הבא נקבע',
                      ),
                ),
              ),
            ),
        ],
      ),
    );
    final legal = db.pmRules.where((r) => r.isLegal).length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _pageTitle(
          'בדיקות ותחזוקה',
          '$legal בדיקות חובה בחוק. המערכת זוכרת את המועד הבא של כל אחת.',
        ),
        for (final (title, due, color) in groups)
          if (all.any((x) => x.$2 == due)) ...[
            MxSectionTitle(
              title,
              count: all.where((x) => x.$2 == due).length,
              color: color,
            ),
            for (final (r, d) in all.where((x) => x.$2 == due))
              card(r, d, color),
          ],
      ],
    );
  }
}

// ── purchasing: orders + stock in one tab ────────────────────────────────────

class _BuyPage extends ConsumerWidget {
  const _BuyPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(_buySectionProvider);
    final db = ref.watch(mxDbProvider);
    final pending = db.pendingApproval.length;
    final low = db.lowStock.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: kMxPrimary,
              selectedForegroundColor: Colors.white,
              foregroundColor: kMxPrimary,
              side: const BorderSide(color: kMxLine),
            ),
            segments: [
              ButtonSegment(
                value: 'orders',
                label: Text(
                  pending > 0 ? 'הזמנות ($pending לאישור)' : 'הזמנות',
                  key: const Key('buy-orders'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ButtonSegment(
                value: 'stock',
                label: Text(
                  low > 0 ? 'מלאי ($low להזמין)' : 'מלאי',
                  key: const Key('buy-stock'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            selected: {section},
            onSelectionChanged:
                (s) => ref.read(_buySectionProvider.notifier).state = s.first,
          ),
        ),
        Expanded(
          child: section == 'stock' ? const _StockPage() : const _OrdersPage(),
        ),
      ],
    );
  }
}

// ── stock ────────────────────────────────────────────────────────────────────

class _StockPage extends ConsumerStatefulWidget {
  const _StockPage();
  @override
  ConsumerState<_StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<_StockPage> {
  String _filter = 'הכול';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final types = [
      'הכול',
      'להזמין',
      ...{for (final p in db.parts) p.storeType},
    ];
    final shown =
        db.parts.where((p) {
          if (_filter == 'הכול') return true;
          if (_filter == 'להזמין') return db.qty(p.sku) < p.min;
          return p.storeType == _filter;
        }).toList();
    final low = db.lowStock.length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _pageTitle(
          low == 0 ? 'המלאי מלא' : '$low חלקים להזמין',
          low == 0
              ? 'כל החלקים מעל המינימום.'
              : 'לחיצה אחת יוצרת הזמנה נפרדת לכל חנות, לאישורך.',
        ),
        if (role == MxRole.manager) ...[
          MxPrimaryButton(
            key: const Key('auto-reorder'),
            label: low == 0 ? 'אין מה להזמין' : 'הזמינו את כל מה שחסר ($low)',
            icon: Icons.add_shopping_cart,
            color: kMxPrimary,
            onPressed:
                low == 0
                    ? null
                    : () {
                      final err = ref.read(mxDbProvider.notifier).autoReorder();
                      _toast(
                        context,
                        err,
                        'נוצרו בקשות הזמנה, אחת לכל חנות. הן מחכות לאישורך ב"הזמנות".',
                      );
                      if (err == null) {
                        ref.read(_buySectionProvider.notifier).state = 'orders';
                      }
                    },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('import-prices'),
                icon: const Icon(Icons.upload_file),
                label: const Text('קיבלתי מחירון מהחנות (אקסל או CSV)'),
                onPressed: _importPrices,
              ),
            ),
          ),
        ],
        _chips(
          'stock-filter',
          [for (final t in types) (t, t == 'להזמין' ? 'להזמין ($low)' : t)],
          _filter,
          (k) => setState(() => _filter = k),
        ),
        if (shown.isEmpty)
          const MxEmpty(
            icon: Icons.inventory_2_outlined,
            title: 'אין פריטים בסינון הזה',
          )
        else
          _listCard([
            for (final p in shown)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${db.qty(p.sku)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: db.qty(p.sku) < p.min ? _bad : kMxInk,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    MxStockBar(qty: db.qty(p.sku), min: p.min),
                    const SizedBox(height: 4),
                    Text(
                      '${p.storeType} · מינימום ${p.min} · ${mxShekels(db.priceAt(kMxStoreId, p.sku))}'
                      '${db.onOrder(p.sku) > 0 ? ' · בהזמנה ${db.onOrder(p.sku)}' : ''}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ]),
      ],
    );
  }

  Future<void> _importPrices() async {
    const sample =
        'מק"ט,שם,מחיר\nEL-T8,פלורסנט LED T8,19.90\nEL-SK16,מנגנון שקע 16A,16.50\nHW-WSTOP,מעצור חלון,29\n';
    final csv = await _askText(
      context,
      'הדביקו את המחירון שקיבלתם',
      'עמודות: מק״ט, שם, מחיר',
      initial: sample,
      ok: 'קלטו מחירים',
      maxLines: 8,
    );
    if (csv == null || !mounted) return;
    final (err, imp) = ref
        .read(mxDbProvider.notifier)
        .importPrices(kMxStoreId, csv);
    final extra =
        imp == null || imp.errors.isEmpty
            ? ''
            : ', ${imp.errors.length} שורות לא נקלטו';
    _toast(
      context,
      err,
      'נקלטו ${imp?.matched.length ?? 0} מחירים מ${ref.read(mxDbProvider).store(kMxStoreId).name}$extra',
    );
  }
}

// ── purchase orders (manager / tech) ─────────────────────────────────────────

List<MxStep> _poSteps(MxPurchaseOrder o) {
  final rank = switch (o.status) {
    MxPoStatus.pendingApproval => 0,
    MxPoStatus.approved => 1,
    MxPoStatus.sent ||
    MxPoStatus.storeConfirmed ||
    MxPoStatus.storePartial => 2,
    MxPoStatus.ready => 3,
    MxPoStatus.received => 4,
    MxPoStatus.rejected => -1,
  };
  const labels = ['אישור', 'נשלחה', 'בחנות', 'מוכנה', 'התקבלה'];
  return [
    for (var i = 0; i < labels.length; i++)
      (labels[i], i < rank || rank == 4, i == rank && rank != 4),
  ];
}

/// Open WhatsApp with the order; on success mark it sent. Returns whether
/// WhatsApp opened.
Future<bool> _sendWhatsApp(
  BuildContext context,
  WidgetRef ref,
  String poId,
) async {
  final n = ref.read(mxDbProvider.notifier);
  try {
    final uri = mxWhatsAppUri(
      ref.read(mxDbProvider),
      ref.read(mxDbProvider).po(poId),
      baseUrl: kMxStoreBaseUrl,
      orgName: kMxOrgName,
    );
    final ok = await ref.read(urlLauncherProvider)(uri);
    if (ok && ref.read(mxDbProvider).po(poId).status == MxPoStatus.approved) {
      n.markSent(poId);
    }
    return ok;
  } on MxError catch (e) {
    if (context.mounted) _toast(context, e.message, '');
    return false;
  }
}

class _OrdersPage extends ConsumerStatefulWidget {
  const _OrdersPage();
  @override
  ConsumerState<_OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<_OrdersPage> {
  String _filter = 'open';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final n = ref.read(mxDbProvider.notifier);
    // Rebuild when the store moves its order on the BuildSmart dashboard.
    ref.watch(ordersEngineProvider);
    if (db.purchaseOrders.isEmpty) {
      return const MxEmpty(
        icon: Icons.shopping_cart_outlined,
        title: 'אין הזמנות עדיין',
        body: 'הזמנה נוצרת כשטכנאי מבקש חלק, או מהמלאי בלחיצה אחת.',
      );
    }
    final pending = db.pendingApproval.length;
    final all = db.purchaseOrders.reversed.toList();
    final list = switch (_filter) {
      'pending' =>
        all.where((o) => o.status == MxPoStatus.pendingApproval).toList(),
      'closed' => all.where((o) => !o.isOpen).toList(),
      'all' => all,
      _ => all.where((o) => o.isOpen).toList(),
    };
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _pageTitle(
          pending == 0 ? 'הזמנות לחנויות' : '$pending מחכות לאישורך',
          'הזמנה מאושרת נשלחת לחנות בוואטסאפ, ומופיעה גם בלוח החנות.',
        ),
        _chips(
          'po-filter',
          [
            ('open', 'פתוחות'),
            ('pending', 'לאישור ($pending)'),
            ('closed', 'סגורות'),
            ('all', 'הכול'),
          ],
          _filter,
          (k) => setState(() => _filter = k),
        ),
        if (list.isEmpty)
          const MxEmpty(icon: Icons.inbox_outlined, title: 'אין כאן הזמנות'),
        for (final o in list) _poCard(context, db, n, role, o),
      ],
    );
  }

  Widget _poCard(
    BuildContext context,
    MxDb db,
    MxNotifier n,
    MxRole role,
    MxPurchaseOrder o,
  ) {
    final stage = n.storeStageOf(o);
    return MxEdgeCard(
      key: Key('po-${o.id}'),
      color: _poColor(o.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: kMxTealTint,
                child: Icon(Icons.storefront_outlined, color: _brand),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      db.store(o.storeId).name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${mxPoLabel(o.id)} · ${o.requestedBy}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              MxTag(_poStatus(o.status), _poColor(o.status)),
            ],
          ),
          const SizedBox(height: 10),
          for (final l in o.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    l.missing
                        ? Icons.remove_circle_outline
                        : Icons.check_circle_outline,
                    size: 16,
                    color: l.missing ? _bad : _ok,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l.missing
                          ? '${db.part(l.sku).name}: יש ${l.supplied} מתוך ${l.qty}'
                          : '${l.qty} × ${db.part(l.sku).name}',
                      style: TextStyle(color: l.missing ? _bad : null),
                    ),
                  ),
                  Text(
                    mxShekels(l.totalAgorot),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          const Divider(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'סה״כ לפני מע״מ',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Text(
                mxShekels(o.totalAgorot),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (o.status == MxPoStatus.rejected && o.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'סיבת הדחייה: ${o.note}',
                style: const TextStyle(color: _bad),
              ),
            ),
          if (o.status != MxPoStatus.rejected) MxTimeline(_poSteps(o)),
          if (stage != null)
            Text(
              'בלוח החנות: ${mxStageLabel(stage)}',
              key: Key('po-bs-${o.id}'),
              style: const TextStyle(
                color: _brand,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          if (o.fulfil == MxFulfil.delivery && o.status == MxPoStatus.ready)
            const Text(
              'החנות שלחה את ההזמנה במשלוח',
              style: TextStyle(fontSize: 14),
            ),
          if (o.invoiceNo.isNotEmpty)
            Text(
              'חשבונית ${o.invoiceNo}${o.allocationNo.isEmpty ? '' : ', מספר הקצאה ${o.allocationNo}'}',
              style: const TextStyle(fontSize: 14),
            ),
          if (role == MxRole.manager) ..._poActions(context, db, n, o),
        ],
      ),
    );
  }

  List<Widget> _poActions(
    BuildContext context,
    MxDb db,
    MxNotifier n,
    MxPurchaseOrder o,
  ) {
    Widget wide(Widget b) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(width: double.infinity, height: 48, child: b),
    );
    final store = db.store(o.storeId).name;
    return [
      if (o.status == MxPoStatus.pendingApproval)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    key: Key('po-approve-${o.id}'),
                    style: FilledButton.styleFrom(backgroundColor: _brand),
                    icon: const Icon(Icons.send_rounded),
                    label: const FittedBox(child: Text('אשרו ושלחו בוואטסאפ')),
                    onPressed: () async {
                      final err = n.approve(o.id);
                      if (err != null) return _toast(context, err, '');
                      final sent = await _sendWhatsApp(context, ref, o.id);
                      if (!context.mounted) return;
                      _toast(
                        context,
                        null,
                        sent
                            ? 'אושר ונפתח וואטסאפ אל $store. לחצו שם "שלח".'
                            : 'אושר, אבל טרם נשלח. אפשר לשלוח שוב מהכרטיס.',
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    key: Key('po-reject-${o.id}'),
                    onPressed: () async {
                      final why = await _askText(
                        context,
                        'למה לדחות?',
                        'הסיבה תוצג לטכנאי',
                        quick: const [
                          'יש במחסן',
                          'יקר מדי – לבדוק חנות אחרת',
                          'לא דחוף עכשיו',
                        ],
                        ok: 'דחו בקשה',
                      );
                      if (why == null || !context.mounted) return;
                      _toast(
                        context,
                        n.reject(o.id, reason: why),
                        'הבקשה נדחתה, והטכנאי רואה את הסיבה',
                      );
                    },
                    child: const Text('דחו'),
                  ),
                ),
              ),
            ],
          ),
        ),
      if (o.token.isNotEmpty && o.isOpen) ...[
        if (o.status == MxPoStatus.approved)
          wide(
            FilledButton.icon(
              key: Key('po-wa-${o.id}'),
              style: FilledButton.styleFrom(backgroundColor: _brand),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('שלחו לחנות בוואטסאפ'),
              onPressed: () async {
                final ok = await _sendWhatsApp(context, ref, o.id);
                if (!context.mounted) return;
                _toast(
                  context,
                  ok ? null : 'לא ניתן לפתוח וואטסאפ',
                  'נפתח וואטסאפ עם ההזמנה',
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 4,
            children: [
              if (o.status != MxPoStatus.approved)
                TextButton.icon(
                  key: Key('po-wa-${o.id}'),
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('שלחו שוב בוואטסאפ'),
                  onPressed: () => _sendWhatsApp(context, ref, o.id),
                ),
              TextButton.icon(
                icon: const Icon(Icons.link, size: 18),
                label: const Text('העתקת קישור'),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: mxStoreLink(kMxStoreBaseUrl, o.token)),
                  );
                  if (context.mounted) _toast(context, null, 'הקישור הועתק');
                },
              ),
              TextButton.icon(
                key: Key('po-storeview-${o.id}'),
                icon: const Icon(Icons.storefront_outlined, size: 18),
                label: const Text('מה החנות רואה'),
                onPressed: () => _open(context, MxStorePage(token: o.token)),
              ),
              if (mxCanReroute(db, o))
                TextButton.icon(
                  key: Key('po-reroute-${o.id}'),
                  icon: const Icon(Icons.alt_route, size: 18),
                  label: const Text('החוסרים לחנות אחרת'),
                  onPressed:
                      () => _toast(
                        context,
                        n.reroute(o.id),
                        'נוצרה הזמנה לחנות חלופית, והיא מחכה לאישורך',
                      ),
                ),
            ],
          ),
        ),
        if (o.status != MxPoStatus.approved)
          wide(
            OutlinedButton.icon(
              key: Key('po-receive-${o.id}'),
              icon: const Icon(Icons.inventory_outlined),
              label: const Text('קיבלתי את הסחורה'),
              onPressed: () async {
                final arriving = [
                  for (final l in o.lines)
                    if (l.supplied > 0)
                      '${l.supplied} × ${db.part(l.sku).name}',
                ];
                final yes = await _confirm(
                  context,
                  title: 'לקלוט את הסחורה למלאי?',
                  body:
                      arriving.isEmpty
                          ? 'לא סומנו פריטים שהגיעו.'
                          : 'יתווספו למלאי:\n${arriving.join('\n')}',
                  ok: 'קלטו למלאי',
                );
                if (!yes || !context.mounted) return;
                _toast(
                  context,
                  n.receive(o.id),
                  'המלאי עודכן. קריאות שחיכו לחלק חזרו לטכנאי.',
                );
              },
            ),
          ),
      ],
    ];
  }
}

// ── store side (link page + store inbox) ─────────────────────────────────────

class _StoreInbox extends ConsumerWidget {
  const _StoreInbox();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final mine =
        db.purchaseOrders
            .where((o) => o.storeId == kMxStoreId && o.token.isNotEmpty)
            .toList()
            .reversed
            .toList();
    final open = mine.where((o) => o.isOpen).length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _pageTitle(
          db.store(kMxStoreId).name,
          open == 0
              ? 'אין הזמנות פתוחות כרגע.'
              : open == 1
              ? 'הזמנה אחת מחכה לך'
              : '$open הזמנות מחכות לך',
        ),
        if (mine.isEmpty)
          const MxEmpty(
            icon: Icons.storefront_outlined,
            title: 'עוד אין הזמנות',
            body: 'כשמחלקת האחזקה תאשר הזמנה, היא תופיע כאן ותגיע גם בוואטסאפ.',
          )
        else
          _listCard([
            for (final o in mine)
              ListTile(
                key: Key('inbox-${o.id}'),
                minVerticalPadding: 14,
                leading: const CircleAvatar(
                  backgroundColor: kMxTealTint,
                  child: Icon(Icons.receipt_long_outlined, color: _brand),
                ),
                title: Text(
                  '${mxPoLabel(o.id)} · ${o.lines.length} פריטים',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${mxShekels(o.totalAgorot)} · ${_date(o.createdAt)}',
                ),
                trailing: MxTag(_poStatus(o.status), _poColor(o.status)),
                onTap: () => _open(context, MxStorePage(token: o.token)),
              ),
          ]),
      ],
    );
  }
}

/// The page a store owner reaches from the WhatsApp link `/s/<token>` —
/// no login; the token is the only key. Also used from the store dashboard.
/// [fromLink]: opened directly from WhatsApp, so there is nowhere to go back.
class MxStorePage extends ConsumerStatefulWidget {
  const MxStorePage({required this.token, this.fromLink = false, super.key});
  final String token;
  final bool fromLink;
  @override
  ConsumerState<MxStorePage> createState() => _MxStorePageState();
}

class _MxStorePageState extends ConsumerState<MxStorePage> {
  final _invoice = TextEditingController();
  final _alloc = TextEditingController();

  @override
  void dispose() {
    _invoice.dispose();
    _alloc.dispose();
    super.dispose();
  }

  void _ready(MxFulfil how) {
    final n = ref.read(mxDbProvider.notifier);
    _toast(
      context,
      n.storeReady(
        widget.token,
        invoiceNo: _invoice.text,
        allocationNo: _alloc.text,
        fulfil: how,
      ),
      how == MxFulfil.delivery
          ? 'סומן שיצא למשלוח. מחלקת האחזקה קיבלה עדכון.'
          : 'סומן מוכן לאיסוף. מחלקת האחזקה קיבלה עדכון.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final n = ref.read(mxDbProvider.notifier);
    final o = db.poByToken(widget.token);
    if (o == null) {
      return _page(
        'הזמנה',
        back: !widget.fromLink,
        const MxEmpty(
          icon: Icons.link_off,
          title: 'הקישור לא תקף',
          body: 'ייתכן שההזמנה בוטלה. אפשר לפנות למחלקת האחזקה.',
        ),
      );
    }
    final closed = !o.isOpen;
    final needsAlloc = mxNeedsAllocation(o);
    final site = mxPoDeliverySite(db, o);
    final anyMissing = o.lines.any((l) => l.missing);
    final unconfirmed =
        o.status == MxPoStatus.sent || o.status == MxPoStatus.approved;
    return _page(
      mxPoLabel(o.id),
      back: !widget.fromLink,
      ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mxShekels(o.totalAgorot),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: kMxPrimary,
                          ),
                        ),
                      ),
                      MxTag(_poStatus(o.status), _poColor(o.status)),
                    ],
                  ),
                  Text(
                    'הזמנה מ$kMxOrgName · ${o.lines.length} פריטים · לפני מע״מ',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const Divider(height: 20),
                  MxInfoRow(
                    Icons.place_outlined,
                    'כתובת',
                    Text(
                      site.address.isEmpty
                          ? '${site.city} – ${site.name}'
                          : site.address,
                    ),
                  ),
                  const MxInfoRow(
                    Icons.person_outline,
                    'איש קשר',
                    Text('מחלקת האחזקה, $kMxManagerPhone'),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      key: const Key('store-call'),
                      icon: const Icon(Icons.call),
                      label: const Text('התקשרו למחלקת האחזקה'),
                      onPressed: () => _call(ref, context, kMxManagerPhone),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!closed)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'חסר לכם משהו? שנו את הכמות שיש לכם עם − ו־+, או לחצו "אין לי".',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
          _listCard([
            for (final l in o.lines)
              Padding(
                key: Key('store-line-${l.sku}'),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            db.part(l.sku).name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              decoration:
                                  l.supplied == 0
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                        ),
                        if (l.missing)
                          MxTag(
                            l.supplied == 0
                                ? 'אין'
                                : 'יש ${l.supplied} מתוך ${l.qty}',
                            _warn,
                          ),
                      ],
                    ),
                    Text(
                      'הוזמנו ${l.qty} · ${mxShekels(l.unitAgorot)} ליח׳',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    if (!closed)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            MxStepper(
                              keyPrefix: 'store-sup-${l.sku}',
                              value: l.supplied,
                              max: l.qty,
                              onChanged:
                                  (v) => _undoable(
                                    context,
                                    ref,
                                    n.storeSupplied(widget.token, l.sku, v),
                                    'עודכן: יש $v מתוך ${l.qty}',
                                  ),
                            ),
                            const Spacer(),
                            if (l.supplied > 0)
                              TextButton(
                                key: Key('store-missing-${l.sku}'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black54,
                                ),
                                onPressed:
                                    () => _undoable(
                                      context,
                                      ref,
                                      n.storeMissing(widget.token, l.sku),
                                      'סומן שאין לכם את הפריט',
                                    ),
                                child: const Text('אין לי'),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ]),
          if (!closed) ...[
            const MxSectionTitle('כשההזמנה מוכנה'),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                key: const Key('store-invoice'),
                controller: _invoice,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'מספר חשבונית (לא חובה)',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                key: const Key('store-alloc'),
                controller: _alloc,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      needsAlloc
                          ? 'מספר הקצאה (חובה מעל 5,000 ₪)'
                          : 'מספר הקצאה (אם יש)',
                ),
              ),
            ),
          ] else
            const MxEmpty(
              icon: Icons.verified_outlined,
              title: 'ההזמנה סגורה',
              body: 'תודה על השירות!',
            ),
        ],
      ),
      bottom:
          closed
              ? null
              : MxBottomBar(
                children: [
                  if (unconfirmed)
                    MxPrimaryButton(
                      key: const Key('store-confirm'),
                      label: anyMissing ? 'מאשר את מה שיש' : 'מאשר, יש לי הכול',
                      icon: Icons.thumb_up_alt_outlined,
                      color: kMxPrimary,
                      onPressed:
                          () => _toast(
                            context,
                            n.storeConfirm(widget.token),
                            'תודה! ההזמנה אושרה',
                          ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              key: const Key('store-ready'),
                              icon: const Icon(Icons.storefront_outlined),
                              label: const FittedBox(
                                child: Text('מוכן לאיסוף'),
                              ),
                              onPressed: () => _ready(MxFulfil.pickup),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              key: const Key('store-ship'),
                              icon: const Icon(Icons.local_shipping_outlined),
                              label: const FittedBox(child: Text('יצא למשלוח')),
                              onPressed: () => _ready(MxFulfil.delivery),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

/// Standalone app wrapper (used by the demo entry and tests): RTL + theme.
class MxApp extends StatelessWidget {
  const MxApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ניהול אחזקה ורכש',
    theme: mxTheme(),
    locale: const Locale('he'),
    builder:
        (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
    home: const MxHome(),
  );
}
