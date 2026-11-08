/// Maintenance module — screens (Hebrew, RTL, light, phone-first).
///
/// [MxHome] is the whole module: a role switch (manager / tech / staff /
/// store) and per-role tabs. Drill-downs are pushed routes that watch
/// [mxDbProvider], so every screen updates live after any action.
library;

import 'package:buildsmart/features/maintenance/mx_brand.dart';
import 'package:buildsmart/features/maintenance/mx_bridge.dart';
import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_state.dart';
import 'package:buildsmart/features/maintenance/mx_store_link.dart';
import 'package:buildsmart/features/maintenance/mx_ui.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo identities (real auth maps users to these).
const String kMxTechName = 'יוסי – טכנאי';
const String kMxStaffUnit = 'jrs-3';
const String kMxStaffLabel = 'מדריך – דירה 3';
const String kMxStoreId = 'st-tambur';

const Color _brand = kMxPrimary;
const Color _bad = kMxBad;
const Color _warn = kMxWarn;
const Color _ok = kMxOk;

ThemeData mxTheme() => mxBrandTheme();

void _toast(BuildContext context, String? error, String success) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(error ?? success),
        duration: const Duration(milliseconds: 2500),
        backgroundColor: error == null ? null : _bad,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.color);
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
    ),
  );
}

Widget _section(String title) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
  child: Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  ),
);

Widget _listCard(List<Widget> tiles) => Card(
  clipBehavior: Clip.antiAlias,
  child: Column(
    children: [
      for (var i = 0; i < tiles.length; i++) ...[
        if (i > 0) const Divider(height: 1),
        tiles[i],
      ],
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
  MxPoStatus.sent => 'נשלח לחנות',
  MxPoStatus.storeConfirmed => 'החנות אישרה',
  MxPoStatus.storePartial => 'חסרים פריטים',
  MxPoStatus.ready => 'מוכן לאיסוף',
  MxPoStatus.received => 'התקבל',
  MxPoStatus.rejected => 'נדחה',
};

Color _poColor(MxPoStatus s) => switch (s) {
  MxPoStatus.pendingApproval || MxPoStatus.storePartial => _warn,
  MxPoStatus.received => _ok,
  MxPoStatus.rejected => _bad,
  _ => _brand,
};

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

// ── shell ────────────────────────────────────────────────────────────────────

class MxHome extends ConsumerStatefulWidget {
  const MxHome({super.key});
  @override
  ConsumerState<MxHome> createState() => _MxHomeState();
}

typedef _Tab = (String key, IconData icon, String label);

class _MxHomeState extends ConsumerState<MxHome> {
  int _tab = 0;

  List<_Tab> _tabs(MxRole role) => switch (role) {
    MxRole.manager => const [
      ('home', Icons.dashboard_outlined, 'לוח'),
      ('sites', Icons.apartment_outlined, 'מסגרות'),
      ('wo', Icons.build_outlined, 'קריאות'),
      ('pm', Icons.event_available_outlined, 'תחזוקה'),
      ('stock', Icons.inventory_2_outlined, 'מלאי'),
      ('po', Icons.shopping_cart_outlined, 'הזמנות'),
    ],
    MxRole.tech => const [
      ('wo', Icons.build_outlined, 'המשימות שלי'),
      ('sites', Icons.apartment_outlined, 'מסגרות'),
      ('stock', Icons.inventory_2_outlined, 'מלאי'),
      ('po', Icons.shopping_cart_outlined, 'בקשות'),
    ],
    MxRole.staff => const [
      ('report', Icons.campaign_outlined, 'דיווח תקלה'),
      ('wo', Icons.list_alt_outlined, 'הדיווחים שלי'),
    ],
    MxRole.store => const [
      ('store', Icons.storefront_outlined, 'הזמנות לחנות'),
    ],
  };

  void _go(String key) {
    final i = _tabs(ref.read(mxRoleProvider)).indexWhere((t) => t.$1 == key);
    if (i >= 0) setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(mxRoleProvider);
    final db = ref.watch(mxDbProvider);
    final tabs = _tabs(role);
    final tab = _tab.clamp(0, tabs.length - 1);
    int badge(String key) => switch (key) {
      'wo' => db.openWorkOrders.length,
      'stock' => db.lowStock.length,
      'po' => role == MxRole.manager ? db.pendingApproval.length : 0,
      _ => 0,
    };
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(36),
          ),
        ),
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: kMxWordmark,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
              ),
              TextSpan(
                text: '  ·  $kMxSubtitle',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'איפוס הדגמה',
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              ref.read(mxDbProvider.notifier).reset();
              _toast(context, null, 'ההדגמה אופסה');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<MxRole>(
                key: const Key('mx-roles'),
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  foregroundColor: Colors.white,
                  selectedForegroundColor: _brand,
                  selectedBackgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                segments: const [
                  ButtonSegment(
                    value: MxRole.manager,
                    label: Text('מנהל', maxLines: 1, softWrap: false),
                  ),
                  ButtonSegment(
                    value: MxRole.tech,
                    label: Text('טכנאי', maxLines: 1, softWrap: false),
                  ),
                  ButtonSegment(
                    value: MxRole.staff,
                    label: Text('מדריך', maxLines: 1, softWrap: false),
                  ),
                  ButtonSegment(
                    value: MxRole.store,
                    label: Text('חנות', maxLines: 1, softWrap: false),
                  ),
                ],
                selected: {role},
                onSelectionChanged: (s) {
                  ref.read(mxRoleProvider.notifier).state = s.first;
                  setState(() => _tab = 0);
                },
              ),
            ),
          ),
        ),
      ),
      body: switch (tabs[tab].$1) {
        'home' => _Dashboard(onGo: _go),
        'sites' => const _SitesPage(),
        'wo' => const _WorkOrdersPage(),
        'pm' => const _PmPage(),
        'stock' => const _StockPage(),
        'po' => const _OrdersPage(),
        'report' => _ReportPage(onSent: () => _go('wo')),
        _ => const _StoreInbox(),
      },
      bottomNavigationBar:
          tabs.length < 2
              ? null
              : NavigationBar(
                selectedIndex: tab,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                height: 64,
                onDestinationSelected: (i) => setState(() => _tab = i),
                destinations: [
                  for (final t in tabs)
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: badge(t.$1) > 0,
                        label: Text('${badge(t.$1)}'),
                        child: Icon(t.$2),
                      ),
                      label: t.$3,
                    ),
                ],
              ),
    );
  }
}

// ── dashboard ────────────────────────────────────────────────────────────────

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.onGo});
  final void Function(String) onGo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final now = ref.watch(mxClockProvider)();
    final due = db.pmDue(now);
    final overdue = due.where((d) => d.$2 == MxDue.overdue).length;
    final soon = due.where((d) => d.$2 == MxDue.soon).length;
    final open = db.openWorkOrders.length;
    final pending = db.pendingApproval.length;
    final parts = <String>[
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
            : parts.join(' · ');
    Widget stat(
      String key,
      int v,
      String label,
      IconData icon,
      Color c,
      String go,
    ) => Expanded(
      child: MxStatCard(
        key: Key('kpi-$key'),
        value: v,
        label: label,
        icon: icon,
        color: c,
        onTap: () => onGo(go),
      ),
    );
    const gap = SizedBox(width: 10, height: 10);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        MxHero(title: mxGreeting(now), subtitle: summary),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Row(
                children: [
                  stat(
                    'wo',
                    open,
                    'קריאות פתוחות',
                    Icons.build_outlined,
                    _bad,
                    'wo',
                  ),
                  gap,
                  stat(
                    'po',
                    pending,
                    'הזמנות לאישור',
                    Icons.shopping_cart_outlined,
                    _warn,
                    'po',
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
                    'pm',
                  ),
                  gap,
                  stat(
                    'soon',
                    soon,
                    'בדיקות השבוע',
                    Icons.event_outlined,
                    _warn,
                    'pm',
                  ),
                ],
              ),
              gap,
              Row(
                children: [
                  stat(
                    'low',
                    db.lowStock.length,
                    'חלקים להזמין',
                    Icons.inventory_2_outlined,
                    _warn,
                    'stock',
                  ),
                  gap,
                  Expanded(
                    child: MxStatCard(
                      key: const Key('kpi-points'),
                      value: db.points.length,
                      label: 'נקודות במעקב',
                      icon: Icons.apartment_outlined,
                      color: _brand,
                      onTap: () => onGo('sites'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _section('דחוף עכשיו'),
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
              trailing: _Tag(
                d == MxDue.overdue ? 'באיחור' : 'השבוע',
                d == MxDue.overdue ? _bad : _warn,
              ),
              onTap: () => onGo('pm'),
            ),
          for (final w in db.openWorkOrders)
            ListTile(
              minVerticalPadding: 12,
              leading: Icon(mxPointIcon(db.point(w.pointId).type), color: _bad),
              title: Text(
                w.desc,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(db.pointPath(w.pointId)),
              trailing: _Tag(_woStatus(w.status), _woColor(w.status)),
              onTap: () => _open(context, _WorkOrderPage(w.id)),
            ),
          if (db.openWorkOrders.isEmpty && overdue + soon == 0)
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: _ok),
              title: Text('אין משימות דחופות'),
            ),
        ]),
      ],
    );
  }
}

void _open(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

Scaffold _page(String title, Widget body) => Scaffold(
  appBar: AppBar(
    title: Text(title),
    backgroundColor: _brand,
    foregroundColor: Colors.white,
  ),
  body: body,
);

// ── sites → unit → room → point ──────────────────────────────────────────────

class _SitesPage extends ConsumerWidget {
  const _SitesPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    return ListView(
      children: [
        _section('מסגרות'),
        _listCard([
          for (final s in db.sites)
            ListTile(
              leading: const Icon(Icons.apartment_outlined),
              title: Text('${s.city} – ${s.name}'),
              subtitle: Text('${db.unitsOf(s.id).length} דירות'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _open(context, _SitePage(s.id)),
            ),
        ]),
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
        padding: const EdgeInsets.only(top: 12),
        children: [
          _listCard([
            for (final u in db.unitsOf(siteId))
              ListTile(
                leading: const Icon(Icons.door_front_door_outlined),
                title: Text(u.name),
                subtitle: Text(
                  '${db.roomsOf(u.id).length} חדרים · ${db.pointCountOfUnit(u.id)} נקודות',
                ),
                trailing:
                    db.faultyCountOfUnit(u.id) > 0
                        ? _Tag('${db.faultyCountOfUnit(u.id)} תקולות', _bad)
                        : const _Tag('תקין', _ok),
                onTap: () => _open(context, _UnitPage(u.id)),
              ),
          ]),
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
        padding: const EdgeInsets.only(top: 12),
        children: [
          _listCard([
            for (final r in db.roomsOf(unitId))
              Builder(
                builder: (context) {
                  final pts = db.pointsOf(r.id);
                  final bad =
                      pts.where((p) => p.status == MxPointStatus.faulty).length;
                  return ListTile(
                    leading: Icon(mxRoomIcon(r.name), color: _brand),
                    title: Text(r.name),
                    subtitle: Text('${pts.length} נקודות'),
                    trailing:
                        bad > 0
                            ? _Tag('$bad תקולות', _bad)
                            : const Icon(Icons.chevron_left),
                    onTap: () => _open(context, _RoomPage(r.id)),
                  );
                },
              ),
          ]),
        ],
      ),
    );
  }
}

class _RoomPage extends ConsumerWidget {
  const _RoomPage(this.roomId);
  final String roomId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final r = db.room(roomId);
    final u = db.unit(r.unitId);
    return _page(
      '${u.name} · ${r.name}',
      ListView(
        padding: const EdgeInsets.only(top: 12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code_2, size: 40),
              title: Text(r.name),
              subtitle: const Text(
                'מדבקת QR על דלת החדר – סריקה פותחת את המסך הזה',
              ),
            ),
          ),
          _listCard([
            for (final p in db.pointsOf(roomId))
              ListTile(
                key: Key('pt-${p.id}'),
                leading: Icon(
                  mxPointIcon(p.type),
                  color: p.status == MxPointStatus.faulty ? _bad : _brand,
                ),
                title: Text(p.label),
                subtitle: Text(p.spec),
                trailing:
                    p.status == MxPointStatus.faulty
                        ? const _Tag('תקול', _bad)
                        : const _Tag('תקין', _ok),
                onTap: () => _open(context, _PointPage(p.id)),
              ),
          ]),
        ],
      ),
    );
  }
}

class _PointPage extends ConsumerWidget {
  const _PointPage(this.pointId);
  final String pointId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final p = db.point(pointId);
    final part = db.part(p.sku);
    final role = ref.watch(mxRoleProvider);
    Widget row(String k, Widget v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(child: v),
        ],
      ),
    );
    return _page(
      p.label,
      ListView(
        padding: const EdgeInsets.only(top: 12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  row('מיקום', Text(db.pointPath(pointId))),
                  row('מפרט', Text(p.spec)),
                  row('חלק החלפה', Text('${part.name} (${part.sku})')),
                  row(
                    'במלאי',
                    Row(
                      children: [
                        Text('${db.qty(p.sku)} יח׳  '),
                        if (db.qty(p.sku) < part.min)
                          const _Tag('מתחת למינימום', _warn),
                      ],
                    ),
                  ),
                  row('תחזוקה', Text(p.pm.isEmpty ? '—' : p.pm)),
                  row(
                    'מצב',
                    p.status == MxPointStatus.faulty
                        ? const _Tag('תקול', _bad)
                        : const _Tag('תקין', _ok),
                  ),
                ],
              ),
            ),
          ),
          _section('היסטוריה'),
          _listCard([
            if (p.history.isEmpty) const ListTile(title: Text('אין אירועים')),
            for (final e in p.history)
              ListTile(
                title: Text(e.text),
                subtitle: Text(
                  '${_date(e.at)} · ${e.by}${e.costAgorot > 0 ? ' · ${mxShekels(e.costAgorot)}' : ''}',
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              key: const Key('report-point'),
              style: FilledButton.styleFrom(
                backgroundColor: _bad,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('דווח תקלה בנקודה הזו'),
              onPressed: () async {
                final text = await _askText(
                  context,
                  'מה קרה?',
                  'לדוגמה: השקע מעלה ניצוצות',
                );
                if (text == null || !context.mounted) return;
                final n = ref.read(mxDbProvider.notifier);
                final by =
                    role == MxRole.staff
                        ? kMxStaffLabel
                        : role == MxRole.tech
                        ? kMxTechName
                        : 'מנהל אחזקה';
                final err = n.report(pointId, text, by);
                _toast(context, err, 'נפתחה קריאה ${n.lastCreatedId}');
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> _askText(
  BuildContext context,
  String title,
  String hint, {
  String initial = '',
}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text(title),
          content: TextField(
            key: const Key('ask-text'),
            controller: c,
            autofocus: true,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ביטול'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text('אישור'),
            ),
          ],
        ),
  );
}

// ── work orders ──────────────────────────────────────────────────────────────

class _WorkOrdersPage extends ConsumerWidget {
  const _WorkOrdersPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final list = switch (role) {
      MxRole.staff =>
        db.workOrders.where((w) => w.reportedBy == kMxStaffLabel).toList(),
      MxRole.tech =>
        db.workOrders
            .where(
              (w) => w.assignee == kMxTechName || w.status == MxWoStatus.open,
            )
            .toList(),
      _ => db.workOrders,
    };
    return ListView(
      children: [
        _section(
          role == MxRole.tech
              ? 'המשימות שלי'
              : role == MxRole.staff
              ? 'הדיווחים שלי'
              : 'קריאות שירות',
        ),
        _listCard([
          if (list.isEmpty) const ListTile(title: Text('אין קריאות')),
          for (final w in list)
            ListTile(
              key: Key('wo-${w.id}'),
              leading: Icon(
                mxPointIcon(db.point(w.pointId).type),
                color: _woColor(w.status),
              ),
              title: Text('${w.id} · ${w.desc}'),
              subtitle: Text(db.pointPath(w.pointId)),
              trailing: _Tag(_woStatus(w.status), _woColor(w.status)),
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
    final canWork =
        role == MxRole.tech &&
        (w.status == MxWoStatus.open || w.status == MxWoStatus.assigned);
    Widget info(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
    return _page(
      'קריאה ${w.id}',
      ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
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
                        backgroundColor: _bad.withValues(alpha: 0.1),
                        child: Icon(mxPointIcon(p.type), color: _bad, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          w.desc,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      _Tag(_woStatus(w.status), _woColor(w.status)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  info(Icons.place_outlined, db.pointPath(w.pointId)),
                  info(
                    Icons.person_outline,
                    'דווח: ${w.reportedBy} · ${_date(w.createdAt)}',
                  ),
                  if (w.assignee.isNotEmpty)
                    info(Icons.engineering_outlined, 'טכנאי: ${w.assignee}'),
                  info(
                    Icons.inventory_2_outlined,
                    'חלק: ${part.name} · במלאי $inStock',
                  ),
                  if (w.poId.isNotEmpty)
                    info(
                      Icons.local_shipping_outlined,
                      'הזמנה ${w.poId}: ${_poStatus(db.po(w.poId).status)}',
                    ),
                  if (w.hasPhoto)
                    info(Icons.photo_camera_outlined, 'צורפה תמונה מהדירה'),
                ],
              ),
            ),
          ),
          MxTimeline(_steps(w)),
          const SizedBox(height: 8),
          if (role == MxRole.manager && w.status == MxWoStatus.open) ...[
            MxPrimaryButton(
              key: const Key('wo-assign'),
              label: 'שייך ליוסי – טכנאי',
              icon: Icons.engineering_outlined,
              color: kMxPrimary,
              onPressed:
                  () => _toast(
                    context,
                    n.assign(woId, kMxTechName),
                    'שויך ל$kMxTechName · נשלחה לו התראה',
                  ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                'טיפ להדגמה: עברו ל"טכנאי" למעלה כדי לראות את הצד שלו',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
          if (canWork) ...[
            MxPrimaryButton(
              key: const Key('wo-fix'),
              label: inStock < 1 ? 'החלק חסר במלאי' : 'תוקן · השתמשתי בחלק אחד',
              icon: Icons.check_circle_outline,
              color: _ok,
              onPressed:
                  inStock < 1
                      ? null
                      : () => _toast(
                        context,
                        n.closeWithPart(woId, kMxTechName),
                        'כל הכבוד! הקריאה נסגרה · ירד 1 מהמלאי · נרשם בהיסטוריה',
                      ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        key: const Key('wo-fix-nopart'),
                        onPressed:
                            () => _toast(
                              context,
                              n.closeNoPart(woId, kMxTechName),
                              'נסגר ללא חלק',
                            ),
                        child: const Text('תוקן ללא חלק'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        key: const Key('wo-need'),
                        onPressed: () {
                          final err = n.requestPart(woId, 4, kMxTechName);
                          _toast(
                            context,
                            err,
                            'נשלחה בקשה ${n.lastCreatedId} לאישור המנהל',
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
          if (w.status == MxWoStatus.done)
            const Padding(
              padding: EdgeInsets.all(16),
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
        ],
      ),
    );
  }
}

// ── staff report ─────────────────────────────────────────────────────────────

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
  bool _photo = false;
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

  void _send() {
    final n = ref.read(mxDbProvider.notifier);
    final desc = [
      _reason,
      _text.text.trim(),
    ].where((s) => s.isNotEmpty).join(' – ');
    final err = n.report(_point!, desc, kMxStaffLabel, photo: _photo);
    if (err != null) {
      _toast(context, err, '');
      return;
    }
    final id = n.lastCreatedId;
    setState(() {
      _room = null;
      _point = null;
      _reason = '';
      _photo = false;
      _text.clear();
    });
    mxShowSuccess(
      context,
      title: 'הדיווח נשלח',
      body:
          'מנהל האחזקה קיבל את הדיווח $id ויטפל בו.\nאפשר לעקוב אחריו ב"הדיווחים שלי".',
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
    return ListView(
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
                  icon: const Icon(Icons.arrow_back),
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
              color: kMxCta,
              backgroundColor: kMxLine,
            ),
          ),
        ),
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
                  caption: p.loc,
                  alert: p.status == MxPointStatus.faulty,
                  onTap: () => setState(() => _point = p.id),
                ),
            ],
          ),
        if (_step == 3) ..._details(db),
      ],
    );
  }

  List<Widget> _details(MxDb db) {
    final p = db.point(_point!);
    return [
      Card(
        child: ListTile(
          minVerticalPadding: 14,
          leading: CircleAvatar(
            backgroundColor: kMxPrimary.withValues(alpha: 0.1),
            child: Icon(mxPointIcon(p.type), color: kMxPrimary),
          ),
          title: Text(
            p.label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          subtitle: Text(db.room(p.roomId).name),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (i, r) in mxQuickReasons(p.type).indexed)
              ChoiceChip(
                key: Key('rep-reason-$i'),
                label: Text(r, style: const TextStyle(fontSize: 15)),
                selected: _reason == r,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                selectedColor: kMxCta.withValues(alpha: 0.12),
                side: BorderSide(
                  color: _reason == r ? kMxCta : kMxLine,
                  width: _reason == r ? 2 : 1,
                ),
                shape: const StadiumBorder(),
                onSelected:
                    (_) => setState(() => _reason = _reason == r ? '' : r),
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
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
              _photo ? Icons.check_circle : Icons.photo_camera_outlined,
              color: _photo ? _ok : null,
            ),
            label: Text(_photo ? 'התמונה צורפה' : 'צלמו תמונה (עוזר לטכנאי)'),
            onPressed: () => setState(() => _photo = true),
          ),
        ),
      ),
      MxPrimaryButton(
        key: const Key('rep-send'),
        label: 'שלח דיווח',
        icon: Icons.send_rounded,
        onPressed: _reason.isEmpty && _text.text.trim().isEmpty ? null : _send,
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
    return ListView(
      children: [
        _section('תחזוקה מונעת ובדיקות חובה'),
        _listCard([
          for (final (r, d) in db.pmDue(now))
            ListTile(
              key: Key('pm-${r.id}'),
              title: Text(r.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${r.scope} · יעד ${_date(r.nextDue)}'),
                  if (r.isLegal)
                    Text(
                      '⚖ ${r.legalBasis}',
                      style: const TextStyle(
                        color: _bad,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              isThreeLine: r.isLegal,
              trailing:
                  d == MxDue.ok
                      ? const _Tag('בזמן', _ok)
                      : FilledButton.tonal(
                        key: Key('pm-done-${r.id}'),
                        onPressed:
                            () => _toast(
                              context,
                              ref.read(mxDbProvider.notifier).completePm(r.id),
                              'נרשם כבוצע · המועד הבא נקבע אוטומטית',
                            ),
                        child: Text(
                          d == MxDue.overdue ? 'באיחור · בוצע' : 'בוצע',
                        ),
                      ),
            ),
        ]),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'המערכת מחשבת את המועד הבא לפי התדירות של כל בדיקה. בדיקות עם ⚖ מחויבות בחוק או בתקן.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}

// ── stock ────────────────────────────────────────────────────────────────────

class _StockPage extends ConsumerWidget {
  const _StockPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final byType = <String, List<MxPart>>{};
    for (final p in db.parts) {
      (byType[p.storeType] ??= []).add(p);
    }
    return ListView(
      children: [
        _section('מלאי חלקי חילוף'),
        if (role == MxRole.manager) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: FilledButton.icon(
              key: const Key('auto-reorder'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(
                'צור הזמנות לכל מה שמתחת למינימום (${db.lowStock.length})',
              ),
              onPressed: () {
                final err = ref.read(mxDbProvider.notifier).autoReorder();
                _toast(
                  context,
                  err,
                  'נוצרו בקשות הזמנה – אחת לכל חנות. ממתינות לאישורך בלשונית הזמנות',
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: OutlinedButton.icon(
              key: const Key('import-prices'),
              icon: const Icon(Icons.upload_file),
              label: const Text('ייבוא מחירון מהחנות (CSV / אקסל)'),
              onPressed: () => _importPrices(context, ref),
            ),
          ),
        ],
        for (final e in byType.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(e.key, style: const TextStyle(color: Colors.black54)),
          ),
          _listCard([
            for (final p in e.value)
              ListTile(
                dense: true,
                title: Text(p.name),
                subtitle: Text(
                  '${p.sku} · מינימום ${p.min} · ${mxShekels(db.priceAt(kMxStoreId, p.sku))}'
                  '${db.onOrder(p.sku) > 0 ? ' · בהזמנה ${db.onOrder(p.sku)}' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${db.qty(p.sku)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (db.qty(p.sku) < p.min)
                      const _Tag('להזמין', _warn)
                    else
                      const _Tag('תקין', _ok),
                  ],
                ),
              ),
          ]),
        ],
      ],
    );
  }

  Future<void> _importPrices(BuildContext context, WidgetRef ref) async {
    const sample =
        'מק"ט,שם,מחיר\nEL-T8,פלורסנט LED T8,19.90\nEL-SK16,מנגנון שקע 16A,16.50\nHW-WSTOP,מעצור חלון,29\n';
    final csv = await _askText(
      context,
      'הדביקו את המחירון (עמודות: מק"ט, שם, מחיר)',
      'מק"ט,שם,מחיר',
      initial: sample,
    );
    if (csv == null || !context.mounted) return;
    final (err, imp) = ref
        .read(mxDbProvider.notifier)
        .importPrices(kMxStoreId, csv);
    final extra =
        imp == null || imp.errors.isEmpty
            ? ''
            : ' · ${imp.errors.length} שורות לא נקלטו';
    _toast(
      context,
      err,
      'נקלטו ${imp?.matched.length ?? 0} מחירים לטמבור$extra',
    );
  }
}

// ── purchase orders (manager / tech) ─────────────────────────────────────────

class _OrdersPage extends ConsumerWidget {
  const _OrdersPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final n = ref.read(mxDbProvider.notifier);
    // Rebuild when the store moves its order on the BuildSmart dashboard.
    ref.watch(ordersEngineProvider);
    if (db.purchaseOrders.isEmpty) {
      return ListView(
        children: [
          _section('הזמנות לחנויות'),
          const Card(
            child: ListTile(
              title: Text('אין הזמנות עדיין. אפשר ליצור מלשונית מלאי.'),
            ),
          ),
        ],
      );
    }
    return ListView(
      children: [
        _section(role == MxRole.tech ? 'בקשות הזמנה' : 'הזמנות לחנויות'),
        for (final o in db.purchaseOrders)
          Card(
            key: Key('po-${o.id}'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${o.id} · ${db.store(o.storeId).name}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _Tag(_poStatus(o.status), _poColor(o.status)),
                    ],
                  ),
                  Text(
                    'ביקש: ${o.requestedBy} · ${mxShekels(o.totalAgorot)} לפני מע"מ',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  for (final l in o.lines)
                    Text(
                      '${l.missing ? '✖ ' : '• '}${l.qty} × ${db.part(l.sku).name}${l.missing ? ' (חסר בחנות)' : ''}',
                      style: TextStyle(color: l.missing ? _bad : null),
                    ),
                  if (o.orderId.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'לוח החנות ב-BuildSmart: ${o.orderId} · '
                        '${mxStageLabel(n.storeStageOf(o) ?? 'new')}',
                        key: Key('po-bs-${o.id}'),
                        style: const TextStyle(
                          color: _brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (o.matReqId.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'ממתין בתור הבקשות של BuildSmart',
                        style: TextStyle(color: _brand),
                      ),
                    ),
                  if (o.invoiceNo.isNotEmpty)
                    Text(
                      'חשבונית ${o.invoiceNo}${o.allocationNo.isEmpty ? '' : ' · הקצאה ${o.allocationNo}'}',
                    ),
                  const SizedBox(height: 8),
                  if (role == MxRole.manager)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _poActions(context, ref, n, db, o),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _poActions(
    BuildContext context,
    WidgetRef ref,
    MxNotifier n,
    MxDb db,
    MxPurchaseOrder o,
  ) {
    return [
      if (o.status == MxPoStatus.pendingApproval) ...[
        FilledButton(
          key: Key('po-approve-${o.id}'),
          style: FilledButton.styleFrom(backgroundColor: _ok),
          onPressed:
              () => _toast(
                context,
                n.approve(o.id),
                'אושר · אפשר לשלוח לחנות בוואטסאפ',
              ),
          child: const Text('✔ אשר'),
        ),
        OutlinedButton(
          onPressed: () => _toast(context, n.reject(o.id), 'ההזמנה נדחתה'),
          child: const Text('דחה'),
        ),
      ],
      if (o.token.isNotEmpty && o.isOpen) ...[
        FilledButton.icon(
          key: Key('po-wa-${o.id}'),
          icon: const Icon(Icons.chat_outlined),
          label: const Text('שלח בוואטסאפ'),
          onPressed: () async {
            try {
              final uri = mxWhatsAppUri(
                db,
                o,
                baseUrl: kMxStoreBaseUrl,
                orgName: kMxOrgName,
              );
              final ok = await ref.read(urlLauncherProvider)(uri);
              if (context.mounted) {
                _toast(
                  context,
                  ok ? null : 'לא ניתן לפתוח וואטסאפ',
                  'נפתח וואטסאפ עם ההזמנה',
                );
              }
            } on MxError catch (e) {
              if (context.mounted) _toast(context, e.message, '');
            }
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.link),
          label: const Text('העתק קישור לחנות'),
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: mxStoreLink(kMxStoreBaseUrl, o.token)),
            );
            if (context.mounted) _toast(context, null, 'הקישור הועתק');
          },
        ),
        OutlinedButton.icon(
          key: Key('po-storeview-${o.id}'),
          icon: const Icon(Icons.storefront_outlined),
          label: const Text('מה החנות רואה'),
          onPressed: () => _open(context, MxStorePage(token: o.token)),
        ),
      ],
      if (o.status == MxPoStatus.storePartial)
        OutlinedButton(
          key: Key('po-reroute-${o.id}'),
          onPressed:
              () => _toast(
                context,
                n.reroute(o.id),
                'החוסרים נשלחו לאישור מול חנות חלופית',
              ),
          child: const Text('שלח חוסרים לחנות אחרת'),
        ),
      if (o.status == MxPoStatus.ready ||
          o.status == MxPoStatus.storeConfirmed ||
          o.status == MxPoStatus.storePartial ||
          o.status == MxPoStatus.sent)
        FilledButton.tonal(
          key: Key('po-receive-${o.id}'),
          onPressed:
              () => _toast(
                context,
                n.receive(o.id),
                'התקבל · המלאי עודכן · קריאות שחיכו חזרו לטכנאי',
              ),
          child: const Text('קיבלתי את הסחורה'),
        ),
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
            .toList();
    return ListView(
      children: [
        _section(db.store(kMxStoreId).name),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'כך בעל החנות רואה את ההזמנות – באפליקציה, או דרך הקישור שקיבל בוואטסאפ.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
        _listCard([
          if (mine.isEmpty)
            const ListTile(
              title: Text('אין הזמנות פתוחות. מנהל צריך לאשר הזמנה קודם.'),
            ),
          for (final o in mine)
            ListTile(
              key: Key('inbox-${o.id}'),
              title: Text(
                '${o.id} · ${o.lines.length} פריטים · ${mxShekels(o.totalAgorot)}',
              ),
              subtitle: Text(_date(o.createdAt)),
              trailing: _Tag(_poStatus(o.status), _poColor(o.status)),
              onTap: () => _open(context, MxStorePage(token: o.token)),
            ),
        ]),
      ],
    );
  }
}

/// The page a store owner reaches from the WhatsApp link `/s/<token>` —
/// no login; the token is the only key. Also used from the store dashboard.
class MxStorePage extends ConsumerStatefulWidget {
  const MxStorePage({required this.token, super.key});
  final String token;
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

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final n = ref.read(mxDbProvider.notifier);
    final o = db.poByToken(widget.token);
    if (o == null) {
      return _page('הזמנה', const Center(child: Text('הקישור לא תקף')));
    }
    final closed = !o.isOpen;
    final needsAlloc = mxNeedsAllocation(o);
    return _page(
      'הזמנה ${o.id}',
      ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'מ$kMxOrgName',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              _Tag(_poStatus(o.status), _poColor(o.status)),
            ],
          ),
          const SizedBox(height: 8),
          _listCard([
            for (final l in o.lines)
              ListTile(
                key: Key('store-line-${l.sku}'),
                title: Text(
                  '${l.qty} × ${db.part(l.sku).name}',
                  style: TextStyle(
                    decoration: l.missing ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('${mxShekels(l.unitAgorot)} ליח׳'),
                trailing:
                    l.missing
                        ? const _Tag('חסר', _bad)
                        : closed
                        ? null
                        : TextButton(
                          key: Key('store-missing-${l.sku}'),
                          onPressed:
                              () => _toast(
                                context,
                                n.storeMissing(widget.token, l.sku),
                                'סומן כחסר',
                              ),
                          child: const Text('אין לי'),
                        ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              'סה"כ ${mxShekels(o.totalAgorot)} לפני מע"מ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (!closed) ...[
            if (o.status == MxPoStatus.sent)
              FilledButton(
                key: const Key('store-confirm'),
                style: FilledButton.styleFrom(
                  backgroundColor: _ok,
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed:
                    () => _toast(
                      context,
                      n.storeConfirm(widget.token),
                      'אישרת את ההזמנה',
                    ),
                child: const Text('✔ מאשר – יש לי הכול'),
              ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('store-invoice'),
              controller: _invoice,
              decoration: const InputDecoration(
                labelText: 'מספר חשבונית (לא חובה)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('store-alloc'),
              controller: _alloc,
              decoration: InputDecoration(
                labelText:
                    needsAlloc
                        ? 'מספר הקצאה (חובה – מעל 5,000 ₪)'
                        : 'מספר הקצאה (אם יש)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('store-ready'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed:
                  () => _toast(
                    context,
                    n.storeReady(
                      widget.token,
                      invoiceNo: _invoice.text,
                      allocationNo: _alloc.text,
                    ),
                    'סומן מוכן לאיסוף – המנהל קיבל עדכון',
                  ),
              child: const Text('מוכן לאיסוף / נשלח'),
            ),
          ] else
            const Text('ההזמנה סגורה. תודה!'),
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
